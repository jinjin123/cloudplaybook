import os
import sys
if(len(sys.argv)!=5):
 print 'you need to input access key,secret key ,region and useId in order'
 print 'sample input:'
 print 'python ConfigureAWS-Cli.py AXAXWXWSAAS SESDFGQERG/AasdfWDF ap-northeast-1 101\n'
 sys.exit(0)

#print os.environ['HOME']

homeDir = os.environ['HOME']
configDir = "%s/.aws"%(homeDir)
configFileName=""
if sys.argv[4]!="0":
  configFileName = "%s_config" % (sys.argv[4])
else:
  configFileName = "config" 
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
line += "%s\n" % (sys.argv[1])
line += "aws_secret_access_key = "
line += "%s\n" % (sys.argv[2])
line += "region = "
line += "%s\n" % (sys.argv[3])
#os.chdir(configDir)
configFile = open(configFileLocation,"w")
configFile.write(line)
configFile.close()
os.system("chmod 600 %s"%(configFileLocation))
#flag = os.system("cat %s/.bash_profile | grep %s"%(homeDir,configFileLocation)
flag =  os.system('cat %s/.bash_profile | grep %s'%(homeDir,configFileLocation))
#print type(flag)
if flag!=0:
  envSet = ("export AWS_CONFIG_FILE=%s"%(configFileLocation))
  os.system("echo %s >> %s/.bash_profile"%(envSet,homeDir))
print 'config success!'
print 'to make settings take effect immediately ,you should run : source %s/.bash_profile' % (homeDir)

