Param (
 [Parameter(Mandatory=$true)]
[String] $SubscriptionId,

[Parameter(Mandatory=$true)]
[String] $ApplicationDisplayName,

[string]$backupKeyVaultName

)


 function Create-AesManagedObject($key, $IV) {

   $aesManaged = New-Object "System.Security.Cryptography.AesManaged"
   $aesManaged.Mode = [System.Security.Cryptography.CipherMode]::CBC
   $aesManaged.Padding = [System.Security.Cryptography.PaddingMode]::Zeros
   $aesManaged.BlockSize = 128
   $aesManaged.KeySize = 256

   if ($IV) {
       if ($IV.getType().Name -eq "String") {
           $aesManaged.IV = [System.Convert]::FromBase64String($IV)
       }
       else {
           $aesManaged.IV = $IV
       }
   }

   if ($key) {
       if ($key.getType().Name -eq "String") {
           $aesManaged.Key = [System.Convert]::FromBase64String($key)
       }
       else {
           $aesManaged.Key = $key
       }
   }

   $aesManaged
}

function Create-AesKey() {
   $aesManaged = Create-AesManagedObject
   $aesManaged.GenerateKey()
   [System.Convert]::ToBase64String($aesManaged.Key)
}


#Uncomment for authentication if running independently
#Add-AzureRmAccount -EnvironmentName "AzureUSGovernment"
#Select-AzureRmSubscription -SubscriptionId $SubscriptionId


$app = Get-AzureRmADApplication -DisplayNameStartWith $ApplicationDisplayName

if(!$app) {
#Create the 44-character key value
$keyValue = Create-AesKey
$psadCredential = New-Object "Microsoft.Azure.Commands.Resources.Models.ActiveDirectory.PSADPasswordCredential"
$startDate = Get-Date
$psadCredential.StartDate = $startDate
$psadCredential.EndDate = $startDate.AddYears(1)
$psadCredential.KeyId = [guid]::NewGuid()
$psadCredential.Password = 'adfadf$%TR$#t'



$newId = (New-Guid).Guid
$Application = New-AzureRmADApplication -DisplayName $ApplicationDisplayName -HomePage ("http://" + $ApplicationDisplayName) -IdentifierUris ("http://" + $newId) -PasswordCredentials $psadCredential

Write-Output "Azure AD application with Id: $($Application.ApplicationId) created successfully."

$newClientApp = Get-AzureRmADApplication -ApplicationId "$($Application.ApplicationId)" -ErrorAction SilentlyContinue
$clientAppRetries = 0;
 While ($newClientApp -eq $null -and $clientAppRetries -le 6)
{
       sleep 5
       $newClientApp = Get-AzureRmADApplication -ApplicationId "$($Application.ApplicationId)" -ErrorAction SilentlyContinue
       $clientAppRetries++;
}

New-AzureRMADServicePrincipal -ApplicationId $Application.ApplicationId | Write-Verbose
Get-AzureRmADServicePrincipal | Where {$_.ApplicationId -eq $Application.ApplicationId} | Write-Verbose

$NewRole = $null
$Retries = 0;
While ($NewRole -eq $null -and $Retries -le 6)
{
   # Sleep here for a few seconds to allow the service principal application to become active (should only take a couple of seconds normally)
   Sleep 5
   Try {
       New-AzureRMRoleAssignment -RoleDefinitionName "Automation Operator" -ServicePrincipalName $Application.ApplicationId | Write-Verbose -ErrorAction SilentlyContinue
   }
   Catch {
       Write-Output "Service Principal not yet active, delay before adding the the role assignment."
   }
   Sleep 10
   $NewRole = Get-AzureRMRoleAssignment -ServicePrincipalName $Application.ApplicationId -ErrorAction SilentlyContinue
   $Retries++;
}

Write-Output "Azure AD application - $($ApplicationDisplayName) - and service principal with role assignment(s) created."

if($backupKeyVaultName){
   Try {
       $AppIdSecretValue = ConvertTo-SecureString -String $Application.ApplicationId -AsPlainText –Force
       $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name  "$($ApplicationDisplayName)AppId" -Destination 'Software'
       $AppIdsecret = Set-AzureKeyVaultSecret -VaultName $backupKeyVaultName -Name "$($ApplicationDisplayName)AppId" -SecretValue $AppIdSecretValue
   }
   Catch {
       $ErrorMessage = $_.Exception.Message
       Write-Output "App Id Secret not written to backup key vault for client service principal: $($ErrorMessage)"
   }
   Try {
       $KeySecretValue = ConvertTo-SecureString -String $keyValue -AsPlainText –Force
       $key = Add-AzureKeyVaultKey -VaultName $keyVaultName -Name  "$($ApplicationDisplayName)Key"  -Destination 'Software'
       $KeyValuesecret = Set-AzureKeyVaultSecret -VaultName $backupKeyVaultName -Name "$($ApplicationDisplayName)Key" -SecretValue $KeySecretValue
   }
   Catch {
       Write-Output "Key Value Id Secret not written to backup key vault for client service principal: $($ErrorMessage)"
   }
}

} else {
   Write-Output "Application with that name already exists in the tenant, please try again."
}
