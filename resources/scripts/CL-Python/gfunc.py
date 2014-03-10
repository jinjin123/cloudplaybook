#!/usr/bin/python
import sys,os

# create user credential file in home directory

def create_user_credential(userid="",accessKey="",secretKey="",region=""):
  homeDir = os.environ['HOME']
  configDir = "%s/.aws"%(homeDir)
  configFileName = "%s_config" % (userid)
  configFileLocation = "%s/%s"%(configDir,configFileName)

#print homeDir
#print configDir
#print configFileLocation
  os.system("mkdir -p %s"%(configDir))
  if os.path.isfile(configFileLocation):
   print 'aws config already exist!'
   sys.exit(0)

  line =""
  line += "[default]\n"
  line += "aws_access_key_id = "
  line += "%s\n" % (accessKey)
  line += "aws_secret_access_key = "
  line += "%s\n" % (secretKey)
  line += "region = "
  line += "%s\n" % (region)
  configFile = open(configFileLocation,"w")
  configFile.write(line)
  configFile.close()
  os.system("chmod 600 %s"%(configFileLocation))

 
#check if the user has configed his aws credential file,if not ,then create it

def check_user_credential(userid="",accessKey="",secretKey="",region=""):
  homeDir = os.environ['HOME']
  configFileLocation = "%s/.aws/%s_config"%(homeDir,userid)
  if os.path.isfile(configFileLocation):
    return True
  else:
    create_user_credential(userid=userid,accessKey=accessKey,secretKey=secretKey,region=region)
    return False 
  

#modifier of custom class functions
def args(*args,**kwargs):
    def _decorator(func):
        func.__dict__.setdefault('args',[]).insert(0,(args,kwargs))
        return func
    return _decorator

#convert two string into input parameters which will be user by argparser 's function add_argument
def get_para_as_string(parg,narg):
  if parg=="":
    print "PositionPara could not be blank!"
    sys.exit(1)
  paraString = ""
  parglist = parg.split(",")
  transParglist = []
  for arg in parglist:
    transParglist.insert(0,"\'%s\'"%(arg))
  frontString = ",".join(transParglist)
  narglist = narg.split(",")
  transNarglist = []
  for argn in narglist:
    index  = argn.find("=")
    if index==-1:
      print "function parameters form error! parameter : %s" %(argn)
      sys.exit(1)
    transNarg = argn[:index+1] +"\'"+argn[index+1:]+"\'"
    transNarglist.insert(0,transNarg)
  tailString =  ",".join(transNarglist)
  paraString  = frontString
  if tailString:
    paraString += ","+tailString
  return paraString


def custom_methods_of(obj):
    result =[]
    for i in dir(obj):
      if callable(getattr(obj,i)) and not i.startswith('_'):
        result.append((i,getattr(obj,i)))
    return result


def fetch_priority_arg(arg=[],kwargs={}):
  priority_arg = ""
  if arg or kwargs:
    if kwargs.has_key("dest"):
      priority_arg = kwargs.get("dest")
    else :
      for var in arg:
        if var.startswith("--"):
          priority_arg = var[var.find("--")+2:]
          break
        elif var.startswith("-"):
          priority_arg = var[var.find("-")+1:]
    return priority_arg


def fetch_func_args(func,matchargs):
    fn_args=[]
    for args,kwargs in getattr(func,'args',[]):
        argslist = args[0]
        adict = {}
        alist = []

        for arginfo in argslist:
          pString  = arginfo.get("PositionPara")
          argInput = pString.split(",")

          nString = arginfo.get("NamePara")
          kwargs = {}
          if nString:
            pairs = nString.split(',')
            for pairInfo in pairs:
              pairInfoList = pairInfo.split('=')
              kwargs.setdefault(pairInfoList[0],pairInfoList[1])

          arg= fetch_priority_arg(args,kwargs)
        #print matchargs
          fn_args.append(getattr(matchargs,arg))
    return fn_args




