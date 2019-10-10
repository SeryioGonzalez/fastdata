#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupHDI
module="hdi"

export AZURE_HDI_VNET_ID=$(az network vnet show -g $resGroupNetworking -n $coreVnet --query id -o tsv)
export AZURE_HDI_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet-name $coreVnet -n $subnetNameHDI --query id -o tsv)


echo "Creating hdi clusters"
az group deployment create --resource-group $resGroupName  --name $hdiKafkaDeploymentName --template-file $templateHDIKafka --parameters \
	baseClusterName=$environmentName \
	clusterLoginPassword=$hdiClusterHTTPPassword \
	clusterLoginUserName=$hdiClusterHTTPUser \
	clusterWorkerNodeSize=$hdiKafkaWorkerNodeSize \
	sshPassword=$hdiClusterHTTPPassword \
	sshUserName=$hdiClusterHTTPUser \
	subnetId=$AZURE_HDI_SUBNET_ID \
	vnetId=$AZURE_HDI_VNET_ID 