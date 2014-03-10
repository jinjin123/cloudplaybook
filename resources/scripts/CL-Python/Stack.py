#!/usr/bin/python
import boto
import json

from boto.cloudformation.connection import CloudFormationConnection

from gfunc import args
from gfunc import check_user_credential


from DataDefine import StackGroup


#def check_user_credential(userid="",accessKey="",secretKey="",region=""):

TEMPLATE = {
	"VPC" : "/home/ec2-user/templates/vpc.template",
	"RDS" : "/home/ec2-user/templates/rds_mysql.template",
	"GLUSTERFS" : "/home/ec2-user/templates/glusterfs.template",
	"CHEFSERVER" : "/home/ec2-user/templates/chefServer.template",
	"CHEFCLIENT" : "/home/ec2-user/templates/chefClient.template"
}

class Region():
  def __init__(self,region):
    self.name=region
    self.endpoint = 'cloudformation.%s.amazonaws.com' % region


class Stack(object):
  def __init__(self):
    pass

  @args([{"PositionPara":"-A,--accessid","NamePara":"help=aws access key id,dest=accessid,required=True"},
         {"PositionPara":"-S,--secretid","NamePara":"help=aws secret key id,dest=secretid,required=True"},
         {"PositionPara":"-R,--region","NamePara":"help=aws region,dest=region,required=True"},
         {"PositionPara":"-n,--stackname","NamePara":"help=aws cloudformation stack name,dest=stackname,required=True"},
         {"PositionPara":"-p,--parameters","NamePara":"help=parameters of cloudformation stack,dest=parameters,nargs=?,const=N,default=N"},
         {"PositionPara":"-T,--template","NamePara":"help=template type of cloudformation,dest=templatetype,required=True"}
])
  def create(self,accessid="",secretid="",region="",stackname="",parameters="",templatetype=""):
    print "accessid=%s,secretid=%s,region=%s,stackname=%s,parameters=%s,templatetype=%s"%(accessid,secretid,region,stackname,parameters,templatetype)
    awsregion = Region(region)
    templateFile = open(TEMPLATE.get(templatetype),'r')
    json_data = json.loads(templateFile.read())
    templateBody = json.dumps(json_data)
    templateFile.close()
    cfn  =  CloudFormationConnection(aws_access_key_id=accessid,aws_secret_access_key=secretid,region=awsregion)
    if parameters == 'N':
      cfn.create_stack(stackname,template_body=templateBody,capabilities=['CAPABILITY_IAM'])
    else:
      print("you input parameters:%s!"%(parameters))
 
  @args([
	 {"PositionPara":"-A,--accessid","NamePara":"help=aws access key id,dest=accessid,required=True"},
         {"PositionPara":"-S,--secretid","NamePara":"help=aws secret key id,dest=secretid,required=True"},
         {"PositionPara":"-R,--region","NamePara":"help=aws region,dest=region,required=True"},
         {"PositionPara":"-n,--stackname","NamePara":"help=aws cloudformation stack name,dest=stackname,required=True"}
])
  def describe_stacks(self,accessid="",secretid="",region="",stackname=""):
    awsregion = Region(region)
    cfn = CloudFormationConnection(aws_access_key_id=accessid,aws_secret_access_key=secretid,region=awsregion)
    stack = cfn.describe_stacks(stack_name_or_id=stackname)  
    print stack
    print type(stack)
    print dir(stack)
    print stack.statu
  
  @args([
         {"PositionPara":"-A,--accessid","NamePara":"help=aws access key id,dest=accessid,required=True"},
         {"PositionPara":"-S,--secretid","NamePara":"help=aws secret key id,dest=secretid,required=True"},
         {"PositionPara":"-R,--region","NamePara":"help=aws region,dest=region,required=True"}
])
  def listall(self,accessid="",secretid="",region=""):
   print accessid,secretid,region
   region_  = Region(region)
   stackGroup = StackGroup(accessid,secretid,region_)
   stackGroup.fetchStackGeneralInfos()
   stackGroup.fetchStacksReInfos()
   print stackGroup.getJsonStacks()

    
