#!/bin/bash

./runchefclientdocker.sh 20170815000000 '
{
    "deployuser": "root",
    "projectname": "kyligence",
    "docker": {
      "privaterepo": "dockerpriv.kybot.io:5002",
      "username": "keithyau",
      "password": "thomas123"
    },
    "deploycode": {
      "basedirectory": "/root/tools/code/",
      "configuration": {
        "azure": {
          "action": "removeall",
          "scheme": "allinonevnet",
          "credentials": {
            "env": "AzureChinaCloud",
            "username": "jacky.chan@kycloud.partner.onmschina.cn",
            "password": "Kyligence2016"
          },
          "kylin": {
            "kapagentid": "testf254cdea-a5f0-4d24-b151-a5b77a43408a",
            "kaptoken": "dda18812-e57b-47f1-8aae-38adebecde8a",
            "identifier": "20170815000000",
            "region": "chinaeast",
            "appType": "KAP+KyAnalyzer+Zeppelin",
            "app":{
              "appType":"KAP+KyAnalyzer+Zeppelin",
              "kapUrl":"https://kyhub.blob.core.chinacloudapi.cn/packages/kap/kap-2.4.4-GA-hbase1.x.tar.gz",
              "KyAnalyzerUrl":"https://kyhub.blob.core.chinacloudapi.cn/packages/kyanalyzer/KyAnalyzer-2.4.0.tar.gz",
              "ZeppelinUrl":"https://kyhub.blob.core.chinacloudapi.cn/packages/zeppelin/zeppelin-0.8.0-kylin.tar.gz"
            },
            "clusterLoginUserName": "admintest",
            "clusterLoginPassword": "Kyligence2016",
            "clusterName": "default",
            "clusterType": "hbase",
            "clusterVersion": "3.5",
            "clusterWorkerNodeCount": 2,
            "containerName": "default",
            "edgeNodeSize": "Standard_D3_V2",
            "metastoreName": "default",
            "sshUserName": "admintest",
            "sshPassword": "Kyligence2016",
            "storageAccount": "20170815000000sa"
          }
        }
      }
    }
}
'
