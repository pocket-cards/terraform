data "aws_region" "this" {}

locals {
  # -----------------------------------------------
  # Project Informations
  # -----------------------------------------------
  remote_init      = "${data.terraform_remote_state.initialize.outputs}"
  project_name     = "${local.remote_init.project_name}"
  project_name_uc  = "${local.remote_init.project_name_uc}"
  project_name_stn = "${local.remote_init.project_name_stn}"
  region           = "${data.aws_region.this.name}"
  environment      = "${terraform.workspace}"
  is_test          = "${local.environment == "test" ? 1 : 0}"

  # -----------------------------------------------
  # S3 Buckets
  # -----------------------------------------------
  bucket_name_audio    = "${local.project_name}-audios-${random_id.bucket.hex}"
  bucket_name_frontend = "${local.project_name}-frontend-${random_id.bucket.hex}"
  bucket_name_logging  = "${local.project_name}-logging-${random_id.bucket.hex}"
  bucket_name_images   = "${local.project_name}-images-${random_id.bucket.hex}"

  # -----------------------------------------------
  # Dynamodb Tables
  # -----------------------------------------------
  dyanmodb_random_id       = "${length(random_id.dynamodb) == 1 ? random_id.dynamodb.0.hex : ""}"
  dynamodb_name_users      = "${local.project_name_uc}_Users${local.dyanmodb_random_id}"
  dynamodb_name_groupwords = "${local.project_name_uc}_GroupWords${local.dyanmodb_random_id}"
  dynamodb_name_userGroups = "${local.project_name_uc}_UserGroups${local.dyanmodb_random_id}"
  dynamodb_name_words      = "${local.project_name_uc}_Words${local.dyanmodb_random_id}"
  dynamodb_name_history    = "${local.project_name_uc}_History${local.dyanmodb_random_id}"
}

# data "aws_cognito_user_pools" "this" {
#   name = "${aws_cognito_user_pool.this.name}"
# }
