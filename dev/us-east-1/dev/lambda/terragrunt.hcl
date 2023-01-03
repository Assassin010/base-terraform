terraform {
  source = "https://github.com/Assassin010/tfenv-tgenv-modules/tree/main/lambda"
}

inputs = {
  zip_output_dir = "files"
  tags = {
    # Define custom tags here as key = "value"
  }
}

include {
  path = find_in_parent_folders()
}


/*// this variable is needed so that the module can correctly generate a zip
// and then later reference that zip in a relative manner. Otherwise the path
// becomes dependent on the particular `.terragrunt-cache` directory.
inputs = {
  zip_output_dir = "files"
}*/