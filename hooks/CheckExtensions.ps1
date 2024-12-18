param (
    [string]$extensionName = "ml"
)

function Get-AzExtensionInstalled {
    param (
        [string]$extensionName
    )

    $extensions = az extension list --output json | ConvertFrom-Json 
    $extensionInstalled = $false 
    foreach ($extension in $extensions) { 
        if ($extension.name -eq $extensionName) { 
            $extensionInstalled = $true
            break 
        } 
    } 

    return $extensionInstalled
}

function Install-AzExtension {
    param (
        [string]$extensionName
    )

    az extension add --name $extensionName
}

# Check if the extension is installed
$extensionInstalled = Get-AzExtensionInstalled -extensionName $extensionName



if (-not $extensionInstalled) {
    Write-Output "The 'az $extensionName' extension is not installed and is needed for this script."
    $install = Read-Host -Prompt "Install now? (Y or N)"
    if ($install -eq "Y") {
        Install-AzExtension -extensionName $extensionName
    }
    else {
        Write-Output "Exiting script"
        exit
    }
}