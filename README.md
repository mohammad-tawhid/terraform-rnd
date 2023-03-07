# terraform-rnd

## User Data

```
#!/bin/bash
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
sudo yum -y install terraform
sudo amazon-linux-extras install ansible2 -y

sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
sudo amazon-linux-extras install java-openjdk11 -y

sudo yum install jenkins -y
sudo yum -y install packer
yum install git -y

sudo systemctl enable jenkins
sudo systemctl start jenkins
```
