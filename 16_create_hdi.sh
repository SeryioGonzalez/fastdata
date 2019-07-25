#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupHDI
module="hdi"

export AZURE_HDI_VNET_ID=$(az network vnet show -g $resGroupNetworking -n $coreVnet --query id -o tsv)

echo "Creating hdi kafka"
az group deployment create --debug --resource-group $resGroupName --name $kafkaDeploymentName --template-file $templateKafka --parameters \
	moduleName=$module \
	clusterName=$kafkaClusterName \
	clusterLoginPassword=$kafkaHTTPPassword \
	clusterLoginUserName=$kafkaHTTPUser \
	sshUserName=$kafkaSSHUser \
	sshPassword=$kafkaSSHPassword \
	subnetName=$subnetNameHDI \
	vnetId=$AZURE_HDI_VNET_ID \
	headNodeCount=$kafkaHeadNodeCount \
	headNodeSize=$kafkaHeadNodeSize \
	workerNodeSize=$kafkaWorkerNodeSize \
	workerNodeCount=$kafkaWorkerNodeCount \
	workerDiskCount=$kafkaWorkerDiskCount \
	zookeperNodeCount=$kafkaZookeeperNodeCount \
	zookeperNodeSize=$kafkaZookeeperNodeSize 