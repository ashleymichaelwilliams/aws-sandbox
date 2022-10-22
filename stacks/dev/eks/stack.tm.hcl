stack {
  name = "AWS Elastic Kubernetes Service Stack"
  id   = "aws-eks-dev"

  after = [
    "/stacks/dev/vpc",
  ]
}