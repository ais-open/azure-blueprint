# Audit protection against altering records, purging [AU-9, AU-9 (3)]

## Compliance

**AU-9: The information system protects audit information and audit tools from unauthorized access, modification, and deletion.**

* need to address at the OS-level, for OMS, and anywhere else audit data is available (Also see issues #14, #19.)

Logical access controls are used to protect audit information and tools within this Azure Blueprint Solution from unauthorized access, modification, and deletion. Azure Active Directory enforces approved logical access using Active Directory policies and role-based group memberships. The ability to view audit information and use auditing tools is limited to users that require these permissions.

AU-9 (3): The information system implements cryptographic mechanisms to protect the integrity of audit information and audit tools. [need implementation details (e.g., transfer of audit data to OMS is via encrypted channel, OMS records are encrypted at rest, etc.)]
