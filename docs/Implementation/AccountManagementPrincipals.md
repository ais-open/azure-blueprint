# Account Management Principals [AC-2 (3), AC-7.a, AC-7.b, AC-8.a, AC-8.b, AC-10, AC-11.a, AC-11.b, AC-11 (1), AC-12, AC-12 (1).a, AC-12 (1).b, IA-4.e]

# Compliance

**AC-2 (3): The information system automatically disables inactive accounts after [Assignment: 35 days for user accounts].**

All users account types implemented by this Azure Blueprint Solution (see AC-2.a) are configured to be disable after 35 days of inactivity.

**AC-7.a: The information system enforces a limit of [Assignment: not more than three] consecutive invalid logon attempts by a user during a [Assignment: 15 minute time period].**

The Azure portal limits consecutive invalid logon attempts by users. An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy limits consecutive invalid logon attempts by users to not more than three within a 15 minute period.

**AC-7.b: The information system automatically [Selection: locks the account/node for an [Assignment: a minimum of three hours]; locks the account/node until released by an administrator; delays next logon prompt according to [Assignment: organization-defined delay algorithm]] when the maximum number of unsuccessful attempts is exceeded.**

The Azure portal locks accounts after [...] consecutive invalid logon attempts by users. An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy locks accounts for three hours after three consecutive invalid logon attempts by users.

**AC-8.a: The information system displays to users [Assignment: organization-defined system use notification message or banner] before granting access to the system.**

An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements a system use notification that is displayed to users prior to login. NOTE: This solution will implement an example notification banner that the customer will customize to meet their organization requirements e.g., "Sample system use notification. Customer must edit this text to comply with customer organization and/or regulatory body requirements."


**AC-8.b: The information system retains the notification message or banner on the screen until users acknowledge the usage conditions and take explicit actions to log on to or further access the information system.**

An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements a system use notification that is displayed to users prior to logon. The user must acknowledge the notification in order to log in.

**AC-10: The information system limits the number of concurrent sessions for each [Assignment: organization-defined account and/or account type] to [Assignment: three sessions for privileged accounts; two sessions for non-privileged accounts].**

[An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements concurrent session restrictions (three sessions for privileged accounts two sessions for non-privileged accounts).]

**AC-11.a: The information system prevents further access to the system by initiating a session lock after [Assignment: 15 minutes] of inactivity or upon receiving a request from a user.**

An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements an inactivity session lock. Users may manually initiate the lock.

**AC-11.b: The information system retains the session lock until the user reestablishes access using established identification and authentication procedures.**

An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements an inactivity session lock. Users must reauthenticate to unlock the session.

**AC-11 (1): The information system conceals, via the session lock, information previously visible on the display with a publicly viewable image.**

[An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements an inactivity session lock. The session lock conceals information previously visible.

**AC-12: The information system automatically terminates a user session after [Assignment: organization-defined conditions or trigger events requiring session disconnect].**

NOTE: FedRAMP does not provide conditions to trigger a session disconnect; possible implementations include RDP session inactivity. [TBD: An operating system policy is implemented for virtual machines deployed by this Azure Blueprint Solution. The policy implements session termination after a period of inactivity.

**AC-12 (1).a: The information system provides a logout capability for user-initiated communications sessions whenever authentication is used to gain access to [Assignment: organization-defined information resources].**

The Azure portal and virtual machine operating systems deployed by this Azure Blueprint Solution enable uses to initiate a logout.

**AC-12 (1).b: The information system displays an explicit logout message to users indicating the reliable termination of authenticated communications sessions.**

[The Azure portal and virtual machine operating systems deployed by this Azure Blueprint Solution enable uses to initiate a logout. The logout process provides indication to the users that the session has been terminated.]

**IA-5.e: The organization manages information system identifiers by disabling the identifier after [Assignment: 35 days of inactivity].**

[All accounts within Azure Active Directory are configured to automatically be disabled after 35 days of inactivity.]
