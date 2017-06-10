# Boundary Protection [AC-17 (3), SC-5, SC-7.a, SC-7.b, SC-7.c, SC-7 (3), SC-7 (5), SC-7 (11), SC-7 (12)]
This Azure Blueprint solution routes all remote accesses through [ managed network access control points -- Remote access to the web application is through an application gateway that includes a web application firewall and load balancing capabilities. Remote access to all other resources is through a JumpBox or Bastion Host. Deployed virtual machines supporting the web tier, database tier, and AD are also deployed in a scalable availability set.

This Azure Blueprint solution deploys a set of network security groups that can be configured to control commutations at external boundaries and between internal subnets. Network security group event and diagnostic logs are collected by OMS Log Analytics to allow customer monitoring.

The architecture related to this solution is made up of a virtual network with a separate subnet for  web, database, Active Directory, and management computers. Subnets are logically separated by network security group rules applied to the individual subnets to restrict traffic between subnets to only that necessary for system and management functionality (e.g., external traffic cannot access the database, management, or Active Directory subnets).

The application gateway used in this solution is deployed with a Web Application firewall. WAF logs are integrated with Azure Monitor to track WAF alerts and logs and easily monitor trends. Customization of the WAF firewall can be done by following [this documentation](https://docs.microsoft.com/en-us/azure/application-gateway/application-gateway-customize-waf-rules-portal). Application Gateway actively blocks intrusions and attacks detected by its rules. The attacker receives a 403 unauthorized access exception and the connection is terminated. Prevention mode continues to log such attacks in the WAF.

###Configuration
- WAF Mode: Prevention
- WAF Rule Set Type: OWASP
- WAF Rule Set Version: 3.0
  - REQUEST-910-IP-REPUTATION	Contains rules to protect against known spammers or malicious activity.
  - REQUEST-911-METHOD-ENFORCEMENT	Contains rules to lock down methods (PUT, PATCH< ..)
  - REQUEST-912-DOS-PROTECTION	Contains rules to protect against Denial of Service (DoS) attacks.
  - REQUEST-913-SCANNER-DETECTION	Contains rules to protect against port and environment scanners.
  - REQUEST-920-PROTOCOL-ENFORCEMENT	Contains rules to protect against protocol and encoding issues.
  - REQUEST-921-PROTOCOL-ATTACK	Contains rules to protect against header injection, request smuggling, and response splitting
  - REQUEST-930-APPLICATION-ATTACK-LFI	Contains rules to protect against file and path attacks.
  - REQUEST-931-APPLICATION-ATTACK-RFI	Contains rules to protect against Remote File Inclusion (RFI)
  - REQUEST-932-APPLICATION-ATTACK-RCE	Contains rules to protect again Remote Code Execution.
  - REQUEST-933-APPLICATION-ATTACK-PHP	Contains rules to protect against PHP injection attacks.
  - REQUEST-941-APPLICATION-ATTACK-XSS	Contains rules for protecting against cross site scripting.
  - REQUEST-942-APPLICATION-ATTACK-SQLI	Contains rules for protecting against SQL injection attacks.
  - REQUEST-943-APPLICATION-ATTACK-SESSION-FIXATION	Contains rules to protect against Session Fixation Attacks.
- 1 NSG for WEB Tier
- 1 NSG for Active Directory
- 1 NSG for SQL
- 1 NSG for MGT / JumpBox
