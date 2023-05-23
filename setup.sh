#!/bin/bash

# Run using the below command
# bash setup_airflow.sh

echo "Downloading anaconda..."
wget https://repo.anaconda.com/archive/Anaconda3-2023.03-Linux-x86_64.sh

echo "Running anaconda script..."
bash Anaconda3-2023.03-Linux-x86_64.sh -b -p ~/anaconda

echo "Removing anaconda script..."
rm Anaconda3-2023.03-Linux-x86_64.sh

#activate conda
eval "$($HOME/anaconda/bin/conda shell.bash hook)"

echo "Running conda init..."
conda init

# Using -y flag to auto-approve
echo "Running conda update..."
conda update -y conda

echo "Installed conda version..."
conda --version

echo "Running sudo apt-get update..."
sudo apt-get update

echo "Installing Docker..."
sudo apt-get -y install docker.io

echo "Docker without sudo setup..."
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo service docker restart

echo "Installing docker-compose..."
cd 
mkdir -p bin
cd bin
wget https://github.com/docker/compose/releases/download/v2.17.3/docker-compose-linux-x86_64 -O docker-compose
sudo chmod +x docker-compose
sudo chmod 666 /var/run/docker.sock

echo "Setup .bashrc..."
echo '' >> ~/.bashrc
echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc

cd
sudo chmod +x bin/docker-compose
echo "docker-compose version..."
docker-compose --version

echo "Download Minikube for Kubernetes single node in local environment"
echo "Downloading Minikube..."

curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

echo "Minikube version..."
minikube version

echo "Downloading Helm..."

curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm

echo "Helm version..."
helm version

echo "Downloading Kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

echo "Downloading Kubectl checksum..."
curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check

echo "Installing kubectl..."
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

echo "Kubectl version..."
kubectl version --client

# in case of gcp 
mkdir -p ~/.google/credentials