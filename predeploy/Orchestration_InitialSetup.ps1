#requires -RunAsAdministrator
#requires -Modules AzureRM

<#
.Description
This script will create a Key Vault with a Key Encryption Key for VM DIsk Encryption and Azure AD Application Service Principal inside a specified Azure subscription

.Example
$BaseSourceControl = 'C:\Users\davoodharun\Desktop\azure-blueprint'
. "$BaseSourceControl\predeploy\Orchestration_InitialSetup.ps1" @MyParams -verbose

.Parameter BaseSourceControl
Should be the string path to the predeploy directory in the format c:\path\to\source\control\predeploy

.Parameter recoveryServicesAADServicePrincipalName
This is the ApplicationId for the BackupFairfax (usgovvirginia) AzureAD Service Principal
Azure commercial Backup Management Service ApplicationId is 262044b1-e2ce-469f-a196-69ab7ada62d3

.Parameter adminPassword
Must meet complexity requirements
14+ characters, 2 numbers, 2 upper and lower case, and 2 special chars

.Parameter sqlServerServiceAccountPassword
Must meet complexity requirements
14+ characters, 2 numbers, 2 upper and lower case, and 2 special chars
#>

[cmdletbinding()]
Param(
	[string]$environmentName = "AzureUSGovernment",
	[string]$location = "USGov Virginia",
	[string]$recoveryServicesAADServicePrincipalName = "ff281ffe-705c-4f53-9f37-a40e6f2c68f3",
    [Parameter(Mandatory=$true)]
    [string]$BaseSourceControl,
	[Parameter(Mandatory=$true)]
	[string]$subscriptionId,
	[Parameter(Mandatory=$true)]
	[string]$resourceGroupName,
	[Parameter(Mandatory=$true)]
	[string]$keyVaultName,
	[Parameter(Mandatory=$true)]
	[string]$adminUsername,
	[Parameter(Mandatory=$true)]
	[SecureString]$adminPassword,
	[Parameter(Mandatory=$true)]
	[SecureString]$sqlServerServiceAccountPassword,
	[Parameter(Mandatory = $true)]
	[string]$aadAppName,
	[Parameter(Mandatory = $true)]
	[string]$keyEncryptionKeyName
)

