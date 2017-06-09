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

6. **ProvisioningApplicationGateway** (4) - 10 mins | 16 min

        a. Public IP for Application Gateway
        b. Application Gateway (6b)

7. **ProvisioningNICsSQLADMGT** (5) - 30 sec | 7 min

        a. Public IP for MGT/Bastion
        b. Primary DC Network Interface
        c. Backup DC Network Interface
        d. SQL 0 Network Interface
        e. SQL 1 Network Interface
        f. SQL Witness Network Interface
        g. MGT/Bastion Network Interface (7a)

8. **ProvisioningVMsSQLADMGT** (7, 3) - 1 hr 30 mins | 1 hr 40 min

        a. Domain Controller Availability Set
        b. SQL Controller Availability Set
        c. SQL Storage Account for sql0 and sql1 VMs
        d. Domain Controller Storage Account for dc VMs
        e. SQL Storage Account for sqlw VMs
        f. MGT/Bastion Storage Account mgt VMs
        g. Diagnostics Storage Account for dcs
        h. Diagnostics Storage Account for sql VMs
        i. Primary Domain Controller VM (8a, 8d, 8g)
            I. Primary Domain Controller Baseline DSC Extension
        j. Backup Domain Controller VM (8a, 8d, 8g, 8i)
        k. SQL VMs (8b, 8c, 8h) \*
        l. SQL W VM (8b, 8e, 8h)
        m. UpdatingDNStoPrimaryADVM (8i, 8iI)
        n. ConfiguringBackupADVM (8j, 8m)
          I. Backup Domain Controller Baseline DSC Extension
        o. UpdatingDNSwithBackupADVM (8n)
        p. UpdatingSQLWNic (8k, 8l, 8o)
        q. UpdatingSQL0Nic (8p)
        r. UpdatingSQL1Nic (8q)
        s. MGT/Bastion VM (8f, 8o)
          I. Domain Join Extension for MGT/Bastion
          II. MGT/Bastion Basline DSC Extension
        t. PreparingAlwaysOnSqlServer (8r)
          I. SQLW Baseline DSC Extension
          II. SQL0 Iaas Extension
          III. SQL1 Iaas Extension
          IV. SQL0 Baseline DSC Extension (8tI, 8tII)
          V. SQL0 Antimalware Extension (8tIV)
        u. ConfiguringAlwaysOn (8t)
          I. SQL1 Baseline DSC Extension
          II. SQL1 Antimaleware Extension (8uI)
        v. ConfigurationVMEncryption (8i, 8j, 8k, 8l, 8s, 8u) \*
          I. Azure Disk Encryption Extension
        w. BackUp Configuration (8v) \*
          I. Recovery Services Vault Protected Items

9. **WebTier** (9) - 20 mins

        a. Web Storage Account
        b. Web Availability Set
        c. Web Network Interfaces \*
        d. Web VMs (9a, 9b, 9c) \*
          I. Domain Join Extension for Web VMs \*
          II. Web Baseline DSC Extension (9d, 9dI)
        e. ConfigurationVMEncryption-WEB (9dII) \*
          I. Azure Disk Encryption Extension
        f. BackUp Configuration (9e) \*
          I. Recovery Services Vault Protected Items

10. **ConfigurationOMSMonitoring for Web VMs** (9) \*

        a. Microsoft Monitoring Agent Extension
        b. Hybrid Workers Custom Script Extension (10a)

11. **ConfigurationAutomationSchedules for Web VMs** (10) \*

        a. Automation Account Schedule
        b. Automation Account Job Schedule (11a)


  \* = loop

  (xx) = dependency                      
