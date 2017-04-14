###真功夫服务器列表
* version: 1.1
* 该文档请只保留在自己的电脑上，不要上传到任何的云服务器或者云盘！！
* 一般情况下，每个服务器都使用keepalived做了高可用。名字里带v的，一般都是virtual ip.
* 重要！！该文档维护人员，如果改文档有任何更新，请邮件更新到相关人员。

| ENV | IP | Name | root-password | spark-password | software |
| --- | ------| ------ | ------ | --- | --- |
| dev | 172.16.104.205| test.zkf.vpn | 222222 | 222222 | software |
| dev | 172.16.104.204| dev.zkf.vpn | 222222 | 222222 | docker,nginx,php,mysql |
| stage | 172.16.104.207| prod.zkf.vpn | 222222 | 222222 | docker,nginx,php,mysql |
| stage | 172.16.104.123| mq-rabbitmq.zkf.vpn | 222222 | 222222 | docker,nginx,php,mysql |
| stage | 172.16.104.124| oc.zkf.vpn | 222222 | 222222 | docker,nginx,php,mysql |
| stage | 172.16.104.125| fe.zkf.vpn | 222222 | 222222 | docker,nginx,php,mysql |
| stage | 172.16.104.126| cdmp.zkf.vpn | 222222 | 222222 | docker,nginx,php,mysql |
| stage | 172.16.104.121| mysql-oc.zkf.vpn | 222222 | 222222 | mysql |
| stage | 172.16.104.122| mysql-cdmp.zkf.vpn | 222222 | 222222 | docker,mysql |
| prod | 172.16.102.119 | nfs1.zkf.vpn | sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nfs|
| prod | 172.16.102.120 | nfs2.zkf.vpn | sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nfs|
|prod|172.16.102.118 | nfsv.zkf.vpn | sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nfs|
|prod|172.16.102.103 | fcd.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nfs|
|prod|172.16.102.101 | fe1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.102 | fe2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.100 | fev.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.104 | cc1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.105 | cc2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.106 | ccv.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.109 | cdmp1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.111 | cdmp2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.108 | cdmpv.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.113 | cdmpd.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |nginx,php,mysql |
|prod|172.16.102.114 | oc1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |tomcat, nginx |
|prod|172.16.102.115 | oc2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |tomcat, nginx |
|prod|172.16.102.116 | ocv.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |tomcat, nginx |
|prod|172.16.102.117 | ocd.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |
|prod|172.16.102.121 | mq1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |docker, rabbitmq, mq|
|prod|172.16.102.123 | mq2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |docker, rabbitmq, mq|
|prod|172.16.102.122 | mqv.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |docker, rabbitmq, mq|
|prod|172.16.103.185 | ocdb1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|
|prod|172.16.103.187 | ocdb2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|
|prod|172.16.103.186 | ocdbv.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|
|prod|172.16.103.189 | cdmpdb1.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|
|prod|172.16.103.190 | cdmpdb2.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|
|prod|172.16.103.121 | erp-crmdb1.zkf.vpn | Cb/+JSeNTctdziWrvh8KIA | N/A |mysql|
|prod|172.16.103.123 | erp-crmdb2.zkf.vpn | Cb/+JSeNTctdziWrvh8KIA | N/A |mysql|
|prod|172.16.103.122 | erp-crmdbv.zkf.vpn | Cb/+JSeNTctdziWrvh8KIA | N/A |mysql|
|prod|172.16.102.228 | de1.zkf.vpn | 1qaz@WSX |AMvyE#Yuf#jPr58R |docker, php, nginx|
|prod|172.16.102.229 | de2.zkf.vpn | 1qaz@WSX | AMvyE#Yuf#jPr58R |docker, php, nginx|
|prod|172.16.102.230 | dev.zkf.vpn | 1qaz@WSX | AMvyE#Yuf#jPr58R |docker, php, nginx|
|prod|172.16.102.112 | erp-crm1.zkf.vpn | jlM5oonL3zWN3GWP@J4H5hYXGXl|4SYx2ZwlINUS8B3kv1+Sp8gQe|docker, php, nginx|
|prod|172.16.102.113 | erp-crm2.zkf.vpn | jlM5oonL3zWN3GWP@J4H5hYXGXl|4SYx2ZwlINUS8B3kv1+Sp8gQe|docker, php, nginx|
|prod|172.16.102.115 | erp-crmv.zkf.vpn | jlM5oonL3zWN3GWP@J4H5hYXGXl|4SYx2ZwlINUS8B3kv1+Sp8gQe|docker, php, nginx|
|prod|172.16.103.203 | rpdbs.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|
|prod|172.16.103.207 | rpocd.zkf.vpn| sbl6CewNOZB2vy3c | AMvyE#Yuf#jPr58R |mysql|