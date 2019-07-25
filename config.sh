
#Environment
environmentName="fastdata-mex"
subscription="ca3d18ab-d373-4afb-a5d6-7c44f098d16a"
region="westus"

#Networking Addressing
hubVnetGatewaySubnetPrefix="10.0.0.0/24"
coreVnetHDISubnetPrefix="10.1.0.0/24"
coreVnetElasticSubnetPrefix="10.2.0.0/24"
coreVnetWafSubnetPrefix="10.3.0.0/24"
coreVnetAPPSubnetPrefix="10.4.0.0/24"

#ResourceGroups
resGroupNetworking=$environmentName"-rg-net"
resGroupOAM=$environmentName"-rg-oam"
resGroupHDI=$environmentName"-rg-hdi"
resGroupElastic=$environmentName"-rg-elastic"
resGroupApps=$environmentName"-rg-apps"

#Networking Names
subnetNameHDI="subnet-hdi"
subnetNameElastic="subnet-elastic"
subnetNameWAF="subnet-waf"
subnetNameAPP="subnet-app"

hubVnet=$environmentName"-vnet-hub"
coreVnet=$environmentName"-vnet-core"
vpnGwName=$environmentName"-vpn-gw"
vpnGwPubIPAddressName=$environmentName"-vpn-gw-pub-ip"
appGwName=$environmentName"-app-gw"
appGwPubIPAddressName=$environmentName"-app-gw-pub-ip"
appGwDeployment=$environmentName"-deployment-app-gw"
appGwSku="WAF_v2"
appGwCertName=$environmentName"-app-gw-cert"
appGwHTTPSListenerName=$environmentName"-app-gw-https-listener"
appGwHTTPSFrontEndPortName=$environmentName"-app-gw-https-port"
appGwRuleName=$environmentName"-app-gw-rule"

#APP VMs
appVMsAvSetName=$environmentName"-app-vms-av-set"
appVMsNamePrefix=$environmentName"-app-vm-"
appVMsNumVMs=5
appVMsSize="Standard_D4s_v3"
appVMsUser="proadminecu"
appVMsPass="Proadminecu1_proadminecu"
appVMsInstallScript="app-vm.sh"

#HDI
storageAccountNameHDI=$(echo $environmentName | sed 's/\-//g')"hdi"
kafkaClusterName="kafka-hdi-"$environmentName
kafkaContainer=$environmentName"-kafka"
kafkaVersion="3.6.1000.67"
kafkaHTTPPassword="S3rg10_s3rg10"
kafkaHTTPUser="sergio"
kafkaSSHPassword="S3rg10_s3rg10"
kafkaSSHUser="sergio"
kafkaHeadNodeCount=3
kafkaHeadNodeSize="Standard_D3v2"
kafkaWorkerNodeSize="Standard_D4v2"
kafkaWorkerNodeCount=3
kafkaWorkerDiskCount=2
kafkaZookeeperNodeCount=2
zookeperNodeSize="Standard_D3v2"
kafkaDeploymentName=$environmentName"-kafka-deployment"

sparkClusterName="spark-hdi-"$environmentName
sparkContainer=$environmentName"-spark"
sparkDeploymentName=$environmentName"-spark-deployment"
sparkVersion="3.6.1000.67"
sparkHTTPPassword="S3rg10_s3rg10"
sparkHTTPUser="sergio"
sparkSSHPassword="S3rg10_s3rg10"
sparkSSHUser="sergio"
sparkHeadNodeSize="Standard_D3v2"
sparkWorkerNodeSize="Standard_D4v2"
sparkWorkers=3

#OAM
logAnalyticsWorkspaceName=$environmentName"-log-analytics"
logAnalyticsDeployment=$environmentName"-deployment-log-analytics"
recoveryVaultName=$environmentName"-recovery-services-vault"
storageAccountScripts=$(echo $environmentName | sed 's/\-//g')"scripts"
blobContainerScripts="scripts"

#TEMPLATES
templateLogAnalytics="template-log-analytics.json"
templateAppGw="template-app-gw.json"
templateAppVM="template-app-vm.json"
templateKafka="template-hdi-kafka.json"
templateSpark="template-hdi-spark.json"