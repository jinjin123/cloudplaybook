from DataDefine import *

stackGroup = StackGroup()


stackGroup.fetchStackGeneralInfos()
stackGroup.fetchStacksReInfos()

#for stackKey in stackGroup._stacks.keys():
#  print ("stack name %s"%(stackKey))
#  stackIn = stackGroup._stacks.get(stackKey)
#  for reKey in stackIn._resources.keys():
#   res = stackIn._resources.get(reKey)
#   print ("Resource Type: %s Resource id %s"%(res._resourceType,res._physicalResourceId))
  


jsonResult = stackGroup.getJsonStacks()
print jsonResult
#cache = ElastiCache()
#nodeEndpoints = cache.adptNodeUrl("clo-ca-yl4h0hp3bmim.crhznq.cfg.apne1.cache.amazonaws.com",11211,2)
#pint nodeEndpoints
