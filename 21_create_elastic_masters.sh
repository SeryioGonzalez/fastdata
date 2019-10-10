#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupElastic
module="elastic"
role="master"

#Push installation script
az storage blob upload --account-name $storageAccountScripts --container-name $blobContainerScripts  --name $elasticMasterVMsInstallScript --file scripts/$elasticMasterVMsInstallScript

expiryDate=$(date +%Y-%m-%dT%H:%M:%SZ -d "+1days")
AZURE_BLOB_URL=$(az storage blob generate-sas --container-name $blobContainerScripts --name $elasticMasterVMsInstallScript --account-name $storageAccountScripts --expiry $expiryDate --permissions r --full-uri | sed 's/"//g')

#Av-Set
echo "Creating av-set for elastic Master VMs"
az vm availability-set create -g $resGroupName -n $elasticMasterVMsAvSetName --tags module=$module
echo "Creating $elasticMasterNumVMs master VMs"
lastVMIndex=$(expr $elasticMasterNumVMs - 1)

export AZURE_ELASTIC_VM_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet $coreVnet --name $subnetNameElastic --query id -o tsv)

export AZURE_ELASTIC_VM_AV_SET_ID=$(az vm availability-set show -g $resGroupName -n $elasticMasterVMsAvSetName --query id -o tsv)

for i in $(seq 0 $lastVMIndex)
do
	echo "Creating elastic master VM $i"
	elasticMasterVMName=$elasticMasterVMsNamePrefix"-"$i
	az group deployment create --no-wait --resource-group $resGroupName --name "elasticMasterVM$i" --template-file $templateElasticVM --parameters \
		elasticVMName=$elasticMasterVMName \
		elasticVMAVSetId=$AZURE_ELASTIC_VM_AV_SET_ID \
		elasticVMSize=$elasticMasterVMsSize \
		elasticVMUser=$elasticMasterVMsUser \
		elasticVMPass=$elasticMasterVMsPass \
		moduleName=$module \
		roleName=$role \
		subnetId=$AZURE_ELASTIC_VM_SUBNET_ID \
		scriptURL="$AZURE_BLOB_URL"
	
done

