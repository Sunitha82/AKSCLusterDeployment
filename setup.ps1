# AKS Terraform Deployment Setup Script
# This script automates the process of deploying an AKS cluster using Terraform

# Define colors for output
function Write-ColorOutput {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        [Parameter(Mandatory=$false)]
        [string]$Color = "White"
    )

    $originalColor = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $Color
    Write-Output $Message
    $host.UI.RawUI.ForegroundColor = $originalColor
}

Write-ColorOutput "AKS Terraform Automation Setup" "Yellow"
Write-ColorOutput "------------------------------" "Yellow"

# Check required tools
Write-ColorOutput "Checking prerequisites..." "Yellow"

# Check Azure CLI
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "Azure CLI is not installed. Please install it first." "Red"
    Write-ColorOutput "Visit: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli" "Red"
    exit
}

# Check Terraform
if (-not (Get-Command terraform -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "Terraform is not installed. Please install it first." "Red"
    Write-ColorOutput "Visit: https://learn.hashicorp.com/tutorials/terraform/install-cli" "Red"
    exit
}

# Check kubectl
if (-not (Get-Command kubectl -ErrorAction SilentlyContinue)) {
    Write-ColorOutput "kubectl is not installed. Please install it first." "Red"
    Write-ColorOutput "Visit: https://kubernetes.io/docs/tasks/tools/install-kubectl/" "Red"
    exit
}

Write-ColorOutput "All prerequisites are installed!" "Green"

# Login to Azure
Write-ColorOutput "Logging in to Azure..." "Yellow"
az login 

# List subscriptions
Write-ColorOutput "Available subscriptions:" "Yellow"
az account list --output table

# Select subscription
Write-ColorOutput "Enter the subscription ID you want to use:" "Yellow"
$subscriptionId = Read-Host
az account set --subscription "$subscriptionId"
Write-ColorOutput "Subscription set to: $subscriptionId" "Green"

# Create AAD group for AKS admins if needed
Write-ColorOutput "Do you want to create a new Azure AD group for AKS administrators? (y/n)" "Yellow"
$createAadGroup = Read-Host

if ($createAadGroup -eq "y") {
    Write-ColorOutput "Enter a name for the AAD group:" "Yellow"
    $aadGroupName = Read-Host

    # Create AAD group
    $aadGroupId = az ad group create --display-name "$aadGroupName" --mail-nickname "$($aadGroupName -replace ' ','')" --query "id" -o tsv
    Write-ColorOutput "Created AAD group: $aadGroupName with ID: $aadGroupId" "Green"

    # Update terraform.tfvars with the AAD group ID
    $tfvarsContent = Get-Content -Path "terraform.tfvars" -Raw
    $tfvarsContent = $tfvarsContent -replace 'aks_admin_group_object_id = ".*"', "aks_admin_group_object_id = `"$aadGroupId`""
    Set-Content -Path "terraform.tfvars" -Value $tfvarsContent

    # Add current user to the group
    $currentUser = az ad signed-in-user show --query "id" -o tsv
    az ad group member add --group "$aadGroupId" --member-id "$currentUser"
    Write-ColorOutput "Added current user to the AAD group." "Green"
} else {
    Write-ColorOutput "Enter your existing AAD group object ID for AKS administrators:" "Yellow"
    $aadGroupId = Read-Host
    $tfvarsContent = Get-Content -Path "terraform.tfvars" -Raw
    $tfvarsContent = $tfvarsContent -replace 'aks_admin_group_object_id = ".*"', "aks_admin_group_object_id = `"$aadGroupId`""
    Set-Content -Path "terraform.tfvars" -Value $tfvarsContent
}

# Customize other variables
Write-ColorOutput "Do you want to customize other Terraform variables? (y/n)" "Yellow"
$customizeVars = Read-Host

if ($customizeVars -eq "y") {
    Write-ColorOutput "Enter resource group name [aks-terraform-rg]:" "Yellow"
    $resourceGroupName = Read-Host
    if ($resourceGroupName) {
        $tfvarsContent = Get-Content -Path "terraform.tfvars" -Raw
        $tfvarsContent = $tfvarsContent -replace 'resource_group_name = ".*"', "resource_group_name = `"$resourceGroupName`""
        Set-Content -Path "terraform.tfvars" -Value $tfvarsContent
    }

    Write-ColorOutput "Enter Azure region [eastus]:" "Yellow"
    $location = Read-Host
    if ($location) {
        $tfvarsContent = Get-Content -Path "terraform.tfvars" -Raw
        $tfvarsContent = $tfvarsContent -replace 'location = ".*"', "location = `"$location`""
        Set-Content -Path "terraform.tfvars" -Value $tfvarsContent
    }

    Write-ColorOutput "Enter AKS cluster name [aks-terraform-cluster]:" "Yellow"
    $clusterName = Read-Host
    if ($clusterName) {
        $tfvarsContent = Get-Content -Path "terraform.tfvars" -Raw
        $tfvarsContent = $tfvarsContent -replace 'cluster_name = ".*"', "cluster_name = `"$clusterName`""
        Set-Content -Path "terraform.tfvars" -Value $tfvarsContent
    }

    Write-ColorOutput "Enter Kubernetes version [1.25.5]:" "Yellow"
    $kubernetesVersion = Read-Host
    if ($kubernetesVersion) {
        $tfvarsContent = Get-Content -Path "terraform.tfvars" -Raw
        $tfvarsContent = $tfvarsContent -replace 'kubernetes_version = ".*"', "kubernetes_version = `"$kubernetesVersion`""
        Set-Content -Path "terraform.tfvars" -Value $tfvarsContent
    }
}

# Initialize Terraform
Write-ColorOutput "Initializing Terraform..." "Yellow"
terraform init

# Validate Terraform configuration
Write-ColorOutput "Validating Terraform configuration..." "Yellow"
terraform validate

# Plan Terraform changes
Write-ColorOutput "Planning Terraform changes..." "Yellow"
terraform plan -out="tfplan"

# Ask for confirmation
Write-ColorOutput "Do you want to apply these changes? (y/n)" "Yellow"
$applyChanges = Read-Host

if ($applyChanges -eq "y") {
    Write-ColorOutput "Applying Terraform changes..." "Yellow"
    terraform apply "tfplan"

    # Get AKS credentials if deployment was successful
    if ($LASTEXITCODE -eq 0) {
        Write-ColorOutput "Deployment successful! Getting AKS credentials..." "Green"
        $resourceGroupName = terraform output -raw resource_group_name
        $clusterName = terraform output -raw kubernetes_cluster_name

        az aks get-credentials --resource-group $resourceGroupName --name $clusterName --overwrite-existing

        Write-ColorOutput "Testing connection to Kubernetes cluster..." "Yellow"
        kubectl get nodes

        Write-ColorOutput "Applying RBAC configuration..." "Yellow"
        kubectl apply -f rbac.yaml

        Write-ColorOutput "Setup complete! Your AKS cluster is ready." "Green"
        Write-ColorOutput "Run 'kubectl get nodes' to see your cluster nodes." "Green"
    }
} else {
    Write-ColorOutput "Deployment cancelled. You can apply later with 'terraform apply tfplan'" "Yellow"
}
