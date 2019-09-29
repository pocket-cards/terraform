# -----------------------------------------------
# AWS Provider
# -----------------------------------------------
provider "aws" {}

# -----------------------------------------------
# GitHub Provider
# -----------------------------------------------
provider "github" {
  token        = "${local.github_token}"
  organization = "${local.github_organization}"
}

# -----------------------------------------------
# AWS Provider - US
# -----------------------------------------------
provider "aws" {
  region = "${local.region_us}"
  alias  = "global"
}

# -----------------------------------------------
# Terraform Settings
# -----------------------------------------------
terraform {
  backend "s3" {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/architecture2.tfstate"
  }

  required_version = ">= 0.12"
}


# -----------------------------------------------
# Remote state - Initialize
# -----------------------------------------------
data "terraform_remote_state" "initialize" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/initialize.tfstate"
  }
}

# -----------------------------------------------
# Remote state - Unmutable
# -----------------------------------------------
data "terraform_remote_state" "unmutable" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/unmutable.tfstate"
  }
}
# -----------------------------------------------
# Remote state - Architecture1
# -----------------------------------------------
data "terraform_remote_state" "backend" {
  backend   = "s3"
  workspace = "${terraform.workspace}"

  config = {
    bucket = "terraform-workspaces"
    region = "ap-northeast-1"
    key    = "pocket-cards/architecture1.tfstate"
  }
}
