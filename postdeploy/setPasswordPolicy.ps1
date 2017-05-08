Enable-PSRemoting -Force
$Domain = (gwmi WIN32_ComputerSystem).Domain

Import-Module ActiveDirectory

#Provide Domain admin credentials
$User='aisadmin'
$Password='Azuresample123$'
$UserDomain=$Domain+í\í+$User
$SecurePassword=Convertto-SecureString ñString $Password ñAsPlainText ñforce

#PS credentials
$AdminCredentials=New-object System.Management.Automation.PSCredential $UserDomain,$SecurePassword

#this etting errors out
#Setting password policy
#Set-ADDefaultDomainPasswordPolicy -Identity $Domain -AuthType Basic -Credential $AdminCredentials -MaxPasswordAge 60.00:00:00 -MinPasswordAge 1.00:00:00 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $true -MinPasswordLength 14


#Setting password policy for domain users- with auth type as "Negotiate"
#this does not error out
Set-ADDefaultDomainPasswordPolicy -Identity $domain -AuthType Negotiate -MaxPasswordAge 60.00:00:00 -MinPasswordAge 1.00:00:00 -PasswordHistoryCount 24 -ComplexityEnabled $true -ReversibleEncryptionEnabled $true -MinPasswordLength 14



#all users in the AD should change password at next logon
#$users= get-aduser -Filter * -SearchBase "CN=Users,DC=$Domain,DC=com"
$users= get-aduser -Filter *
ForEach($user in $users)
    {

       Set-ADUser -PasswordNeverExpires $False -ChangePasswordAtLogon $true -Identity $user -Confirm:$false -WhatIf:$false -ErrorAction Stop
                Write-Verbose -Message 'Change password at logon set to True'

    }
