# Key Vault / Key Management

## Implementation and Configuration
This Azure Blueprint Solution implements Key Vault to protect authenticator content from unauthorized disclosure and modification. Azure Key Vault helps safeguard cryptographic keys and secrets used by cloud applications and services. Azure Key Vault can generate keys using a FIPS 140-2 level 2 hardware security module (HSM) key generation capability.

There is no use of unencrypted static authenticators embedded in applications, access scripts, or function keys deployed by this Azure Blueprint Solution. Any script or application that uses an authenticator makes a call to an Azure Key Vault container prior to each use. Access to Azure Key Vault containers is audited, which allows detection of violations of this prohibition if a service account is used to access a system without a corresponding call to the Azure Key Vault container

A Key Vault is deployed as a part of the predeployment process -- [see script here](https://github.com/AppliedIS/azure-blueprint/blob/master/predeploy/Orchestration_InitialSetup.ps1)

As a part of the predeployment process, specific keys are uploaded to the key vault that will be needed for the rest of the deployment process

### Keys Uploaded to Key Vault

1) Azure Username - username that will be used for specific DSC configuration scripts used to manipulate and configure Azure resources
2) Azure Password - password associated with Azure Username
3) Admin Password - password used for Administrator accounts on all machines
4) Encryption Key Url - key URL need for disk encryption
5) Azure Active Directory Client ID
6) Azure Active Directory Client Secret

## Compliance Documentation
