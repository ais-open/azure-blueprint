<#
    .DESCRIPTION
        This Runbook changes the WordPress configuration by replacing the wp-config.php and replace it with wp-config.php.Azure. 
        The old file will get renamed as wp-config.php.onprem
        This is an example script used in blog https://azure.microsoft.com/en-us/blog/one-click-failover-of-application-to-microsoft-azure-using-site-recovery

        This runbook uses an external powershellscript located at https://raw.githubusercontent.com/ruturaj/RecoveryPlanScripts/master/ChangeWPDBHostIP.ps1
        and runs it inside all of the VMs of the group this script is added to.

        Parameter to change -
            $recoveryLocation - change this to the location to which the VM is recovering to
            
    .NOTES
        AUTHOR: RuturajD@microsoft.com
        LASTEDIT: 27 March, 2017
#>


workflow AutomationRunbooks
{
    param (
        [parameter(Mandatory=$false)]
        [Object]$RecoveryPlanContext
    )

	$connectionName = "AzureRunAsConnection"
    
    

    # This is special code only added for this test run to avoid creating public IPs in S2S VPN network
    #if ($RecoveryPlanContext.FailoverType -ne "Test") {
    #    exit
    #}

	try
	{
		# Get the connection "AzureRunAsConnection "
		$servicePrincipalConnection=Get-AutomationConnection -Name $connectionName         

        

		"Logging in to Azure..."
		#Add-AzureRmAccount `
        Login-AzureRmAccount `
			-ServicePrincipal `
			-TenantId $servicePrincipalConnection.TenantId `
			-ApplicationId $servicePrincipalConnection.ApplicationId `
			-CertificateThumbprint $servicePrincipalConnection.CertificateThumbprint 
	}
	catch {
		if (!$servicePrincipalConnection)
		{
			$ErrorMessage = "Connection $connectionName not found."
			throw $ErrorMessage
		} else{
			Write-Error -Message $_.Exception
			throw $_.Exception
		}
	}   
    

    #Write-Host 'Please log into Azure now' -foregroundcolor Green;
    #Login-AzureRmAccount -ErrorAction "Stop" 1> $null;

    <#if($subscriptionId)
    {
        Select-AzureRmSubscription -SubscriptionId $subscriptionId;
    }
#>

########################################################################################################################
# Section2:  Get Hybrid Worker Group Name
########################################################################################################################

    $ResourceGroupName = 'AzureTest2'
    $AutomationAccountName = 'TeatAutoAcc'
    $ScheduleName = "MyTestScheduleName"

    "Get Hybrid Worker Group Name ..."

    $HybridWorkerGroups = Get-AzureRMAutomationHybridWorkerGroup -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

    # Wait for Hybrid Workers Provision
    if($HybridWorkerGroups -eq ""){
        $timeout = new-timespan -Minutes 5
        $sw = [diagnostics.stopwatch]::StartNew()
        while ($sw.elapsed -lt $timeout){
            $HybridWorkerGroups = Get-AzureRMAutomationHybridWorkerGroup -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName

            if ($HybridWorkerGroups -ne ""){
                #write-host "Hybrid Workers Provisioned!"
                return
            }
        
            start-sleep -seconds 5
        }
        
        #write-host "Timed out"
    }

    $computerIdList="";
    foreach ($worker in $HybridWorkerGroups){
        #Write-Host "Name: $($worker.name)";
        $computerIdList = $computerIdList + $worker.name + "=Windows;"
    }

    if($computerIdList -ne "" -and $computerIdList -match '.+?;$'){       

        # Remove the last Character
        $computerIdList = $computerIdList.Substring(0,$computerIdList.Length-1)
        #Write-Host "ComputerIdList: $($computerIdList)" -foregroundcolor Green;
    }
    else{
        #Write-Host "ComputerIdList: $($computerIdList)";
    }

########################################################################################################################
# Section2: Automation Account Variable
########################################################################################################################
    $VariableName = "ComputerIdList"
    "Setting Automation Account Variable ... "
    if(-not (Get-AzureRmAutomationVariable -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName | Where-Object { $_.Name -eq $VariableName } ) ){
        #Write-Host "Create new Azure Automation Account Variable with name = $($VariableName)" -foregroundcolor Green
        New-AzureRmAutomationVariable -Name $VariableName -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Encrypted $false -Value $computerIdList
    }
    else{
        #Write-Host "Update Azure Automation Account Variable name = $($VariableName)" -foregroundcolor Yellow
       Set-AzureRmAutomationVariable -Name $VariableName -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Encrypted $false -Value $computerIdList
    }	


    $StartTime = (Get-Date).AddMinutes(6)

    New-AzureRmAutomationSchedule -Name $ScheduleName -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -StartTime $StartTime -HourInterval 1

    $Params = @{
        "Duration" = "04:00:00";
        "ScheduleName"= $ScheduleName;
        "WorkspaceId"= $AutomationAccountName;
        "ComputerIdList"= $computerIdList
    }

    #$LinkedSchedule = Register-AzureRmAutomationScheduledRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -RunbookName "Patch-MicrosoftOMSComputers" -ScheduleName $ScheduleName -Parameters $Params

    #$runbook = Get-AzureRmAutomationScheduledRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -JobScheduleId $LinkedSchedule.JobScheduleId

}