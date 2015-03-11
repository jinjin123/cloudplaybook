# Separating clone_repo into anothe recipe to perform code reuse/function aliked action
git "clone_repo" do
     user node[:deploycode][:code_owner]
           group node[:deploycode][:code_group]
           repository node[:deploycode][:gitrepo]
           depth 10
           retries 3
           retry_delay 30
           action :nothing
           destination node[:deploycode][:localsourcefolder]
           checkout_branch nil
     end
