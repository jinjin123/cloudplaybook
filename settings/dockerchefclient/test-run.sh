#!/bin/bash

./runchefclientdocker.sh 20170516000000 '
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
          "scheme": "separated",
          "credentials": {
            "env": "AzureChinaCloud",
            "username": "jacky.chan@kycloud.partner.onmschina.cn",
            "password": "Kyligence2016@"
          },
          "kylin": {
            "identifier": "20170516000000",
            "region": "chinaeast",
            "cluster": true,
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
            "storageAccount": "20170516000000sa"
          }
        }
      },
      "localfolder": {
        "azure-cli": "nodownload"
      },
      "runtime": {
        "azure": {
          "tag": "latest",
          "image": "dockerpriv.kybot.io:5002/keithyau/azure-cli",
          "mountlocal": "localdir",
          "mountdocker": "/templates"
        }
      }
    }
}
'
