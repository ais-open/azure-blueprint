Azure deploy.json uses the ps1 file to deploy an extension to AD DC vm to set password restrcition on domain users.     
        
##What the script accomplishes:         
        1)Strong initial password       
        2)Minimum lifetime (1 day)      
        3)Maximum lifetime (60 days)    
        4)Complexity (14 char. length, AT LEAST 3 of the following types: upper case, lower case, number, special char.)        
        5)Reuse restrictions (24 generations)   
        6)Change at first logon requirement [do not enable in ref. arch.]- (Only optional -commented out)       
        7)Password strength enforcement 
        8)Storage/transmission encryption       

##What is NOT accomplished through the script:  
        1)Change entropy (at least 50%)         
        2)Complexity (14 char. length, at least one of each: upper case, lower case, number, special char.)     
        
        
##INSTRUCTIONS BEFORE EXECUTION:        
--1) From azuredeploy.json file: In the "fileuris" section: add proper path for the .ps1 script while running the ARM template          
--2) In protected settings section: IF ps1 file is kept in a storage account: Provide name and key for the account before running.


##Please test with following instructions:              
        
Step 1:         
                
1)Login to domain controller VM         
2)From Start Menu- go to active directory users and computers.          
3)Select domain->users folder           
On the right pane, right click->new->user.              
4)Create a new user by providing details such as first name, last name, userlogon name.         
5)Click Next-> create a new password and confirm the password. Uncheck "user must change password at next logon".               
The password you gave must: "have 14 char length, and AT LEAST 3 out of the 4 type of given characters: upper case, lower case, number, special char".          
6)Click Next-> click finish.            
                
Step 2:         
                
1)Login to domain controller VM           
2)From Start Menu->Run->GPEDIT.msc->ok          
3)Local computer policy->computer configuration->windows settings->security settings->account policies->password policy.                
The following should be the values:             
Enforce password history: 24 passwords remembered               
Maximum password age: 60 days           
Minimum password age: 1 day             
Minimum password length: 14 characters          
Password must meet complexity requirement: Enabled              
Store Passwords using reversible encryption: Enabled            
                
                
