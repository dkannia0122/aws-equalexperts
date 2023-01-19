terraform {
  required_version = "0.13.7"

  backend "local" {
    workspace_dir = "/terraform_state/us/region/"
  }
}

