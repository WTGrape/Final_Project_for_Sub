# Do not change anything!

##  작업 순서

### 0. tfstate_s3.tf 및 key 준비
- tfstate 관리 s3 생성을 위해 tfstate_s3.tf terraform 실행
- ~/.ssh/ 에 keypair 에서 사용할 public & private key(terraform-key) 추가
### 1. networkings
- 네트워크 인프라 구축을 위해 networkings directory 에서 terraform 실행
- nexus 접속
ssh -i %{key file} -p 9999 ec2-user@"${dev-dmz-nlb dns_name}"
vim ~/.ssh/terraform-key ;
chmod 600 .ssh/terraform-key;

- eks-master (shared_int nlb 3000 port) 접속 후 prod 유저 생성 및 sudo password 생략
ssh -i %{key file} -p 3000 ec2-user@"${shared-int-lb dns_name}"
sudo useradd prod -G wheel
sudo vim /etc/sudoers           
sudo cp -r /home/ec2-user/.ssh /home/prod/.
sudo chown prod:prod -R /home/prod

### 2.db dummy data 추가
- db-control (shared_int nlb 2000 port) 접속 후 dummy 추가
prod-rds 와 test-dev-rds 에 dummy data 추가 
files/schema.sql & files/fesivalInfo.sql 참조

### 3. eks_control 접속 후 alb controller 생성
- eks 및 logging 구축을 위해 eks directory 에서 terraform 실행
- test-dev 영역
ssh -i %{key file} -p 3000 ec2-user@"${shared-int-lb dns_name}"
aws eks update-kubeconfig --name test_dev_was 후 terraform apply
rds_service.yaml 에 rds endpoint 추가 후 kubectl apply

- prod 영역
ssh -i %{key file} -p 3000 prod@"${shared-int-lb dns_name}"
aws eks update-kubeconfig --name prod_was 후 terraform apply
argo_ingress.yaml 에 terraform output 으로 나온 ACM ARN 추가 후 kubectl apply 는 아래 argo cd 작업 완료 후 해준다.

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

kubectl apply 해준다.

- dev-dmz nlb 와 연결
ingrtess 로 생성된 LB 의 ENI private 를 dev-dmz nlb 의 443 port target group에 대상 등록
https://dev-dmz_nlb_dnsname 접속 후 argo-cd 설정 마무리

### 5. configuration terraform apply
- prometheus
dev-dmz_nlb_dnsname:8888
- grafana
dev-dmz_nlb_dnsname:7777

### 6. nginx conf lambada 실행
- dev-dmz-nginx-conf 및 user-dmz-nginx-conf 실행
## 최종 확인
### 서비스 접속 확인
www.nadri-project.com or nadri-project.com
### opensearch 접속
- powershell 에서 SSH tunneling
ssh -i ~/.ssh/terraform-key -p 9999 ec2-user@"dev-dmz-nlb.dns_name" -N -L 9200:opensearch.endpoints:443
- browser 접속
https://localhost:9200/_dashboards
Security -> Roles -> all_access -> Mapped users -> Manage mapping
-> Backend roles 에 iam role arn 추가
- backend role 목록
arn:aws:iam::${account-id}:role/role-cloudwatch-to-opensearch
arn:aws:iam::${account-id}:role/role-firehose-to-opensearch
- stack 설정
Stack Management -> Index patterns -> Create index pattern
- log 기록 확인
Discover