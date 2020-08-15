#!/bin/bash
# The below configuration can be edited up on your needs and and please note the it's just an example configuration.
# We are going to create an OKD cluster with one master and 3 worker nodes.

# OKD Version
export OKD_VERSION=3.11

# OKD Master Node Configuration
export OKD_MASTER_IP=192.168.2.50
export OKD_MASTER_HOSTNAME=master

# OKD Worker Node 1 Configuration
export OKD_WORKER_NODE_1_IP=192.168.2.51
export OKD_WORKER_NODE_1_HOSTNAME=worker1

# OKD Worker Node 2 Configuration
export OKD_WORKER_NODE_2_IP=192.168.2.52
export OKD_WORKER_NODE_2_HOSTNAME=worker2

# The  below setting will be used to access OKD console https://console.$DOMAIN:$API_PORT"
# By default we can login using the URL https://console.caas.knowbiz.ca:8443
# To access URL from your local system we need to configure master host in C:\Windows\System32\drivers\etc\hosts file as below
# 192.168.2.50  console.caas.knowbiz.ca
export DOMAIN=caas.knowbiz.ca
export API_PORT=8443

# OKD Login Credentials
# By default admin/admin operator will be created and can be used to login to OKD console.
export OKD_USERNAME=admin
export OKD_PASSWORD=admin123

# OKD Add-Ons
# Enable "True"  only if one of the VM has 4GB memory.
export INSTALL_METRICS=True

# Enable "True"  only one of the VM 16GB memory. 
export INSTALL_LOGGING=False
