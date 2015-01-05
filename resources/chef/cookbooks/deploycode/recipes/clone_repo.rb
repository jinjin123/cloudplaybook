# Separating clone_repo into anothe recipe to perform code reuse/function aliked action
        git "clone_repo" do
                user node[:deploycode][:code_owner]
                group [:deploycode][:code_group]
                repository node[:deploycode][:gitrepo]
                depth 1
                retries 3
                retry_delay 30
                reference "master"
                action :sync
                destination node[:deploycode][:localsourcefolder]
        end
