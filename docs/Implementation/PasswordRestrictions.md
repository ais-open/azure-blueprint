# Password Restrictions
Password Restriction controls are met by applying a domain Group Policy that is applied to every computer in the domain. The domain Group Policy is applied by a PowerShell script deployed through a Windows Azure Custom Script Extension. The script can be found [here](../../postdeploy/setPasswordPolicy.ps1). This provides a set of restrictions for any profiles created after deployment.
Validation is done for admin account creation through an PowerShell script that can be found [here](../../predeploy/checkPassword.ps1).

## Configuration
#### Group Domain Policy
- Configurations to the Group Domain Policy must be made in [setPasswordPolicy.ps1](../../postdeploy/setPasswordPolicy.ps1)).

#### Initial Admin Account
- Configurations to initial admin account password restrictions can be made in [checkPassword.ps1](../../predeploy/checkPassword.ps1).

## Group Domain Policy
Restrictions applied:
- Minimum lifetime (1 day)
- Maximum lifetime (60 days)
- Complexity (14 char. length, at least one of each: upper case, lower case, number, special char.)
- Reuse restrictions (24 generations)
- Storage/transmission encryption
- Strong initial password
- Password strength enforcement
- [RDP connection encryption (high)](https://technet.microsoft.com/en-us/library/ff458357.aspx)

\* Password change entropy is not applied

## Initial admin user accounts.
- Complexity (14 char. length, at least one of each: upper case, lower case, number, special char.)
- No blank passwords
- No spaces
