# Operating System Baseline [CM-5 (3), CM-6.a, CM-6.b, CM-6.d, CM-6 (1), CM-6 (2), CM-7.a, CM-7.b, SC-7 (12), SI-2.c]

## Compliance

**CM-5 (3): The information system prevents the installation of [Assignment: organization-defined software and firmware components] without verification that the component has been digitally signed using a certificate that is recognized and approved by the organization. Software and firmware components prevented from installation unless signed with recognized and approved certificates include, for example, software and firmware version updates, patches, service packs, device drivers, and basic input output system (BIOS) updates. Digital signatures and organizational verification of such signatures, is a method of code authentication.**

[NOTE: need implementation details; likely implementation limited to Windows update patches.]

**CM-6.a: The organization establishes and documents configuration settings for information technology products employed within the information system using [Assignment: USGCB, CIS, or organizaiton-defined] that reflect the most restrictive mode consistent with operational requirements.**

 NOTE: For consideration: https://docs.microsoft.com/en-us/windows/device-security/windows-security-baselines

**CM-6.b: The organization implements the configuration settings.**

NOTE: For consideration: https://docs.microsoft.com/en-us/windows/device-security/windows-security-baselines (Also see issue #22.)

**CM-6.d: The organization monitors and controls changes to the configuration settings in accordance with organizational policies and procedures.**

[This Azure Blueprint Solution deploys Azure Automation DSC. Automation DSC aligns machine configurations with a specific organization-defined configuration.]

**CM-6 (1): The organization employs automated mechanisms to centrally manage, apply, and verify configuration settings for [Assignment: organization-defined information system components].**

[This Azure Blueprint Solution deploys Azure Automation DSC. Automation DSC aligns machine configurations with a specific organization-defined configuration and continually monitors for changes.]

**CM-6 (2): The organization employs [Assignment: organization-defined security safeguards] to respond to unauthorized changes to [Assignment: organization-defined configuration settings].**

[This Azure Blueprint Solution deploys Azure Automation DSC. Part of Azure's Operations Management Suite (OMS), Automation DSC can be configured to generate an alert or to remedy misconfigurations when detected.]

**CM-7.a: The organization configures the information system to provide only essential capabilities.**

[The resources deployed by this Azure Blueprint Solution are configured to provide the least functionality for their intended purpose.] NOTE: This requirement extends beyond operating systems; should I create a separate issue to track? (Also see issue #22.)

**CM-7.b: The organization prohibits or restricts the use of the following functions, ports, protocols, and/or services: [Assignment: organization-defined prohibited or restricted functions, ports, protocols, and/or services].**

[The resources deployed by this Azure Blueprint Solution are configured to restrict the use of functions, ports, protocols, and services to provide only the functionality intended. Azure Application Gateway and network security groups are deployed to restrict the use of ports and protocols to only those necessary.] NOTE: This requirement extends beyond operating systems (also see above). (Also see issue #22.)

**SC-7 (12): The organization implements [Assignment: organization-defined host-based boundary protection mechanisms] at [Assignment: organization-defined information system components].**

[Virtual machines deployed by this Azure Blueprint Solution are configured with a host-based firewall enabled.] (Also see issue #31.)

**SI-2.c: The organization installs security-relevant software and firmware updates within [Assignment: 30 days] of the release of the updates.**

Windows virtual machines deployed by this Azure Blueprint Solution are configured by default to receive automatic updates from Windows Update Service. This solution also deploys the OMS Automation & Control solution through which Update Deployments can be created to deploy patches to Windows servers when needed. (Also see issue #23.)
