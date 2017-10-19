# Azure Blueprint multi-tier web application solution for FedRAMP

This Azure Blueprint solution automatically deploys a multi-tier web application architecture with pre-configured security controls to help customers achieve compliance with FedRAMP requirements. The solution consists of Azure Resource Manager (ARM) templates and PowerShell scripts that guide resource deployment and configuration. Accompanying Azure Blueprint [compliance documentation](https://github.com/AppliedIS/azure-blueprint/wiki) is provided, indicating security control inheritance from Azure and where deployed resources and configurations align with NIST SP 800-53 security controls, thereby enabling organizations to fast-track compliance obligations. *Note: This solution deploys to Azure Government.*

#### Quickstart
1. Clone this repository to your local workstation.
2. Run the pre-deployment PowerShell script: azure-blueprint/predeploy/Orchestration_InitialSetup.ps1. [Read more about pre-deployment.](#pre-deployment)
3. Click the button below, sign into the Azure portal, enter the required ARM template parameters, and click **Purchase**. [Read more about deployment.](#deployment)

	[![Deploy to Azure](http://azuredeploy.net/AzureGov.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAppliedIS%2Fazure-blueprint%2Fmaster%2Fazuredeploy.json)

## In this document

* [Architecture](#architecture)
* [Deployment instructions](#deployment-instructions)
* [Frequently asked questions](#frequently-asked-questions)
* [Troubleshooting](#troubleshooting)

----------------------------------------------------------------

## Architecture

This solution deploys a notional architecture for a web application with a database backend. The architecture includes a web tier, data tier, Active Directory infrastructure, application gateway, and load balancer. Virtual machines deployed to the web and data tiers are configured in an availability set, and SQL Server instances are configured in an AlwaysOn availability group for high availability. Virtual machines are domain-joined, and Active Directory group policies are used to enforce security and compliance configurations at the operating system level. A management jumpbox (bastion host) provides a secure connection for administrators to access deployed resources.

![alt text](docs/n-tier-diagram.png?raw=true "Azure Blueprint FedRAMP multi-tier web application architecture")

The architecture includes the following Azure services:
* **Virtual Machines**
	- (1) Management/bastion (Windows Server 2016 Datacenter)
	- (2) Active Directory domain controller (Windows Server 2016 Datacenter)
	- (2) SQL Server cluster node (Windows Server 2012 R2 on SQL2014SP2)
	- (1) SQL Server witness (Windows Server 2016 Datacenter)
	- (2) Web/IIS (Windows Server 2016 Datacenter)
* **AvailabilitySets**
	- (1) Active Directory domain controllers
	- (1) SQL cluster nodes and witness
	- (1) Web/IIS
* **Virtual Network**
	- (1) /16 virtual networks
	- (5) /24 subnets
	- DNS settings are set to both domain controllers
* **Load Balancer**
	- (1) SQL load balancer
* **Application Gateway**
	- (1) WAF Application Gateway
	-- Enabled
	-- Firewall Mode: Prevention
	-- Rule set: OWASP 3.0
	-- Listener: Port 443
* **Storage**
    - (7) Geo-redundant storage accounts
* **Backup**
    - (1) Recovery Services vault
* **Key Vault**
	- (1) Key Vault
	  - (3) Access policies (user, AADServicePrincipal, BackupFairFax)
	  - (7) Secrets (aadClientID, aadClientSecret, adminPassword, azurePassword, azureUserName, keyEncryptionKeyURL, sqlServerServiceAccountPassword)
* **Azure Active Directory**
* **Azure Resource Manager**
* **Log Analytics**
* **Automation**
	- (1) Automation account
* **Scheduler**
* **Operations Management Suite**
	- (1) OMS workspace

---------------------------------------------------------------

## Instructions

This Azure Blueprint solution is comprised of JSON configuration files and PowerShell scripts that are handled by Azure Resource Manager's API service to deploy resources within Azure. For more information about ARM template deployment, see the following documentation:

- [Azure Resource Manager templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#template-deployment)
- [ARM template functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions)
- [ARM templates and nesting resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates)

### PRE-DEPLOYMENT

During pre-deployment, you will confirm that your Azure subscription and local workstation are prepared to deploy the solution. The final pre-deployment step will run a PowerShell script that verifies the setup requirements, gathers parameters and credentials, and creates resources in Azure to prepare for deployment.

#### Azure subscription requirements

This Azure Blueprint solution is designed to deploy to Azure Government. The solution does not currently support Azure commercial regions. For customers with a multi-tenant environment, the account used to deploy must be a member of the Azure Active Directory instance that is associated with the subscription where this solution will be deployed.

#### Local workstation requirements

PowerShell is used to initiate some pre-deployment tasks. PowerShell version 5.0 or greater must be installed on your local workstation. In PowerShell, use the following command to check the version:

`$PSVersionTable.psversion`

In order to run the pre-deployment script, you must have the current Azure PowerShell AzureRM modules installed (see [Installing AzureRM modules](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.1.0)).

#### SSL certificate
This solution deploys an Application Gateway and requires an SSL certificate. To generate a self-signed SSL certificate using PowerShell, run [this script](predeploy/generateCert.ps1). Note that self-signed certificates are not recommended for use in production environments.

#### Pre-deployment script

The pre-deployment PowerShell script will verify that the necessary Azure PowerShell modules are installed. Azure PowerShell modules provide cmdlets for managing Azure resources. After all the setup requirements are verified, the script will ask you to sign into Azure and then will prompt you for parameters and credentials to use when the solution is deployed. The script will prompt you for the following parameters, in this order:

* **Azure username**: Your Azure username (ex. someuser@contoso.onmicrosoft.com)
* **Azure password**: Password for the Azure account above
* **Admin username**: Administrator username you want to use for the administrator accounts on deployed virtual machines
* **adminPassword**: Administrator password you want to use for the administrator accounts on deployed virtual machines (must meet the complexity requirements; see below)
* **sqlServerServiceAccountPassword**: SQL service account password you want to use (must meet the complexity requirements; see below)
* **subscriptionId**: To find your Azure Government subscription ID, navigate to https://portal.azure.us and sign in. Expand the service menu, and begin typing "subscription" in the filter box. Click **Subscriptions** to open the subscriptions blade. Note the subscription ID, which has the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.
* **resourceGroupName**: Resource group name you want to use for this deployment; must be a string of 1-90 alphanumeric characters (such as 0-9, a-z, A-Z), periods, underscores, hyphens, and parenthesis, and it cannot end in a period (such as `blueprint-rg`).
* **keyVaultName**: Key Vault name you want to use for this deployment; must be a string 3-24 alphanumeric characters (such as 0-9, a-z, A-Z) and hyphens, and it must be unique across Azure Government.

Passwords must be at least 14 characters and contain one each of the following: lower case character, upper case character, number, and special character.

#### Pre-deployment instructions

1. Clone this GitHub repository to your local workstation:
`git clone https://github.com/AppliedIS/azure-blueprint.git`
2. Start PowerShell as an administrator
3. Run Orchestration_InitialSetup.ps1
4. Enter the parameters above when prompted

Note the resource group name and Key Vault name; these will be required during the deployment phase. The script will also generate a GUID for use during the deployment phase.

------------------------------------------------------------------------

### DEPLOYMENT

During this phase, an Azure Resource Manager (ARM) template will deploy Azure resources to your subscription and perform configuration activities.

After clicking the Deploy to Azure Gov button, the Azure portal will open and prompt you for the following settings:

**Basics**
* **Subscription**: Choose the same subscription used during the pre-deployment phase
* **Resource group**: Select 'Use existing' and choose the resource group created during pre-deployment
* **Location**: Select 'USGovVirginia'

**Settings**
* **Admin Username**: Administrator username you want to use for administrative accounts for deployed resources (can be the same username you entered during the pre-deployment phase)
* **Key Vault Name**: Name of the Key Vault created during pre-deployment
* **Key Vault Resource Group Name**: Name of the resource group created during pre-deployment
* **Cert Data**: 64bit-encoded certificate for SSL
* **Cert Password**: Password used to create the certificate
* **Scheduler Job GUID**: GUID for the runbook job to be started (use GUID output by pre-deployment script or run New-Guid in PowerShell)
* **OMS Workspace Name**: Name you want to use for the Log Analytic workspace; must be a string 4-63 alphanumeric characters (such as 0-9, a-z, A-Z) and hyphens, and it must be unique across Azure Government.
* **OMS Automation Account Name**: Name you want to use for the automation account used with OMS; must be a string 6-50 alphanumeric characters (such as 0-9, a-z, A-Z) and hyphens, and it must be unique across Azure Government.

#### Deployment instructions

1. Click the button below.

	[![Deploy to Azure](http://azuredeploy.net/AzureGov.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAppliedIS%2Fazure-blueprint%2Fmaster%2Fazuredeploy.json)
2. Enter the settings above.
3. Review the terms and conditions and click **I agree to the terms and conditions stated above**.
4. Click **Purchase**.

#### Monitoring deployment status
This solution uses multiple nested templates to deploy and configure the resources shown in the architecture diagram. The full deployment will take approximately **[120]** minutes. You can monitor the deployment from Azure Portal.

See [TIMELINE.md](/docs/TIMELINE.md) for a resource dependency outline.

### POST-DEPLOYMENT

#### Post-deployment instructions

1. Set Retention time - Set the data retention time in the OMS resource blade from 31 to 365 days to meet FedRAMP compliance.

#### Accessing deployed resources

You can access your machines through the MGT VM that is created from the deployment. From this VM, you can remote into and access any of the VMs in the network.

#### Cost

Deploying this solution will create resources within your Azure subscription. You will be responsible for the costs associated with these resources, so it is important that you review the applicable pricing and legal terms associated with all the resources and offerings deployed as part of this solution. For cost estimates, you can use the Azure Pricing Calculator.

#### Extending the Solution with Advanced Configuration

If you have a basic knowledge of how Azure Resource Manager (ARM) templates work, you can customize the deployment by editing  azuredeploy.json or any of the templates located in the nested templates folder. Some items you might want to edit include, but are not limited to:
- Network Security Group rules (nestedtemplates/virtualNetworkNSG.json)
- OMS alert rules and configuration (nestedtemplates/provisioningAutoAccOMSWorkspace)
- Application Gateway routing rules (nestedtemplates/provisioningApplicationGateway.json)

For more information about template deployment, read the following links:

1. [Azure Resource Manager Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#template-deployment)
2. [ARM Template Functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions)
3. [ARM Templating and Nesting Resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates)

If you do not want to specifically alter the template contents, you can edit the parameters section at the top level of the JSON object within azuredeploy.json.

#### Troubleshooting

If your deployment should fail, to avoid incurring costs and orphan resources it is advisable to delete the resource group associated with this solution in its entirety, fix the issue, and redeploy the solution. See the section below for instructions to delete all resources deployed by the solution.

Please feel free to open and submit a GitHub issue pertaining to the error you are experiencing.

#### How to delete deployed resources

To help with deleting protected resources, use postdeploy/deleteProtectedItems.ps1 -- this will specifically help you with removing the delete lock on the resources inside your vault.

## Known Issues

1. OMS Monitoring Extension fails intermittently on different machines ([See issue #95](https://github.com/AppliedIS/azure-blueprint/issues/95)).
2. SQL Always On configuration is currently broken for SQL2016-WS2012R2 ([See issue #73](https://github.com/AppliedIS/azure-blueprint/issues/73)).
3. Deployment only works successfully with a new key vault (it does not work with an existing key vault). This will force the user to run the pre-deployment script to create a new resource group and key vault before each deployment.
