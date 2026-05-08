## Azure ExpressRoute Port Deployment Module

This module helps you deploy an Azure ExpressRoute Port and its related dependencies. Before using this module, review the official Azure [ExpressRoute Documentation](https://learn.microsoft.com/en-us/azure/expressroute/expressroute-introduction).

> [!IMPORTANT]
> As the overall [AVM](https://aka.ms/avm) (Azure Verified Modules) framework is not yet GA (Generally Available), the CI (Continuous Integration) framework and test automation may not be fully functional across all supported languages. **Breaking changes** are possible.
>
> However, this **DOES NOT** imply that the modules are unusable. These modules **CAN** be used in all environments, including dev, test, and production. Treat them as you would any other Infrastructure-as-Code (IaC) module, and review release notes before upgrading to newer versions.

## Resources Deployed by this Module
- ExpressRoute Port
- ExpressRoute Port Authorization
- Resource Lock
- IAM (Identity and Access Management)
- Diagnostic Settings (Metrics)

## Deployment Process

1. **Deploy the ExpressRoute Port**: Start by deploying the port with the required physical and encryption configuration.

2. **Configure Access and Integrations**: Add role assignments, locks, managed identities, and diagnostics as needed.

3. **Use with Circuit Workflows**: When your scenario includes circuit connectivity, pair this module with the AVM ExpressRoute Circuit module.

## Example

For a complete end-to-end usage reference, see the default example in [examples/default](examples/default).

## Feedback
We welcome your feedback. If you encounter issues or have feature requests, open an issue in this module repository.

---
