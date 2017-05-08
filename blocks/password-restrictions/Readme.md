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
