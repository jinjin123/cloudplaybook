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
