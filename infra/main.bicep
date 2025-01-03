targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the environment that can be used as part of naming resource convention')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

// Tags that should be applied to all resources.
// 
// Note that 'azd-service-name' tags should be applied separately to service host resources.
// Example usage:
//   tags: union(tags, { 'azd-service-name': <service name in azure.yaml> })
var tags = {
  'azd-env-name': environmentName
}

var abbrs = loadJsonContent('./abbreviations.json')
param currentUserId string
param vnetName string = ''
param storageAccountName string = ''

var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: 'rg-${environmentName}'
  location: location
  tags: tags
}

// This Bicep file uses Azure Verified Modules (AVM) to deploy an Azure Machine Learning Workspace with the following resources:
// - Virtual Network
// - Storage Account
// - Container Registry
// - Key Vault
// - Application Insights
// - Virtual Network Gateway
// - Managed Identity for the Compute Instance
// - Machine Learning Workspace and a Compute Instance
// - Role Assignments for the Machine Learning Workspace Identity
// - Role Assignments for the Compute Instance Identity
// - Role Assignments for the current user

//Documentation about Azure Verified Modules can be found here:
//https://azure.github.io/Azure-Verified-Modules/

module virtualNetwork 'br/public:avm/res/network/virtual-network:0.5.1' = {
  name: 'virtualNetworkDeployment'
  scope: rg
  params: {
    tags: tags
    name: !empty(vnetName) ? vnetName : '${abbrs.networkVirtualNetworks}${resourceToken}'
    location: location
    addressPrefixes: [
      '10.2.0.0/16'
    ]
    subnets: [
      {
        addressPrefix: '10.2.0.0/24'
        name: 'default'
      }
      {
        addressPrefix: '10.2.1.0/24'
        name: 'GatewaySubnet'
      }
    ]
  }
}

module computeUserAssignedIdentity 'br/public:avm/res/managed-identity/user-assigned-identity:0.4.0' = {
  name: 'computeUserAssignedIdentityDeployment'
  scope: rg
  params: {
    name: 'computeIdentity'
    location: location
    tags: tags
  }
}

module storageAccount 'br/public:avm/res/storage/storage-account:0.14.3' = {
  name: 'storageAccountDeployment'
  scope: rg

  params: {
    name: !empty(storageAccountName) ? storageAccountName : '${abbrs.storageStorageAccounts}${resourceToken}'
    tags: tags
    allowBlobPublicAccess: true //is a false here needed?
    defaultToOAuthAuthentication: true // Default to Entra ID Authentication
    supportsHttpsTrafficOnly: true
    kind: 'StorageV2'
    location: location
    skuName: 'Standard_LRS'
    blobServices: {
      enabled: true
    }
    fileServices: {
      enabled: true
    }
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    roleAssignments: [
      {
        principalId: computeUserAssignedIdentity.outputs.principalId
        roleDefinitionIdOrName: 'Storage File Data Privileged Contributor'
      }
      {
        principalId: computeUserAssignedIdentity.outputs.principalId
        roleDefinitionIdOrName: 'Storage Blob Data Contributor'
      }
    ]
  }
}

module registry 'br/public:avm/res/container-registry/registry:0.6.0' = {
  name: 'registryDeployment'
  scope: rg
  params: {
    name: '${abbrs.containerRegistryRegistries}${resourceToken}'
    acrSku: 'Premium'
    location: location
    acrAdminUserEnabled: true
    networkRuleBypassOptions: 'AzureServices'
    publicNetworkAccess: 'Disabled'
    tags: tags
  }
}

module vault 'br/public:avm/res/key-vault/vault:0.11.0' = {
  name: 'vaultDeployment'
  scope: rg
  params: {
    name: '${abbrs.keyVaultVaults}${resourceToken}'
    tags: tags
    enablePurgeProtection: false
    enableRbacAuthorization: true
    enableVaultForDeployment: true
    enableVaultForDiskEncryption: true
    enableVaultForTemplateDeployment: true
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    location: location
  }
}

//App Insights Workspace
module operationalworkspace 'br/public:avm/res/operational-insights/workspace:0.9.0' = {
  name: 'operationalworkspaceDeployment'
  scope: rg
  params: {
    name: '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    location: location
    tags: tags
  }
}

//Application Insights
module component 'br/public:avm/res/insights/component:0.4.2' = {
  name: 'componentDeployment'
  scope: rg
  params: {
    name: '${abbrs.insightsComponents}${resourceToken}'
    workspaceResourceId: operationalworkspace.outputs.resourceId
    location: location
    tags: tags
  }
}

