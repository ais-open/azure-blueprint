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
  [string]$resourceGroupName,
	[Parameter(Mandatory=$true)]
  [string]$keyVaultName,
	[Parameter(Mandatory=$true)]
  [string]$adminUsername,
	[Parameter(Mandatory=$true)]
  [SecureString]$adminPassword,
	[Parameter(Mandatory=$true)]
  [SecureString]$sqlServerServiceAccountPassword
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

Write-Host "Creating resource group '$($resourceGroupName)' to hold the automation account, key vault, and template storage account."

if (-not (Get-AzureRmResourceGroup -Name $resourceGroupName -Location $location -ErrorAction SilentlyContinue)) {
	New-AzureRmResourceGroup -Name $resourceGroupName -Location $location  | Out-String | Write-Verbose
}

Write-Host "Create a keyVault '$($keyVaultName)' to store the service principal ids, key, certificate"
if (-not (Get-AzureRMKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -ErrorAction SilentlyContinue )) {
	New-AzureRMKeyVault -VaultName $keyVaultName -ResourceGroupName $resourceGroupName -EnabledForTemplateDeployment -Location $location | Out-String | Write-Verbose
	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'adminPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'adminPassword' -SecretValue $adminPassword

	$key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -Destination 'Software'
	$secret = Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name 'sqlServerServiceAccountPassword' -SecretValue $sqlServerServiceAccountPassword
}
