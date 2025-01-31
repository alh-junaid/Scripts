#!/bin/bash

SUBSCRIPTION_ID="YOUR SUBSCRIPTION NAME"

# Confirm the deletion action
read -p "Are you sure you want to delete all resources in subscription $SUBSCRIPTION_ID? (yes/no): " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
    echo "Deletion aborted."
    exit 0
fi

echo "Fetching all resource groups for subscription: $SUBSCRIPTION_ID..."
RESOURCE_GROUPS=$(az group list --subscription "$SUBSCRIPTION_ID" --query "[].name" -o tsv)

# Check if there are resource groups
if [[ -z "$RESOURCE_GROUPS" ]]; then
    echo "No resource groups found in the subscription."
    exit 0
fi

# Delete all resources in each resource group
for RESOURCE_GROUP in $RESOURCE_GROUPS; do
    echo "Deleting all resources in Resource Group: $RESOURCE_GROUP..."
    
    # Delete all resources in the resource group with dependency resolution
    az resource delete --ids $(az resource list --subscription "$SUBSCRIPTION_ID" --resource-group "$RESOURCE_GROUP" --query "[?managedBy==null].id" -o tsv)
    
    # Delete the resource group after emptying it
    echo "Deleting Resource Group: $RESOURCE_GROUP..."
    az group delete --name "$RESOURCE_GROUP" --subscription "$SUBSCRIPTION_ID" --yes --no-wait
done

# Final confirmation
echo "All deletions initiated. It may take some time to complete."

# Summary of operations
TOTAL_RESOURCE_GROUPS=$(az group list --subscription "$SUBSCRIPTION_ID" --query "length(@)")
if [[ "$TOTAL_RESOURCE_GROUPS" -eq 0 ]]; then
    echo "All resource groups and their resources have been deleted successfully."
else
    echo "Some resource groups or resources could not be deleted. Check Azure Portal or CLI logs for details."
fi