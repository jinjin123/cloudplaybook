#!/bin/bash

./runchefclientdocker.sh kycloud20170802000 '
{
    "deploycode": {
      "basedirectory": "/root/tools/code/",
      "configuration": {
        "aws": {
          "action": "removeall",
          "credentials": {
            "awskey": "AKIAJZXGXX235NVY4QSQ",
            "awssecret": "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",
            "region": "ap-southeast-1"
          },
          "kylin": {
            "kaptoken": "dda18812-e57b-47f1-8aae-38adebecde8a",
            "identifier": "kycloud20170802000",
            "region": "ap-southeast-1",
            "appType": "KAP+KyAnalyzer+Zeppelin",
            "keypair": "kylin",
            "keypairprivatekey": "-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAqRgw8Sxit/3B/vaCSXlN61DLBaUP3Ifj2BU2doCk5d1zRRkR
7LY/Q0RoKHyREnad7sUY4BbK2LjXxVMN3H04KFonFefQ2XImPlFlDot+SvXZzZEd
b3VJxZwBmBu7nWQoQBFSZ1JXMiOBTzyjEbijhluE2MSBs4plu0gncd5nl5XSCwX8
oQ5MYtEGwyo9bH+CB21SdieM7NupIWu+Sh4V57DMzbztZjAL+pWYPEmoRmynArSp
A22q0raISj3oxIBJKeS7GRRu8sPYzR3sCrGaz/Yn0CAi0bvcG6/xAAZ5pGO7l0bZ
LW3I8SR9RINvlQTg4nSy6xXi5HE4XY7UNmmIsQIDAQABAoIBAEQRDdp3QIHJ7yZ/
+nAzGU+JJUBvclQWi3v3BgZrwHUbUIRXFCUSM6MTTU5G3mrtPqPXySyjYCIfPhQb
W7AO4+UybRtfRm3Ril15jFFvi3YHQxaBvLSaJQkbxHSDbWFs6NrpXh9jQOBY9Ht9
8DJ4/bJe8roDWCZ6pnreD6rBmTemGu67yktWlLqN4YKdeM0GkQjYZVngpHJg1Qpx
aBDGqxmPEG2KCYfQDZqm24L6JUMQTeuUEWe7v287MDFB42HE/eNVTTMhpxgZF0/X
RTiiE5l1u6smeEN3i+qSPHjlSDspKnz0Fg7dAYpe6non0Ei9ZxhO7S5yMHoo/Mqa
jsKCnTECgYEA1CfHABbTOam9GJnRglwleb3SSwGV9q8sr9bWLWr8KySZguOEHcLe
8mje0xne/XAydaecPVld3mWbIggvYFvm5wr0nFFMsley4Thdg2FuQ6owU9jyVUOB
a/gsFq57nLoEJHk2quASZJxyJy2M8dlLS2jCOJ1C8dCT4F6N3/+QX50CgYEAzAo/
uUVacgO0fcZ0K2He/FQIfOFXIwaU7KAA+Vow3z3ESntKoHprLhiOPCyoXN0QJ8n0
FtCatYFzPscswSQnTpLtb9BcJZXkbAd3UWvQkcsEpm+LoF/kzAO+KddVTjvm9EO3
+0UCz3B+eFqJ0m8JoibLzOGLLoUHEjqIumg6YyUCgYBY7b+FswuhPRwthrSCbzuq
Nz5CAI0q1SznHCe07AZ90x6h9dp4Wyn29KyKUmrdUz1jgfmE4cPuKCsJ7eJmAr/c
EwSLzaxXiVlK/MR+AMYmiN0vGF4kDWLfrixU6ZiZDoQUAdc/cyNilw1mjLpq2gms
t2HKN2lLUYHa5+eSgF61JQKBgDALmcW+lvWR+cZEHMa6XQ99miINzb7ppdeyNYiB
vFBU8wu2zHPNX7+S+KsiuOJlC5DS9S8KH+Ptf32g2OEB6l+OKWrS3V/cU9U8TNRX
Vt19uLKYQYCaE/4WQ4kGs4egg1mxOHlqXqcKDj241AtBKjuMdyDfWy6xFGEud1Ot
h1IhAoGBAJj0AZ28ELENmK3bYeXrhL6ai3zh6ZnWfj7dO9+OQPGQe+NqugXo3z2B
f4Td1ScVCq/mpsGtN/rh00q1+l+PTukRpk5ZkfqGb4c4/OUwb6NToznFTPlYqXf7
n8pQmzUCissZFP2YTsz4D8GmLXDKdz0LnwL7MAR90v1GkG+oQkiJ
-----END RSA PRIVATE KEY-----"
          }
        }
      }
    }
}
'
