#!/bin/bash

source settings.sh

ssh-keygen -t rsa
cat ~/.ssh/id_rsa.pub | ssh root@${OKD_MASTER_IP} "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | ssh root@${OKD_WORKER_NODE_1_IP} "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | ssh root@${OKD_WORKER_NODE_2_IP} "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
cat ~/.ssh/id_rsa.pub | ssh root@$181.215.182.160 "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"

CERT=/etc/letsencrypt/live/${DOMAIN}/fullchain.pem
CA_CERT=/etc/letsencrypt/live/${DOMAIN}/chain.pem
PRV_KEY=/etc/letsencrypt/live/${DOMAIN}/privkey.pem

if [[ ! -f "$CERT" || ! -f "$CA_CERT" || ! -f "$PRV_KEY" ]]; then
  echo "Some of the certificate/key files are missing. Trying to create them..."
  echo "Allow port 80 on your network router and NAT to the master node $OKD_MASTER_IP."
  # Install CertBot
	yum install --enablerepo=epel -y certbot
  # Configure Let's Encrypt certificate
	certbot certonly --manual \
	  --preferred-challenges dns \
		--email $MAIL \
		--server https://acme-v02.api.letsencrypt.org/directory \
		--agree-tos \
		-d $DOMAIN \
		-d *.$DOMAIN \
		-d *.apps.$DOMAIN
        
  # Add Cron Task to renew certificate
	echo "@weekly  certbot renew --pre-hook=\"oc scale --replicas=0 dc router\" --post-hook=\"oc scale --replicas=1 dc router\"" > certbotcron
	crontab certbotcron
	rm certbotcron
  exit 1
fi

cat << EOF > inventory.ini

[OSEv3:children]
masters
nodes
etcd

[masters]
${OKD_MASTER_IP} openshift_ip=${OKD_MASTER_IP} openshift_schedulable=true 

[etcd]
${OKD_MASTER_IP} openshift_ip=${OKD_MASTER_IP}

[nodes]
${OKD_MASTER_IP} openshift_ip=${OKD_MASTER_IP} openshift_node_group_name='node-config-master-infra'
${OKD_WORKER_NODE_1_IP} openshift_ip=${OKD_WORKER_NODE_1_IP} openshift_node_group_name='node-config-compute'
${OKD_WORKER_NODE_2_IP} openshift_ip=${OKD_WORKER_NODE_2_IP} openshift_node_group_name='node-config-compute'


[OSEv3:vars]
openshift_additional_repos=[{'id': 'centos-paas', 'name': 'centos-paas', 'baseurl' :'https://buildlogs.centos.org/centos/7/paas/x86_64/openshift-origin311', 'gpgcheck' :'0', 'enabled' :'1'}]

ansible_ssh_user=root
enable_excluders=False
enable_docker_excluder=False
ansible_service_broker_install=False

containerized=True
os_sdn_network_plugin_name='redhat/openshift-ovs-multitenant'
openshift_disable_check=disk_availability,docker_storage,memory_availability,docker_image_availability

deployment_type=origin
openshift_deployment_type=origin

template_service_broker_selector={"region":"infra"}
openshift_metrics_image_version="v${OKD_VERSION}"
openshift_logging_image_version="v${OKD_VERSION}"
openshift_logging_elasticsearch_proxy_image_version="v1.0.0"
openshift_logging_es_nodeselector={"node-role.kubernetes.io/infra":"true"}
logging_elasticsearch_rollout_override=false
osm_use_cockpit=true

openshift_metrics_install_metrics=${INSTALL_METRICS} 
openshift_logging_install_logging=${INSTALL_LOGGING} 

openshift_master_identity_providers=[{'name': 'htpasswd_auth', 'login': 'true', 'challenge': 'true', 'kind': 'HTPasswdPasswordIdentityProvider'}]
openshift_master_htpasswd_file='/etc/origin/master/htpasswd'

openshift_public_hostname=console.${DOMAIN}
openshift_master_default_subdomain=apps.${DOMAIN}

openshift_master_api_port=${API_PORT}
openshift_master_console_port=${API_PORT}


openshift_master_overwrite_named_certificates=true
openshift_master_cluster_hostname=console-internal.${DOMAIN}
openshift_master_cluster_public_hostname=console.${DOMAIN}
openshift_master_named_certificates=[{"certfile": "$CERT", "keyfile": "$PRV_KEY", "cafile": "$CA_CERT", "names": ["console.${DOMAIN}"]}]
openshift_hosted_router_certificate={"certfile": "$CERT", "keyfile": "$PRV_KEY", "cafile": "$CA_CERT"}
openshift_hosted_registry_routehost=registry.apps.${DOMAIN}
openshift_hosted_registry_routecertificates={"certfile": "$CERT", "keyfile": "$PRV_KEY", "cafile": "$CA_CERT"}
openshift_hosted_registry_routetermination=reencrypt

EOF
