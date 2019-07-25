
source config.sh

for rg in $(set | grep "resGroup" | cut -d= -f2)
do
	echo "Creating in $region for subscription $subscription RG $rg"
	az group create --name $rg --location $region --subscription $subscription --tags environment=$environmentName
done
