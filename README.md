# azure-blueprint

[![Deploy to Azure](http://azuredeploy.net/deploybutton.svg)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAppliedIS%2Fazure-blueprint%2Fmaster%2Fazuredeploy.json)

![alt text](docs/n-tier-diagram.png?raw=true "Azure Blueprint FedRAMP three-tier web-based application compliance architecture")

## instructions
1. Clone repo to local environment
2. Start PowerShell session as Administrator
3. Run ```Import-Module AzureRM ````
4. Set $BaseSourceControl equal to the path of the location of the repo you just cloned (do not include the actual repo folder).
5. Run /predeploy/Orchestration_InitialSetup.ps1 to create a new Resource Group with a new Key Vault that will contain the administrator passwords that you enter.
```
# Example
$BaseSourceControl = 'C:\Users\USERNAME\Desktop\azure-blueprint'
. "$BaseSourceControl\predeploy\Orchestration_InitialSetup.ps1"
```
6. After the script has completed, click the Deploy to Azure button above, login into Azure Gov, and complete the form to begin the deployment process.
