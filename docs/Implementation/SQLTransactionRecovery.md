# SQL Transaction Recovery
This request enables the **Automated backup** feature for the IaaS Sql server VM. The automated backup uses the feature lets us configure the backup storage location, retention period and the encryption credentials.  However the time to backup and frequency are decided by Azure based on the usage. [this link](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/sql/virtual-machines-windows-sql-automated-backup ) identifies the Automated backup reference.

## Implementation and Configuration
- Retention Period
- Storage Account
- Enable Encryption(this is to enable encryption of the Database backups at rest)
- Credential (This is needed when Encryption is enabled)

The Automated backup feature may be enabled from the 'SQL Server Configuration' tab inside the IaaS SQL Server VM in Azure portal or by using the IaaS Extension using powershell.

To verify if the Automated backup has been enabled for the IaaS Sql Server VM
1) Goto the Storage Account --> Containers
2)  Check the **automaticbackup** folder. This folder will contain the .cer, .pvk, .key files for the backup
3)  There will be another folder with the name <<IaasSqlServerVM>>-mssqlserver. Replace <<IaasSqlServerVM>>-with the IaaS Sql Server VM name.
4) Login to the Sql server VM and connect to SSMS
5) In Security --> Credentials, a new credential will be added with the name 'AutoBackup_Credential'
6) Create a new database in the Sql Server
7) In Storage Account --> Containers --> <<IaasSqlServerVM>>-mssqlserver, the .bak(backup file) and .log(log files) will be written to the storage account
8) .Bak and .Log files are then written as per SQL Server load.

## Compliance Documentation
