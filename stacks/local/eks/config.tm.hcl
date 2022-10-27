globals {

  mng_config = {
    spot = {

      name = "spot-eks-mng"

      capacity_type  = "SPOT"
      instance_types = ["t3.medium"]

      min_size     = 2
      max_size     = 5
      desired_size = 2

      update_config = {
        max_unavailable_percentage = 50
      }

      labels = {
        GithubRepo = "terraform-aws-eks"
        GithubOrg  = "terraform-aws-modules"
      }

      # block_device_mappings = {
      #   xvda = {
      #     ebs = {
      #       volume_size           = 50
      #       volume_type           = "gp3"
      #       iops                  = 150
      #       throughput            = 150
      #     }
      #   }
      # }

    }
  }
}