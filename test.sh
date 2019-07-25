#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupHDI
module="hdi"

export AZURE_HDI_VNET_ID=$(az network vnet show -g $resGroupNetworking -n $coreVnet --query id -o tsv)

templateHDI="test-spark.json"
clusterLoginPassword="Pepito1_pepito2"
sshPassword=$clusterLoginPassword

echo "Creating hdi clusters"
az group deployment create --mode Complete --debug --resource-group $resGroupName --name "tes" --template-file $templateHDI --parameters \
	hdiClusterLoginPassword=$clusterLoginPassword \
	hdiClusterSshPassword=$sshPassword \
	vnetId=$AZURE_HDI_VNET_ID \
	subnetName=$subnetNameHDI