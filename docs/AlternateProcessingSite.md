# Alternate Processing Site

The following steps will describe how to setup a N-tier application infrastructure in multiple Azure regions to achieve high availability and a robust disaster recovery system.

1. Deploy n-tier application to the "US Gov Virginia" region using the [README](https://github.com/AppliedIS/azure-blueprint/new/master/README.md) of this repository as a guide.
2. Deploy a second n-tier application to the "US Gov Iowa" region using the [README](https://github.com/AppliedIS/azure-blueprint/new/master/README.md) of this repository as a guide.
3. Deploy Vnet Gateway for applications in both regions
4. Deploy connections
5. Deploy Traffic Manager

