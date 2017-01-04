# Separating clone_repo into anothe recipe to perform code reuse/function aliked action
git "clone_repo" do
  user node[:deploycode][:code_owner]
  group node[:deploycode][:code_group]
  repository node[:deploycode][:de_gitrepo]
  depth 10
  retries 1
  retry_delay 30
  action :nothing
  destination node[:deploycode][:localfolder_de]
#  checkout_branch 'master'
  enable_checkout false
end
