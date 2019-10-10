#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupElastic
module="elastic"
role="nodes"
#Push installation script
az storage blob upload --account-name $storageAccountScripts --container-name $blobContainerScripts  --name $elasticVMsInstallScript --file scripts/$elasticVMsInstallScript
expiryDate=$(date +%Y-%m-%dT%H:%M:%SZ -d "+1days")
AZURE_BLOB_URL=$(az storage blob generate-sas --container-name $blobContainerScripts --name $elasticMasterVMsInstallScript --account-name $storageAccountScripts --expiry $expiryDate --permissions r --full-uri | sed 's/"//g')

#Av Set
echo "Creating av-set for elastic VMs"
az vm availability-set create -g $resGroupName -n $elasticVMsAvSetName --tags module=$module
echo "Creating $elasticDataNumVMs data VMs"
lastVMIndex=$(expr $elasticDataNumVMs - 1)

export AZURE_ELASTIC_VM_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet $coreVnet --name $subnetNameElastic --query id -o tsv)

export AZURE_ELASTIC_VM_AV_SET_ID=$(az vm availability-set show -g $resGroupName -n $elasticVMsAvSetName --query id -o tsv)



for i in $(seq 0 $lastVMIndex)
do
	echo "Creating elastic VM $i"
	elasticVMName=$elasticVMsNamePrefix"-"$i
	az group deployment create --no-wait --resource-group $resGroupName --name "elasticVM$i" --template-file $templateElasticVM --parameters \
		elasticVMName=$elasticVMName \
		elasticVMAVSetId=$AZURE_ELASTIC_VM_AV_SET_ID \
		elasticVMSize=$elasticVMsSize \
		elasticVMUser=$elasticVMsUser \
		elasticVMPass=$elasticVMsPass \
		moduleName=$module \
		roleName=$role \
		subnetId=$AZURE_ELASTIC_VM_SUBNET_ID \
		scriptURL="$AZURE_BLOB_URL"

done

