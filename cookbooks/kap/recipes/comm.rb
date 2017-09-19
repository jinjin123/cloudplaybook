require 'date'


def get_time_prefix
  now = Time.now
  now_str = now.strftime("[%Y-%m-%d %H:%M:%S]")
end

def get_log_prefix(title)
  now = Time.now
  now_str = now.strftime("[%Y-%m-%d %H:%M:%S]")
  prefix = now_str + " " + title + " "
end

#function: output result log of important operation to processlog
def result_log(title, message, processlog, returnflagfile)
  logprefix = get_log_prefix(title)
  execute "operation_success" do
    command "echo '#{logprefix} #{message} result:[success]' >> #{processlog}"
    only_if { ::File.exist?(returnflagfile)}
  end
  execute "operation_failed" do
    command "echo '#{logprefix} #{message} result:[failed]' >> #{processlog}"
    not_if { ::File.exist?(returnflagfile)}
  end
  ruby_block "manual_fatal" do
    block do
      Chef::Application.fatal!("chefclient is mannually aborted due to failure of execute ", 42) if not ::File.exist?(returnflagfile)
    end
    action :run
  end
  file "#{returnflagfile}" do
    action :delete
    ignore_failure true
  end
end

# just put the message to procees log without check the returnflagfile
def result_pure_log(title, message, processlog)
  logprefix = get_log_prefix(title)
  execute "result_pure_log" do
    command "echo '#{logprefix} #{message}' >> #{processlog}"
  end
end
