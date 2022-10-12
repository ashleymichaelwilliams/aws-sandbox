# aws-sandbox

<br>

![CI Status](https://github.com/ashleymichaelwilliams/aws-sandbox/actions/workflows/ci.yml/badge.svg)

<br>

## Overview:
### This repository serves as an example project where you can experiment with different "stacks" using Terramate following generally good design practices.

<br><br>


## Project Note:
#### Considering there is lots of opportunies for cleanup and general optimizing of the config mgmt aspects for this project, please understand this project was intended for testing purposes of sample Infra Code which can be used to illustrate more how things go together then the module development. 

<br><br>

## Prerequisites:
* aws-cli (v2.7)
* terramate (v0.35.0+)
* terraform (v0.14.8+)
* kubectl (v1.19+)

<br><br>

## Project Walkthrough:

<br>

### Configure AWS Cli Tool
```
# Set AWS CLI Config
export AWS_DEFAULT_REGION='us-west-2'
export AWS_ACCESS_KEY_ID='<PASTE_YOUR_ACCESS_KEY_ID_HERE>'
export AWS_SECRET_ACCESS_KEY='<PASTE_YOUR_SECRET_ACCESS_KEY_HERE>'
```
<br>

### Generate Terraform code and Provision the Terramate Stacks
```
# Terramate Generate
terramate generate
git add -A


# Terraform Provisioning
terramate run -- terraform init
terramate run -- terraform apply
```
<br>

### EKS Cluster Configuration:
```
# Add EKS Cluster Configure/Creds
aws eks update-kubeconfig --name ex-eks

# Edit Kube Config to Connect to cluster (Add to the bottom of the "Users" section of the config...) 
cat <<EOT >> ~/.kube/config
      env:
      - name: AWS_ACCESS_KEY_ID
        value: ${AWS_ACCESS_KEY_ID}
      - name: AWS_SECRET_ACCESS_KEY
        value: ${AWS_SECRET_ACCESS_KEY}
EOT
```
<br>

### Testing:

```
# Scale the Deployment causing Karpenter to Add/Scale-Up Nodes
kubectl scale deployment inflate --replicas 2
```


```
# Scale the Deployment causing Karpenter to Removes/Scale-Down Nodes
kubectl scale deployment inflate --replicas 0
```

### Cleanup: 
```
terramate run -- terraform destroy
```