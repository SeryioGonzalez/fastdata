#!/bin/bash

source config.sh
az account set --subscription $subscription

for rg in $(set | grep "resGroup" | cut -d= -f2)
do
	echo "Deleting in $region for subscription $subscription RG $rg"
	az group delete --yes --no-wait --name $rg --subscription $subscription 
done
