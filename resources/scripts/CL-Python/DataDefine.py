import os,sys,re,json,subprocess,time,StringIO
import logging,logging.config


from ProcessHelper import ProcessHelper
from ProcessHelper import ProcessResult

import boto
from boto.cloudformation.connection import CloudFormationConnection
import boto.rds2
import boto.elasticache
import boto.ec2
#boto.set_stream_logger('hello')
#boto.config.debug=0



logging.config.fileConfig('logger.conf')
log=logging.getLogger('fetchinfo')

#log.error("error occured!")

ResourceType2Class={
 "AWS::EC2::Instance":"Ec2",
 "AWS::RDS::DBInstance":"Rds",
 "AWS::ElastiCache::CacheCluster":"ElastiCache"
}
FilterResources=[
 "AWS::EC2::Instance",
 "AWS::RDS::DBInstance",
 "AWS::ElastiCache::CacheCluster"
]


class Resource:
 def __init__(self,father,prd="",lrd="",rs="",rt="",lut=""):
  self._physicalResourceId=prd
  self._logicalResourceId=lrd
  self._resourceStatus=rs
  self._resourceType=rt
  self._lastUpdateTimestamp=lut
 
  self._dataInfo={} #save resource information in dict
 
  self._owner = father

 def onFetchInfoFailed(self):
  self._resourceStatus = "ABNORMAL"
 
 def getInfo(self):
  self._dataInfo.setdefault("PhysicalResourceId",self._physicalResourceId)
  self._dataInfo.setdefault("LogicalResourceId",self._logicalResourceId)
  self._dataInfo.setdefault("ResourceStatus",self._resourceStatus)
  self._dataInfo.setdefault("ResourceType",self._resourceType)
  self._dataInfo.setdefault("LastUpdateTimestamp",self._lastUpdateTimestamp)
  return self._dataInfo

class Ec2(Resource):
 def __init__(self,father,cprd="",clrd="",crs="",crt="",clut="",it="",pdn="",pia="",kn=""):
  Resource.__init__(self,father,prd=cprd,lrd=clrd,rs=crs,rt=crt,lut=clut)
  self._instanceType=it
  self._publicDnsName=pdn
  self._privateIpAddress=pia
  self._keyName=kn
 
  self._conn = None

 def getConn(self,region,accessKey,secretKey):
   if self._conn:
     return self._conn
   else:
     self._conn = boto.ec2.connect_to_region(region,aws_access_key_id=accessKey,aws_secret_access_key=secretKey)
     return self._conn
   


 def getInfo(self):
  Resource.getInfo(self)
  self._dataInfo.setdefault("InstanceType",self._instanceType)
  self._dataInfo.setdefault("PublicDnsName",self._publicDnsName)
  self._dataInfo.setdefault("PrivateIpAddress",self._privateIpAddress)
  self._dataInfo.setdefault("KeyName",self._keyName)
  return self._dataInfo
  

 def setDetailedInfo(self,info):
  if info:
   self._instanceType = info.instance_type
   
   self._publicDnsName = info.public_dns_name
   self._privateIpAddress = info.private_ip_address
   self._keyName=info.key_name

 def fetchDetailedInfo(self):
   region = self._owner._owner._region
   accessKey = self._owner._owner._accessKey
   secretKey = self._owner._owner._secretKey
   conn = self.getConn(region.name,accessKey,secretKey)

   try:
     
     ec2Results = conn.get_all_instances(instance_ids=[self._physicalResourceId])
     ins =  ec2Results[0].instances[0]
     self.setDetailedInfo(ins)
   except :
     log.error("fetch resource info failed ,resource id %s"%(self._physicalResourceId))
     Resource.onFetchInfoFailed(self)
  
