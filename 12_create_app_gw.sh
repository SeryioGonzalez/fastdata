#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupNetworking
module="appgw"

#Getting subnetId para APP GW
export AZURE_WAF_SUBNET_ID=$(az network vnet subnet show -g $resGroupNetworking --vnet $coreVnet --name $subnetNameWAF --query id -o tsv)

#Create APP GW
echo "Creating app gw pub ip"
az network public-ip create -g $resGroupName --name $appGwPubIPAddressName --sku Standard --tags module=appvms
publicIPId=$(az network public-ip show -g $resGroupName --name $appGwPubIPAddressName --query "id" -o tsv)

#List APP VM IPs
listOfIPs=$(az network nic list -g $resGroupApps --query "[].ipConfigurations[].privateIpAddress" -o tsv | tr '\n' ' ')


echo "Creating app gw"
az network application-gateway create -g $resGroupName --name $appGwName --subnet $AZURE_WAF_SUBNET_ID \
	--public-ip-address $publicIPId --sku $appGwSku --servers $listOfIPs --tags module=appvms

echo "Creating app gw ssl cert"
az network application-gateway ssl-cert create -g $resGroupName --gateway-name $appGwName --name $appGwCertName --cert-file crypt/certificate.pfx --cert-password "sergio" 

echo "Creating app gw ssl port"
az network application-gateway frontend-port create -g $resGroupName --gateway-name $appGwName --name $appGwHTTPSFrontEndPortName --port 443

echo "Creating app gw ssl listener"
az network application-gateway http-listener create -g $resGroupName --gateway-name $appGwName --name $appGwHTTPSListenerName --frontend-port $appGwHTTPSFrontEndPortName --frontend-ip appGatewayFrontendIP --ssl-cert $appGwCertName
	
echo "Creating app gw probes"
az network application-gateway probe create -g $resGroupName --gateway-name $appGwName -n "healthprobe-9001" --protocol http --host-name-from-http-settings true --path "/consumption/*" --timeout 30 --threshold 3
az network application-gateway probe create -g $resGroupName --gateway-name $appGwName -n "healthprobe-9002" --protocol http --host-name-from-http-settings true --path "/timeline/*"    --timeout 30 --threshold 3

echo "Creating app gw http settings"
az network application-gateway http-settings create -g $resGroupName --gateway-name $appGwName -n "httpsetting-9001" --protocol http --port 9001 --probe "healthprobe-9001" --timeout 20 --host-name-from-backend-pool true
az network application-gateway http-settings create -g $resGroupName --gateway-name $appGwName -n "httpsetting-9002" --protocol http --port 9002 --probe "healthprobe-9002" --timeout 20 --host-name-from-backend-pool true

echo "Create url-path-map"
az network application-gateway url-path-map create -g $resGroupName --gateway-name $appGwName \
  --name $appGwRuleName --paths /consumption/*  \
  --address-pool appGatewayBackendPool --default-http-setting appGatewayBackendHttpSettings --http-settings httpsetting-9001 --rule-name 9001-consumption-rule

echo "Add rule to url-path-map"
az network application-gateway url-path-map rule create -g $resGroupName --gateway-name $appGwName \
  --name 9002-timeline-rule \
  --path-map-name $appGwRuleName \
  --paths /timeline/* \
  --address-pool appGatewayBackendPool \
  --http-settings httpsetting-9002 > /dev/null 

echo "Create rule with url-path-map"
az network application-gateway rule create -g $resGroupName --gateway-name $appGwName -n $appGwRuleName --rule-type PathBasedRouting --http-listener $appGwHTTPSListenerName --http-settings appGatewayBackendHttpSettings --url-path-map $appGwRuleName

echo "Delete default settings - rule 1"
az network application-gateway rule delete          -g $resGroupName --gateway-name $appGwName -n rule1

echo "Delete default settings - listener"
az network application-gateway http-listener delete -g $resGroupName --gateway-name $appGwName -n appGatewayHttpListener
