#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupOAM
module="oam"

#Log Analytics
echo "Creating log analytics workspace"
az group deployment create --resource-group $resGroupName --name $logAnalyticsDeployment --template-file $templateLogAnalytics --parameters moduleName=$module workspaceName=$logAnalyticsWorkspaceName --no-wait

echo "Creating recovery vault"
az backup vault create -l $region --name $recoveryVaultName --resource-group $resGroupName 

echo "Creating storage account for scripts"
az storage account create --name $storageAccountScripts --resource-group $resGroupName --https-only true --kind StorageV2 --sku Standard_GRS
export AZURE_STORAGE_KEY=$(az storage account keys list \
    --account-name $storageAccountScripts --resource-group $resGroupName --query [0].value -o tsv)
az storage container create --name $blobContainerScripts --account-key $AZURE_STORAGE_KEY --account-name $storageAccountScripts