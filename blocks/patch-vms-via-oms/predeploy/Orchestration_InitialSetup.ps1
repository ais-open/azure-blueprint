#requires -RunAsAdministrator
#requires -Modules AzureRM

<#
.Description
Script needs to be run with elevated priveleges, as it interacts with the local file system (for generation of a certificate)
Executes the initial setup script, creating a dedicated resource group, storage account, and azure automation account.
Optionally uploads arm templtes and ps runbooks to created storage account (if path specified)
Optionally publishes all ps runbooks in specified directory to azure automation account created by the process.

.Example
$BaseSourceControl = 'C:\Users\davoodharun\Desktop'
$MyParams = @{
	environmentName = "AzureUSGovernment"
	location = "USGov Virginia"
	subscriptionId = "eee71d43-1ba6-4da6-a6c4-ab75f599c1dc"
	resourceGroupName = "OrchestrationRG"
	StorageAccountName = "orchestrationstorage"
	armtemplatesLocalDir = "$BaseSourceControl\OD4Gov\Templates"
	psrunbooksLocalDir = "$BaseSourceControl\OD4Gov\Scripts\orchestration\automationrunbooks"
	scriptsLocalDir = "$BaseSourceControl\OD4Gov\Scripts\DSC"
	automationAccountName = "OrchestrationAutomationUser"
	keyVaultName = "OrchestrationKeyVault"
	serverPrincipalCertPassword = New-QMAlphanumericSecurePassword
    aadAppName = "aadKeyVaultApp"
    keyEncryptionKeyName = "KeyVaultEncryptionKeyName"
}
. "$BaseSourceControl\OD4Gov\Scripts\orchestration\Orchestration_InitialSetup.ps1" @MyParams -verbose


#>
[cmdletbinding()]
Param(
  [string]$environmentName = "AzureUSGovernment",
  [string]$location = "USGov Virginia",
  [Parameter(Mandatory=$true)]
  [string]$subscriptionId,
  [Parameter(Mandatory=$true)]
  [string]$azureUserName,
  [Parameter(Mandatory=$true)]
  [SecureString]$azurePassword,
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

    Write-Host "Set Azure Key Vault Access Policy. Set AzureUserName in Key Vault: $keyVaultName";
    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'azureUserName' -Destination 'Software'
    $azureUserNameSecureString = ConvertTo-SecureString $azureUserName -AsPlainText -Force
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'azureUserName' -SecretValue $azureUserNameSecureString

    Write-Host "Set Azure Key Vault Access Policy. Set AzurePassword in Key Vault: $keyVaultName";
    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'azurePassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'azurePassword' -SecretValue $azurePassword

    Write-Host "Set Azure Key Vault Access Policy. Set AdminPassword in Key Vault: $keyVaultName";
    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'adminPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'adminPassword' -SecretValue $adminPassword

    Write-Host "Set Azure Key Vault Access Policy. Set SqlServerServiceAccountPassword in Key Vault: $keyVaultName";
	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -SecretValue $sqlServerServiceAccountPassword

    Write-Host "Set Azure Key Vault Access Policy. Set Application Client ID in Key Vault: $keyVaultName";
    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'aadClientID' -Destination 'Software'
    $aadClientIDSecureString = ConvertTo-SecureString $aadClientID -AsPlainText -Force
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'aadClientID' -SecretValue $aadClientIDSecureString

    Write-Host "Set Azure Key Vault Access Policy. Set Application Client Secret in Key Vault: $keyVaultName";
    $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'aadClientSecret' -Destination 'Software'
    $aadClientSecretSecureString = ConvertTo-SecureString $aadClientSecret -AsPlainText -Force
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'aadClientSecret' -SecretValue $aadClientSecretSecureString

    Write-Host "Set Azure Key Vault Access Policy. Set Key Encryption URL in Key Vault: $keyVaultName";
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

