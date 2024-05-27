# Do not change anything!

##  작업 순서

### 0. tfstate_s3.tf
- tfstate 관리를 위한 s3 생성

### 1. networkings
- eks-master 접속 후 prod 유저 생성 및 sudo password 생략
sudo useradd prod -G wheel
sudo vim /etc/sudoers           
sudo cp -r /home/ec2-user/.ssh /home/prod/.
sudo chown prod:prod -R /home/prod

- kubectl & terraform install
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo dnf repolist 
sudo dnf install terraform -y 
sudo yum --showduplicate list terraform 
sudo rpm -qa | grep terraform 
curl -O https://s3.us-west-2.amazonaws.com/amazon-eks/1.27.1/2023-04-19/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo cp kubectl /usr/bin/
sudo rm -rf kubectl
sudo terraform version
kubectl version --client

### 2.eks

### 3. eks_control 접속 후 alb controller 생성
- test-dev 영역
aws eks update-kubeconfig --name test_dev_was 후 terraform apply
rds_service.yaml 에 rds endpoint 추가 후 kubectl apply

- prod 영역
aws eks update-kubeconfig --name prod_was 후 terraform apply
argo_ingress.yaml 에 terraform output 으로 나온 ACM ARN 추가 후 kubectl apply

### 4. argo cd
argocd 초기 설정
- secret 비밀 번호 확인
kubectl get secret -n argocd argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

- pod 접속 후 비밀번호 변경
kubectl exec -it -n argocd deployment/argocd-server -- /bin/bash
$ argocd login localhost:8080
#Username : admin
#Password: 위 secret으로 획득한 비밀번호
$ argocd account update-password

### 5. configuration
- 

### 6. nginx conf lambada 실행
- 

## 최종 확인
### 서비스 접속 확인
www.nadri-project.com or nadri-project.com
### opensearch 접속 확인
ssh -i ~/.ssh/terraform-key -p 9999 ec2-user@"dev-dmz-nlb.dns_name" -N -L 9200:opensearch.endpoints:443