#requires -RunAsAdministrator
#requires -Modules AzureRM

<#
.Description
This script will create a Key Vault with a Key Encryption Key for VM DIsk Encryption and Azure AD Application Service Principal inside a specified Azure subscription

.Example
$BaseSourceControl = 'C:\Users\davoodharun\Desktop\azure-blueprint'
. "$BaseSourceControl\predeploy\Orchestration_InitialSetup.ps1" @MyParams -verbose

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

$azureUserName = Read-Host "Enter your Azure username"
$azurePassword = Read-Host -assecurestring "Enter your Azure password"

try {
	$AzureAuthCreds = New-Object System.Management.Automation.PSCredential -ArgumentList @($azureUserName,$azurePassword)
	$azureEnv = Get-AzureRmEnvironment -Name $EnvironmentName
  Login-AzureRmAccount -EnvironmentName "AzureUSGovernment" -Credential $AzureAuthCreds
} catch {
	Throw "Your credentials are incorrect or invalid. Make sure you are using your Azure Government account information"
}
$adminUsername = Read-Host "Enter an admin username"

$passwordNames = @("adminPassword","sqlServerServiceAccountPassword")
$passwords = New-Object -TypeName PSObject

function checkPasswords
{
	Param(
		[Parameter(Mandatory=$true)]
		[string]$name
	)

	$password = Read-Host -assecurestring "Enter $($name)"
  $Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($password)
  $pw2test = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
  [System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)

	$passLength = 14

	if ($pw2test.Length -ge $passLength) {
		$isGood = 1
    If ($pw2test -match " "){
      "Password does not meet complexity requirements. Password cannot contain spaces"
      checkPasswords -name $name
    } Else {
      $isGood++
    }
		If ($pw2test -match "[^a-zA-Z0-9]"){
			$isGood++
    } Else {
        "Password does not meet complexity requirements. Password must contain a special character"
        checkPasswords -name $name
    }
		If ($pw2test -match "[0-9]") {
			$isGood++
    } Else {
        "Password does not meet complexity requirements. Password must contain a numerical character"
        checkPasswords -name $name
    }
		If ($pw2test -cmatch "[a-z]") {
			$isGood++
    } Else {
      "Password must contain a lowercase letter"
        "Password does not meet complexity requirements"
        checkPasswords -name $name
    }
		If ($pw2test -cmatch "[A-Z]"){
			$isGood++
    } Else {
      "Password must contain an uppercase character"
        "Password does not meet complexity requirements"
        checkPasswords -name $name
    }
		If ($isGood -ge 4) {
      $passwords | Add-Member -MemberType NoteProperty -Name $name -Value $password
      return
    } Else {
      "Password does not meet complexity requirements"
      checkPasswords -name $name
    }
  } Else {

    "Password is not long enough - Passwords must be at least " + $passLength + " characters long"
    checkPasswords -name $name

  }

}

function orchestration
{
	Param(
		[string]$environmentName = "AzureUSGovernment",
		[string]$location = "USGov Virginia",
		[string]$recoveryServicesAADServicePrincipalName = "ff281ffe-705c-4f53-9f37-a40e6f2c68f3",
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
			$guid = new-guid
			Write-Host "Please note that you will need to provide the keyVaultId and keyVaultResourceGroupName when deploying your template" -foregroundcolor Green;
			Write-Host "You will also need a new GUID to use for deployment: $($guid)" -foregroundcolor Green;
}


for($i=0;$i -lt $passwordNames.Length;$i++){
   checkPasswords -name $passwordNames[$i]
}


orchestration -azureUsername $azureUsername -adminUsername $adminUsername -azurePassword $azurePassword -adminPassword $passwords.adminPassword -sqlServerServiceAccountPassword $passwords.sqlServerServiceAccountPassword
