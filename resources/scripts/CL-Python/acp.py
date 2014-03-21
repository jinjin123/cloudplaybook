#!/usr/bin/python
import sys
import argparse


### load external functions
from gfunc import get_para_as_string 
from gfunc import custom_methods_of
from gfunc import fetch_priority_arg
from gfunc import fetch_func_args



### load custom classes
from Demo import Demo
from Stack import Stack

### custom dict of command line name to custom Class,the key is the command line name ,the value is name of the class
### note: relational item should be add to this dict when new custom class is defined!




COMMANDS_TO_CLASS = {
	"demo" : "Demo",
        "stack": "Stack"
}




def main(command):
   #  print command
   #  sys.exit(1)
     
     topParser = argparse.ArgumentParser(description='package aws command line',prog='acp')
     topParser.add_argument("-v","--version",help="Version of acp",action="store_true")
     subparsers = topParser.add_subparsers(title='sub-commands',description='valid subcommands',help='additional help',dest='subparser_name')
     for category in COMMANDS_TO_CLASS:
         # print category
         command_object = eval("%s()"%(COMMANDS_TO_CLASS[category]))
         category_parser = subparsers.add_parser(category)
         category_subparsers = category_parser.add_subparsers(dest='action')
         for(action,action_fn) in custom_methods_of(command_object):
             parser = category_subparsers.add_parser(action)
             action_kwargs = []
             for args,kwargs in getattr(action_fn,'args',[]):
                 #print args
                 #print kwargs
                 argslist = args[0]
                 
                 #print argslist
                 #sys.exit(1)
                 for argInfo in argslist:
                   positionArg = argInfo.get("PositionPara")
                   nameArg = argInfo.get("NamePara")
                   parameters = get_para_as_string(positionArg,nameArg)
                   
                   eval("parser.add_argument(%s)"%(parameters))  
             parser.set_defaults(action_fn=action_fn)
             parser.set_defaults(action_kwargs=action_kwargs)

     match_args = topParser.parse_args(command.split())
     #print match_args

     #sys.exit(0)  
     fn = match_args.action_fn
     fn_args = fetch_func_args(fn,match_args)
     #print fn_args
     fn(*fn_args)

if __name__=="__main__":
  carg = sys.argv[1:]
  #print carg
  main(' '.join(carg))
