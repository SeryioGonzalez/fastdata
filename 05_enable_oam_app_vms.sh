#!/bin/bash

source config.sh
az account set --subscription $subscription

lastVMIndex=$(expr $appVMsNumVMs - 1)

#Log Analytic linking is via REST
azureAPItoken=$(az account get-access-token --query accessToken -o tsv)
logAnalyticsURL="https://management.azure.com/subscriptions/$subscription/resourcegroups/$resGroupOAM/providers/Microsoft.OperationalInsights/workspaces/$logAnalyticsWorkspaceName/sharedkeys?api-version=2015-03-20"
logAnalyticsKey=$(wget --quiet --method POST --header "authorization: Bearer $azureAPItoken"  --header 'content-type: application/json' --output-document - $logAnalyticsURL | jq ".primarySharedKey" -r )
logAnalyticsId=(az resource show -g fastdata-mex-rg-oam --resource-type Microsoft.OperationalInsights/workspaces -n fastdata-mex-log-analytics --query "properties.customerId" -o tsv)


for i in $(seq 0 $lastVMIndex)
do

	appVMName=$appVMsNamePrefix$i
	vmID=$(az vm show -g $resGroupApps -n $appVMName --query id -o tsv)

#Enable backup for VMs	
	echo "Creating backup for VM $i"
	az backup protection enable-for-vm \
		--resource-group $resGroupOAM \
		--vault-name $recoveryVaultName \
		--vm $vmID --policy-name DefaultPolicy

#Connect VM TO LOG ANALYTICS
	echo "Adding VM $i to log analytics" 		
	az vm extension set \
		--resource-group $resGroupApps \
		--vm-name $appVMName \
		--name OmsAgentForLinux \
		--publisher Microsoft.EnterpriseCloud.Monitoring \
		--version 1.7 --protected-settings '{"workspaceKey": "$logAnalyticsKey"}' \
		--settings '{"workspaceId": "$logAnalyticsId"}'	--no-wait
done
