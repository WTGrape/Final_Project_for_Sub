#!/bin/bash
sudo hostnamectl hostname eks-control
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf repolist 
sudo dnf install terraform -y 
sudo yum --showduplicate list terraform 
sudo rpm -qa | grep terraform 
sudo curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
sudo chmod +x ./kubectl
sudo cp kubectl /usr/bin/
sudo rm -rf kubectl
sudo terraform version
kubectl version --client