#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupNetworking
module="elastic"

export AZURE_ELASTIC_VM_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet $coreVnet --name $subnetNameElastic --query id -o tsv)

echo "CREATING INTERNAL LB"
az network lb create -n $elasticInternalLB -g $resGroupName --sku Standard --subnet $AZURE_ELASTIC_VM_SUBNET_ID \
	--tags module=$module

echo "CREATING EXTERNAL LB"
az network lb create -n $elasticExternalLB -g $resGroupName --sku Standard --public-ip-address-allocation static \
	--tags module=$module

INTERNAL_BACKEND_ADDRESS_POOL_ID=$(az network lb show -n $elasticInternalLB -g $resGroupName --query "backendAddressPools[0].id" -o tsv)
EXTERNAL_BACKEND_ADDRESS_POOL_ID=$(az network lb show -n $elasticExternalLB -g $resGroupName --query "backendAddressPools[0].id" -o tsv)
EXTERNAL_FRONTENT_IP_CONFIG_ID=$(az network lb show -n $elasticExternalLB -g $resGroupName --query "frontendIpConfigurations[0].id" -o tsv)

echo "ADDING NICs TO INTERNAL LB"
az network nic list --query "[?tags.module=='elastic' && tags.roleName=='nodes'].{name:name,rg:resourceGroup,ipConfig:ipConfigurations[0].name}" \
	-o tsv | while read nicName rg ipConfig
	do 
		az network nic update -g $rg -n $nicName --add ipConfigurations[name=${ipConfig}].loadBalancerBackendAddressPools id=${INTERNAL_BACKEND_ADDRESS_POOL_ID}
	done

echo "ADDING PROBES TO INTERNAL LB"
az network lb probe create --lb-name $elasticInternalLB -g $resGroupName --protocol Tcp --port 9200 --name "$elasticInternalLB-probe-Tcp-9200"
az network lb probe create --lb-name $elasticInternalLB -g $resGroupName --protocol Tcp --port 9300 --name "$elasticInternalLB-probe-Tcp-9300"

echo "ADDING RULES TO INTERNAL LB"
port=9200
az network lb rule create --lb-name $elasticInternalLB -g $resGroupName --protocol Tcp --frontend-port $port --backend-port $port --name "$elasticInternalLB-rule-Tcp-$port" --probe-name "$elasticInternalLB-probe-Tcp-$port"
port=9300
az network lb rule create --lb-name $elasticInternalLB -g $resGroupName --protocol Tcp --frontend-port $port --backend-port $port --name "$elasticInternalLB-rule-Tcp-$port" --probe-name "$elasticInternalLB-probe-Tcp-$port"

echo "ADDING NICs TO EXTERNAL LB"
az network nic list --query "[?tags.module=='elastic' && tags.roleName=='nodes'].{name:name,rg:resourceGroup,ipConfig:ipConfigurations[0].name}" \
	-o tsv | while read nicName rg ipConfig
	do 
		az network nic update -g $rg -n $nicName --add ipConfigurations[name=${ipConfig}].loadBalancerBackendAddressPools id=${EXTERNAL_BACKEND_ADDRESS_POOL_ID}
	done

echo "ADDING OUTBOUND RULE IN EXTERNAL LB"
az network lb outbound-rule create --lb-name $elasticExternalLB -g $resGroupName -n outbound-rule-elastic-nodes --address-pool $EXTERNAL_BACKEND_ADDRESS_POOL_ID --protocol All --frontend-ip-configs $EXTERNAL_FRONTENT_IP_CONFIG_ID
