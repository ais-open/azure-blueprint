## This Deletes all protected item Containers and Recovery Points for an array of Recovery Services Vaults.
## If you do not want to delete all protected items in the vaults then the script will need to be adjust to filter only the specified items

Import-Module AzureRm
Add-AzureRmAccount -EnvironmentName AzureUSGovernment


Select-AzureRmSubscription -SubscriptionId "9876753f-ae2e-46ef-b58a-2ddda6937ea3"

$rcvNames = @("AZ-RCV-01")

for($i=0;$i -lt $rcvNames.Length;$i++){
    $vault = Get-AzureRmRecoveryServicesVault | ?{$_.Name -eq $rcvNames[$i]}
    Set-AzureRmRecoveryServicesVaultContext -Vault $vault

    $containers = Get-AzureRmRecoveryServicesBackupContainer -ContainerType AzureVM -BackupManagementType AzureVM
    $containers | %{
        $item = Get-AzureRmRecoveryServicesBackupItem -Container $_ -WorkloadType AzureVM
        Disable-AzureRmRecoveryServicesBackupProtection -Item $item -RemoveRecoveryPoints -Force -Verbose
    }
}
