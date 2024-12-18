# Define the path to your Bicep file
$bicepFilePath = "./infra/main.bicep"

# Validate the Bicep file without generating an output file
$validationResult = az bicep build --file $bicepFilePath --stdout

# Check if the validation was successful
if ($LASTEXITCODE -eq 0) {
    Write-Host "Bicep file validation succeeded."
}
else {
    Write-Host "Bicep file validation failed."
    Write-Host $validationResult
}