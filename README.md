# Azure Blueprint multi-tier web application solution for FedRAMP

This Azure Blueprint solution automatically deploys a multi-tier web application architecture with pre-configured security controls to help customers achieve compliance with FedRAMP requirements. The solution consists of Azure Resource Manager (ARM) templates and PowerShell scripts that guide resource deployment and configuration. An accompanying Blueprint compliance matrix is provided, showing security control inheritance from Azure and where deployed resources and configurations align with NIST SP 800-53 security controls, thereby enabling organizations to fast-track compliance obligations. 


![alt text](docs/n-tier-diagram.png?raw=true "Azure Blueprint FedRAMP three-tier web-based application compliance architecture")

The architecture includes the following Azure products:
* Azure Storage
* Azure Virtual Network
* Azure Application Gateway
* Azure Key Vault
* Azure Active Directory
* Log Analytics
* Azure Automation
* Operations Management Suite
* Azure Backup

## PRE-DEPLOYMENT

During pre-deployment you will confirm that your Azure subscription and local workstation are prepared to deploy the solution. The final pre-deployment step will run a PowerShell script that verifies setup requirements, gathers parameters and credentials, and creates resources in Azure to prepare for deployment.

### Azure subscription requirements

This Azure Blueprint solution is designed to deploy to Azure Government regions. The solution does not currently support Azure commercial regions. Customers must have a paid Azure Government subscription or sponsored account to deploy this solution. (The solution cannot be deployed to Azure Government Trail accounts because…)

The Azure Active Directory administrator with global privileges is required to deploy this solution.

[Are there any other steps that need to occur within the subscription to be able to deploy?]

### Local workstation requirements

PowerShell is used to initiate pre-deployment, deployment, and post-deployment tasks. PowerShell version X.X or greater must be installed on your local workstation. In PowerShell, you can use the following command to check the version:

`$PSVerstionTable.psversion`

The PowerShell pre-deployment task includes installation of Azure PowerShell modules, so PowerShell must be run in administrator mode.

### Pre-deployment script

The pre-deployment PowerShell script will verify that a supported version of PowerShell is installed, that the necessary Azure PowerShell modules are installed. Azure PowerShell modules provide cmdlets for managing Azure resources. After all setup requirements are verified, the script will prompt for parameters and credentials to use when the solution is deployed. The script will prompt for the following parameters (suggested values are provided):

[table; note: for parameters that the customer needs to look up (e.g., subscription ID), provide instructions to find]




[![Deploy to Azure](http://azuredeploy.net/deploybutton.svg)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAppliedIS%2Fazure-blueprint%2Fmaster%2Fazuredeploy.json)


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
