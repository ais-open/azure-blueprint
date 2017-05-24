# azure-blueprint

[![Deploy to Azure](http://azuredeploy.net/deploybutton.svg)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAppliedIS%2Fazure-blueprint%2Ftesting%2Fazuredeploy.json)

![alt text](docs/n-tier-diagram.png?raw=true "Azure Blueprint FedRAMP three-tier web-based application compliance architecture")

## instructions
1. Start PowerShell session as Administrator
2. Run ```Import-Module AzureRM ````
3. Clone repo to local environment
4. Checkout origin/testing branch
5. Run \predeploy\Orchestration_InitialSetup.ps1 to create a new Resource Group with a new Key Vault that will contain the administrator passwords that you enter.
```
# Example
PS C:\Users\davoodharun\Desktop> Import-Module AzureRM
PS C:\Users\davoodharun\Desktop> git clone https://github.com/AppliedIS/azure-blueprint.git
PS C:\Users\davoodharun\Desktop> cd azure-blueprint
PS C:\Users\davoodharun\Desktop> git checkout origin/testing
PS C:\Users\davoodharun\Desktop> .\predeploy\Orchestration_InitialSetup.ps1
BaseSourceControl: C:\Users\davoodharun\Desktop\azure-blueprint\predeploy
subscriptionId: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx
resourceGroupName: <enter a new resource group name>
keyVaultName: <enter a new key vault name>
adminUsername: <enter a new username>
adminPassword: ***************
sqlServerServiceAccountPassword: ***************
aadAppName: <enter a name for a new azure AD application>
keyEncryptionKeyName: <enter a name for a new encryption key>
```
6. After the script has completed, click the Deploy to Azure button above, login into Azure Gov, and complete the form to begin the deployment process.
