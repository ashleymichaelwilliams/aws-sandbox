# Generate '_terramate_generated_backend.tf' in each stack for Local File-System
generate_hcl "_terramate_generated_backend.tf" {
  condition = global.isLocal == true

  content {
    terraform {

      backend "local" {
        path = global.local_tfstate_path
      }
    }
  }
}



# Generate '_terramate_generated_backend.tf' in each stack for Remote Terraform Cloud
generate_hcl "_terramate_generated_backend.tf" {
  condition = global.isLocal == false

  content {
    terraform {

      backend "remote" {
        organization = global.tfe_organization

        workspaces {
          name = global.tfe_workspace
        }
      }
    }
  }
}