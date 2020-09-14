#!/bin/bash

echo "#########################################"
echo "### REMOVING OLDER VERSIONS OF DOCKER ###"
echo "#########################################"
sudo apt-get remove docker docker-engine docker.io containerd runc
if [[ $? == "0" ]]; then
    echo "#########################################"
    echo "####       INSTALLING DOCKER         ####"
    echo "#########################################"
    sudo apt-get update
    sudo apt-get install apt-transport-https
    if [[ $? != "0" ]]
    then 
        echo "FAILED TO INSTALL <<apt-transport-https>>"
        exit 1
    fi
    sudo apt-get install ca-certificates
    if [[ $? != "0" ]]
    then 
        echo "FAILED TO INSTALL <<ca-certificates>>"
        exit 1
    fi
    sudo apt-get install curl gnupg-agent software-properties-common
    if [[ $? != "0" ]]
    then 
        echo "FAILED TO INSTALL <<curl, gnupg-agent, software-properties-common>>"
        exit 1
    fi
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    if [[ $? != "0" ]]
    then 
        echo "FAILED TO CURL"
        exit 1
    fi
    sudo apt-key fingerprint 0EBFCD88
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    if [[ $? != "0" ]]
    then 
        echo "### <<FAILED to add-apt-repos>> ###"
        exit 1
    fi
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io
    if [[ $? != "0" ]]
    then
        echo "### <<FAILED TO INSTALL DOCKER>> ###"
        exit 1
    fi
else 
    echo "### There is a problem in removing older versions ###"
    exit
fi

echo "##########################################"
echo "###### DOCKER INSTALLED SUCCESSFULLY #####"
echo "##########################################"


echo "=========================================="

echo "##########################################"
echo "######### SETTING UP KUBERNETES ##########"
echo "##########################################"

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

if [ $? != "0" ]; then
    echo "### FAILED TO CREATE k8s.conf FILE ###"
    exit
fi
sudo sysctl --system
sudo apt-get update && sudo apt-get install -y apt-transport-https curl
if [ $? != "0" ]; then
    echo "FAILED TO INSTALL <<apt-transport-https and curl>>"
    exit
fi
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
if [ $? != "0" ]; then
    echo "FAILED TO CURL THE PACKAGE"
    exit
fi
sudo apt-get update
echo "**** INSTALLING KUBELET ****"
sudo apt-get install -y kubelet
if [ $? != "0" ]; then
    echo "FAILED TO INSTALL KUBELET"
    exit
fi
echo "**** INSTALLING KUBEADM ****"
sudo apt-get install kubeadm
if [ $? != "0" ]; then
    echo "FAILED TO INSTALL KUBEADM"
    exit
fi
echo "**** INSTALLING KUBELET ****"
sudo apt-get install kubectl
if [ $? != "0" ]; then
    echo "FAILED TO INSTALL KUBECTL"
    exit
fi
echo " HOLDING KUBELET KUBEADM KUBECTL "
sudo apt-mark hold kubelet kubeadm kubectl
if [ $? != "0" ]; then
    echo "FAILED TO HOLD SERVICES"
    exit
fi
systemctl daemon-reload
echo "**** RESTARTING KUBELET ****"
systemctl restart kubelet 
if [ $? != "0" ]; then
    echo "FAILED TO RESTART KUBELET"
    exit
fi

