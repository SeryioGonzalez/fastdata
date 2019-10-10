
#Environment
environmentName="fastdata-de"
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
elasticInternalLB=$environmentName"-internal-lb-elastic"
elasticExternalLB=$environmentName"-external-lb-elastic"

hubVnet=$environmentName"-vnet-hub"
coreVnet=$environmentName"-vnet-core"
vpnGwName=$environmentName"-vpn-gw"
vpnGwPubIPAddressName=$environmentName"-vpn-gw-pub-ip"
appGwName=$environmentName"-app-gw"
appGwPubIPAddressName=$environmentName"-app-gw-pub-ip"
appGwDeployment=$environmentName"-deployment-app-gw"
appGwSku="Standard_v2"
appGwCertName=$environmentName"-app-gw-cert"
appGwHTTPSListenerName=$environmentName"-app-gw-https-listener"
appGwHTTPSFrontEndPortName=$environmentName"-app-gw-https-port"
appGwRuleName=$environmentName"-app-gw-rule"

#APP VMs
appVMsAvSetName=$environmentName"-app-vms-av-set"
appVMsNamePrefix=$environmentName"-app-vm-"
appVMsNumVMs=5
appVMsSize="Standard_D4s_v3"
appVMsUser="proadministradorss"
appVMsPass="NeedToPutAKeyVault"
appVMsInstallScript="app-vm.sh"

#Elastic-Node
elasticVMsAvSetName=$environmentName"-elastic-node-vms-av-set"
elasticVMsNamePrefix=$environmentName"-elastic-node-vm"
elasticDataNumVMs=4
elasticVMsSize="Standard_D4s_v3"
elasticVMsUser="proadministradorss"
elasticVMsPass="NeedToPutAKeyVault"
elasticVMsInstallScript="elastic-vm.sh"

#Elastic-Master
elasticMasterVMsAvSetName=$environmentName"-elastic-master-vms-av-set"
elasticMasterVMsNamePrefix=$environmentName"-elastic-master-vm"
elasticMasterNumVMs=2
elasticMasterVMsSize="Standard_D4s_v3"
elasticMasterVMsUser="proadministradorss"
elasticMasterVMsPass="NeedToPutAKeyVault"
elasticMasterVMsInstallScript="elastic-master-vm.sh"

#Elastic-Kibana
elasticKibanaVMsAvSetName=$environmentName"-elastic-kibana-vms-av-set"
elasticKibanaVMsName=$environmentName"-elastic-kibana-vm"
elasticKibanaVMsSize="Standard_D4s_v3"
elasticKibanaVMsUser="proadministradorss"
elasticKibanaVMsPass="NeedToPutAKeyVault"
elasticKibanaVMsInstallScript="elastic-kibana-vm.sh"

#HDI
hdiClusterHTTPPassword="Sergito_sameple_password_putKeyVault2"
hdiClusterHTTPUser="sergio"
hdiClusterSSHPassword="Sergito_sameple_password_putKeyVault2"
hdiClusterSSHUser="sergio"

hdiKafkaDeploymentName=$environmentName"-hdi-kafka-deployment"
hdiKafkaWorkerNodeSize="Standard_A4_v2"


hdiSparkDeploymentName=$environmentName"-hdi-spark-deployment"
hdiSparkWorkerNodeSize="Standard_A4_v2"

hdiClusterNameSuffix="hdi-"$environmentName
hdiClusterHeadNodeCount=3
hdiClusterHeadNodeSize="Standard_D3v2"
hdiClusterWorkerNodeCount=3
hdiClusterWorkerDiskCount=8
hdiClusterZookeeperNodeCount=3
hdiClusterZookeeperNodeSize="Standard_D3v2"
hdiSparkVersion="2.1"

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
templateElasticVM="template-elastic-vm.json"
templateElasticKibanaVM="template-elastic-kibana-vm.json"
templateHDIKafka="template-hdi-kafka.json"
templateHDISpark="template-hdi-spark.json"
