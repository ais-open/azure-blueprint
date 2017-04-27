**Blueprint Architecture User Stories / Capabilities**

**Identifier / authenticator management**

_The solution demonstrates complaint use of account identifiers and authenticators. This includes identifiers/authenticators for both user accounts and system/service accounts. Identifiers are unique/non-default. Strong authenticators are used, meeting FedRAMP requirements for passwords. Authenticator management is integrated with Key Vault, where appropriate (e.g., SQL encryption key, BitLocker keys, etc.). The information system is configured to protect the confidentiality/integrity of authenticators (keys, password) when transmitted during authentication and when stored. Identifiers/authenticators for solution example accounts (see account management section) are compliant._

- Identifier / authenticator management
  - Unique identifiers (e.g., no &quot;Administrator&quot;)
  - Password restrictions
    - Strong initial password
    - Minimum lifetime (1 day)
    - Maximum lifetime (60 days)
    - Complexity (14 char. length, at least one of each: upper case, lower case, number, special char.)
    - Change entropy (at least 50%)
    - Reuse restrictions (24 generations)
    - Change at first logon requirement [do not enable in ref. arch.]
    - Password strength enforcement
    - Storage/transmission encryption
  - AD federation (pre-setup / guidance)
  - Key management / Key Vault
    - BitLocker
    - SQL encryption

**Audit**

_The solution and all constituent components are configured to audit system events in accordance with FedRAMP requirements (including, OS-level auditing, application-level auditing (e.g., SQL Server), and within the Azure portal). Audit logs from system components are collected in OMS Log Analytics to provide a system-wide, time-correlated audit trail that is retained for a period of one year. An OMS Log Analytics dashboard provides an overview of key auditing metrics and indicators such as use of privileged functions, atypical activity, account actions, etc. The audit function is configured to protect against unauthorized record purging or alteration of audit records and limits access to audit functionality to a subset of authorized users._

- Audit
  - Configure auditing based on FedRAMP requirements
    - OS-level
    - Azure resources
    - Firewall / application gateway
    - Account actions (create, enable, modify, disable, delete)
    - Use of privileged functions
    - Account use monitoring
      - Atypical activity
  - Audit storage capacity
    - Retention (1 year)
      - Capacity alerts
  - Audit system failure (action / alerts)
  - Audit protection against altering records, purging
  - Restrictions on audit configurations / tools (who can configure / view)
  - Time sync
    - 1 second
    - UTC
  - Offload to Log Analytics
    - Central review / correlation

**Account management**

_The solution employs a discrete set of explicitly defined account types (e.g., individual user, system/service). Accounts are managed for all solution components from the OS level to the Azure portal. Accounts are configured using role-based access control to implement the concepts of least privilege and separation of duties for specific roles (e.g., security admin, web admin, DB admin). The solution deploys example accounts to demonstrate this functionality. The solution enforces account management principles as required by FedRAMP, including inactivity controls, session lock/termination, system use notification, and other logon restrictions. Remote access to the solution is managed._

- Account management
  - Establish user account types
    - Individual user
    - System / service
  - For all accounts, as applicable (e.g., OS-level, RDP, Azure portal):
    - Automatic disable of temporary accounts, inactive accounts
    - Inactivity logout / session termination
    - Unsuccessful logon attempts
    - System use notification
    - Concurrent session control
    - Session lock, termination
  - RBAC
    - OS roles, Azure roles
    - Separation of duties
    - Least privilege – e.g.:
      - Security admin
      - Web admin
      - DB admin
      - Audit manager
  - Remote access
    - Managed access points (via bastion host / jumpbox)

**Configuration management**

_A baseline configuration is established for the information system. This baseline includes ARM templates and associated scripts and configurations. A security baseline is established for operating systems and includes restrictions on ports, protocols, services, and software installation/use. Operating systems and other software are configured for automate patching (or patching is invoked from OMS). Antimalware software is installed and configured in accordance with FedRAMP requirements. OMS is integrated into the solution to monitor configuration deviations, patching compliance, and the antimalware solution. The solution monitors the configuration and provides alerting via OMS / email when deviations from the established baseline occur._

- Configuration management
  - Uniform baseline applied to operating systems
    - Baseline deviation reporting in OMS via Automation
    - OS baseline configuration requirements
      - Limit software installation
      - Signed components only
      - Whitelisting
      - Alerting if unauthorized software installed
      - Least functionality (ports, protocols, services, etc.)
  - Application configuration (e.g., SQL server)
    - Encryption / TDE
  - Patching
    - Windows update configured
    - Dashboard reporting in OMS
  - Anti-malware
    - Installed/configured on operating systems
      - automatic signature updates
      - periodic scanning
      - real-time detection
      - detection action(s)
      - nonsignature-based detection
      - logging/alerting
      - OMS reporting
    - Application firewall
      - Inbound/outbound traffic monitoring

**Resilient architecture**

_The solution is designed for resiliency. The selection of architecture, storage, and configuration must consider resiliency of the solution (e.g., geo-redundant storage, multi-region load balancing (premium), data backup, SQL transaction recovery)._

- Resiliency
  - Alternate processing site (premium / v2 feature)
  - Redundant storage (geo-replicated)
    - Backup data
  - Backup
    - User-level
    - System-level
    - Encrypted (SSE)
    - Dashboard reporting
  - SQL transaction recovery

**Secure architectures**

_The solution is designed for security. System component are partitioned to separate user and administrative functionality, functionality of information system components (e.g., web tier / DB tier). Management components (e.g., bastion host / jumpbox) are separated from production-side components. Information flow is enforced between the separated components of the system and external systems using boundary protections (e.g., NSGs, firewalls) configured in a deny-by-default scheme._

- Architecture
  - Partitioning
    - user / admin function separation
    - security function isolation
    - bastion host / management subnet
  - Information flow enforcement
    - SQL tier to db tier
    - Management
  - Boundary protection
    - Deny by default
    - Restrict incoming traffic
    - Application firewall
    - NSGs
      - Security component isolation
      - SQL tier / DB tier separation
    - Host-based firewall

**Communications protection**

_Communications sessions are secured by cryptographic mechanisms (e.g., web sessions, RDP). Solution is pre-provisioned to use ExpressRoute (premium)._

- Communications protection
  - Web traffic secured
    - Application gateway
  - RDP sessions secured
- ExpressRoute (premium / v2 feature)

**Encryption**

_Information is encrypted at rest demonstrating a layered approach (storage account encryption, OS-level encryption, DB encryption, etc.)._

- Encryption
  - Information at rest
    - BitLocker
    - SSE
    - Backup