try {
	$Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($adminPassword)
	$result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
	[System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
	& "$BaseSourceControl\checkPassword.ps1" -password $result
}
catch {
	Throw "Administrator password did not meet the complexity requirements"
}

try {
	$Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($sqlServerServiceAccountPassword)
	$result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
	[System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
	& "$BaseSourceControl\checkPassword.ps1" -password $result
}
catch {
	Throw "sqlServerServiceAccountPassword  did not meet the complexity requirements"
}

$errorActionPreference = 'stop'

try
{
	$Exists = Get-AzureRmSubscription  -SubscriptionId $SubscriptionId
	Write-Host "Using existing authentication"
}
catch {

}

if (-not $Exists)
{
	Write-Host "Authenticate to Azure subscription"
	Add-AzureRmAccount -EnvironmentName $EnvironmentName | Out-String | Write-Verbose
}

Write-Host "Selecting subscription as default"
Select-AzureRmSubscription -SubscriptionId $SubscriptionId | Out-String | Write-Verbose

########################################################################################################################
# Create AAD app . Fill in $aadClientSecret variable if AAD app was already created
########################################################################################################################


    # Check if AAD app with $aadAppName was already created
    $SvcPrincipals = (Get-AzureRmADServicePrincipal -SearchString $aadAppName);
    if(-not $SvcPrincipals)
    {
        # Create a new AD application if not created before
        $identifierUri = [string]::Format("http://localhost:8080/{0}",[Guid]::NewGuid().ToString("N"));
        $defaultHomePage = 'http://contoso.com';
        $now = [System.DateTime]::Now;
        $oneYearFromNow = $now.AddYears(1);
        $aadClientSecret = [Guid]::NewGuid();

        Write-Host "Creating new AAD application ($aadAppName)";
        $ADApp = New-AzureRmADApplication -DisplayName $aadAppName -HomePage $defaultHomePage -IdentifierUris $identifierUri  -StartDate $now -EndDate $oneYearFromNow -Password $aadClientSecret;
        $servicePrincipal = New-AzureRmADServicePrincipal -ApplicationId $ADApp.ApplicationId;
        $SvcPrincipals = (Get-AzureRmADServicePrincipal -SearchString $aadAppName);
        if(-not $SvcPrincipals)
        {
            # AAD app wasn't created 
            Write-Error "Failed to create AAD app $aadAppName. Please log-in to Azure using Login-AzureRmAccount  and try again";
            return;
        }
        $aadClientID = $servicePrincipal.ApplicationId;
        Write-Host "Created a new AAD Application ($aadAppName) with ID: $aadClientID ";
    }
    else
    {
        if(-not $aadClientSecret)
        {
            $aadClientSecret = Read-Host -Prompt "Aad application ($aadAppName) was already created, input corresponding aadClientSecret and hit ENTER. It can be retrieved from https://manage.windowsazure.com portal" ;
        }
        if(-not $aadClientSecret)
        {
            Write-Error "Aad application ($aadAppName) was already created. Re-run the script by supplying aadClientSecret parameter with corresponding secret from https://manage.windowsazure.com portal";
            return;
        }
        $aadClientID = $SvcPrincipals[0].ApplicationId;
    }

########################################################################################################################
# Create KeyVault or setup existing keyVault
########################################################################################################################

Write-Host "Creating resource group '$($resourceGroupName)' to hold the automation account, key vault, and template storage account."

if (-not (Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction SilentlyContinue)) {
	New-AzureRmResourceGroup -Name $resourceGroupName -Location $location  | Out-String | Write-Verbose
}

#Create a new vault if vault doesn't exist
if (-not (Get-AzureRMKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue )) {
	Write-Host "Create a keyVault '$($keyVaultName)' to store the service principal ids, key, certificate"
	New-AzureRMKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -EnabledForTemplateDeployment -Location $location | Out-String | Write-Verbose
	    Write-Host "Created a new KeyVault named $keyVaultName to store encryption keys";

	# Specify privileges to the vault for the AAD application - https://msdn.microsoft.com/en-us/library/mt603625.aspx
     Write-Host "Set Azure Key Vault Access Policy. Set ServicePrincipalName: $aadClientID in Key Vault: $keyVaultName";
    Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ServicePrincipalName $aadClientID -PermissionsToKeys wrapKey -PermissionsToSecrets set;
	Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ServicePrincipalName $recoveryServicesAADServicePrincipalName -PermissionsToKeys backup,get,list -PermissionsToSecrets get,list;
    Set-AzureRmKeyVaultAccessPolicy -VaultName $keyVaultName -EnabledForDiskEncryption;

    if($keyEncryptionKeyName)
    {
        Try
        {
            $kek = Get-AzureKeyVaultKey -VaultName $keyVaultName -Name $keyEncryptionKeyName -ErrorAction SilentlyContinue;
        }
        Catch [Microsoft.Azure.KeyVault.KeyVaultClientException]
        {
            Write-Host "Couldn't find key encryption key named : $keyEncryptionKeyName in Key Vault: $keyVaultName";
            $kek = $null;
        } 

        if(-not $kek)
        {
            Write-Host "Creating new key encryption key named:$keyEncryptionKeyName in Key Vault: $keyVaultName";
            $kek = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name $keyEncryptionKeyName -Destination Software -ErrorAction SilentlyContinue;
            Write-Host "Created  key encryption key named:$keyEncryptionKeyName in Key Vault: $keyVaultName";
        }

        $keyEncryptionKeyUrl = $kek.Key.Kid;
    } 

	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'adminPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'adminPassword' -SecretValue $adminPassword

	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -SecretValue $sqlServerServiceAccountPassword

	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'aadClientID' -Destination 'Software'
    $aadClientIDSecureString = ConvertTo-SecureString $aadClientID -AsPlainText -Force
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'aadClientID' -SecretValue $aadClientIDSecureString

    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'aadClientSecret' -Destination 'Software'
    $aadClientSecretSecureString = ConvertTo-SecureString $aadClientSecret -AsPlainText -Force
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'aadClientSecret' -SecretValue $aadClientSecretSecureString

    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'keyEncryptionKeyURL' -Destination 'Software'
    $keyEncryptionKeyUrlSecureString = ConvertTo-SecureString $keyEncryptionKeyUrl -AsPlainText -Force
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'keyEncryptionKeyURL' -SecretValue $keyEncryptionKeyUrlSecureString
}

########################################################################################################################
#  Displays values that should be used while enabling encryption. Please note these down
########################################################################################################################
    Write-Host "Please note down below aadClientID, aadClientSecret, diskEncryptionKeyVaultUrl, keyVaultResourceId values that will be needed to enable encryption on your VMs " -foregroundcolor Green;
    Write-Host "`t aadClientID: $aadClientID" -foregroundcolor Green;
    Write-Host "`t aadClientSecret: $aadClientSecret" -foregroundcolor Green;
    Write-Host "`t keyEncryptionKeyURL: $keyEncryptionKeyUrl" -foregroundcolor Green;
    Write-Host "Please Press [Enter] after saving values displayed above. They are needed to enable encryption using Set-AzureRmVmDiskEncryptionExtension cmdlet" -foregroundcolor Green;
    Read-Host;
