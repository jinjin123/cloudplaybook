import subprocess


class ProcessResult(object):
    """
    Return object for ProcessHelper
    """
    def __init__(self, returncode, stdout, stderr):
        self._returncode = returncode
        self._stdout = stdout
        self._stderr = stderr
    @property
    def returncode(self):
        return self._returncode

    @property
    def stdout(self):
        return self._stdout

    @property
    def stderr(self):
        return self._stderr

class ProcessHelper(object):
#Helper to simplify command line execution
   def __init__(self, cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, env=None, cwd=None,userid=None):
    self._cmd = cmd
    self._stdout = stdout
    self._stderr = stderr
    self._cwd = cwd
    if not env:
     customEnv = os.environ.copy()
     if userid:
       customEnv["AWS_CONFIG_FILE"] ="/root/.aws/%s_config"%(userid)
     else:
       customEnv["AWS_CONFIG_FILE"] ="/root/.aws/config"
     self._env = customEnv
    else:
     self._env = env   
    
   def call(self):
#Calls the command, returning a tuple of (returncode, stdout, stderr)
     process = subprocess.Popen(self._cmd, stdout=self._stdout, stderr=self._stderr,env=self._env,shell=True)
     returnData = process.communicate()
     return ProcessResult(process.returncode, returnData[0], returnData[1])

