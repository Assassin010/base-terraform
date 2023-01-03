# Set account-wide variables. These are automatically pulled in to configure the remote state bucket in the root
# terragrunt.hcl configuration.
locals {
  account = {
    name           = "dev"
    aws_account_id = "955769636964"
    aws_profile    = "default"
  }
}
