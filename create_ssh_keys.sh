#! /bin/bash
#Purpose : To install ansible and jenkins in master Node
#Version : v1
#Created Date :  Wed Sep 27 08:50:05 AM IST 2023
#Author : Narendra Kaduru
############### START ###############
set -x
read -rp "Please provide user name: " user
read -rsp "Please provide the password for $user: " password
echo # Print a newline to separate input from output

# Read a list of hosts from the user and store them in an array
read -rp "Please provide a list of remote hosts (space-separated): " host_list
IFS=" " read -ra hosts <<< "$host_list"

# Get the current hostname
current_hostname=$(hostname)

key_file="/home/$user/.ssh/id_rsa"

# Check if the current hostname is $host
if [ "$current_hostname" == "master" ]; then

	# Install Jenkins
	curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | sudo tee \
		/usr/share/keyrings/jenkins-keyring.asc > /dev/null
		
	echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
		https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
		/etc/apt/sources.list.d/jenkins.list > /dev/null

	sudo apt-get update

	sudo apt-get install -y jenkins	sshpass ansible
	
    echo "Hostname is $host, generating SSH keys..."
    ssh-keygen -t rsa -N "" -f "$key_file"
    echo "SSH key pair generated at: $key_file"
	
	# Copy the public key to the remote host if specified
    for host in "${hosts[@]}"; do
		sshpass -p "$password" ssh-copy-id -i "$key_file" "$user@$host"
	done
else
    echo "Current hostname is not $host. No action taken."
fi
###############  END  ###############