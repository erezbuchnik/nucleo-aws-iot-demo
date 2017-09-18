#!/bin/bash

action=$1

host_workdir=`pwd`
container_workdir="/src/nucleo-aws-iot-demo-docker"

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
	sudo apt -y install jq
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
	[[ `sudo apt-key fingerprint ${docker_fingerprint} | xargs echo` == "" ]] && { echo "missing prerequisites"; exit; }
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
	upgrade_version=`cat ${workdir}/sys_config.json | jq -r '.docker.upgrade_version'`
	
	# Upgrade:
	apt-cache madison docker-ce
	sudo apt-get install docker-ce="${upgrade_version}"
}

function uninstall_docker_ce {

	echo "#${FUNCNAME[0]} $@"
	# Uninstall:
	sudo apt -y purge docker-ce
}


function nucleo_img_build {

	echo "#${FUNCNAME[0]} $@"
	sudo docker build -t nucleo_img ./
}


function nucleo_container_run {

	echo "#${FUNCNAME[0]} $@"
	cp ./sys_config.json ./share/
	cp ./nucleo_run.sh ./share/
	sudo docker run -ti \
		--name nucleo_cont \
		-v "${host_workdir}"/share:"${container_workdir}"/share \
		nucleo_img \
		"${container_workdir}"/share/nucleo_run.sh
}


if [[ "${action}" == "fullinstall" ]] ; then
	remove_old_versions
	uninstall_docker_ce
	install_repo
	install_docker_ce
	test_docker_ce
elif [[ "${action}" == "install" ]] ; then
	install_docker_ce
	test_docker_ce
elif [[ "${action}" == "uninstall" ]] ; then
	uninstall_docker_ce
	test_docker_ce
elif [[ "${action}" == "upgrade" ]] ; then
	upgrade_docker_ce
	test_docker_ce
elif [[ "${action}" == "build" ]] ; then
	nucleo_img_build
elif [[ "${action}" == "run" ]] ; then
	nucleo_container_run
fi

