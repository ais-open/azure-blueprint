# Application Configuration e.g SQL Server

The Azure Key Vault Integration feature for the Sql Server Configuration is enabled.
This feature is used to register the Azure Key Vault and the credentials to the SQL Server. This can later be used to create Asymmetric keys in the Azure Key vault and use the keys to encrypt the databases.

# Configuration
a) Key Vault Url
b) Principal Name
c) Principal Secret
d) Credential Name

This feature can be enabled using the 'SQL Server Configuration' tab on the Iaas SQL VM or using Powershell by installing the IaaS extension.

To verify that the Key Vault integration is enabled follow the steps below:
1) Login to the SQL Server VM and connect to the SSMS
2) Check Security --> Credentials. The newly added credential should be visible in the Credentials
3) Check Security --> Cryptographic Providers. The entry for the addition of the Azure Key Vault is present here.
