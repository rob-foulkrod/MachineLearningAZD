[comment]: <> (please keep all comment items at the top of the markdown file)
[comment]: <> (please do not change the ***, as well as <div> placeholders for Note and Tip layout)
[comment]: <> (please keep the ### 1. and 2. titles as is for consistency across all demoguides)
[comment]: <> (section 1 provides a bullet list of resources + clarifying screenshots of the key resources details)
[comment]: <> (section 2 provides summarized step-by-step instructions on what to demo)


[comment]: <> (this is the section for the Note: item; please do not make any changes here)
***
### Azure Machine Learning Workspace with Secure Networking - demo scenario

<div style="background: lightgreen; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Note:** Below demo steps should be used **as a guideline** for doing your own demos. Please consider contributing to add additional demo steps.
</div>

[comment]: <> (this is the section for the Tip: item; consider adding a Tip, or remove the section between <div> and </div> if there is no tip)

<div style="background: lightblue; 
            font-size: 14px; 
            color: black;
            padding: 5px; 
            border: 1px solid lightgray; 
            margin: 5px;">

**Tip:** 
1. This scenario demonstrates enterprise-ready Azure Machine Learning setup with secure networking, VPN connectivity, and proper RBAC configurations.

2. The deployment includes a VPN Gateway for secure connectivity - this component takes approximately 20-30 minutes to deploy.

3. The workspace is initially deployed with private networking and then updated to allow public access after network provisioning is complete.

4. All storage permissions are configured automatically using managed identities and RBAC instead of access keys.
</div>

***

## Prerequisites

Before you begin, make sure you have:

- An active Azure subscription with appropriate permissions to create resources
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) installed
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Git installed for cloning the repository

## Deployment Steps

### 1. Clone the Repository

```bash
git clone https://github.com/rob-foulkrod/MachineLearningAZD.git
cd MachineLearningAZD
```

### 2. Initialize and Deploy with AZD

```bash
azd up
```

Follow the prompts:
- **Environment Name**: Choose a unique name (e.g., `ml-demo-001`)
- **Subscription**: Select your Azure subscription
- **Location**: Choose your preferred Azure region (e.g., `eastus2`, `westus2`)

The deployment will take approximately 30-45 minutes due to the VPN Gateway provisioning.

### 3. Monitor the Deployment

The deployment process includes:
1. Infrastructure provisioning (20-30 minutes)
2. Post-provisioning hooks that configure the ML workspace networking (10-15 minutes)

You can monitor progress in the Azure portal by navigating to your resource group.

***

### 1. What Resources are getting deployed

This scenario deploys a comprehensive Azure Machine Learning environment with the following resources:

* **rg-{environment-name}** - Resource Group containing all resources
* **vnet-{uniqueid}** - Virtual Network with subnets for default traffic and VPN Gateway
* **vpngw-{uniqueid}** - VPN Gateway (VpnGw2AZ) with dual active configuration  
* **ml-{uniqueid}** - Azure Machine Learning Workspace with system-assigned managed identity
* **ci{uniqueid}** - Compute Instance within the ML workspace
* **st{uniqueid}** - Storage Account with blob and file services enabled
* **cr{uniqueid}** - Azure Container Registry (Premium tier) for ML model containers
* **kv-{uniqueid}** - Key Vault for secrets and certificates
* **log-{uniqueid}** - Log Analytics Workspace for monitoring
* **appi-{uniqueid}** - Application Insights for ML workspace telemetry
* **computeIdentity** - User-assigned managed identity for the compute instance

**Key Features:**
- **Secure Networking**: Private networking with VPN connectivity for secure access
- **RBAC Integration**: Proper role assignments for managed identities and users
- **Enterprise Security**: Private endpoints, managed identities, and minimal public access
- **Monitoring**: Comprehensive logging and telemetry collection

The ML workspace URL can be found in the Azure portal or by running:
```bash
azd env get-value WORKSPACE_ID
```

### 2. Baseline Environment for ML Demos

This template provides a production-ready baseline environment for building and demonstrating machine learning scenarios. The following sections outline the key components and capabilities that are available as a foundation for your custom ML demos and experiments.

#### 2.1 Azure Machine Learning Studio Access
1. **Navigate to ML Studio**:
   - Use the Azure portal to find your ML workspace
   - Click "Launch Studio" to access Azure ML Studio
   - Demonstrate the integrated development environment

2. **Explore the Compute Instance**:
   - Show the pre-configured compute instance in the Compute section
   - Demonstrate how it's configured with managed identity authentication
   - Show the integrated Jupyter/VS Code environments

#### 2.2 Secure Storage Integration
1. **Storage Access Demo**:
   - Navigate to the Datastores section in ML Studio
   - Show how the workspace automatically connects to storage using managed identity
   - Demonstrate file upload/download capabilities without needing access keys

2. **Container Registry Integration**:
   - Show how the private container registry is configured
   - Demonstrate pulling/pushing ML model containers
   - Explain the security benefits of private registry access

#### 2.3 Networking and Security Features
1. **VPN Connectivity**:
   - Explain the VPN Gateway configuration for secure site-to-site connectivity
   - Show the virtual network configuration with proper subnetting
   - Demonstrate how private networking protects ML workloads

2. **Identity and Access Management**:
   - Show the various role assignments in the Access Control (IAM) section
   - Explain how managed identities eliminate the need for stored credentials
   - Demonstrate the principle of least privilege implementation

#### 2.4 Development Workflow Demo
1. **Create a Simple ML Experiment**:
   - Use the compute instance to create a new notebook
   - Demonstrate data loading from the configured storage account
   - Show a simple model training workflow
   - Explain how logs are captured in Application Insights

2. **Model Management**:
   - Show model registration capabilities
   - Demonstrate model versioning and tracking
   - Explain the integration with the container registry for model deployment

#### 2.5 Monitoring and Logging
1. **Application Insights Integration**:
   - Navigate to the Application Insights resource
   - Show telemetry data from ML workspace operations
   - Demonstrate custom logging from notebooks/experiments

2. **Resource Monitoring**:
   - Use Azure Monitor to show resource utilization
   - Demonstrate cost tracking and optimization opportunities
   - Show security and compliance monitoring

#### 2.6 Extension Capabilities
1. **Additional Storage Integration**:
   - Explain how the `AddStorage.ps1` hook can be used post-deployment
   - Demonstrate connecting additional storage accounts
   - Show proper permission assignment for extended storage access

#### 2.7 Cleanup
1. **Resource Cleanup**:
   ```bash
   azd down
   ```
   
2. **Complete Resource Removal**:
   ```bash
   azd down --force --purge
   ```
   - Use `--force --purge` to completely remove everything including resource groups
   - Explain the importance of cleaning up expensive resources like VPN Gateways
   - Show cost implications of leaving resources running

### Additional Resources

- [Azure Machine Learning Documentation](https://learn.microsoft.com/en-us/azure/machine-learning/)
- [Azure Developer CLI Documentation](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [ML Security Best Practices](https://learn.microsoft.com/en-us/azure/machine-learning/concept-enterprise-security)