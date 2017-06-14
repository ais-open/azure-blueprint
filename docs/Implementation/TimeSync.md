#Time sync [AU-8.a, AU-8.b, AU-8 (1).a, AU-8 (1).b]

## Implementation and Configuration

##Compliance Documentation

**AU-8.a: The information system uses internal system clocks to generate time stamps for audit records.**

Resources deployed by this Azure Blueprint Solution use internal system clocks to generate time stamps for audit records.

NOTE: Need to address all components that generate audit records.

**AU-8.b: The information system records time stamps for audit records that can be mapped to Coordinated Universal Time (UTC) or Greenwich Mean Time (GMT) and meets [Assignment: organization-defined granularity of time measurement (one second)].**

Resources deployed by this Azure Blueprint Solution use internal system clocks to generate time stamps for audit records. Time stamps are recorded in UTC.

NOTE: Need to address all components that generate audit records.

**AU-8 (1).a: The information system compares the internal information system clocks [Assignment: at least hourly] with [Assignment: http://tf.nist.gov/tf-cgi/servers.cgi].**

Resources deployed by this Azure Blueprint Solution use internal system clocks to generate time stamps for audit records. Internal system clocks are configured to sync with an authoritative time source each hour.

 NOTE: Need to address all components that generate audit records.

**AU-8 (1).b: The information system synchronizes the internal system clocks to the authoritative time source when the time difference is greater than [Assignment: organization-defined time period]**

Resources deployed by this Azure Blueprint Solution use internal system clocks to generate time stamps for audit records. Internal system clocks are configured to sync with an authoritative time source each hour.] NOTE: Need to address all components that generate audit records.
