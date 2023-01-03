terraform {
  source = "git::git@github.com:Assassin010/tfenv-tgenv-modules/tree/main/apigw"
}

locals {
  account_vars     = read_terragrunt_config(find_in_parent_folders("account.hcl"))
  region_vars      = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  environment_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
  account_name     = local.account_vars.locals.account.name
  aws_region       = local.region_vars.locals.region.aws_region
  env              = local.environment_vars.locals.environment.name
}

inputs = {

  env                     = local.env
  tags = {
    "apigw-private" = "true"
  }
}

include {
  path = find_in_parent_folders()
}
