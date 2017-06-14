# Restrictions on audit configurations / tools [AU-9, AU-9 (4)]

**AU-9: The information system protects audit information and audit tools from unauthorized access, modification, and deletion.**

 [Logical access controls are used to protect audit information and tools within this Azure Blueprint Solution from unauthorized access, modification, and deletion. Azure Active Directory enforces approved logical access using Active Directory policies and role-based group memberships. The ability to view audit information and use auditing tools is limited to users that require these permissions.] need to address at the OS-level, for OMS, and anywhere else audit data is available (Also see issue #13, #19.)

**AU-9 (4): The organization authorizes access to management of audit functionality to only [Assignment: organization-defined subset of privileged users].**

[Azure Active Directory restricts the management of audit functionality to members of the appropriate security groups. Only personnel with a specific need to access the management of audit functionality are granted these permissions within this Azure Blueprint Solution.] (Also see issue #19.)
