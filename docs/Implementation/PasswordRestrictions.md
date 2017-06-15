# Password Restrictions

## Implementation and Configuration
Password Restriction controls are met by applying a domain Group Policy that is applied to every computer in the domain. The domain Group Policy is applied by a PowerShell script deployed through a Windows Azure Custom Script Extension. The script can be found [here](https://github.com/AppliedIS/azure-blueprint/blob/master/postdeploy/setPasswordPolicy.ps1). This provides a set of restrictions for any profiles created after deployment.
Validation is done for admin account creation through an PowerShell script that can be found [here](https://github.com/AppliedIS/azure-blueprint/blob/master/predeploy/checkPassword.ps1).

### Group Domain Policy
- Configurations to the Group Domain Policy must be made in [setPasswordPolicy.ps1](https://github.com/AppliedIS/azure-blueprint/blob/master/postdeploy/setPasswordPolicy.ps1)).

Restrictions applied:
- Minimum lifetime (1 day)
- Maximum lifetime (60 days)
- Complexity (14 char. length, at least one of each: upper case, lower case, number, special char.)
- Reuse restrictions (24 generations)
- Storage/transmission encryption
- Strong initial password
- Password strength enforcement
- [RDP connection encryption (high)](https://technet.microsoft.com/en-us/library/ff458357.aspx)

### Initial Admin Account
- Configurations to initial admin account password restrictions can be made in [checkPassword.ps1](https://github.com/AppliedIS/azure-blueprint/blob/master/checkPassword.ps1).

\* Password change entropy is not applied

### Initial admin user accounts.
- Complexity (14 char. length, at least one of each: upper case, lower case, number, special char.)
- No blank passwords
- No spaces

## Compliance Documentation
