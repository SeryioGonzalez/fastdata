#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupApps
module="appvms"

#Push installation script
#az storage blob upload --account-name $storageAccountScripts --container-name $blobContainerScripts  --name $appVMsInstallScript --file scripts/$appVMsInstallScript
AZURE_BLOB_URL="https://$storageAccountScripts.blob.core.windows.net/$blobContainerScripts/$appVMsInstallScript"

#Log Analytics
echo "Creating av-set for app VMs"
az vm availability-set create -g $resGroupName -n $appVMsAvSetName --tags module=$module

echo "Creating $appVMsNumVMs app VMs"
lastVMIndex=$(expr $appVMsNumVMs - 1)

export AZURE_APP_VM_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet $coreVnet --name $subnetNameAPP --query id -o tsv)

export AZURE_APP_VM_AV_SET_ID=$(az vm availability-set show -g $resGroupName -n $appVMsAvSetName --query id -o tsv)

for i in $(seq 0 $lastVMIndex)
do
	echo "Creating app VM $i"
	appVMName=$appVMsNamePrefix$i
	az group deployment create --no-wait --resource-group $resGroupName --name "appVM$i" --template-file $templateAppVM --parameters \
		appVMName=$appVMName \
		appVMNameAVSetId=$AZURE_APP_VM_AV_SET_ID \
		appVMNameSize=$appVMsSize \
		appVMNameUser=$appVMsUser \
		appVMNamePass=$appVMsPass \
		moduleName=$module \
		subnetId=$AZURE_APP_VM_SUBNET_ID \
		scriptURL=$AZURE_BLOB_URL

done

