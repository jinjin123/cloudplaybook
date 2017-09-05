require 'date'

def get_time_prefix
  now = Time.now
  now_str = now.strftime("[%Y-%m-%d %H:%M:%S]")
end

def get_log_prefix(identifier)
  now = Time.now
  now_str = now.strftime("[%Y-%m-%d %H:%M:%S]")
  prefix = now_str + " " + identifier + ""
end

#function: output result log of important operation to processlog
def result_log(identifier, message, processlog, returnflagfile)
  logprefix = get_log_prefix(identifier)
  execute "operation_success" do
    command "echo '#{logprefix} #{message} result:[success]' >> #{processlog}"
    only_if { ::File.exist?(returnflagfile)}
  end
  execute "operation_failed" do
    command "echo '#{logprefix} #{message} result:[failed]' >> #{processlog} && ech --deploy_resouce_faild."
    not_if { ::File.exist?(returnflagfile)}
  end
  file "#{returnflagfile}" do
    action :delete
    ignore_failure true
  end
end

# just put the message to procees log without check the returnflagfile
def result_pure_log(identifier, message, processlog)
  logprefix = get_log_prefix(identifier)
  execute "result_pure_log" do
    command "echo '#{logprefix} #{message}' >> #{processlog}"
  end
end
