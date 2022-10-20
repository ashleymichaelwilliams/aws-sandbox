stack {
  name = "AWS Elastic Kubernetes Service Stack"
  id   = "aws-eks"

  after = [
    "/stacks/dev/vpc",
  ]
}