# ---------------------------------------------------------------------------------------------------------------------
# TERRAGRUNT CONFIGURATION
# Terragrunt is a thin wrapper for Terraform that provides extra tools for working with multiple Terraform modules,
# remote state, and locking: https://github.com/gruntwork-io/terragrunt
# ---------------------------------------------------------------------------------------------------------------------

terragrunt_version_constraint = "0.42.5"
terraform_version_constraint  = "1.3.6"

locals {
  # Automatically load account-level variables
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Automatically load region-level variables
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))

  # Automatically load environment-level variables
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))

  # Extract the variables we need for easy access
  account_name = local.account_vars.locals.account.name
  account_id   = local.account_vars.locals.account.aws_account_id
  aws_profile  = local.account_vars.locals.account.aws_profile
  aws_region   = local.region_vars.locals.region.aws_region
  state_region = local.region_vars.locals.region.state_region
  env          = local.environment_vars.locals.environment.name
}

# Generate an AWS provider block
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "aws" {
  region = "${local.aws_region}"
  profile = "{local.aws_profile}"
  allowed_account_ids = ["${local.account_id}"]

  skip_metadata_api_check = true
}
EOF
}

# Configure Terragrunt to automatically store tfstate files in an S3 bucket and use DynamoDB Table for locking.
remote_state {
  backend = "s3"
  config = {
    disable_bucket_update = true
    encrypt               = true
    bucket                = "kwatatshey.terraform-state.${local.account_name}.${local.state_region}"
    key                   = "${path_relative_to_include()}/terraform.tfstate"
    region                = local.aws_region
    dynamodb_table        = "kwatatshey-${local.account_name}-${local.state_region}-terrafrom-state-lock"
    profile               = "{local.aws_profile}"

    skip_metadata_api_check = true

    s3_bucket_tags = {
      "account-name"        = "${local.account_name}"
      "env"                 = "${local.env}"
      "managed-by"          = "terraform"
      "data-classification" = "internal"
    }

    dynamodb_table_tags = {
      "account-name"        = "${local.account_name}"
      "env"                 = "${local.env}"
      "managed-by"          = "terraform"
      "data-classification" = "internal"
    }
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

inputs = {
  common_tags = {
    "account-name"   = "${local.account_name}",
    "env"            = "${local.env}",
    "managed-by"     = "terraform",
    "terraform-path" = "${path_relative_to_include()}",
  }
}
