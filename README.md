# aws-sandbox


![CI Status](https://github.com/ashleymichaelwilliams/aws-sandbox/actions/workflows/ci.yml/badge.svg) ![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ashleymichaelwilliams/aws-sandbox) ![GitHub language count](https://img.shields.io/github/languages/count/ashleymichaelwilliams/aws-sandbox) ![GitHub top language](https://img.shields.io/github/languages/top/ashleymichaelwilliams/aws-sandbox)<br>
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white) ![AquaSec](https://img.shields.io/badge/aqua-%231904DA.svg?style=for-the-badge&logo=aqua&logoColor=#0018A8) ![Infracost](https://i.ibb.co/chDDfgF/infracost3.jpg) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)



<br><br>

## Project Summary:
This repository serves as an example project where you can experiment with different "stacks" using Terramate following generally good design practices.

<br><br>
### High-Level Diagram
![Diagram](AWS-Lab-HLD.jpg)

<br><br>


### Project Note:
Considering there is lots of opportunies for cleanup and general optimizing of the config mgmt aspects for this project, please understand this project was intended for testing purposes of sample Infra Code which can be used to illustrate more how things go together then the module development. 

<br><br>


## Project Walkthrough:
<br>

### Prerequisites:
* aws-cli (v2.7)
* terramate (v0.1.35+)
* terraform (v1.2.9+)
* kubectl (v1.19+)

<br><br>


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