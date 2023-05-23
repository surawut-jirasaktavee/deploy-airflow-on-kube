# DEPLOY AIRFLOW ON KUBERNETES

This repository is for practice to deploy Apache AirFlow on Kubernetes and sync dags folder with git repository

## Prerequisite packages

- [Docker](https://docs.docker.com/get-docker/)
- [Docker-compose](https://github.com/docker/compose/releases)
- [Minikube](https://minikube.sigs.k8s.io/docs/start/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Anaconda](https://www.anaconda.com/download/)


## Setup

```bash
# Clone this repository
git clone git@github.com:surawut-jirasaktavee/deploy-airflow-on-kube.git
```

## Run

```bash
# Start setup
cd deploy-airflow-on-kube
./setup.sh
```

```bash
# Build image
docker build <docker-registry/<image_name>:<image_tag>
```

```bash
# Push image
docker login
docker push <docker-registry/<image_name>:<image_tag>
```

```bash
# Start Minikube for create Kubernetes single node in local environment
minikube start --driver=docker
```

```bash
# Add Airflow helm chart
helm repo add apache-airflow https://airflow.apache.org
helm repo update
```

```bash
# Create namespace for Airflow cluster
kubectl create namespace airflow-cluster
```

```bash
# Install Airflow cluster
helm install airflow apache-airflow/airflow \
    --namespace airflow-cluster \
```

### Check AirFlow Services

```bash
kubectl get pod,deploy,svc -n airflow-cluster
```

```bash
# Download values file from helm
mkdir -p kube/airflow-chart
helm show values apache-airflow/airflow > kube/airflow-chart/values.yaml
```


### Change AirFlow to use KubernetesExecutor

```yaml
# Airflow executor
# One of: LocalExecutor, LocalKubernetesExecutor, CeleryExecutor, KubernetesExecutor, CeleryKubernetesExecutor
executor: "KubernetesExecutor"
```

```bash
# Upgrade Airflow cluster
helm upgrade airflow apache-airflow/airflow \
    --namespace airflow-cluster \
    -f kube/airflow-chart/values.yaml
```

## Sync AirFlow dag folder with another Git repository with SSH

### Github SSH key

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "<email>"
```

```bash
# Add SSH key to ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa
```

```bash
# Copy SSH key to clipboard
pbcopy < ~/.ssh/id_rsa.pub
```

>Note: Add SSH key to Github go to Github > Project repository > Settings > Deploy keys


## Create Kubernetes secret for Airflow to sync with GitHub

```bash
# Create Kubernetes secret
kubectl create secret generic airflow-ssh-git-secret \
    --from-file=GitSshKey=~/.ssh/id_rsa
```

```bash
# Check Secret
kubectl get secret -n airflow-cluster
```

## Set chart values to use GitSync

```yaml
# Git sync
dags:
  gitSync:
    enabled: True
    repo: git@github.com:surawut-jirasaktavee/airflow-dags.git # Git url or ssh
    branch: main # Git branch
    rev: HEAD 
    depth: 1
    maxFailures: 0
    subPath: "dags/" # Folder to sync
    sshKeySecret: airflow-ssh-git-secret # Secret key
    wait: 10
    containerName: git-sync
    uid: 65533
```

```bash
# Upgrade Airflow cluster
helm upgrade airflow apache-airflow/airflow \
    --namespace airflow-cluster \
    -f kube/airflow-chart/values.yaml
```

```bash
# Check Airflow cluster
kubectl get pod,deploy,svc -n airflow-cluster
```

## Check Airflow UI

```bash
# Get Airflow UI url
minikube service airflow-webserver -n airflow-cluster --url
```
