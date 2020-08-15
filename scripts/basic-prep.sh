#!/bin/bash
# Basic preparation, run on each of the nodes both master and worker

source settings.sh

cat >>/etc/hosts<<EOF
${OKD_MASTER_IP} ${OKD_MASTER_HOSTNAME} console console.${DOMAIN}
${OKD_WORKER_NODE_1_IP} ${OKD_WORKER_NODE_1_HOSTNAME}
${OKD_WORKER_NODE_2_IP} ${OKD_WORKER_NODE_2_HOSTNAME}
EOF

# install updates
yum update -y

# install the following base packages
yum install -y wget figlet zile nano net-tools docker-1.13.1\
 bind-utils iptables-services bridge-utils bash-completion kexec-tools sos\
 psacct openssl-devel httpd-tools NetworkManager python-cryptography\
 python2-pip python-devel python-passlib\
 java-1.8.0-openjdk-headless "@Development Tools" epel-release

# Disable the EPEL repository globally so that is not accidentally used during later steps of the installation
sed -i -e "s/^enabled=1/enabled=0/" /etc/yum.repos.d/epel.repo

systemctl | grep "NetworkManager.*running"
if [ $? -eq 1 ]; then
        systemctl start NetworkManager
        systemctl enable NetworkManager
fi

if [ -z $DISKDEV ]; then
	echo "Not setting the Docker storage."
else
	cp /etc/sysconfig/docker-storage-setup /etc/sysconfig/docker-storage-setup.bk

	echo DEVS=$DISKDEV > /etc/sysconfig/docker-storage-setup
	echo VG=DOCKER >> /etc/sysconfig/docker-storage-setup
	echo SETUP_LVM_THIN_POOL=yes >> /etc/sysconfig/docker-storage-setup
	echo DATA_SIZE="100%FREE" >> /etc/sysconfig/docker-storage-setup

	systemctl stop docker

	rm -rf /var/lib/docker
	wipefs --all $DISK
	docker-storage-setup
fi
 
systemctl restart docker
systemctl enable docker
