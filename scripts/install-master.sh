#!/bin/bash

# Run this on only master node

source settings.sh

# install the packages for Ansible
yum -y --enablerepo=epel install ansible pyOpenSSL
curl -o ansible.rpm https://releases.ansible.com/ansible/rpm/release/epel-7-x86_64/ansible-2.6.5-1.el7.ans.noarch.rpm
yum -y --enablerepo=epel install ansible.rpm

# checkout openshift-ansible repository
[ ! -d openshift-ansible ] && git clone https://github.com/openshift/openshift-ansible.git
cd openshift-ansible && git fetch && git checkout release-${OKD_VERSION} && cd ..

mkdir -p /etc/origin/master/
touch /etc/origin/master/htpasswd

# check pre-requisites
ansible-playbook -i inventory.ini openshift-ansible/playbooks/prerequisites.yml

# deploy cluster
ansible-playbook -i inventory.ini openshift-ansible/playbooks/deploy_cluster.yml

htpasswd -b /etc/origin/master/htpasswd $OKD_USERNAME ${OKD_PASSWORD}
oc adm policy add-cluster-role-to-user cluster-admin $OKD_USERNAME


echo "#####################################################################"
echo "* Your console is https://console.$DOMAIN:$API_PORT"
echo "* Your username is $OKD_USERNAME "
echo "* Your password is $OKD_PASSWORD "
echo "*"
echo "* Login using:"
echo "*"
echo "$ oc login -u ${OKD_USERNAME} -p ${OKD_PASSWORD} https://console.$DOMAIN:$API_PORT/"
echo "#####################################################################"

oc login -u ${OKD_USERNAME} -p ${OKD_PASSWORD} https://console.$DOMAIN:$API_PORT/
