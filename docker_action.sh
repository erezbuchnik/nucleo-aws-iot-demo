#!/bin/bash

command_name=$_
action=$1

host_workdir=`pwd`
container_workdir="/src"

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


function iot_aws_img_build {

	echo "#${FUNCNAME[0]} $@"
	cp ./Dockerfile.aws ./Dockerfile
	sudo docker build -t iot_aws_img ./
	rm Dockerfile
}


function iot_aws_container_run {

	echo "#${FUNCNAME[0]} $@"
	if [ ! -f ./sys_config.json ]; then
		echo "ABORT: sys_config.json file not found."
		return
	fi
	cp ./sys_config.json ./share/
	cp ./iot_aws_run.sh ./share/
	sudo docker run -ti \
		--name iot_aws_cont \
		-v "${host_workdir}"/share:"${container_workdir}"/share \
		iot_aws_img \
		"${container_workdir}"/share/iot_aws_run.sh
}


function iot_aws_container_kill {

	echo "#${FUNCNAME[0]} $@"
	sudo docker kill iot_aws_cont
	sudo docker rm iot_aws_cont
}


function iot_dash_img_build {

	echo "#${FUNCNAME[0]} $@"
	cp ./Dockerfile.dash ./Dockerfile
	sudo docker build -t iot_dash_img ./
	rm Dockerfile
}


function iot_dash_container_run {

	echo "#${FUNCNAME[0]} $@"
	if [ ! -f ./sys_config.json ]; then
		echo "ABORT: sys_config.json file not found."
		return
	fi
	cp ./sys_config.json ./share/
	cp ./iot_dash_run.sh ./share/
	sudo docker run -ti \
		--name iot_dash_cont \
		-v "${host_workdir}"/share:"${container_workdir}"/share \
		iot_dash_img \
		"${container_workdir}"/share/iot_dash_run.sh
}


function iot_dash_container_kill {

	echo "#${FUNCNAME[0]} $@"
	sudo docker kill iot_dash_cont
	sudo docker rm iot_dash_cont
}


function usage {

	echo 
	echo "#${command_name} ${FUNCNAME[0]} $@"
	echo "---------------"
	echo "#${command_name} fullinstall"
	echo "#${command_name} install"
	echo "#${command_name} uninstall"
	echo "#${command_name} upgrade"
	echo "#${command_name} aws_build"
	echo "#${command_name} aws_run"
	echo "#${command_name} aws_kill"
	echo "#${command_name} dash_build"
	echo "#${command_name} dash_run"
	echo "#${command_name} dash_kill"
	echo 
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
elif [[ "${action}" == "aws_build" ]] ; then
	iot_aws_img_build
elif [[ "${action}" == "aws_run" ]] ; then
	iot_aws_container_run
elif [[ "${action}" == "aws_kill" ]] ; then
	iot_aws_container_kill
elif [[ "${action}" == "dash_build" ]] ; then
	iot_dash_img_build
elif [[ "${action}" == "dash_run" ]] ; then
	iot_dash_container_run
elif [[ "${action}" == "dash_kill" ]] ; then
	iot_dash_container_kill
else
	usage
fi

