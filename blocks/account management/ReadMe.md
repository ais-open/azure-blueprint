For Harun: This script should be applied as a custom script extension on domain controller.  
In the last line of this script: reboot is required for group policies to be applied-     
Please apply that only at the end of script to avoid any issues. (it is commented out right now)    
  
   

##What script accomplishes:   
##What to test:  

1. Sets account lockout policies:  
-On entering wrong password account locks out after 3 attempts.  
-After each unsuccessful attempt to login- lockout period is 15 minutes.   
-After 3 unsusccessful attempts to login, lokcout period id 3 hours.   
  
2. Inactive session policies:   
-RDP session gets locked after 15 minutes of inactivity.   
-User needs to enter password (authenticate again) to log back in.     
  
3. Disbales inactive active directory user account after 35 days of inactivity. 
The script adds a powershell scirpt at location "c:\scripts\Windows-PowerShell\disableinactiveaccounts.ps1",   
which is scheduled to run everyday via task scheduler automatically.   
(For testing: Go to start->Task scheduler-> search for the task "Inactive accounts script" on the left menu,   
and check if it scheduled to run at 4 am everyday.)  
 
  
4. Shows a logon message when you login to the VM using RDP.  
You have to click on "OK" displayed under the message to login to the session.  
  
5. When you signout by going on 'start->user->signout', it will display message "signing out" 
to authenticate your successful logout and terminate the user session.  
  

  
############################# 
  
