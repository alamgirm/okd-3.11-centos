

# okd-installation-centos

![enter image description here](https://lh3.googleusercontent.com/OBGT85EIBjT43vxUsI0Pmhl68NmYxqOUbBuTjRivjP24t5r38ft0ioTNuEV0IAyV3izoadJsdYIlnw)

# About...
  

*This repository is used to create ***OKD 3.11 Cluster*** with **9** simple steps on ***Bare VM's**** 
  

# Table of Contents

* [What are the VM's provisioned ?](#configuration)
* [How to deploy okd cluster ?](#deploy)
* [How to access okd Console ?](#console)
* [What are the addons provided ?](#addons)

   
<a id="configuration"></a>

# What are the VM's provisioned ?

***Note: We are not going to create any VM's during this process. User is expected to have VM's before proceeding with this repository***
We have three nodes: 1 master (for master+infra) and 2 workers (compute).
*Below is the ***example configuration*** that we are going to refer ***through out this repository***.*

*Name*|*IP*|*OS*|*RAM*|*CPU*|*Disk*|
|----|----|----|----|----|----|
*master*  |*192.168.2.50*|*CentOS7*|*16GB*|*4*|*40GB*|
*worker1* |*192.168.2.51*|*CentOS7*|*16GB*|*4*|*40+100GB*|
*worker2* |*192.168.2.52*|*CentOS7*|*16GB*|*4*|*40+100GB*|

<a id="deploy"></a>

# How to deploy openshift cluster ?


## ***Step 1***
 
***Update the system and host names for all nodes***

* `192.168.2.50 (master)`
* `192.168.2.51 (worker1)`
* `192.168.2.52 (worker2)`

  
***Unix Command!!!***

`$ yum update -y`

`$ nano /etc/hostname`  

## ***Step 2***

  ***Enable SELINUX=enforcing on all master/worker/infra nodes***
  
* `192.168.2.50 (master)`
* `192.168.2.51 (worker1)`
* `192.168.2.52 (worker2)`

***Unix Command!!!***

`$ nano /etc/selinux/config`

***We can verify the status by running the below command. The correct status will not reflect once we changed until we reboot the machines***

`$ sestatus`


## ***Step 3***

  ***Reboot all master/worker nodes***
 
* `192.168.2.50 (master)`
* `192.168.2.51 (worker1)`
* `192.168.2.52 (worker2)`
 
***Unix Command!!!***

`$ reboot`

     
## ***Step 4***  

*Checkout the code *

## ***Step 5***  

***Copy "okd-installation-centos" folder to all master/worker nodes***

* `192.168.2.50 (master)`
* `192.168.2.51 (worker1)`
* `192.168.2.52 (worker2)`

*Example copy to root folder and execution permissions can be applied by executing the below command.*
 

***Unix Command!!!***

`$ chmod +x -R okd-installation-centos`


## ***Step 6***

***Execute the below script on all master/worker nodes***

* `192.168.2.50 (master)`
* `192.168.2.51 (worker1)`
* `192.168.2.52 (worker2)`

***Unix Command!!!***

`$ okd-installation-centos/provisioning/install_prerequisites.sh`

  
## ***Step 7***

***Enable SSH to communicate all the other "worker/infra nodes" from "master" with out "password". All the below commands needs to be executed on "master" node only***

* `100.10.10.101 (okd-master-node)`
  
***Unix Command!!!***

`$ ssh-keygen -t rsa`

***okd-master-node***

`$ cat ~/.ssh/id_rsa.pub | ssh   root@100.10.10.100  "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`
`$ cat ~/.ssh/id_rsa.pub | ssh   root@100.10.10.101  "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`
`$ cat ~/.ssh/id_rsa.pub | ssh   root@100.10.10.102  "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`
`$ cat ~/.ssh/id_rsa.pub | ssh   root@100.10.10.104  "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"`

## ***Step 8***

***Execute the below script only on master node***

* `100.10.10.101 (okd-master-node)`
  
***Unix Command!!!***

`$ okd-installation-centos/provisioning/install_master.sh`
  

## ***Step 9***

***Verify okd installation is success by executing below two commands to see all the nodes and pods.***

***Unix Command!!!***
  
`$ oc login -u admin -p admin https://console.okd.nip.io:8443`

`$ oc get projects`

  
  <a id="console"></a>

# How to access okd Console ?

The ***okd Console*** can be accessed via the below URL from your local machine   

[https://console.okd.nip.io:8443](https://console.okd.nip.io:8443)


<a id="addons"></a>
# What are the addons provided ?

* `helm`
