# Azure Machine Learning AZD Template

This repository contains an Azure Developer CLI (AZD) template for deploying a comprehensive Azure Machine Learning environment with enterprise security features.

## What Gets Deployed

This template deploys a production-ready Azure Machine Learning workspace with:

- **Azure Machine Learning Workspace** with system-assigned managed identity
- **Compute Instance** for development work
- **Virtual Network** with secure networking configuration
- **VPN Gateway** for site-to-site connectivity
- **Azure Storage Account** with proper RBAC permissions
- **Azure Container Registry** (Premium) for ML model containers
- **Azure Key Vault** for secrets management
- **Application Insights** for monitoring and telemetry
- **Log Analytics Workspace** for centralized logging

## Prerequisites

Before you begin, ensure you have:

- An active Azure subscription with appropriate permissions
- [Azure Developer CLI (azd)](https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/install-azd) installed
- [Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli) installed
- Git for cloning the repository

## Quick Start

### 1. Clone and Deploy

```bash
git clone https://github.com/rob-foulkrod/MachineLearningAZD.git
cd MachineLearningAZD
azd up
```

### 2. Follow the Prompts

- **Environment Name**: Choose a unique name (this becomes your resource group name)
- **Subscription**: Select your Azure subscription  
- **Location**: Choose your preferred Azure region

### 3. Wait for Deployment

The deployment takes approximately 30-45 minutes due to VPN Gateway provisioning.

## Configuration Options

The template accepts the following optional parameters during deployment:

- **Environment Name**: Used for resource group and resource naming
- **Location**: Azure region for deployment (default: `eastus2`)
- **VNet Name**: Custom virtual network name (optional)
- **Storage Account Name**: Custom storage account name (optional)

## Post-Deployment

After deployment completes:

1. **Access ML Studio**: Navigate to your ML workspace in the Azure portal and click "Launch Studio"
2. **Use Compute Instance**: The pre-configured compute instance is ready for development
3. **Explore Security**: All resources are configured with managed identities and RBAC

## Demo Guide

For detailed demonstration scenarios and step-by-step instructions, see the [Demo Guide](./demoguide/demoguide.md).

## Clean Up

To remove all deployed resources:

```bash
azd down
```

**Important**: The VPN Gateway is an expensive resource. Make sure to clean up when not needed.

## Advanced Configuration

### Additional Storage Integration

The `hooks/AddStorage.ps1` script can be used after deployment to integrate additional storage accounts that contain samples or demo material. This script assigns the appropriate permissions to connect external storage accounts to your Azure Machine Learning workspace.

#### Usage

Get your deployed resource information:
```bash
# Get the resource group name
azd env get-value RG_NAME

# Get the workspace name  
azd env get-value WORKSPACE_NAME

# Get the compute instance name
azd env get-value WORKSPACE_INSTANCE_NAME
```

Run the storage integration script:
```powershell
./hooks/AddStorage.ps1
```

The script will:
- Prompt you to select additional storage accounts to integrate
- Configure proper RBAC permissions for the ML workspace
- Set up access for the compute instance managed identity
- Grant appropriate permissions to your user account

This enables seamless access to external datasets and resources from within your ML workspace environment.

## Architecture

This template uses [Azure Verified Modules (AVM)](https://azure.github.io/Azure-Verified-Modules/) to ensure best practices and enterprise readiness. The infrastructure includes:

- **Network Security**: Private networking with VPN gateway for secure connectivity
- **Identity Management**: Managed identities with RBAC instead of access keys
- **Monitoring**: Comprehensive logging and telemetry collection
- **Compliance**: Enterprise security configurations and private endpoints

For detailed architecture information, see the [Demo Guide](./demoguide/demoguide.md).