# CONSUL SETUP


# First time run follwoing command 
ansible-playbook consul_openstack_play.yml -u <user_id> -i <host_fIle>  --private-key <key_Path> --skip-tags "server"
	# skip-tags server means you are running one server as a bootstrap.

# Not first time.
ansible-playbook consul_openstack_play.yml -u <user_id> -i <host_fIle>  --private-key <key_Path> --skip-tags "bootstrap"
        # skip-tags bootstrap means you are running all the server as server[ if any one of the server is failed it would fix it].

# Note:
  Please update the Consul_host file with your IP addresses.
  also roles/consul/vars/main.yml file to match varibales to your IP addresses.
