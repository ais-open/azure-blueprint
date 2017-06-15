# Offload to Log Analytics [AU-4, AU-4 (1), AU-5 (1), AU-6 (3), AU-6 (4), AU-7.a, AU-7.b, AU-7 (1), AU-9 (2), AU-11, AU-12 (1), SC-7.a]

## Compliance

**AU-4: The organization allocates audit record storage capacity in accordance with [Assignment: organization-defined audit record storage requirements].**

This control is related to AU-11, which requires audit records be retained for 1 year. This retention period is maintained by OMS. Local audit storage capacity should be configured accordingly. OMS audit storage capacity is configured to retain for a minimum of 1 year. This Azure Blueprint Solution allocates sufficient storage capacity to retain audit records for a period of one year. (Also see issue #11.)

**AU-4 (1): The information system off-loads audit records [Assignment: organization-defined frequency] onto a different system or media than the system being audited.**

[This Azure Blueprint Solution forwards audit records to OMS...] (Also see issue #11.)

**AU-5 (1): The information system provides a warning to [Assignment: organization-defined personnel, roles, and/or locations] within [Assignment: organization-defined time period (real-time)] when allocated audit record storage volume reaches [Assignment: organization-defined percentage (90%)] of repository maximum audit record storage capacity.**

[need implementation details] (Also see issue #11.)

**AU-6 (3): The organization analyzes and correlates audit records across different repositories to gain organization-wide situational awareness.**

This Azure Blueprint Solution implements OMS Log Analytics to centralize audit data across deployed resources, supporting organization-wide situational awareness.

**AU-6 (4): The information system provides the capability to centrally review and analyze audit records from multiple components within the system.**

[This Azure Blueprint Solution implements OMS Log Analytics to centralize audit data across deployed resources, supporting centralized review, analysis, and reporting.]

**AU-7.a: The information system provides an audit reduction and report generation capability that supports on-demand audit review, analysis, and reporting requirements and after-the-fact investigations of security incidents.**

[This Azure Blueprint Solution implements OMS Log Analytics. Log Analytics provides monitoring services for OMS by collecting data from managed resources into a central repository. Once collected, the data is available for alerting, analysis, and export.]

**AU-7.b: The information system provides an audit reduction and report generation capability that does not alter the original content or time ordering of audit records.**

[This Azure Blueprint Solution implements OMS Log Analytics. Log Analytics provides monitoring services for OMS by collecting data from managed resources into a central repository. The content and time ordering of audit records are not altered.]

**AU-7 (1): The information system provides the capability to process audit records for events of interest based on [Assignment: organization-defined audit fields within audit records].**

[This Azure Blueprint Solution implements OMS Log Analytics. Log Analytics provides monitoring services for OMS by collecting data from managed resources into a central repository. Once collected, the data is available for alerting, analysis, and export. Log Analytics includes a powerful query language to extract data stored in the repository.]

**AU-9 (2): The information system backs up audit records [Assignment: at least weekly] onto a physically different system or system component than the system or component being audited.**

[This Azure Blueprint Solution implements OMS Log Analytics. Log Analytics provides monitoring services for OMS by collecting data from managed resources into a central repository that is separate from the components being audited. Data is collected by OMS in near real-time.]

**AU-11: The organization retains audit records for [Assignment: at least one year] to provide support for after-the-fact investigations of security incidents and to meet regulatory and organizational information retention requirements.**

[This Azure Blueprint Solution implements OMS Log Analytics. Log Analytics provides monitoring services for OMS by collecting data from managed resources into a central repository. Once collected, the data retained for one year per Log Analytics configuration...] (Also see issue #11).

**AU-12 (1): The information system compiles audit records from [Assignment: all network, data storage, and computing devices] into a system-wide (logical or physical) audit trail that is time-correlated to within [Assignment: organization-defined level of tolerance for the relationship between time stamps of individual records in the audit trail].**

[This Azure Blueprint Solution implements OMS Log Analytics. Log Analytics provides monitoring services for OMS by collecting data from managed resources into a central repository. Audit record time stamps are not altered, therefore the audit trail is time-correlated.]

**SC-7.a: The information system monitors and controls communications at the external boundary of the system and at key internal boundaries within the system.**

This Azure Blueprint Solution deploys an Application Gateway, load balancer, and configures network security group rules to control commutations at external boundaries and between internal subnets. Application Gateway, load balancer, and network security group event and diagnostic logs are collected by OMS Log Analytics to allow customer monitoring. (Also see issue #31.)
