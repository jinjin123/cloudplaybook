#!/usr/bin/python
from  gfunc import args


class Demo(object):
      def __init__(self):
         pass
      
#@args('version',nargs='?',default='versiondefault',help='version help')


      @args([{"PositionPara":"version","NamePara":"nargs=?,default=versiondefault,help=version help"}])
      def status(self,version=None):
          print 'hello,this is a complete test case!'
     

#@args('version',nargs='?',default='versiondefault',help='version help')



      @args([{"PositionPara":"-l,--listall","NamePara":"help=list info,dest=listdest"},
             {"PositionPara":"-a","NamePara":"help=high,dest=aaa"}
])
      def list(self,listdest="",aaa=""):
          print 'list ok!'
          print 'parameter:listdest,parameter:%s'%(listdest)

