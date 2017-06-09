# Azure Blueprint multi-tier web application solution for FedRAMP


This Azure Blueprint solution automatically deploys a multi-tier web application architecture with pre-configured security controls to help customers achieve compliance with FedRAMP requirements. The solution consists of Azure Resource Manager (ARM) templates and PowerShell scripts that guide resource deployment and configuration. An accompanying Blueprint compliance matrix is provided, showing security control inheritance from Azure and where deployed resources and configurations align with NIST SP 800-53 security controls, thereby enabling organizations to fast-track compliance obligations.

#### Quickstart
1. Clone repository
2. Run azure-blueprint/predeploy/Orchestration_InitialSetup.ps1
	- This script will create a resource group with a keyvault -- remember the names that you choose for these items because you will need them in the next step.
3. Click the button below

	[![Deploy to Azure](http://azuredeploy.net/deploybutton.svg)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdavoodharun%2Fazure-blueprint%2Fsqlbypass%2Fazuredeploy.json)

	\** You will need an SSL cert (.pfx) in 64bit encoded form along with its password before you can deploy to your Azure subscription

	##### READ MORE ABOUT:

	- [Solution Architecture](#architecture)
	- [Pre-deployment Steps](#pre-deployment)
		- [Pre-deployment Script Params](#pre-deployment-script)
	- [Deployment Steps and Parameters](#Deployment)
	- [Post-deployment Steps](#post-deployment)
	- [Advanced Configuration](#extending-the-solution-with-advanced-configuration)

----------------------------------------------------------------

## Architecture

This solution deploys a notional architecture for a web application with a database backend. The architecture includes a web tier, data tier, Active Directory infrastructure, application gateway and load balancer. Virtual machines deployed to the web and data tiers are configured in an availability set and SQL Servers are configured in an Always On availability group for high availability. A management jumpbox (bastion host) provides a secure connection for administrators to access deployed resources.


![alt text](docs/n-tier-diagram.png?raw=true "Azure Blueprint FedRAMP three-tier web-based application compliance architecture")

The architecture includes the following Azure products:
* **Virtual Machines**
	- (1) Management/Bastion (Windows Server 2016 Datacenter)
	- (2) Active Directory Domain Controller (Windows Server 2016 Datacenter)
	- (2) SQL Server Cluster Node (Windows Server 2012 R2)
	- (1) SQL Server Witness (Windows Server 2016 Datacenter)
	- (2) Web/IIS (Windows Server 2016 Datacenter)
* **AvailabilitySets**
	- (1) Active Directory Domain Controllers
	- (1) SQL Cluster Nodes and Witness
* **Virtual Network**
	- (1) /16 VNet
	- (5) /24 Subnets
	- DNS Settings are set to both Domain Controllers
* **Load Balancer**
	- (1) SQL Loadbalancer
* **Application Gateway**
	- (1) WAF Application Gateway
	-- Enabled
	-- Firewall Mode: Prevention
	-- Rule set: OWASP 3.0
	-- Listener: Port 443
* **Storage**
* **Backup**
* **Key Vault**
	- (1) keyVault
	-- (3) Access Policies (user, AADServicePrincipal, BackupFairFax)
	-- (7) Secrets (aadClientID, aadClientSecret, adminPassword, azurePassword, azureUserName, keyEncryptionKeyURL, sqlServerServiceAccountPassword)
* **Azure Active Directory**
* **Azure Resource Manager**
* **Application Insights**
* **Log Analytics**
* **Automation**
	- (1) Automation Account
* **Scheduler**
* **Operations Management Suite**
	- (1) OMS Workspace

---------------------------------------------------------------

## PRE-DEPLOYMENT

During pre-deployment you will confirm that your Azure subscription and local workstation are prepared to deploy the solution. The final pre-deployment step will run a PowerShell script that verifies setup requirements, gathers parameters and credentials, and creates resources in Azure to prepare for deployment.

### Azure subscription requirements

This Azure Blueprint solution is designed to deploy to Azure Government regions. The solution does not currently support Azure commercial regions. Customers must have a paid Azure Government subscription or sponsored account to deploy this solution.

### Local workstation requirements

PowerShell is used to initiate pre-deployment, deployment, and post-deployment tasks. PowerShell version **[5.0]** or greater must be installed on your local workstation. In PowerShell, you can use the following command to check the version:

`$PSVerstionTable.psversion`

The PowerShell pre-deployment task includes installation of Azure PowerShell modules, so PowerShell must be run in administrator mode.

#### Pre-deployment script

The pre-deployment PowerShell script will verify that a supported version of PowerShell is installed, that the necessary Azure PowerShell modules are installed. Azure PowerShell modules provide cmdlets for managing Azure resources. After all setup requirements are verified, the script will prompt for parameters and credentials to use when the solution is deployed. The script will prompt for the following parameters:

* **BaseSourceControl**: This should be set equal to the absolute path to the predeploy folder in this repository (ex. C:\Users\davoodharun\Desktop\azure-blueprint\predeploy)

* **subscriptionID**: To find your Azure Government subscription ID, navigate to https://portal.azure.us and sign in. Expand the service menu, and begin typing "subscription" in the filter box. Click on **Subscriptions** to open the subscriptions blade. Note the subscription ID, which has the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.

* **resourceGroupName**: The resource group name must be a string of 1-90 alphanumeric characters (0-9, a-z, A-Z), periods, underscores, hyphens, and parenthesis and cannot end in a period (e.g., `blueprint-rg`).


* **keyVaultName**: The Key Vault name must be a string 3-24 alphanumeric characters (0-9, a-z, A-Z) and hyphens and must be unique across Azure Government.


* **adminPassword**: Administrator password for local VM accounts (must complexity requirements)

* **sqlServerServiceAccountPassword**: SQL service account password (must complexity requirements)

* **aadAppName**: name for a new Azure Active Directory application that will be created

* **keyEncryptionKeyName**: name for a new key used in SQL Server Encryption

### Pre-deployment instructions

1. Clone this GitHub repository to your local workstation
`git clone https://github.com/AppliedIS/azure-blueprint.git`
2. Start PowerShell as an administrator
3. Run Orchestration_InitialSetup.ps1
4. Enter the parameters above when prompted

------------------------------------------------------------------------

## DEPLOYMENT

During this phase, an Azure Resource Manger (ARM) template will deploy Azure resources to your subscription and perform configuration activities.

After clicking the Deploy to Azure Gov button, the Azure portal will open and prompt for the following settings:

* **Key Vault Name**: Name of the Key Vault created during pre-deployment

* **Key Vault Resource Group Name**: Name of the resource group created during pre-deployment (e.g., blueprint-rg)

* **Admin Username**: User account name for local VM administrator accounts

* **Cert Data**: Cert 64bit encoded .pfx file for SSL

* **Cert Password**: Password used to create cert for SSL

* **Job Scheduler GUID**: The GUID for the runbook job to be started (use New-GUID in Powershell)

* **OMS Workspace Name**: Assign a name for the Log Analytic Workspace Name

* **OMS Automation Account Name**: Assign a name for the automation account used with OMS

### Deployment instructions

1. Click the button below.

	[![Deploy to Azure](http://azuredeploy.net/deploybutton.svg)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Fdavoodharun%2Fazure-blueprint%2Fsqlbypass%2Fazuredeploy.json)
2. Enter the settings from above.
3. Review the terms and conditions and click **I agree to the terms and conditions stated above**.
4. Click **Purchase**.

### Monitoring deployment status
This solution uses multiple nested templates to deploy and configure the resources shown in the architecture diagram. The full deployment will take approximately **[100]** minutes. You can monitor the deployment from Azure Portal.

See [TIMELINE.md](/docs/TIMELINE.md).

## POST-DEPLOYMENT

Post-deployment tasks include **[...]**

### Post-deployment instructions

1. Set Retention time
2. Configure Always On
3.

### Accessing deployed resources

**[Instructions to access VMs]**

**[Instructions to view OMS dashboard(s)]**

### Cost

Deploying this solution  will create resources within your Azure subscription. You will be responsible for the costs associated with these resources, so it is important that you review the applicable pricing and legal terms associated with all resources and offerings deployed as part of this solution. For cost estimates, you can use the Azure Pricing Calculator.

**[Estimated monthly cost of deployed resources]**

## Extending the Solution with Advanced Configuration

**[TBD]**

## Troubleshooting

If your deployment should fail, to avoid incurring costs and orphan resources it is advisable to delete the resource group associated with this solution in its entirety, fix the issue, and redeploy the solution. See the section below for instructions to delete all resources deployed by the solution.

**[Common problems; where to obtain support, etc.]**

### How to delete deployed resources

TBD
