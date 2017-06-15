# OMS Auditing [AC-2.g, AC-2 (1), AC-2 (4), AC-2 (7).b, AC-2 (12).a, AC-2 (12).b, AC-6 (9), AC-17 (1), AU-2.a, AU-2.d, AU-3, AU-12.a, AU-12.b, AU-12.c, CM-5 (1)]

## Configuration

See the deployment templates for [provisioning OMS](https://github.com/AppliedIS/azure-blueprint/blob/master/nestedtemplates/provisioningAutoAccOMSWorkspace) and the [OMS Monitoring Agent]((https://github.com/AppliedIS/azure-blueprint/blob/master/nestedtemplates/pprovisioningOMSMonitoring.json).

## Known Issues


## Compliance

**AC-2.g: The organization monitors the use of information system accounts.**  

This Azure Blueprint Solution implements the OMS Security and Audit Solution's Identity and Access Dashboard. This dashboard enable account managers to monitor access and use events on all deployed resources. Read more [here] (https://docs.microsoft.com/en-us/azure/operations-management-suite/oms-security-monitoring-resources)


**AC-2 (1): The organization employs automated mechanisms to support the management of information system accounts. The use of automated mechanisms can include, for example: using email or text messaging to automatically notify account managers when users are terminated or transferred; using the information system to monitor account usage; and using telephonic notification to report atypical system account usage.**

This solution employs mechanisms by leveraging an Azure Automation Account to automate manual processes and enforce configurations for virtual machines across information system accounts. The dashboard implemented as a part of this solution also enables account managers to monitor access attempts against deployed resources. This solution can be configured to send alerts when atypical activity is suspected or other predefined events occur.

**AC-2 (4); The information system automatically audits account creation, modification, enabling, disabling, and removal actions, and notifies organization-defined personnel or roles.**

This Azure Blueprint Solution implements the following system account types: Azure Active Directory users and OS-level users. Azure Active Directory account management actions generate an event in the Azure Activity Log, while OS-level account management actions generate an event in the system log -- these logs are sent to OMS.

**AC-2 (7).b: The organization monitors privileged role assignments.**

This Azure Blueprint Solution implements Azure Active Directory Privileged Identity Management. Privileged Identity Management enables account managers to manage, control, and monitor privileged access.

**Not yet available in Azure Gov*

**AC-2 (12).a: The organization monitors information system accounts for organization-defined atypical usage.**

This Azure Blueprint Solution implements the OMS Security and Audit Solution's Identity and Access Dashboard. This dashboard enables account managers to monitor access attempts against deployed resources.

**AC-2 (12).b: The organization reports atypical usage of information system accounts to organization-defined personnel or roles.**

This Azure Blueprint Solution implements the OMS Security and Audit Solution's Identity and Access Dashboard. This dashboard enable account managers to monitor access attempts against deployed resources. This solution can be configured to send alerts when atypical activity is suspected or other predefined events occur

**AC-6 (9): The information system audits the execution of privileged functions.**

This Azure Blueprint Solution implements Azure Active Directory Privileged Identity Management. Privileged Identity Management enables account managers to manage, control, and monitor privileged access.

** Not yet available in Azure Gov*

**AC-17 (1): The information system monitors and controls remote access methods.**

This Azure Blueprint Solution provides remote access to the information system through the Azure portal, through remote desktop connection via a jumpbox, and through a customer-implemented web application. Accesses through the Azure portal and remote desktop sessions are audited and can be monitored through OMS.

**AU-2.a: The organization determines that the information system is capable of auditing the following events: successful and unsuccessful account logon events, account management events, object access, policy change, privilege functions, process tracking, and system events. For web applications: all administrator activity, authentication checks, authorization checks, data deletions, data access, data changes, and permission changes.**

 NOTE: For this control, we need only to verify and document that the various components that make up this architecture support auditing these event types. [Audit capability for this Azure Blueprint Solution is provided by…]

**AU-2.d: The organization determines that the following events are to be audited within the information system: [Assignment: organization-defined audited events (the subset of the auditable events defined in AU-2 a.) along with the frequency of (or situation requiring) auditing for each identified event].**

NOTE: For this control, we need to state the subset of events that the audit components are configured to audit. [Audit capability for this Azure Blueprint Solution is configured to audit the following events…]

**AU-3: The information system generates audit records containing information that establishes what type of event occurred, when the event occurred, where the event occurred, the source of the event, the outcome of the event, and the identity of any individuals or subjects associated with the event.**

 NOTE: This is generally built-in capability. [This Azure Blueprint Solution relies on built-in audit capabilities of Windows Server, SQL Database, and Azure. These audit solutions capture audit records with sufficient detail to satisfy the requirements of this control.

**AU-12.a: The information system provides audit record generation capability for the auditable events defined in AU-2 a. at [Assignment: all information system components where audit capability is deployed/available]. [The following resources deployed by this Azure Blueprint Solution generate audit records: TBD]**

**AU-12.b: The information system allows [Assignment: organization-defined personnel or roles] to select which auditable events are to be audited by specific components of the information system.**

[The configuration of events selected to be audited by resources deployed by this Azure Blueprint Solution can be configured by [...]]

**AU-12.c: The information system generates audit records for the events defined in AU-2 d. with the content defined in AU-3.**

 [The following resources deployed by this Azure Blueprint Solution generate audit records in accordance with the parameters defined in AU-2.d and AU-3: TBD]

**CM-5 (1): The information system enforces access restrictions and supports auditing of the enforcement actions.**

 [NOTE need implementation details; combination of Azure permissions + AD/local account permissions.] (Also see issue #19.)**
