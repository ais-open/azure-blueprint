# IaaS web application Blueprint for FedRAMP-compliant environments

## Overview

The [Federal Risk and Authorization Management Program (FedRAMP)](https://www.fedramp.gov/) is a government-wide program that provides a standardized approach to the security of cloud services. The IaaS web application Blueprint for FedRAMP-compliant environments provides guidance for the deployment of a FedRAMP-compliant Infrastructure-as-a-Service (IaaS) environment suitable for a simple Internet-facing web application. This solution automates deployment and configuration of Azure resources for a common reference architecture, demonstrating ways in which customers can meet specific security and compliance requirements and serves as a foundation for customers to build and configure their own solutions on Azure. The solution implements a subset of controls from the FedRAMP High baseline, based on NIST SP 800-53. For more information about FedRAMP High requirements and this solution, see [FedRAMP High Requirements - High-Level Overview](). *Note: This solution deploys to Azure Government.*

This architecture is intended to serve as a foundation for customers to adjust to their specific requirements and should not be used as-is in a production environment. Deploying an application into this environment without modification is not sufficient to completely meet the requirements of the FedRAMP High baseline. Please note the following:
- This architecture provides a baseline to help customers use Microsoft Azure in a FedRAMP-compliant manner.
- Customers are responsible for conducting appropriate security and compliance assessment of any solution built using this architecture, as requirements may vary based on the specifics of each customer's implementation. 

For a quick overview of how this solution works, watch this [video]]() explaining and demonstrating its deployment.

## Solution components

