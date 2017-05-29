This is an ARM template which deploys OMS workspace in a resource group and several OMS solutions with it:  
•	Antimalware assessment  
•	Security and audit  
•	Update management   
•	SQL Assessment   
•	AD Assessment   


##Retains data for 1 year   

After deploying the workspace it deploys the OMS extension onto the all 5 VMs so that the VMs are connected to the provisioned workspace. 


##Has logical disk space alert configured for low disk space in VMs


Testing instructions:   
1) Go to the resource group where OMS is deployed.    
2) You will fina resource of Type "log analytics". Open that resource.    
3) In OMS workspace section on the left menu, you will find a link to "OMS portal". Click on the link- it will redirect you to OMS portal containing solutions.   
4) On OMS home page, you will find the follwing solutions listed as tiles:    
•	Antimalware assessment      
•	Security and audit      
•	Update management     
•	SQL Assessment      
•	AD Assessment       
      
5) On the same page, Click on settings: select"alerts".   
6) You will find an alert with following details:   
      Name: Logical Disk space quota critical   
      Recipient: <some email id>    
      threshold: < 15   
      frequency:15 min    
      timewindow: 60 min	    
      Saved search: logical disk: free disk size    
      Status: ON    
7)On The settings pane-> go to connnected sources-> make sure the VMs in the resource groups are mentioned in the connected resources.    
