#!/bin/bash

source config.sh
az account set --subscription $subscription

resGroupName=$resGroupNetworking
module="networking"

#Hub VNET
echo "Creating hub vnet"
az network vnet create -g $resGroupName -n $hubVnet \
	--address-prefixes $hubVnetGatewaySubnetPrefix \
	--tags module=$module vnet="hub" \
	--subnet-name "GatewaySubnet" --subnet-prefix $hubVnetGatewaySubnetPrefix 

#VPN GW
echo "Creating vpn-gw"
az network public-ip create    -g $resGroupName -n $vpnGwPubIPAddressName --tags module=$module node="vpn-gw"
az network vnet-gateway create -g $resGroupName -n $vpnGwName --vnet $hubVnet --public-ip-addresses $vpnGwPubIPAddressName --tags module=$module node="vpn-gw" --sku "VpnGw1" --no-wait 

#Core VNET
echo "Creating core vnet"
az network vnet create -g $resGroupName -n $coreVnet \
	--address-prefixes $coreVnetHDISubnetPrefix $coreVnetElasticSubnetPrefix $coreVnetWafSubnetPrefix $coreVnetAPPSubnetPrefix \
	--tags module=$module vnet="core" 
az network vnet subnet create -g $resGroupName --vnet-name $coreVnet --name $subnetNameHDI --address-prefix $coreVnetHDISubnetPrefix 
az network vnet subnet create -g $resGroupName --vnet-name $coreVnet --name $subnetNameElastic --address-prefix $coreVnetElasticSubnetPrefix 
az network vnet subnet create -g $resGroupName --vnet-name $coreVnet --name $subnetNameWAF     --address-prefix $coreVnetWafSubnetPrefix
az network vnet subnet create -g $resGroupName --vnet-name $coreVnet --name $subnetNameAPP     --address-prefix $coreVnetAPPSubnetPrefix 

#Creating peerings
echo "Creating vnet peerings"
az network vnet peering create -g $resGroupNetworking --vnet-name $hubVnet --remote-vnet $coreVnet --name  "hub-to-core" --allow-gateway-transit
az network vnet peering create -g $resGroupNetworking --vnet-name $coreVnet --remote-vnet $hubVnet --name  "core-to-hub" --use-remote-gateways