module virtualNetworkGateway 'br/public:avm/res/network/virtual-network-gateway:0.5.0' = {
  name: 'virtualNetworkGatewayDeployment'
  scope: rg
  params: {
    clusterSettings: {
      clusterMode: 'activePassiveNoBgp'
    }
    gatewayType: 'Vpn'
    name: '${abbrs.networkVpnGateways}${resourceToken}'
    tags: tags
    vNetResourceId: virtualNetwork.outputs.resourceId
    allowRemoteVnetTraffic: true
    disableIPSecReplayProtection: true
    enableBgpRouteTranslationForNat: true
    enablePrivateIpAddress: true
    location: location
    publicIpZones: []
    skuName: 'VpnGw1'
    vpnGatewayGeneration: 'Generation1'
    vpnType: 'RouteBased'
  }
}

//the combined workspacename and instance name need to be until 24 characters
var shortWorkspaceName = take('${abbrs.machineLearningServicesWorkspaces}${resourceToken}', 18)
var instanceName = take('ci${resourceToken}', 6) // but keep it 'unique' for multiple deployments

module workspace 'br/public:avm/res/machine-learning-services/workspace:0.9.0' = {
  name: 'workspaceDeployment'
  scope: rg
  params: {
    name: shortWorkspaceName
    sku: 'Basic'
    associatedApplicationInsightsResourceId: component.outputs.resourceId
    associatedKeyVaultResourceId: vault.outputs.resourceId
    associatedStorageAccountResourceId: storageAccount.outputs.resourceId
    associatedContainerRegistryResourceId: registry.outputs.resourceId
    computes: [
      {
        name: instanceName
        computeType: 'ComputeInstance'
        computeLocation: location
        location: location
        description: 'Default Instance'
        disableLocalAuth: false
        properties: {
          vmSize: 'STANDARD_DS11_V2'
        }
        managedIdentities: {
          systemAssigned: false
          userAssignedResourceIds: [
            computeUserAssignedIdentity.outputs.resourceId
          ]
        }
      }
    ]
    location: location
    tags: tags
    publicNetworkAccess: 'Disabled'
    managedIdentities: {
      systemAssigned: true
    }
    systemDatastoresAuthMode: 'identity'
    hbiWorkspace: false
    managedNetworkSettings: {
      isolationMode: 'AllowInternetOutbound'
    }
  }
}

// Storage Table Data Contributor: 0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3
module amlIdentityRoleStorageTableDataContributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = {
  name: 'amlIdentityRoleStorageTableDataContributorDeployment'
  scope: rg
  params: {
    roleName: 'Storage Table Data Contributor'
    description: 'Assign Storage Table Data Contributor role to the managed Identity on the ML Workspace'
    principalId: workspace.outputs.systemAssignedMIPrincipalId!
    resourceId: storageAccount.outputs.resourceId
    roleDefinitionId: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
    principalType: 'ServicePrincipal'
  }
}

// All three assignments now for the current user
module currentUserRoleStorageBlobDataContributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = {
  name: 'currentUserRoleStorageBlobDataContributorDeployment'
  scope: rg
  params: {
    roleName: 'Storage Blob Data Contributor'
    description: 'Assign Storage Blob Data Contributor role to the managed Identity on the ML Workspace'
    principalId: currentUserId
    resourceId: storageAccount.outputs.resourceId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'User'
  }
}

module currentUserRoleTableDataContributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = {
  name: 'currentUserRoleTableDataContributorDeployment'
  scope: rg
  params: {
    roleName: 'Storage Table Data Contributor'
    description: 'Assign Storage Table Data Contributor role to the managed Identity on the ML Workspace'
    principalId: currentUserId
    resourceId: storageAccount.outputs.resourceId
    roleDefinitionId: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
    principalType: 'User'
  }
}

module currentUserRoleStorageFileDataPrivilegedContributor 'br/public:avm/ptn/authorization/resource-role-assignment:0.1.1' = {
  name: 'currentUserRoleStorageFileDataPrivilegedContributorDeployment'
  scope: rg
  params: {
    roleName: 'Storage File Data Privileged Contributor'
    description: 'Assign Storage File Data Privileged Contributor role to the managed Identity on the ML Workspace'
    principalId: currentUserId
    resourceId: storageAccount.outputs.resourceId
    roleDefinitionId: '69566ab7-960f-475b-8e7c-b3118f30c6bd'
    principalType: 'User'
  }
}

output RG_NAME string = rg.name
output WORKSPACE_ID string = workspace.outputs.resourceId
output WORKSPACE_NAME string = workspace.outputs.name
output WORKSPACE_INSTANCE_NAME string = instanceName
output STORAGE_ACCOUNT_ID string = storageAccount.outputs.resourceId
