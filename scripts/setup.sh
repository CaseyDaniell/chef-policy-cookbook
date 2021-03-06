sudo apt-get update
#Install packages for apt over https
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common \
    docker-compose
#Add Docker GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#Install for amd64
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
#Update apt
sudo apt-get update 
#Install docker
sudo apt-get install docker-ce -y

sudo usermod -aG docker ubuntu
sudo usermod -aG docker jenkins

#create directories 
sudo mkdir -p /data/docker/jenkins/jenkins_home
sudo chown -R 1000 /data/docker/jenkins/jenkins_home
sudo mkdir -p /data/docker/artifactory/
sudo chown -R 1030:1030 /data/docker/artifactory/

#Use new group
/usr/bin/newgrp docker <<EONG
docker-compose up -d
EONG

# Wait for api to be available
timeout 300 bash -c 'while [[ "$(curl -s -o /dev/null -w ''%{http_code}'' localhost:8081)" != "200" ]]; do sleep 5; done' || false# Update artifactory 
sleep 40
curl -uadmin:password -X PATCH "http://localhost:8081/artifactory/api/system/configuration" -H "Content-Type:application/yaml" -T artifactory/configuration.yml
