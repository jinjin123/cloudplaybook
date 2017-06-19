#!/bin/bash

./runchefclientdocker.sh jackytesting1 '
{
  "deploycode": {
    "basedirectory": "/root/tools/code/",
    "configuration": {
      "azure": {
        "scheme": "",
        "action": "create",
        "credentials": {
          "token": {
            "tokenType": "Bearer",
            "expiresIn": 3599,
            "expiresOn": "2017-06-16T07:03:21.996Z",
            "resource": "https://management.core.chinacloudapi.cn/",
            "accessToken": "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im0yZmFQUUZkQzFEVGRmWU1pb09kaHdSblFUMCIsImtpZCI6Im0yZmFQUUZkQzFEVGRmWU1pb09kaHdSblFUMCJ9.eyJhdWQiOiJodHRwczovL21hbmFnZW1lbnQuY29yZS5jaGluYWNsb3VkYXBpLmNuLyIsImlzcyI6Imh0dHBzOi8vc3RzLmNoaW5hY2xvdWRhcGkuY24vMDYzZGI0MjAtMDE0Zi00NDY1LWFhMGMtNTM2OTQ5Mzk5NzUyLyIsImlhdCI6MTQ5NzU5NDcyMSwibmJmIjoxNDk3NTk0NzIxLCJleHAiOjE0OTc1OTg2MjEsImFjciI6IjEiLCJhaW8iOiJBU1FBMi84QUFBQUFpUnJDNm5IdFdBWnZ2TU9rS3dpVmE5TDVHaGZ5SXZQaUlVVkd1WkFjTnVRPSIsImFtciI6WyJwd2QiXSwiYXBwaWQiOiJmOWUxMmRlMC05MmVjLTQ0NGQtYjA4Ni1iZWFjNWE3NzgzOWIiLCJhcHBpZGFjciI6IjEiLCJlX2V4cCI6MjYyODAwLCJmYW1pbHlfbmFtZSI6IkxpdSIsImdpdmVuX25hbWUiOiJLYWlnZSIsImdyb3VwcyI6WyI5NmY4NjFkNS00NmYxLTQ0Y2UtODI4YS0xY2RjMWJhNzQyNjEiXSwiaXBhZGRyIjoiNDcuOTAuNDEuMTI5IiwibmFtZSI6IkthaWdlIExpdSIsIm9pZCI6IjQ2NTVhMTFhLTdhMjEtNGQwOS1hNjEyLWZkMWVhNGJkYWM2ZSIsInBsYXRmIjoiNSIsInB1aWQiOiIyMDAzQkZGRDgxMEU3OTVFIiwic2NwIjoidXNlcl9pbXBlcnNvbmF0aW9uIiwic3ViIjoiMlNMaWhuRTA4QUg1QTNFTXVJakpmSUZkMnVLWjVaX0dhMW1JdkktaERtRSIsInRpZCI6IjA2M2RiNDIwLTAxNGYtNDQ2NS1hYTBjLTUzNjk0OTM5OTc1MiIsInVuaXF1ZV9uYW1lIjoia2FpZ2UubGl1QGt5bGlnZW5jZS5wYXJ0bmVyLm9ubXNjaGluYS5jbiIsInVwbiI6ImthaWdlLmxpdUBreWxpZ2VuY2UucGFydG5lci5vbm1zY2hpbmEuY24iLCJ2ZXIiOiIxLjAifQ.TzNu7GE8aghjlv0PVtZZsv54KqU_ZwC6b0pCGXlI9dLG2rlkgIeYHcq0BqnVg37DPv5JXHIgFa-TlcEI1dkYCHAIgVX1gyFPtYIarXgMQaG5x0UCAc4ORvdCl_QYBRxOfcTcjPY1zF9yd1FbxvEOPsMyyymWJhh9buoPswJF2iF1FTtUJZx1Q9bw87UoezcRuMOT3i6ZKprjGqJqWtlGWzeRvZAopeV5ZX_VULyVhwa9hKglVKiQb_mAI4k94qTkfSquvzwlworxFT6EG2CgLiENQAVyZcH0VsVzkQhhelMHik4H1oB1ayqV1OTNYeHxiqmZKCpg1MSe2Wx1nEGiAg",
            "refreshToken": "AQABAAAAAACrHKvrx7G2SaZbZh-tDnp73N4v9mnurY9WuQapHAbzbfk-n5c0ZUSRctBC9vuvPM5NyMYsrN6iJRc7NYJImfCKS-uIKqMsZhnpmlYaV8SGL-JX3xhSRxZPWoajsBYjiNZbXLzr_e1KRPAeGZxwfCS6rK9yFy_vxc9ZET6O-YgtlQEYeeEgixMVYs-Pf_jMecj3ZSIPTMPtpFUZZ6X5NR7AmOX2NlY_tlMhdR5zUvSzo8UeO0N5Qb611hpxMWhVzCFgtUsnDAvqti49WEwn8wVD2u6mOLlimpXSxIjnhgrgoBWMjaycpfe2y7rfq--aC686_qQRS4yGi2yvijImJ2lBXVwJJ8KcWtESBBauP7GT622f58HHLtu4BPuwxk54-MRTsCZyh7bKXc4VwmVjtoD7Zc2ONhx4qlFw7vrkHeClLQTpQW9J1RnJgmdQcbfbVwR_o6TLMWAuID_il__DBygzmpeCnWAh_8bO7GyZoGefZVKsdJfH-xZzIGIgwB5XfTdImhFiP_q0eHdovOhSoeSWf4arRFJY_RpUTb4JMH9_ewaMlpmJZM1I0Txz4Pj_PzxYJ-WfHOW_ndinXToYNXa9hlMQdTd8cubMwjixlvqnhog3BtZddRNH82xXvzHBhKrsdo3jI--I5dXh0Ogr-bvjsTK4j3l4vSOsk_J-2JOE5_ZFRWcaKQK5VGr6fwTwKTP15PHpUG2uvXeZNYb4wJb6wXgYs2-6Z4aKaUZUMKxksHqt9-Cc9z1vWc93R-JTNB43mXaCGJqXgyeRurdy5c1kIAA",
            "userId": "kaige.liu@kyligence.partner.onmschina.cn",
            "oid": "4655a11a-7a21-4d09-a612-fd1ea4bdac6e",
            "_clientId": "f9e12de0-92ec-444d-b086-beac5a77839b",
            "_authority": "https://login.chinacloudapi.cn/common",
            "isMRRT": true
          },
          "profile": {
            "environments": [],
            "subscriptions": [
              {
                "id": "ff95e2d0-3c52-4a0a-b280-eacc8e645367",
                "name": "Pay-In-Advance",
                "user": {
                  "name": "kaige.liu@kyligence.partner.onmschina.cn",
                  "type": "user"
                },
                "tenantId": "",
                "state": "Enabled",
                "isDefault": true,
                "registeredProviders": [],
                "environmentName": "AzureChinaCloud"
              }
            ]
          }
        },
        "kylin": {
          "identifier": "kgtest3",
          "region": "chinanorth",
          "kaptoken": "",
          "cluster": true,
          "appType": "KAP",
          "clusterLoginUserName": "kaige",
          "clusterLoginPassword": "Admin@2017",
          "clusterName": "c57586kgtest3",
          "clusterName2": "",
          "clusterType": "hbase",
          "clusterVersion": "3.5",
          "clusterWorkerNodeCount": 2,
          "storageAccount": "c57586kgtest3sa",
          "storageAccount1": "",
          "storageAccount2": "",
          "containerName": "default",
          "edgeNodeSize": "Standard_D3",
          "metastoreName": "c57586kgtest3",
          "sshUserName": "kaige",
          "sshPassword": "Admin@2017",
          "vnetName": ""
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
}'
