
$resourceGroupName = azd env get-value "RG_NAME"
$subscriptionId = azd env get-value "AZURE_SUBSCRIPTION_ID"
$workspaceName = azd env get-value "WORKSPACE_NAME"


write-host "Workspace Installer (v0.2)"
write-host ""

# Check if the 'az ml' extension is installed
# the script will fail after many minutes if the extension is not installed
. ./CheckExtensions.ps1 -extensionName "ml"

Write-Host "Provisioning Network for Workspace"
write-host "Command to execute..."
write-host "az ml workspace provision-network --subscription $subscriptionId -g $resourceGroupName -n $workspaceName"
write-host "Start time: $(Get-Date -Format 'HH:mm:ss')"
Write-host "Expect this to take approximately 10 minutes"
write-host "---"

az ml workspace provision-network --subscription $subscriptionId -g $resourceGroupName -n $workspaceName

write-host "Enabling Public Access to Workspace"
write-host "Command to execute..."
write-host "az ml workspace update --name $workspaceName --resource-group $resourceGroupName --public-network-access Enabled"
write-host "---"

az ml workspace update --name $workspaceName --resource-group $resourceGroupName --public-network-access Enabled

write-host "Completed deployment"