class ElastiCache(Resource):
 def __init__(self,father,cprd="",clrd="",crs="",crt="",clut="",ce="",cep="",cnt="",ncn="",cp=""):
  Resource.__init__(self,father,prd=cprd,lrd=clrd,rs=crs,rt=crt,lut=clut)
  self._cacheEngine=ce
  self._configureEndpoint=cep
  self._cacheNodeType=cnt
  self._numCacheNodes=ncn
  self._cachePort = cp
  self._nodesUrl = []

  self._conn = None

 def getConn(self,region,accessKey,secretKey):
   if self._conn:
     return self._conn
   else:
     self._conn = boto.elasticache.connect_to_region(region,aws_access_key_id=accessKey,aws_secret_access_key=secretKey)
     return self._conn

 def getInfo(self):
  Resource.getInfo(self)
  self._dataInfo.setdefault("CacheEngine",self._cacheEngine)
  self._dataInfo.setdefault("ConfigureEndpoint",self._configureEndpoint)
  self._dataInfo.setdefault("CacheNodeType",self._cacheNodeType)
  self._dataInfo.setdefault("NumCacheNodes",self._numCacheNodes)
  self._dataInfo.setdefault("CachePort",self._cachePort)
 
  self._nodesUrl = self.adptNodeUrl(self._configureEndpoint,self._cachePort,self._numCacheNodes)
  self._dataInfo.setdefault("NodesUrl",self._nodesUrl)
  return self._dataInfo
  
   
 
 def adptNodeUrl(self,endpoint,port,nodeNum):
  nodeUrls = []
  if endpoint and port and nodeNum:
   configPigList = endpoint.split(".")
   headString=""
   tailString=""
   changeFlag=False
   for value in configPigList:
    if value=="cfg":
     changeFlag=True
     continue
    if changeFlag:
     tailString += "."+value
    else:
     headString += value+"."
   for i in range(1,nodeNum+1):
    middleString="{0:0>4d}".format(i) 
    nodeEndpoint = headString+middleString+tailString+":"+str(port)
    nodeUrls.append(nodeEndpoint)
  return nodeUrls

 def setDetailedInfo(self,info={}):
  self._cacheEngine= info.get("Engine")
  self._configureEndpoint= info.get("ConfigurationEndpoint").get("Address")
  self._cacheNodeType = info.get("CacheNodeType")
  self._numCacheNodes = info.get("NumCacheNodes")
  self._cachePort = info.get("ConfigurationEndpoint").get("Port")
  
 def onFetchInfoFailed(self):
   self._resourceStatus = "abnormal"
 
 def fetchDetailedInfo(self):
  region = self._owner._owner._region
  accessKey = self._owner._owner._accessKey
  secretKey = self._owner._owner._secretKey
  cacheConn = self.getConn(region.name,accessKey,secretKey)
  try:
    cacheResults = cacheConn.describe_cache_clusters(cache_cluster_id=self._physicalResourceId)
    cacheInfo = cacheResults.get("DescribeCacheClustersResponse").get("DescribeCacheClustersResults").get("CacheClusters")[0]
    self.setDetailedInfo(cacheInfo)
  except :
    log.error("fetch resource info failed resource id : %s"%(self._physicalResourceId))
    Resource.onFetchInfoFailed(self)
  
  
