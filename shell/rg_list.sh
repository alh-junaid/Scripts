#!/bin/bash

SUBSCRIPTION_ID="YOUR SUBSCRIPTION NAME"

# Initialize counters
TOTAL_RESOURCE_GROUPS=0
TOTAL_RESOURCES=0

echo "Fetching resource group and resource details for subscription: $SUBSCRIPTION_ID..."

# Fetch the list of resource groups
RESOURCE_GROUPS=$(az group list --subscription "$SUBSCRIPTION_ID" --query "[].name" -o tsv)

# Loop through each resource group
for RESOURCE_GROUP in $RESOURCE_GROUPS; do
    TOTAL_RESOURCE_GROUPS=$((TOTAL_RESOURCE_GROUPS + 1))

    # Get the resource count in the current resource group
    RESOURCE_COUNT=$(az resource list --subscription "$SUBSCRIPTION_ID" --resource-group "$RESOURCE_GROUP" --query "length(@)")

    # Add to the total resource count
    TOTAL_RESOURCES=$((TOTAL_RESOURCES + RESOURCE_COUNT))

    # Output resource group name and its resource count
    echo "Resource Group: $RESOURCE_GROUP has $RESOURCE_COUNT resources"
done

# Output total counts
echo "==========================================="
echo "Total number of resource groups: $TOTAL_RESOURCE_GROUPS"
echo "Total number of resources: $TOTAL_RESOURCES"