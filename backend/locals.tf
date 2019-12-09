locals {
  # -----------------------------------------------
  # Project Informations
  # -----------------------------------------------
  remote_init = "${data.terraform_remote_state.initialize.outputs}"
  remote_unmu = "${data.terraform_remote_state.unmutable.outputs}"

  project_name        = "${local.remote_init.project_name}"
  project_name_uc     = "${local.remote_init.project_name_uc}"
  region              = "${data.aws_region.this.name}"
  account_id          = "${data.aws_caller_identity.this.account_id}"
  environment         = "${terraform.workspace}"
  is_dev              = "${local.environment == "dev"}"
  region_us           = "us-east-1"
  timezone            = "Asia/Tokyo"
  translation_url     = "${local.remote_init.translation_url}"
  translation_api_key = "${local.remote_init.ssm_param_translation_api_key}"
  ipa_url             = "${local.remote_init.ipa_url}"
  ipa_api_key         = "${local.remote_init.ssm_param_ipa_api_key}"
  parallelism         = "--parallelism=30"
  # -----------------------------------------------
  # API Gateway
  # -----------------------------------------------
  # api_base_path = "cards"
  api_gateway_files = [
    "${filemd5("apigateway.tf")}",
    "${filemd5("lambda_A0.tf")}",
    "${filemd5("lambda_B0.tf")}",
    "${filemd5("lambda_C0.tf")}",
    "${filemd5("lambda_D0.tf")}",
    "${filemd5("lambda_E0.tf")}",
    "${filemd5("lambda_S0.tf")}",
  ]
  api_gateway_deployment_md5 = "${base64encode(join("", local.api_gateway_files))}"
  http_method = {
    get    = "GET"
    post   = "POST"
    delete = "DELETE"
    put    = "PUT"
  }

  authorization_type_cognito = "COGNITO_USER_POOLS"
  # -----------------------------------------------
  # Cognito
  # -----------------------------------------------
  # identity_pool_arn = "${local.remote_main.identity_pool_arn}"
  # -----------------------------------------------
  # CodePipeline
  # -----------------------------------------------
  github_token = "${data.aws_ssm_parameter.github_token.value}"
  # -----------------------------------------------
  # CodeBuild
  # -----------------------------------------------
  build_type                 = "LINUX_CONTAINER"
  build_compute_type         = "BUILD_GENERAL1_SMALL"
  build_image                = "aws/codebuild/standard:2.0"
  github_repo_branch         = "master"
  github_organization        = "${local.remote_unmu.github_organization}"
  github_repo_backend        = "${local.remote_unmu.github_repo_backend}"
  github_repo_automation     = "${local.remote_unmu.github_repo_automation}"
  github_events              = "${local.is_dev ? "push" : "release"}"
  github_filter_json_path    = "${local.is_dev ? "$.ref" : "$.action"}"
  github_filter_match_equals = "${local.is_dev ? "refs/heads/master" : "published"}"
  # -----------------------------------------------
  # S3 Bucket
  # -----------------------------------------------
  bucket_name_audios    = "${local.remote_unmu.bucket_name_audios}"
  bucket_name_images    = "${local.remote_unmu.bucket_name_images}"
  bucket_name_logging   = "${local.remote_unmu.bucket_name_logging}"
  bucket_name_artifacts = "${local.remote_init.bucket_name_artifacts}"
  # -----------------------------------------------
  # DynamoDB
  # -----------------------------------------------
  dynamodb_name_users       = "${local.remote_unmu.dynamodb_name_users}"
  dynamodb_name_user_groups = "${local.remote_unmu.dynamodb_name_user_groups}"
  dynamodb_name_group_words = "${local.remote_unmu.dynamodb_name_group_words}"
  dynamodb_name_words       = "${local.remote_unmu.dynamodb_name_words}"
  dynamodb_name_history     = "${local.remote_unmu.dynamodb_name_history}"

  # -----------------------------------------------
  # API Gateway
  # -----------------------------------------------
  api_gateway_domain         = "${module.api.id}.execute-api.${local.region}.amazonaws.com"
  api_endpoint_configuration = "REGIONAL"

  status_200       = { statusCode = 200 }
  response_version = { version = "${var.app_ver}" }

  deployment_files = [
    "${file("api_methods.tf")}",
    "${file("api_resources.tf")}",
    "${file("apigateway.tf")}",
  ]

  # -----------------------------------------------
  # Cognito
  # -----------------------------------------------
  cognito_identity_pool_id = "${local.remote_unmu.cognito_identity_pool_id}"

  # -----------------------------------------------
  # Lambda Layers
  # -----------------------------------------------
  xray   = "${local.remote_init.layers.xray}"
  moment = "${local.remote_init.layers.moment}"
  lodash = "${local.remote_init.layers.lodash}"
  axios  = "${local.remote_init.layers.axios}"

  # -----------------------------------------------
  # Lambda
  # -----------------------------------------------
  lambda_api_prefix = "arn:aws:apigateway:${local.region}:lambda:path/2015-03-31/functions"
  lambda_arn_prefix = "${local.lambda_api_prefix}/arn:aws:lambda:${local.region}:${local.account_id}:function"

# 
  # lambda_handler              = "index.handler"
  # lambda_runtime              = "nodejs10.x"
  # lambda_alias_name           = "${local.environment}"
  # audio_path_pattern          = "audio"
  # lambda_role_prefix          = "${local.project_name_uc}_Lambda"
  lambda_function_name_prefix = "${local.project_name_uc}"
  lambda_function_alias_v1 = "v1" 

  lambda_function_name = {
    a001 = "${local.lambda_function_name_prefix}_A001:${local.lambda_function_alias_v1}"
    a002 = "${local.lambda_function_name_prefix}_A002:${local.lambda_function_alias_v1}"
    a003 = "${local.lambda_function_name_prefix}_A003:${local.lambda_function_alias_v1}"
    b001 = "${local.lambda_function_name_prefix}_B001:${local.lambda_function_alias_v1}"
    b002 = "${local.lambda_function_name_prefix}_B002:${local.lambda_function_alias_v1}"
    b003 = "${local.lambda_function_name_prefix}_B003:${local.lambda_function_alias_v1}"
    b004 = "${local.lambda_function_name_prefix}_B004:${local.lambda_function_alias_v1}"
    c001 = "${local.lambda_function_name_prefix}_C001:${local.lambda_function_alias_v1}"
    c002 = "${local.lambda_function_name_prefix}_C002:${local.lambda_function_alias_v1}"
    c003 = "${local.lambda_function_name_prefix}_C003:${local.lambda_function_alias_v1}"
    c004 = "${local.lambda_function_name_prefix}_C004:${local.lambda_function_alias_v1}"
    c006 = "${local.lambda_function_name_prefix}_C006:${local.lambda_function_alias_v1}"
    c007 = "${local.lambda_function_name_prefix}_C007:${local.lambda_function_alias_v1}"
    c008 = "${local.lambda_function_name_prefix}_C008:${local.lambda_function_alias_v1}"
    d001 = "${local.lambda_function_name_prefix}_D001:${local.lambda_function_alias_v1}"
    s001 = "${local.lambda_function_name_prefix}_S001:${local.lambda_function_alias_v1}"
  }

  # lambda = {
  #   a001 = {
  #     function_name = "${local.lambda_function_name_prefix}_A001"
  #     role_name     = "${local.lambda_role_prefix}_A001Role"
  #   }
  #   a002 = {
  #     function_name = "${local.lambda_function_name_prefix}_A002"
  #     role_name     = "${local.lambda_role_prefix}_A002Role"
  #   }
  #   a003 = {
  #     function_name = "${local.lambda_function_name_prefix}_A003"
  #     role_name     = "${local.lambda_role_prefix}_A003Role"
  #   }
  #   b001 = {
  #     function_name = "${local.lambda_function_name_prefix}_B001"
  #     role_name     = "${local.lambda_role_prefix}_B001Role"
  #   }
  #   b002 = {
  #     function_name = "${local.lambda_function_name_prefix}_B002"
  #     role_name     = "${local.lambda_role_prefix}_B002Role"
  #   }
  #   b003 = {
  #     function_name = "${local.lambda_function_name_prefix}_B003"
  #     role_name     = "${local.lambda_role_prefix}_B003Role"
  #   }
  #   b004 = {
  #     function_name = "${local.lambda_function_name_prefix}_B004"
  #     role_name     = "${local.lambda_role_prefix}_B004Role"
  #   }
  #   c001 = {
  #     function_name = "${local.lambda_function_name_prefix}_C001"
  #     role_name     = "${local.lambda_role_prefix}_C001Role"
  #   }
  #   c002 = {
  #     function_name = "${local.lambda_function_name_prefix}_C002"
  #     role_name     = "${local.lambda_role_prefix}_C002Role"
  #   }
  #   c003 = {
  #     function_name = "${local.lambda_function_name_prefix}_C003"
  #     role_name     = "${local.lambda_role_prefix}_C003Role"
  #   }
  #   c004 = {
  #     function_name = "${local.lambda_function_name_prefix}_C004"
  #     role_name     = "${local.lambda_role_prefix}_C004Role"
  #   }
  #   c006 = {
  #     function_name = "${local.lambda_function_name_prefix}_C006"
  #     role_name     = "${local.lambda_role_prefix}_C006Role"
  #   }
  #   c007 = {
  #     function_name = "${local.lambda_function_name_prefix}_C007"
  #     role_name     = "${local.lambda_role_prefix}_C007Role"
  #   }
  #   c008 = {
  #     function_name = "${local.lambda_function_name_prefix}_C008"
  #     role_name     = "${local.lambda_role_prefix}_C008Role"
  #   }
  #   d001 = {
  #     function_name = "${local.lambda_function_name_prefix}_D001"
  #     role_name     = "${local.lambda_role_prefix}_D001Role"
  #   }
  #   s001 = {
  #     function_name = "${local.lambda_function_name_prefix}_S001"
  #     role_name     = "${local.lambda_role_prefix}_S001Role"
  #   }
  # }
}
# -----------------------------------------------
# AWS Region
# -----------------------------------------------
data "aws_region" "this" {}
# -----------------------------------------------
# AWS Route53
# -----------------------------------------------
data "aws_route53_zone" "this" {
  name = "${local.remote_init.domain_name}"
}
# -----------------------------------------------
# SSM Parameter Store - Github token
# -----------------------------------------------
data "aws_ssm_parameter" "github_token" {
  name = "${local.remote_init.ssm_param_github_token}"
}
# -----------------------------------------------
# AWS Account
# -----------------------------------------------
data "aws_caller_identity" "this" {}