class Rds(Resource):
 def __init__(self,father,cprd="",clrd="",crs="",crt="",clut="",re="",rev="",dic="",rep="",rp="",ct="",mun=""):
  Resource.__init__(self,father,prd=cprd,lrd=clrd,rs=crs,rt=crt,lut=clut)
  self._rdsEngine=re
  self._rdsEngineVersion=rev
  self._dbInstanceClass=dic
  self._rdsEndpoint=rep
  self._rdsPort=rp
  self._createTime=ct
  self._masterUsername=mun

  self._conn = None

 def getConn(self,region,accessKey,secretKey):
   if self._conn:
     return self._conn
   else:
     self._conn = boto.rds2.connect_to_region(region,aws_access_key_id=accessKey,aws_secret_access_key=secretKey)
     return self._conn

  
 def getInfo(self):
  Resource.getInfo(self)
  self._dataInfo.setdefault("RdsEngine",self._rdsEngine)
  self._dataInfo.setdefault("RdsEngineVersion",self._rdsEngineVersion)
  self._dataInfo.setdefault("DBInstanceClass",self._dbInstanceClass)
  self._dataInfo.setdefault("RdsEndpoint",self._rdsEndpoint)
  self._dataInfo.setdefault("RdsPort",self._rdsPort)
  self._dataInfo.setdefault("CreateTime",self._createTime)
  self._dataInfo.setdefault("MasterUserName",self._masterUsername)
  return self._dataInfo 

 def setDetailedInfo(self,info={}):
  if info:
   self._rdsEngine = info.get("Engine")
   self._rdsEngineVersion = info.get("EngineVersion")
   self._dbInstanceClass= info.get("DBInstanceClass")
   self._rdsEndpoint= info.get("Endpoint").get("Address")
   self._rdsPort = str(info.get("Endpoint").get("Port"))
   self._createTime = info.get("InstanceCreateTime")
   self._masterUsername = info.get("MasterUsername")

 def fetchDetailedInfo(self):
  region = self._owner._owner._region
  accessKey = self._owner._owner._accessKey
  secretKey = self._owner._owner._secretKey
  rdsConn = self.getConn(region.name,accessKey,secretKey)
 
  try:
    rdsResults = rdsConn.describe_db_instances(db_instance_identifier=self._physicalResourceId)
    info = rdsResults.get("DescribeDBInstancesResponse").get("DescribeDBInstancesResult").get("DBInstances")[0]
    self.setDetailedInfo(info)
  except :
    log.error("fetch resource info failed,resource id %s"%(self._physicalResourceId))
    Resource.onFetchInfoFailed(self)
  
  
 @property
 def physicalResourceId(self):
     return self._physicalResourceId
 
 def setGeneralInfo(self,info):
  self._physicalResourceId=info.physicalResourceId
  self._logicalResourceId=info.logicalResourceId
  self._resourceStatus=info.resourceStatus
  self._resourceType=info.resourceType
  self._lastUpdateTimestamp=info.lastUpdateTimestamp

class Stack:
 def __init__(self,owner,sid="",sname="",sst="",ctt=""):
  self._stackId= sid
  self._stackName=sname
  self._stackStatus=sst
  self._creationTime=ctt
  self._parameters={}
  self._resources={}
   
  self._dataInfo={}
  self._resInfos={}
  
  self._owner = owner
 def setParameters(self,info):
  self._parameters = info
  
  
 def getResourcesInfo(self):
  for resKey in self._resources.keys():
   self._resInfos.setdefault(self._resources.get(resKey)._physicalResourceId,self._resources.get(resKey).getInfo())
  return self._resInfos
  
 def getInfo(self):
  self._dataInfo.setdefault("StackId",self._stackId)
  self._dataInfo.setdefault("StackName",self._stackName)
  self._dataInfo.setdefault("StackStatus",self._stackStatus)
  self._dataInfo.setdefault("CreationTime",self._creationTime)
  self._dataInfo.setdefault("Parameters",self._parameters)
  self._dataInfo.setdefault("Resources",self.getResourcesInfo())
  return self._dataInfo

   
 def fetchStackGeneralResourceInfos(self):
  if None == self._stackName or "" == self._stackName:
   log.error("Stack Instance didn't get general info yet!")
   sys.exit(1)
  
  cfc = self._owner.getCfConnection()
  refResults = cfc.list_stack_resources(self._stackName)
  for ref in refResults:
    resourceType = ref.resource_type
    resourceClassName = ""
    resourceInitString = ""
    needDetailedInfo = False
     
    if resourceType not in FilterResources:
      continue
     
    if ResourceType2Class.has_key(resourceType):
        resourceClassName=ResourceType2Class.get(resourceType)
        needDetailedInfo = True
        resourceInitString = "{0}(self,cprd='{1}',clrd='{2}',crs='{3}',crt='{4}',clut='{5}')"
    else:
        resourceClassName="Resource"
        resourceInitString="{0}(self,prd='{1}',lrd='{2}',rs='{3}',rt='{4}',lut='{5}')"
    res = eval(resourceInitString.format(
                              resourceClassName,
                              ref.physical_resource_id,
                              ref.logical_resource_id,
                              ref.resource_status,
                              ref.resource_type,
                              ref.last_updated_time
                          )
                        )
    if needDetailedInfo: #fetch detailed info using specified command base on resource
      if ref.resource_type == "AWS::EC2::Instance":
       res.fetchDetailedInfo()
    self._resources.setdefault(res._physicalResourceId,res)
        

