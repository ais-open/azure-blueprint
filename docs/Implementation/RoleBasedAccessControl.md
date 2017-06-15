# Role Based Access Control [ AC-2 (7).a, AC-3, AC-6, AC-6 (8), AC-6 (10), AU-6 (7), AU-9, AU-9 (4), AU-12 (3), CM-5]

## Implementation and Configuration

## Compliance Documentation

**AC-2 (7).a: The organization establishes and administers privileged user accounts in accordance with a role-based access scheme that organizes allowed information system access and privileges into roles.**

This Azure Blueprint Solution implements the following system account types: Azure Active Directory users (used to manage access to Azure resources), [...]. Azure Active Directory account privileges are implemented using role-based access control

**AC-3: The information system enforces approved authorizations for logical access to information and system resources in accordance with applicable access control policies.**

[This Azure Blueprint Solution enforces logical access authorizations using role-based access control enforced by Azure Active Directory, Active Directory (AD DS) [...].

**AC-6: The organization employs the principle of least privilege, allowing only authorized accesses for users (or processes acting on behalf of users) which are necessary to accomplish assigned tasks in accordance with organizational missions and business functions.**

[This Azure Blueprint Solution implements role-based access control to ensure users are assigned only the privileges explicitly necessary to perform their assigned duties.]

**AC-6 (8): The information system prevents [Assignment: organization-defined software] from executing at higher privilege levels than users executing the software.**

[This Azure Blueprint Solution implements role-based access control to assign users only the privileges explicitly necessary to perform their assigned duties.]

**AC-6 (10): The information system prevents non-privileged users from executing privileged functions to include disabling, circumventing, or altering implemented security safeguards/countermeasures.**

[This Azure Blueprint Solution implements role-based access control to assign users only the privileges explicitly necessary to perform their assigned duties.]

**AU-6 (7): The organization specifies the permitted actions for each [Selection (one or more): information system process; role; user] associated with the review, analysis, and reporting of audit information. Organizations specify permitted actions for information system processes, roles, and/or users associated with the review, analysis, and reporting of audit records through account management techniques. Specifying permitted actions on audit information is a way to enforce the principle of least privilege. Permitted actions are enforced by the information system and include, for example, read, write, execute, append, and delete.**

 [need implementation details]

**AU-9: The information system protects audit information and audit tools from unauthorized access, modification, and deletion.**

Logical access controls are used to protect audit information and tools within this Azure Blueprint Solution from unauthorized access, modification, and deletion. Azure Active Directory enforces approved logical access using Active Directory policies and role-based group memberships. The ability to view audit information and use auditing tools is limited to users that require these permissions.

need to address at the OS-level, for OMS, and anywhere else audit data is available (Also see issues #13, #14.)

**AU-9 (4): The organization authorizes access to management of audit functionality to only [Assignment: organization-defined subset of privileged users].**

Azure Active Directory restricts the management of audit functionality to members of the appropriate security groups. Only personnel with a specific need to access the management of audit functionality are granted these permissions within this Azure Blueprint Solution. (Also see issue #14.)

**AU-12 (3): The information system provides the capability for [Assignment: individuals or roles with audit configuration responsibilities] to change the auditing to be performed on [Assignment: all network, data storage, and computing devices] based on [Assignment: organization-defined selectable event criteria] within [Assignment: organization-defined time thresholds].**

[need implementation details]

**CM-5: The organization defines, documents, approves, and enforces physical and logical access restrictions associated with changes to the information system.**

 [NOTE need implementation details; combination of Azure permissions + AD/local account permissions.]

**CM-5 (1): The information system enforces access restrictions and supports auditing of the enforcement actions.**

 [NOTE need implementation details; combination of Azure permissions + AD/local account permissions.] (Also see issue #10.)
