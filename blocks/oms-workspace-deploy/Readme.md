This is an ARM template which deploys OMS workspace in a resource group and several OMS solutions with it:  
•	Antimalware assessment  
•	Security and audit  
•	Update management   
•	SQL Assessment   
•	AD Assessment   


##Retains data for 1 year   

After deploying the workspace it deploys the OMS extension onto the all 5 VMs so that the VMs are connected to the provisioned workspace. 
