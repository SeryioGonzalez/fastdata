#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupElastic
module="elastic"
role="kibana"

#Push installation script
az storage blob upload --account-name $storageAccountScripts --container-name $blobContainerScripts  \
	--name $elasticKibanaVMsInstallScript --file scripts/$elasticKibanaVMsInstallScript

expiryDate=$(date +%Y-%m-%dT%H:%M:%SZ -d "+1days")
AZURE_BLOB_URL=$(az storage blob generate-sas --container-name $blobContainerScripts --name $elasticMasterVMsInstallScript --account-name $storageAccountScripts --expiry $expiryDate --permissions r --full-uri | sed 's/"//g')

#Av Set
echo "Creating av-set for elastic VMs"
az vm availability-set create -g $resGroupName -n $elasticKibanaVMsAvSetName --tags module=$module

export AZURE_ELASTIC_VM_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet $coreVnet --name $subnetNameElastic --query id -o tsv)

export AZURE_ELASTIC_VM_AV_SET_ID=$(az vm availability-set show -g $resGroupName -n $elasticKibanaVMsAvSetName --query id -o tsv)


echo "Creating elastic kibana VM"
	elasticKibanaVMName=$elasticKibanaVMsName
	az group deployment create --debug --no-wait --resource-group $resGroupName --name "elasticKibanaVM$i" --template-file $templateElasticVM --parameters \
		elasticVMName=$elasticKibanaVMName \
		elasticVMAVSetId=$AZURE_ELASTIC_VM_AV_SET_ID \
		elasticVMSize=$elasticKibanaVMsSize \
		elasticVMUser=$elasticKibanaVMsUser \
		elasticVMPass=$elasticKibanaVMsPass \
		moduleName=$module \
		roleName=$role \
		subnetId=$AZURE_ELASTIC_VM_SUBNET_ID \
		scriptURL=$AZURE_BLOB_URL
	

