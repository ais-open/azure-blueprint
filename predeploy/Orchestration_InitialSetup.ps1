#requires -RunAsAdministrator
#requires -Modules AzureRM

<#
.Description
This script will create a Key Vault inside a specified Azure subscription

.Example
$BaseSourceControl = 'C:\Users\davoodharun\Desktop'
. "$BaseSourceControl\azure-blueprint\predeploy\Orchestration_InitialSetup.ps1" @MyParams -verbose
#>

[cmdletbinding()]
Param(
  [string]$environmentName = "AzureUSGovernment",
  [string]$location = "USGov Virginia",
  [Parameter(Mandatory=$true)]
  [string]$subscriptionId,
  [Parameter(Mandatory=$true)]
  [string]$resourceGroupName,
	[Parameter(Mandatory=$true)]
  [string]$keyVaultName,
	[Parameter(Mandatory=$true)]
  [SecureString]$adminPassword,
	[Parameter(Mandatory=$true)]
  [SecureString]$sqlServerServiceAccountPassword
)

try {
	$Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($adminPassword)
	$result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
	[System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
	. "$BaseSourceControl\checkPassword.ps1" -password $result
}
catch {
	Throw "Administrator password did not meet the complexity requirements"
}

try {
	$Ptr = [System.Runtime.InteropServices.Marshal]::SecureStringToCoTaskMemUnicode($sqlServerServiceAccountPassword)
	$result = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($Ptr)
	[System.Runtime.InteropServices.Marshal]::ZeroFreeCoTaskMemUnicode($Ptr)
	. "$BaseSourceControl\checkPassword.ps1" -password $result
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

Write-Host "Creating resource group '$($resourceGroupName)' to hold key vault."

if (-not (Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction SilentlyContinue)) {
	New-AzureRmResourceGroup -Name $resourceGroupName -Location $location  | Out-String | Write-Verbose
}

Write-Host "Create a keyVault '$($keyVaultName)'"
if (-not (Get-AzureRMKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue )) {
	New-AzureRMKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -EnabledForTemplateDeployment -Location $location | Out-String | Write-Verbose
	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'adminPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'adminPassword' -SecretValue $adminPassword

	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -SecretValue $sqlServerServiceAccountPassword
}
