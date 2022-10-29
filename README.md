# aws-sandbox


![CI Status](https://github.com/ashleymichaelwilliams/aws-sandbox/actions/workflows/ci.yml/badge.svg) ![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ashleymichaelwilliams/aws-sandbox) ![GitHub language count](https://img.shields.io/github/languages/count/ashleymichaelwilliams/aws-sandbox) ![GitHub top language](https://img.shields.io/github/languages/top/ashleymichaelwilliams/aws-sandbox)<br>
![GitHub Actions](https://img.shields.io/badge/github%20actions-%232671E5.svg?style=for-the-badge&logo=githubactions&logoColor=white) ![AquaSec](https://img.shields.io/badge/aqua-%231904DA.svg?style=for-the-badge&logo=aqua&logoColor=#0018A8) ![Infracost](https://i.ibb.co/chDDfgF/infracost3.jpg) ![Docker](https://img.shields.io/badge/docker-%230db7ed.svg?style=for-the-badge&logo=docker&logoColor=white) ![Shell Script](https://img.shields.io/badge/shell_script-%23121011.svg?style=for-the-badge&logo=gnu-bash&logoColor=white) ![Terraform](https://img.shields.io/badge/terraform-%235835CC.svg?style=for-the-badge&logo=terraform&logoColor=white)

<br>

## **Project Summary**:
This repository serves as an example project where you can experiment with different "stacks" using Terramate following generally good design practices.

<br>

### Table of contents

  - [Project Summary](#project-summary)
    - [Diagram of what we are building](#diagram-of-what-we-are-building)
    - [Available Technologies/Tools](#available-technologiestools)
    - [Project Notes](#project-notes)
  - [Project Walkthrough](#project-walkthrough)
    - [Choice of Provisioning Methods](#choice-of-provisioning-methods)
    - [Common Configurations](#common-configurations-necessary-for-either-method)
    - [Provisioning Method 1: Running from your local system](#provisioning-method-1-running-from-your-local-system)
    - [Provisioning Method 2: Running within a built Docker container](#provisioning-method-2-running-within-a-built-docker-container)
  - [Project Exercises](#project-exercises)
    - [Using Fairwinds Pluto](#using-fairwinds-pluto)
    - [Karpenter Testing](#karpenter-testing)
    - [Migrate GP2 EBS Volume to a GP3 Volume using Snapshots](#migrate-gp2-ebs-volume-to-a-gp3-volume-using-snapshots)
    - [Running Infracost and Pluralith](#running-infracost-and-pluralith)
  - [Cleanup](#cleanup)

<br><br>


### Diagram of what we are building
![Diagram](docs/AWS-Lab-HLD.jpg)

<br><br>


### **Available Technologies/Tools:**
<br>

&nbsp;&nbsp;&nbsp; CI Pipeline Related:
* Github Actions
* AquaSec TFsec
* Infracost

&nbsp;&nbsp;&nbsp; Infra-as-Code and Orchestration Related:
* Terraform
* Terraform Cloud
* Terramate
* Pluralith

&nbsp;&nbsp;&nbsp; Kubernetes Related:
* ContainerD
* Helm
* Karpenter
* IRSA using OIDC
* AWS Load Balancer Controller
* VPC CNI
* Amazon EBS CSI Driver
* External Snapshotter Controller
* Prometheus Operator Stack
* metrics-server
* KubeCost

&nbsp;&nbsp;&nbsp; AWS Services:
* VPC
* NAT Instance Gateways
* Identity and Access Management
* EKS - Managed Kubernetes Service
* EC2 Instances
* Launch Templates
* Autoscaling Groups
* Elastic Load Balancers
* KMS - Key Management Service


<br><br>

#### **Project Notes:**
<br>

&nbsp;&nbsp;&nbsp; Some of the documented components/services in the diagram have yet to be added. (See [Available Technologies/Tools](#available-technologiestools) above)
  * Therefore, they will be missing until they are added to the project.

<br>

&nbsp;&nbsp;&nbsp; When provisioning the "dev" stack (`stacks/dev`) by default it's set to "remote" (Terraform Cloud) for backend state storage.
  * You will need to modify the `tfe_organization` global variable in the `stakcs/config.tm.hcl` file with your Organization ID.
  * You can also opt to use the "local" backend storage by setting the global variable `isLocal` to `true` in the `stacks/dev/config.tm.hcl` file.

<br>

&nbsp;&nbsp;&nbsp; We might recommend using a sandbox or trial account (ie. A Cloud Guru Playground) when initially using the project.
  * This protects users from accidently causing any risk/issues with their existing environments/configurations.
  * Using a sandbox account can also prevent any naming collisions during provisioning with their existing resources.

<br>

&nbsp;&nbsp;&nbsp; There are a lot of opportunities for optimizing the config for this project. (This was intentional!)
  * This project was intended for testing purposes of sample Infra Code, which is used to illustrate how you might structure your project.

<br>

&nbsp;&nbsp;&nbsp; Those running an ARM CPU architecture (ie. Apple's M1) might find it challenging when trying to use the project.
  * This is due to lack of current support of compiled binaries for ARM and lack of native emulation (Rosetta 2 expected as part of OSX 13 Ventura).

<br><br><br>


## **Project Walkthrough**:
<br>

### ***Choice of Provisioning Methods***
<ol>
  <li> Method 1: Running from your local system (tested on OSX 10.15 Catalina)
  <li> Method 2: Running within a custom Docker image 
</ol>

<br>

### Binary Prerequisites:
<br>

&nbsp;&nbsp;&nbsp; **Required for Method 1**
* git (v2.x)
* jq (any version)
* make (any version)
* aws-cli (v2.7) 
* terramate (v0.1.35+)
* terraform (v1.2.9+)
* kubectl (v1.19+)

<br>

&nbsp;&nbsp;&nbsp; **Required for Method 2**
* docker [v20.10+]

<br><br><br>


### Common Configurations (necessary for either method)
<br>

#### Set your AWS variables on your local system
```
export AWS_DEFAULT_REGION='us-west-2'
export AWS_ACCESS_KEY_ID='<PASTE_YOUR_ACCESS_KEY_ID_HERE>'
export AWS_SECRET_ACCESS_KEY='<PASTE_YOUR_SECRET_ACCESS_KEY_HERE>'
```


<br><br><br>

### Provisioning Method 1: Running from your local system
<br>

#### Generate Terraform code and Provision the Terramate Stacks
```
# Terramate Generate
terramate generate
git add -A

# Terraform Provisioning
cd stacks/local
terramate run -- terraform init
terramate run -- terraform apply
```

<br>


#### EKS Cluster Configuration:
```
# Adds the EKS Cluster Configure/Creds (Change cluster name if necessary!)
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


<br><br><br>

### Provisioning Method 2: Running within a built Docker container
<br>

#### Build Image and Start Container
```
make build && make start
```


#### Exec into Docker Container Shell
```
make exec
```


#### Generate Terraform code and Provision the Terramate Stacks
```
# Source Script Functions
source functions.sh

# Example: Changing Directory into the "Local" Stack
cd /project/stacks/local

# Terramate Commands (Generate/Validate/Apply)
tm-apply
```

#### Configures Kubernetes CLI (Config/Credentials)
```
eks-creds
```


<br><br><br>

## Project Exercises:
<br>

### Using Fairwinds Pluto:
<br>

#### Check for Deprecated/Removal of Resources
```
pluto detect-helm -o wide -t k8s=v1.25.0
pluto detect-api-resources -o wide -t k8s=v1.25.0
```


<br><br><br>

### Karpenter Testing:
<br>

#### Scale the Deployment causing Karpenter to Add/Scale-Up Nodes
```
kubectl scale deployment inflate --replicas 2
```

#### Scale the Deployment causing Karpenter to Removes/Scale-Down Nodes 
```
kubectl scale deployment inflate --replicas 0
```


<br><br><br>

### Migrate GP2 EBS Volume to a GP3 Volume using Snapshots
<br>

#### Creates an EC2 Snapshot from existing Volume (example using KubeCost)
```
# Returns the PVC ID from the Persistent Volune
PVC_ID=$(kubectl -n kubecost get pv -o json | jq -r '.items[1].metadata.name')

# Note: If the following command doesn't return a value for VOLUME_ID it's likely the volume is already managed by the new
#  EBS CSI, which is the new default gp3 StorageClass. If this occurs please use this "alternate" command to continue exercise.

# Use this for gp2 volume types
VOLUME_ID=$(kubectl get pv $PVC_ID -o jsonpath='{.spec.awsElasticBlockStore.volumeID}' | rev | cut -d'/' -f 1 | rev)

# Alternate command for use with gp3 volume types
VOLUME_ID=$(kubectl get pv $PVC_ID -o jsonpath='{.spec.csi.volumeHandle}' | rev | cut -d'/' -f 1 | rev)

# Creates the Snapshot from the Volume / Persistent Volume
SNAPSHOT_RESPONSE=$(aws ec2 create-snapshot --volume-id $VOLUME_ID --tag-specifications 'ResourceType=snapshot,Tags=[{Key="ec2:ResourceTag/ebs.csi.aws.com/cluster",Value="true"}]')
```

#### Wait for Snapshot to Complete (Run this until it reports Completed)
```
aws ec2 describe-snapshots --snapshot-ids $(echo "${SNAPSHOT_RESPONSE}" | jq -r '.SnapshotId')
```

#### Create Volume Snapshot CRDs to Provision a Volume from Snapshot
```
cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshotContent
metadata:
  name: imported-aws-snapshot-content    # <-- Make sure to use a unique name here
spec:
  volumeSnapshotRef:
    kind: VolumeSnapshot
    name: imported-aws-snapshot
    namespace: kubecost
  source:
    snapshotHandle: $(echo "${SNAPSHOT_RESPONSE}" | jq -r '.SnapshotId')
  driver: ebs.csi.aws.com
  deletionPolicy: Delete
  volumeSnapshotClassName: ebs-csi-aws
EOF


cat <<EOF | kubectl apply -f -
apiVersion: snapshot.storage.k8s.io/v1
kind: VolumeSnapshot
metadata:
  name: imported-aws-snapshot
  namespace: kubecost
spec:
  volumeSnapshotClassName: ebs-csi-aws
  source:
    volumeSnapshotContentName: imported-aws-snapshot-content   # <-- Here is the reference to the Snapshot by name
EOF
```

#### Creates the Peristent Volune Claim with the newly created VolumeSnapshot
```
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: imported-aws-snapshot-pvc
  namespace: kubecost
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: gp3
  resources:
    requests:
      storage: 32Gi
  dataSource:
    name: imported-aws-snapshot
    kind: VolumeSnapshot
    apiGroup: snapshot.storage.k8s.io
EOF
```

#### Patch Deployment with new Volunme Claim
```
kubectl -n kubecost patch deployment kubecost-cost-analyzer --patch '{"spec": {"template": {"spec": {"volumes": [{"name": "persistent-configs", "persistentVolumeClaim": { "claimName": "imported-aws-snapshot-pvc"}}]}}}}'
```

<br><br><br>

### Running Infracost and Pluralith:
<br>

#### Run Infracost for Cost Estimation (Requires an Account)
```
# Set Pluralith Credentials
export INFRACOST_API_KEY="<INFRACOST_API_KEY_HERE>"
export INFRACOST_ENABLE_DASHBOARD=true

# Generated Cost Usage Report
terramate run -- infracost breakdown --path . --usage-file ./infracost-usage.yml --sync-usage-file
```

#### Run Pluralith for Generated Diagrams (Requires an Account)
```
# Set Pluralith Credentials
export PATH=$PATH:/root/.linuxbrew/Cellar/infracost/0.10.13/bin
export PLURALITH_API_KEY="<PLURALITH_API_KEY_HERE>"
export PLURALITH_PROJECT_ID="<PLURALITH_PROJECT_ID_HERE>"

# Run Pluralith Init & Plan
terramate run -- pluralith init --api-key $PLURALITH_API_KEY --project-id $PLURALITH_PROJECT_ID
terramate run -- pluralith run plan --title "Stack" --show-changes=false --show-costs=true ----cost-usage-file=infracost-usage.yml
```


<br><br><br>

## Cleanup
<br>

#### Destroy Provisioned Infrastructure:
```
terramate run --reverse -- terraform destroy
```