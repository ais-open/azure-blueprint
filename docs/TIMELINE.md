# DEPLOYMENT OUTLINE

#### Introduction
This outline provides an overview of the deployment timeline for cloud resources provisioned through this repository. Top level deployments are represented in bold.

### Outline

1. **CreateAutomationAccountAndOMSWorkspace** - 5 mins | 5 mins

        a. OMS Automation Account
        b. OMS Automation Account Module - Azure Profile (1a)  
        c. OMS Automation Account Module - ASR Scripts (1a)
        d. Operational Insights Workspaces (1a)
        e. Operational Insights Workspaces Linked Services (1d, 1a)

2. **RecoverServicesVault** - 10 sec

        a. Recovery Services Vault

3. **BackupPolicyCustom** (2) - 5 sec | 15 sec

        a.  Recovery Services Vault BackUp Policies

4. **VirtualNetworkNSG** (1) - 1 min | 6 min

        a. Network Security Groups - Application Gateway, Domain Controllers, SQL, Web Tier, MGT
        b. Virtual Network (4a)

5. **SQLLoadBalancer** (4) - 10 sec | 6 min

        a. SQL Load Balancer

6. **Storage Accounts** (5)

        a. 1 WEB storage account + Operational Insights configuration
        b. 1 MGT storage account + Operational Insights configuration
        c. 1 SQL storage account + Operational Insights configuration
        d. 1 DC storage account + Operational Insights configuration
        e. 1 SQL File share Witness storage account + Operational Insights configuration
        f. 1 SQL diagnostics storage account + Operational Insights configuration
        g. 1 DC diagnostics storage account + Operational Insights configuration

7. **Availability Sets** (5)

        a. 1 Active Directory availability set
        b. 1 SQL availability set
        c. 1 WEB availability set

8. **ProvisionAndConfigureAD** (6,7)

        a. 1 Network Interface for primary domain controller
        b. 1 Network Interface for backup domain controller
        c. 1 Virtual Machine as primary domain controller (a)
        d. 1 Virtual Machine as backup domain controller (b)
        e. 1 DSC extension to configure baseline for primary domain controller (c)
        f. 1 deployment to update virtual network DNS with primary domain controller (e)
        g. 1 deployment to configure backup domain controller (f)
            i. 1 DSC extension to configure backup domain controller
        h. 1 deployment to update virtual network DNS with backup domain controller (g)
        i. 1 deployment for configuring encryption for domain controllers (h)
        j. 1 deployment for configuring backup up containers for domain controllers (j)

9. **ProvisioningNICs** (8)

        a. 1 Public IP for MGT
        b. 1 Network Interface for primary SQL
        c. 1 Network Interface for secondary SQL
        d. 1 Network Interface for SQL witness
        e. 1 Network Interface for MGT
        f. n Network Interfaces for WEB

10. **ProvisioningApplicationGateway**

        a. 1 Public IP for Application Gateway
        b. 1 Application Gateway (6b)

11. **ProvisioningVirtualMachines** (9)

        a. 1 Primary SQL VM
        b. 1 Secondary SQL VM
        c. 1 SQL Witness VM
        d. 1 MGT VM
        e. n WEB VMs

12. **ConfigureMGT** (11)

        a. 1 domain join extension for MGT VM
        b. 1 DSC extension to configure baseline for MGT VM (a)
        c. 1 deployment for configuring encryption for MGT VM (b)
        d. 1 deployment for configuring backup up containers for MGT VM (b)

13. **ConfigureSQL** (11)

        a. 1 deployment to update SQL Witness network interface with domain controllers as DNS servers
        b. 1 deployment to update primary SQL network interface with domain controllers as DNS servers (a)
        c. 1 deployment to update secondary SQL network interface with domain controllers as DNS servers (b)
        e. 1 deployment to prepare SQL Always On
            i. SQL Witness baseline DSC extension
            ii. Primary SQL IAAS extension
            iii. Secondary SQL IAAS extension
            iv. Primary SQL baseline DSC (i, ii)
            v. AntiMalware Extension for primary SQL (iv)

14. **ConfigureWebTier** (11)

        a. n domain join extension for WEB VMs
        b. n DSC extension to configure baseline for WEB VMs (a)
        c. n deployment for configuring encryption for WEB VMs (b)
        d. n deployment for configuring backup up containers for WEB VMs (b)

15. **ConfigurationOMSMonitoringSQLADMGT** (12, 13, 14) \*

        a. Microsoft Monitoring Agent Extension
        b. Hybrid Workers Custom Script Extension (10a)

16. **ConfigurationOMSMonitoringWEB** (12, 13, 14) \*

        a. Microsoft Monitoring Agent Extension
        b. Hybrid Workers Custom Script Extension (10a)

17. **ConfigurationAutomationSchedules** (15,16) \*

        a. Automation Account Schedule
        b. Automation Account Job Schedule (11a)


  \* = loop

  (xx) = dependency                      