This Azure Blueprint automatically deploys an IaaS web application reference architecture with pre-configured security controls to help customers achieve compliance with FedRAMP requirements. The solution consists of Azure Resource Manager templates and PowerShell scripts that guide resource deployment and configuration. Accompanying Azure Blueprint [compliance documentation](https://github.com/AppliedIS/azure-blueprint/wiki) is provided, indicating security control inheritance from Azure and the deployed resources and configurations that align with NIST SP 800-53 security controls, thereby enabling organizations to fast-track compliance obligations.

## Architecture diagram

This solution deploys a reference architecture for an IaaS web application with a database backend. The architecture includes a web tier, data tier, Active Directory infrastructure, application gateway and load balancer. Virtual machines deployed to the web and data tiers are configured in an availability set and SQL Servers are configured in an AlwaysOn availability group for high availability. Virtual machines are domain-joined, and Active Directory group policies are used to enforce security and compliance configurations at the operating system level. A management jumpbox (bastion host) provides a secure connection for administrators to access deployed resources.


![alt text](docs/n-tier-diagram.png?raw=true "Azure Blueprint FedRAMP multi-tier web application architecture")

This solution uses the following Azure services. Details of the deployment architecture are located in the [Deployment architecture]() section.
* **Azure Virtual Machines**
	- (1) Management/bastion (Windows Server 2016 Datacenter)
	- (2) Active Directory domain controller (Windows Server 2016 Datacenter)
	- (2) SQL Server cluster node (SQL Server 2016 on Windows Server 2012 R2)
	- (1) SQL Server witness (Windows Server 2016 Datacenter)
	- (2) Web/IIS (Windows Server 2016 Datacenter)
* **Availability Sets**
	- (1) Active Directory domain controllers
	- (1) SQL cluster nodes and witness
	- (1) Web/IIS
* **Azure Virtual Network**
	- (1) /16 virtual networks
	- (5) /24 subnets
	- DNS settings are set to both domain controllers
* **Azure Load Balancer**
	- (1) SQL load balancer
* **Azure Application Gateway**
	- (1) WAF Application Gateway
	-- Enabled
	-- Firewall Mode: Prevention
	-- Rule set: OWASP 3.0
	-- Listener: Port 443
* **Azure Storage**
    - (7) Geo-redundant storage accounts
* **Azure Backup**
    - (1) Recovery Services vault
* **Azure Key Vault**
	- (1) Key Vault
	-- (3) Access policies (user, AADServicePrincipal, BackupFairFax)
	-- (7) Secrets (aadClientID, aadClientSecret, adminPassword, azurePassword, azureUserName, keyEncryptionKeyURL, sqlServerServiceAccountPassword)
* **Azure Active Directory**
* **Azure Resource Manager**
* **Azure Log Analytics**
* **Azure Automation**
	- (1) Automation account
* **Operations Management Suite**
	- (1) OMS workspace

## Deployment architecture

The following section details the development and implementation elements.

### Network segmentation and security

#### Application Gateway

The architecture reduces the risk of security vulnerabilities using an Application Gateway with web application firewall (WAF), and the OWASP ruleset enabled. Additional capabilities include:

- [End-to-End-SSL](/azure/application-gateway/application-gateway-end-to-end-ssl-powershell)
- Enable [SSL Offload](/azure/application-gateway/application-gateway-ssl-portal)
- Disable [TLS v1.0 and v1.1](/azure/application-gateway/application-gateway-end-to-end-ssl-powershell)
- [Web application firewall](/azure/application-gateway/application-gateway-webapplicationfirewall-overview) (WAF mode)
- [Prevention mode](/azure/application-gateway/application-gateway-web-application-firewall-portal) with OWASP 3.0 ruleset
- Enable [diagnostics logging](/azure/application-gateway/application-gateway-diagnostics)
- [Custom health probes](/azure/application-gateway/application-gateway-create-gateway-portal)

#### Virtual network

The architecture defines a private virtual network with an address space of 10.200.0.0/16.

#### Network security groups

This solution deploys resources in an architecture with a separate web subnet, database subnet, Active Directory subnet, and management subnet inside of a virtual network. Subnets are logically separated by network security group rules applied to the individual subnets to restrict traffic between subnets to only that necessary for system and management functionality.

See the configuration for [Network Security Groups]() deployed with this solution. Organizations can configure Network Security groups by editing the file above using [this documentation](https://docs.microsoft.com/azure/virtual-network/virtual-networks-nsg) as a guide.

Each of the subnets has a dedicated network security group (NSG):
- 1 NSG for Application Gateway (LBNSG)
- 1 NSG for Jumpbox (MGTNSG)
- 1 NSG for Primary and Backup Domain Controllers (ADNSG)
- 1 NSG for SQL Servers and File Share Witness (SQLNSG)
- 1 NSG for Web Tier (WEBNSG)

#### Subnets

Each subnet is associated with its corresponding NSG.

### Data at rest

The architecture protects data at rest by using several encryption measures.

#### Azure Storage

To meet data-at-rest encryption requirements, all storage accounts use [Storage Service Encryption](https://docs.microsoft.com/en-us/azure/storage/common/storage-service-encryption).

#### SQL Database

SQL Database is configured to use [Transparent Data Encryption (TDE)](https://docs.microsoft.com/sql/relational-databases/security/encryption/transparent-data-encryption), which performs real-time encryption and decryption of data and log files to protect information at rest. TDE provides assurance that stored data has not been subject to unauthorized access. 

#### Azure Disk Encryption

Azure Disk Encryption is used to encrypted Windows IaaS virtual machine disks. [Azure Disk Encryption](https://docs.microsoft.com/azure/security/azure-security-disk-encryption) leverages the BitLocker feature of Windows to provide volume encryption for OS and data disks. The solution is integrated with Azure Key Vault to help control and manage the disk-encryption keys.

### Logging and auditing

[Operations Management Suite (OMS)](https://docs.microsoft.com/azure/security/azure-security-disk-encryption) provides extensive logging of system and user activity as well as system health. 

- **Activity Logs:**  [Activity logs](https://docs.microsoft.com/azure/monitoring-and-diagnostics/monitoring-overview-activity-logs) provide insight into the operations that were performed on resources in your subscription.
- **Diagnostic Logs:**  [Diagnostic logs](https://docs.microsoft.com/azure/monitoring-and-diagnostics/monitoring-overview-of-diagnostic-logs) are all logs emitted by every resource. These logs include Windows event system logs, Azure storage logs, Key Vault audit logs, and Application Gateway access and firewall logs.
- **Log Archiving:**  Azure activity logs and diagnostic logs can be connected to Azure Log Analytics for processing, storing, and dashboarding. Retention is user-configurable up to 730 day to meet organization-specific retention requirements.

### Secrets management

The solution uses Azure Key Vault to manage keys and secrets.

- [Azure Key Vault](https://azure.microsoft.com/services/key-vault/) helps safeguard cryptographic keys and secrets used by cloud applications and services. 
- The solution is integrated with Azure Key Vault to manage IaaS virtual machine disk-encryption keys and secrets.

### Identity management

The following technologies provide identity management capabilities in the Azure environment.
- [Azure Active Directory (Azure AD)](https://azure.microsoft.com/services/active-directory/) is Microsoft's multi-tenant cloud-based directory and identity management service.
- Authentication to a customer-deployed web application can be performed using Azure AD. For more information, see [Integrating applications with Azure Active Directory](https://docs.microsoft.com/azure/active-directory/develop/active-directory-integrating-applications).  
- [Azure Role-based Access Control (RBAC)](https://docs.microsoft.com/azure/active-directory/role-based-access-control-configure) enables precisely focused access management for Azure. Subscription access is limited to the subscription administrator, and access to resources can be limited based on user role.
- A deployed IaaS Active Directory instance provides identity management at the OS-level for deployed IaaS virtual machines.
   
### Compute resources

#### Web tier

The solution deploys web tier virtual machines in an [Availability Set](https://docs.microsoft.com/azure/virtual-machines/windows/tutorial-availability-sets). Availability sets ensure that the virtual machines are distributed across multiple isolated hardware clusters to improve availability.

#### Database tier

The solution deploys database tier virtual machines in an Availability Set as an [AlwaysOn availability group](https://docs.microsoft.com/azure/virtual-machines/windows/sql/virtual-machines-windows-portal-sql-availability-group-overview). The Always On availability group feature provides for high-availability and disaster-recovery capabilities. 

#### Active Directory

All virtual machines deployed by the solution are domain-joined, and Active Directory group policies are used to enforce security and compliance configurations at the operating system level. Active Directory virtual machines are deployed in an Availability Set.

#### Jumpbox (bastion host)

A management jumpbox (bastion host) provides a secure connection for administrators to access deployed resources. The NSG associated with the management subnet where the jumpbox virtual machine is located allows connections only on TCP port 3389 for RDP. 

### Malware protection

[Microsoft Antimalware](https://docs.microsoft.com/en-us/azure/security/azure-security-antimalware) for Virtual Machines provides real-time protection capability that helps identify and remove viruses, spyware, and other malicious software, with configurable alerts when known malicious or unwanted software attempts to install or run on protected virtual machines.

### Operations management

#### Log analytics

[Log Analytics](https://azure.microsoft.com/services/log-analytics/) is a service in Operations Management Suite (OMS) that enables collection and analysis of data generated by resources in Azure and on-premises environments.

#### OMS solutions

The following OMS solutions are pre-installed as part of this solution:
- [AD Assessment](https://docs.microsoft.com/azure/log-analytics/log-analytics-ad-assessment)
- [Antimalware Assessment](https://docs.microsoft.com/azure/log-analytics/log-analytics-malware)
- [Azure Automation](https://docs.microsoft.com/azure/automation/automation-hybrid-runbook-worker)
- [Security and Audit](https://docs.microsoft.com/azure/operations-management-suite/oms-security-getting-started)
- [SQL Assessment](https://docs.microsoft.com/azure/log-analytics/log-analytics-sql-assessment)
- [Update Management](https://docs.microsoft.com/azure/operations-management-suite/oms-solution-update-management)
- [Agent Health](https://docs.microsoft.com/azure/operations-management-suite/oms-solution-agenthealth)
- [Azure Activity Logs](https://docs.microsoft.com/azure/log-analytics/log-analytics-activity)
- [Change Tracking](https://docs.microsoft.com/azure/log-analytics/log-analytics-activity)

## Customer responsibility matrix

Customers are responsible for retaining a copy of the [Responsibility Summary Matrix](), which outlines the FedRAMP requirements that are the responsibility of the customer and those which are the responsibility of Microsoft.

## Deploy the solution

This Azure Blueprint solution is comprised of JSON configuration files and PowerShell scripts that are handled by Azure Resource Manager's API service to deploy resources within Azure. For more information about ARM template deployment see the following documentation:

[Azure Resource Manager templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-overview#template-deployment)
[ARM template functions](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-functions)
[ARM templates and nesting resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates)

#### Quickstart
1. Clone this repository to your local workstation.
2. Run the pre-deployment PowerShell script: azure-blueprint/predeploy/Orchestration_InitialSetup.ps1. [Read more about pre-deployment.](#pre-deployment)
3. Click the button below, sign into the Azure portal, enter the required ARM template parameters, and click **Purchase**. [Read more about deployment.](#deployment)

	[![Deploy to Azure](http://azuredeploy.net/AzureGov.png)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAppliedIS%2Fazure-blueprint%2Fmaster%2Fazuredeploy.json)

### PRE-DEPLOYMENT

During pre-deployment, you will confirm that your Azure subscription and local workstation are prepared to deploy the solution. The final pre-deployment step will run a PowerShell script that verifies setup requirements, gathers parameters and credentials, and creates resources in Azure to prepare for deployment.

#### Azure subscription requirements

This Azure Blueprint solution is designed to deploy to Azure Government. The solution does not currently support Azure commercial regions. For customers with a multi-tenant environment, the account used to deploy must be a member of the Azure Active Directory associated with the subscription where this solution will be deployed.

#### Local workstation requirements

PowerShell is used to initiate some pre-deployment tasks. PowerShell version 5.0 or greater must be installed on your local workstation. In PowerShell, you can use the following command to check the version:

`$PSVersionTable.psversion`

In order to run the pre-deployment script, you will need to have the current Azure PowerShell AzureRM modules installed (see [Installing AzureRM modules](https://docs.microsoft.com/en-us/powershell/azure/install-azurerm-ps?view=azurermps-4.1.0)).

#### SSL certificate
This solution deploys an Application Gateway and requires an SSL certificate. To generate a self-signed SSL certificate using PowerShell, run [this script](predeploy/generateCert.ps1). Note: self-signed certificates are not recommended for use in production environments.

#### Pre-deployment script

The pre-deployment PowerShell script will verify that the necessary Azure PowerShell modules are installed. Azure PowerShell modules provide cmdlets for managing Azure resources. After all setup requirements are verified, the script will ask you to sign into Azure and then prompt for parameters and credentials to use when the solution is deployed. The script will prompt for the following parameters in order:

* **Azure username**: Your Azure username (ex. someuser@contoso.onmicrosoft.com)
* **Azure password**: Password for the Azure account above
* **Admin username**: Administrator username you want to use for the administrator accounts on deployed virtual machines
* **adminPassword**: Administrator password you want to use for the administrator accounts on deployed virtual machines (must complexity requirements, see below)
* **sqlServerServiceAccountPassword**: SQL service account password you want to use (must complexity requirements, see below)
* **subscriptionId**: To find your Azure Government subscription ID, navigate to https://portal.azure.us and sign in. Expand the service menu on the left side of the portal, select "more services," and begin typing "subscription" in the filter box. Click on **Subscriptions** to open the subscriptions blade. Note the subscription ID, which has the format xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx.
* **resourceGroupName**: Resource group name you want to use for this deployment; must be a string of 1-90 alphanumeric characters (0-9, a-z, A-Z), periods, underscores, hyphens, and parenthesis and cannot end in a period (e.g., `blueprint-rg`).
* **keyVaultName**: Key Vault name you want to use for this deployment; must be a string 3-24 alphanumeric characters (0-9, a-z, A-Z) and hyphens and must be unique across Azure Government.

Passwords must be at least 14 characters and contain one each of: lower case character, upper case character, number, special character.

#### Pre-deployment instructions

1. Clone this GitHub repository to your local workstation
`git clone https://github.com/AppliedIS/azure-blueprint.git`
2. Start PowerShell as an administrator
3. Run Orchestration_InitialSetup.ps1
4. Enter the parameters above when prompted

Note the resource group name and Key Vault name; these will be required during the deployment phase. The script will also generate an GUID for use during the deployment phase.

------------------------------------------------------------------------

### DEPLOYMENT

During this phase, an Azure Resource Manager (ARM) template will deploy Azure resources to your subscription and perform configuration activities.

After clicking the Deploy to Azure Gov button, the Azure portal will open and prompt for the following settings:

**Basics**
* **Subscription**: Choose the same subscription used during the pre-deployment phase
* **Resource group**: Select 'Use existing' and choose the resource group created during pre-deployment
* **Location**: Select 'USGovVirginia'

**Settings**
* **Admin Username**: Administrator username you want to use for administrative accounts for deployed resources (can be the same username as entered during pre-deployment phase)
* **Key Vault Name**: Name of the Key Vault created during pre-deployment
* **Key Vault Resource Group Name**: Name of the resource group created during pre-deployment
* **Cert Data**: 64bit-encoded certificate for SSL
* **Cert Password**: Password used to create certificate
* **Scheduler Job GUID**: GUID for the runbook job to be started (use GUID output by pre-deployment script or run New-Guid in PowerShell)
* **OMS Workspace Name**: Name you want to use for the Log Analytic workspace; must be a string 4-63 alphanumeric characters (0-9, a-z, A-Z) and hyphens and must be unique across Azure Government.
* **OMS Automation Account Name**: Name you want to use for the automation account used with OMS; must be a string 6-50 alphanumeric characters (0-9, a-z, A-Z) and hyphens and must be unique across Azure Government.

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

1. Set Retention time - Set the data retention time in the OMS resource blade from 31 to 365 days to meet FedRAMP compliance

#### Accessing deployed resources

You can access your machines through the MGT VM that is created from the deployment. From this VM, you can remote into and access any of the VMs in the network.

#### Cost

Deploying this solution will create resources within your Azure subscription. You will be responsible for the costs associated with these resources, so it is important that you review the applicable pricing and legal terms associated with all resources and offerings deployed as part of this solution. For cost estimates, you can use the Azure Pricing Calculator.

#### Extending the Solution with Advanced Configuration

If you have a basic knowledge of how Azure Resource Manager (ARM) templates work, you can customize the deployment by editing  azuredeploy.json or any of the templates located in the nested templates folder. Some items you might want to edit include but are not limited to:
- Network Security Group rules (nestedtemplates/virtualNetworkNSG.json)
- OMS alert rules and configuration (nestedtemplates/provisioningAutoAccOMSWorkspace)
- Application Gateway routing rules (nestedtemplates/provisioningApplicationGateway.json)

For more information about template deployment, please refer to the following:

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

## Disclaimer

- This document is for informational purposes only. MICROSOFT MAKES NO WARRANTIES, EXPRESS, IMPLIED, OR STATUTORY, AS TO THE INFORMATION IN THIS DOCUMENT. This document is provided "as-is." Information and views expressed in this document, including URL and other Internet website references, may change without notice. Customers reading this document bear the risk of using it.  
- This document does not provide customers with any legal rights to any intellectual property in any Microsoft product or solutions.  
- Customers may copy and use this document for internal reference purposes.  
- NOTE: Certain recommendations in this document may result in increased data, network, or compute resource usage in Azure, and may increase a customer's Azure license or subscription costs.  
- This architecture is intended to serve as a foundation for customers to adjust to their specific requirements and should not be used as-is in a production environment.
