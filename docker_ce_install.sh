#!/bin/bash

action=$1

docker_fingerprint=0EBFCD88

function remove_old_versions {

	echo "#${FUNCNAME[0]} $@"
	# Remove old versions:
	sudo apt -y remove docker docker-engine docker.io
}

function install_repo {

	echo "#${FUNCNAME[0]} $@"
	# Install Docker repo:
	sudo apt -y update
	sudo apt -y install apt-transport-https
	sudo apt -y install ca-certificates
	sudo apt -y install curl
	sudo apt -y install software-properties-common
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
	sudo apt-key fingerprint "${docker_fingerprint}"
	sudo add-apt-repository \
		"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
		$(lsb_release -cs) \
		stable"
}

function install_docker_ce {

	echo "#${FUNCNAME[0]} $@"
	# Install Docker-CE:
	sudo apt -y update
	sudo apt -y install docker-ce
}

function test_docker_ce {

	echo "#${FUNCNAME[0]} $@"
	# Test:
	docker -v
	sudo docker run hello-world
}

function upgrade_docker_ce {

	echo "#${FUNCNAME[0]} $@"
	version=$1
	
	# Upgrade:
	apt-cache madison docker-ce
	sudo apt-get install docker-ce="${version}"
}

function uninstall_docker_ce {

	echo "#${FUNCNAME[0]} $@"
	# Uninstall:
	sudo apt -y purge docker-ce
}

if [[ "${action}" == "prerequisites" ]] ; then
	remove_old_versions
	install_repo
elif [[ "${action}" == "install" ]] ; then
	[[ `sudo apt-key fingerprint ${docker_fingerprint} | xargs echo` == "" ]] && { echo "missing prerequisites"; exit; }
	install_docker_ce
elif [[ "${action}" == "uninstall" ]] ; then
	uninstall_docker_ce
elif [[ "${action}" == "upgrade" ]] ; then
	version=$2
	upgrade_docker_ce "${version}"
fi

test_docker_ce