def convertResultSet2Dic(paras):
  result ={}
  if paras:
    for paraInfo in paras:
      result.setdefault(paraInfo.key,paraInfo.value)
  return result
     
def convertParameters2Dic(paras):
 result= {}
 if paras:
  paraLists = list(paras)
  for p in paras:
   if p.has_key("ParameterKey") and p.has_key("ParameterValue"):
    result.setdefault(p["ParameterKey"],p["ParameterValue"])
   else:
    continue
 return result


class Region():
  def __init__(self,region):
    self.name =region
    self.endpoint = 'cloudformation.%s.amazonaws.com' % region

class StackGroup:
 def __init__(self,accesskey,secretkey,region):
  self._stacks = {}
  self._stackGroupInfo={}

  self._accessKey=accesskey
  self._secretKey=secretkey
  self._region =region

  self._cfConnection =None


 def getCfConnection(self):
   if self._cfConnection:
     return self._cfConnection
   else:
     self._cfConnection = CloudFormationConnection(aws_access_key_id=self._accessKey,aws_secret_access_key=self._secretKey,region = self._region)
     return self._cfConnection  

  
 def setCredential(sefl,accesskey,secretkey,region):
   self._accessKey = accesskey
   self._secretkey = secretkey
   self._region = region
 
 def getJsonStacks(self):
  if not self._stackGroupInfo:
   self.getStackGroupInfo()
   #print self._stackGroupInfo
   #sys.exit(0)
  return json.dumps(self._stackGroupInfo)
 
 def getStackGroupInfo(self):
  for stackKey in self._stacks.keys():
   self._stackGroupInfo.setdefault(stackKey,self._stacks.get(stackKey).getInfo())
  
 def fetchStackGeneralInfos(self):

  cf = self.getCfConnection()
  resultStacks = cf.describe_stacks()
  for stack in resultStacks:
  #  if stack.stack_name == "NewChefServer":
 #     pp = stack.parameters
 #     convertResultSet2Dic(pp)
 #     for var in stack.parameters:
 #        print var
#      sys.exit(0)
    if stack.stack_status != "CREATE_COMPLETE":
      continue
    stackInstance = Stack(self,sid=stack.stack_id,sname=stack.stack_name,sst=stack.stack_status,ctt=str(stack.creation_time))
    parameters = convertResultSet2Dic(stack.parameters)
    stackInstance.setParameters(parameters)
    self._stacks.setdefault(stack.stack_name,stackInstance)    
#  sys.exit(0)

 def fetchStacksReInfos(self):
  for stackKey in self._stacks.keys():
   stackInstance = self._stacks.get(stackKey)
   stackInstance.fetchStackGeneralResourceInfos()
   
  
  
if __name__ == "__main__":
  region  = Region("ap-northeast-1")
  stackGroup = StackGroup('AKIAIMX7UYHK6NZVYBLQ','SZOYFiyQQaUxBzGirfGdvyZC5oHU3yVpxjLcYVPf',region)
  stackGroup.fetchStackGeneralInfos()
  stackGroup.fetchStacksReInfos()
  print stackGroup.getJsonStacks()
   #print 'helloworld'  
  
