TODO: rewrite for the AZD environment

## Prerequisites

Ensure you have the Azure CLI installed. You can download and install it from the following link:
[Install Azure CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli-windows?tabs=azure-cli)

## Running the Script Locally

It is recommended to run the installer locally instead of using CloudShell due to potential timeouts.

### Step 1: Login to Azure

Login to Azure using the following command and provide your credentials:
```powershell
az login
```

### Step 2: Clone the Repository

Clone the repository and navigate to the `MachineLearningBicep` directory:
```powershell
git clone https://github.com/rob-foulkrod/MachineLearningBicep.git
cd MachineLearningBicep
```

### Step 3: Run the Script

Execute the PowerShell script:
```powershell
./run.ps1
```

## Additional Configuration

- **resourceGroupName**: The name of the resource group. Default is `aml-rg`.
- **location**: The Azure region where the resources will be deployed. Default is `eastus2`.
- **prefix**: The prefix for naming resources. Default is `aml`.

### Example Usage with Parameters

To run the script with custom parameters, use the following command:

```powershell
./run.ps1 -resourceGroupName "myResourceGroup" -location "eastus" -prefix "myPrefix"
```

Alternatively, you can use the shorthand version:

```powershell
./run.ps1 -r "myResourceGroup" -l "eastus" -p "myPrefix"
```

## Extras
## AddStorage.ps1

This script is an extension for users who may have additional storage accounts that contain samples or demo material. It assigns the appropriate permissions to the selected storage account for Azure Machine Learning (ML) workspaces and compute instances.

### Parameters

All parameters are optional

- `storageRGName` (string): The name of the resource group containing the storage account.
- `storageAccountName` (string): The name of the storage account.
- `workspaceRGName` (string): The name of the resource group containing the Azure ML workspace.
- `workspaceName` (string): The name of the Azure ML workspace.
- `computeInstanceName` (string): The name of the compute instance within the Azure ML workspace.
- `userId` (string): The user ID of the current user. If not provided, the script will retrieve the current user's principal ID.

### Functionality

1. Retrieves the subscription ID of the current Azure account.
2. If `userId` is not provided, retrieves the current user's principal ID.
3. If `storageAccountName` is not provided, lists all storage accounts in the subscription and prompts the user to select one.
4. If `workspaceName` is not provided, lists all Azure ML workspaces in the subscription and prompts the user to select one.
5. If `computeInstanceName` is not provided, lists all compute instances in the selected workspace and prompts the user to select one.
6. Retrieves the identities of the selected Azure ML workspace and compute instance.
7. Assigns the following roles to the workspace identity on the selected storage account:
    - Storage Account Contributor
    - Storage Blob Data Contributor
    - Storage File Data Privileged Contributor
8. Assigns the following roles to the compute instance identity on the selected storage account:
    - Storage Blob Data Contributor
    - Storage File Data Privileged Contributor
9. Assigns the following roles to the current user identity on the selected storage account:
    - Storage Blob Data Contributor
    - Storage File Data Privileged Contributor

### Usage

Run the script with the required parameters. If any parameters are not provided, the script will prompt the user to select from available options.

#### Example Usage without Parameters

To run the `AddStorage.ps1` script without any parameters, use the following command:

```powershell
./AddStorage.ps1
```

The script will prompt you to select from available options for any parameters that are not provided.

#### Example Usage with All Parameters

To run the `AddStorage.ps1` script with all parameters, use the following command:

```powershell
./AddStorage.ps1 -storageRGName "storageResourceGroup" -storageAccountName "mystorageaccount" -workspaceRGName "workspaceResourceGroup" -workspaceName "myWorkspace" -computeInstanceName "myComputeInstance" -userId "00000000-0000-0000-0000-000000000000"
```