#!/bin/bash

./runchefclientdocker.sh 20170615000aws '
{
    "deploycode": {
      "basedirectory": "/root/tools/code/",
      "configuration": {
        "aws": {
          "credentials": {
            "awskey": "AKIAOLKR63OA4735DYJA",
            "awssecret": "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",
            "region": "cn-north-1"
          },
          "kylin": {
            "kaptoken": "dda18812-e57b-47f1-8aae-38adebecde8a",
            "identifier": "20170615000aws",
            "region": "cn-north-1",
            "appType": "KAP+KyAnalyzer+Zeppelin",
            "keypair": "kylin"
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
            "storageAccount": "20170615000awssa"
          }
        }
      }
    }
}
'
