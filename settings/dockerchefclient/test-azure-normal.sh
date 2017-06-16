#!/bin/bash

./runchefclientdocker.sh 20170615000002 '
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
          "credentials": {
            "env": "AzureChinaCloud",
            "username": "jacky.chan@kycloud.partner.onmschina.cn",
            "password": "Kyligence2016"
          },
          "kylin": {
            "kaptoken": "dda18812-e57b-47f1-8aae-38adebecde8a",
            "identifier": "20170615000002",
            "region": "chinaeast",
            "appType": "KAP+KyAnalyzer+Zeppelin",
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
            "storageAccount": "20170615000002sa"
          }
        }
      }
    }
}
'
