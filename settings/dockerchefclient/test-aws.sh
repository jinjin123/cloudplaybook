#!/bin/bash

./runchefclientdocker.sh kycloud20170810001 '
{
    "deploycode": {
      "basedirectory": "/root/tools/code/",
      "configuration": {
        "aws": {
          "action": "create",
          "credentials": {
            "awskey": "AKIAOAAU6MUOPBRPIGTA",
            "awssecret": "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",
            "region": "cn-north-1"
          },
          "kylin": {
            "clusterWorkerNodeCount": "1",
            "kaptoken": "dda18812-e57b-47f1-8aae-38adebecde8a",
            "identifier": "kycloud20170810001",
            "region": "cn-north-1",
            "instancetype": "m4.large",
            "clusterLoginUserName": "admintest",
            "clusterLoginPassword": "Kyligence2016",
            "appType": "KAP+KyAnalyzer+Zeppelin",
            "keypair": "kylin",
            "keypairprivatekey": "-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEAtSiICsAN2TNdi5lBGeF2KdvOR2mwO7fP3JZ3jr2ct7VsqZMvT7lyRiRjEgvC
tSJWuiXpTVUZsEVie8Kji4PDR0C1y3CdNzp7oP2+/88u6xDnPb9TDk8fIFKv69zVdXuwTQ8mHgkk
BL9NjnZgfGLBwEXkEBBRdNBKUA7XjMJjlp5NCnJVKTxJO42f5TK3xn8ge8F3QvDF4SyaEoyc98CI
X7O74zombSQ8cc73/eEhkxfNGguLw6DWmcCeLUVfjaGSTi/yrcERtpLeKObB+DsCmUkzT0SA9k4B
UnCm1H0YUL3ujA1OXQDHbVgenqSFKgEEzdgo1GaWaaMCSKsIsKSrGwIDAQABAoIBAQCEXUoReMRl
mCdYkbDEhT0+VnGBMlLnP2XsSjCvJhH1FOWBfZ6LBPffEkUk8Vzh1mZB+uNdcrmjVv8faFbw4GR1
km2CaRUmPmAIgH7nEG26qY4cSsgX423dwyzxDFkXTznBBDmYppsfsNutJQdYuxvQLgD2T8YEsRAr
ML0EByCW8nab08F07+4KTEGfeITUcm+AqxHBSmZZjhPTus+AyS9HDdwD0kt06UJCrOaCp8/Z5L9Z
mvjk9MP+LeyPUz1W5NPCTVSYZVNaQ+LdifDpbjf9kvSERLsTNp4JDRKBDwoGv8wLW4XvXXWfIjmg
TzWcuVxA8vJzuCvSdY7ZsABvDZeZAoGBANuBGkuHLiYEQlxNwd9sPwG3J+YLnyeXQ2qP5q/IMNae
VQ6UnNocWKgHf/Q+i8fMBVbb1SGfPphFiRG/hDtgOykcfnbSEcy8ZOA/Iv6c64SeiU/ub27YZUml
PwDZwbDIR3g54PjdCo+lJd0IYSLrQ7mQIuPJ4pXeLrN6toaQx0DFAoGBANNHSPcgVvfaKwAf7VK1
uhT9RBMoURSNC6JTOtTTWO2aqF4qHVusiVsuCQ8zgjk3QfjEZiRtxwS9mb900VpE1i3gw07zt0o9
dEg/vK6ye+fVjobbUmCM5YekqpB+GZInVGMRlrh7+LF3vNnSIrKoIMkleRNJTCHOGOiVwH1cWzpf
AoGBALqCmlsuw7Gd0N0pXOCA05CblhVMLrGvP6NeHn+iNI1H/7Hh6N0TVOmBZeGc+5yK6MaDCDgH
XWJ5QxyHhM4G2H34LiS8Hk++jGBWhV+e6ifHpZj7WkfvKzFGbaBFZuTVaJTpaRVMjFq90sxbAF5x
VRxpMpwmwJbjMP9j94+jmQqZAoGAHkco/cF0tTBe2TW6HRBOCpQBHX25oOhVsn2bAMUJCYQQfO4s
JucjCB4gzjzjfK+elLgQq0fQLa2+SuHC3tzelNSRKM9khQ8pivEXaTHK7/563niv5YZLnpTKnMp1
f6yDO29Z2jZp/YTbW5vxvQi7KhhksY7fijiu+SX83/pMWKECgYAtV6iAPkWQYkexklKZLGNOGgFn
3W1cMAMJA/UXjx/oYlg3wPeziTEHlNbzm4oDYN1h8BP+sRMVv1AwGvkjd+/QK64JYHQ2pkVxv1jT
XFy/2fQLYOkmVgTuklRlLkEd4m+tAnkHOhP0KHe9cEAq8DqufEsCh26I3rT2vJihKaCKCw==
-----END RSA PRIVATE KEY-----"
          }
        }
      }
    }
}
'
