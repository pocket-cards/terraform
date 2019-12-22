# -----------------------------------------------
# AWS CodeBuild IAM Policy - CodeBuild Basic Policy
# -----------------------------------------------
resource "aws_iam_policy" "codebuild_basic" {
  name   = "${local.project_name_uc}_CodeBuild_BasicPolicy"
  policy = file("iam/codebuild_policy_basic.json")
}

# -----------------------------------------------
# AWS CodeBuild - Backend Build
# -----------------------------------------------
resource "aws_codebuild_project" "backend_build" {
  depends_on = [aws_iam_role.codebuild_backend_build_role]

  name          = "${local.project_name_uc}-BackendBuild"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_backend_build_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    location = "${local.bucket_name_artifacts}/cache"
    type     = "S3"
  }

  environment {
    type                        = local.build_type
    compute_type                = local.build_compute_type
    image                       = local.build_image
    image_pull_credentials_type = "CODEBUILD"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# -----------------------------------------------
# AWS Codebuild IAM Role
# -----------------------------------------------
resource "aws_iam_role" "codebuild_backend_build_role" {
  name               = "${local.project_name_uc}_CodeBuild_BackendBuildRole"
  assume_role_policy = file("iam/codebuild_principals.json")
  lifecycle {
    create_before_destroy = false
  }
}

# -----------------------------------------------
# AWS Codebuild IAM Policy - Backend Build
# -----------------------------------------------
resource "aws_iam_policy" "codebuild_backend_build_policy" {
  name   = "${local.project_name_uc}_CodeBuild_BackendBuildPolicy"
  policy = file("iam/codebuild_policy_backend_build.json")
}

# -----------------------------------------------
# AWS Codebuild IAM Role Policy Attachment - Backend Build
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_backend_build_attach1" {
  role       = aws_iam_role.codebuild_backend_build_role.name
  policy_arn = aws_iam_policy.codebuild_backend_build_policy.arn
}

# -----------------------------------------------
# AWS Codebuild IAM Role Policy Attachment - Backend Build
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_backend_build_attach2" {
  role       = aws_iam_role.codebuild_backend_build_role.name
  policy_arn = aws_iam_policy.codebuild_basic.arn
}

# -----------------------------------------------
# AWS Codebuild - Backend publish
# -----------------------------------------------
resource "aws_codebuild_project" "backend_publish" {
  depends_on = [aws_iam_role.codebuild_backend_publish]

  name          = "${local.project_name_uc}-BackendPublish"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuild_backend_publish.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    location = "${local.bucket_name_artifacts}/cache"
    type     = "S3"
  }

  environment {
    type                        = local.build_type
    compute_type                = local.build_compute_type
    image                       = local.build_image
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = local.environment
    }

    environment_variable {
      name  = "PROJECT_NAME_UC"
      value = local.project_name_uc
    }

    environment_variable {
      name  = "APPLICATION_NAME"
      value = aws_codedeploy_app.backend.name
    }

    environment_variable {
      name  = "FUNCTION_ALIAS"
      value = local.lambda_alias_v1
    }

    environment_variable {
      name  = "ARTIFACTS_BUCKET"
      value = local.bucket_name_artifacts
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "publish/buildspec.yml"
  }
}

# -----------------------------------------------
# AWS Codebuild IAM Role - Backend publish
# -----------------------------------------------
resource "aws_iam_role" "codebuild_backend_publish" {
  name               = "${local.project_name_uc}_CodeBuild_BackendPublishRole"
  assume_role_policy = file("iam/codebuild_principals.json")

  lifecycle {
    create_before_destroy = false
  }
}

# -----------------------------------------------
# AWS Codebuild IAM Policy - Backend publish
# -----------------------------------------------
resource "aws_iam_policy" "codebuild_backend_publish" {
  name   = "${local.project_name_uc}_CodeBuild_BackendPublishPolicy"
  policy = file("iam/codebuild_policy_backend_publish.json")
}

# -----------------------------------------------
# AWS Codebuild IAM Role Policy Attachment - Backend publish
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_backend_publish_attach1" {
  role       = aws_iam_role.codebuild_backend_publish.name
  policy_arn = aws_iam_policy.codebuild_backend_publish.arn
}

# -----------------------------------------------
# AWS Codebuild IAM Role Policy Attachment - Backend Build
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_backend_publish_attach2" {
  role       = aws_iam_role.codebuild_backend_publish.name
  policy_arn = aws_iam_policy.codebuild_basic.arn
}

# -----------------------------------------------
# AWS Codebuild - Automation
# -----------------------------------------------
# resource "aws_codebuild_project" "codebuild_automation" {
#   name          = "${local.project_name_uc}-Automation"
#   build_timeout = "5"
#   service_role  = "${aws_iam_role.codebuild_automation_role.arn}"

#   artifacts {
#     type = "CODEPIPELINE"
#   }

#   cache {
#     location = "${local.bucket_name_artifacts}/cache"
#     type     = "S3"
#   }

#   environment {
#     type                        = "${local.build_type}"
#     compute_type                = "${local.build_compute_type}"
#     image                       = "${local.build_image}"
#     image_pull_credentials_type = "CODEBUILD"

#     environment_variable {
#       name  = "ENVIRONMENT"
#       value = "${local.environment}"
#     }

#     environment_variable {
#       name  = "TF_CLI_ARGS_plan"
#       value = "${local.parallelism}"
#     }

#     environment_variable {
#       name  = "TF_CLI_ARGS_apply"
#       value = "${local.parallelism}"
#     }
#   }

#   source {
#     type      = "CODEPIPELINE"
#     buildspec = "buildspec.yml"
#   }
# }

# -----------------------------------------------
# AWS Codebuild IAM Role - Automation
# -----------------------------------------------
# resource "aws_iam_role" "codebuild_automation_role" {
#   name               = "${local.project_name_uc}_CodeBuild_AutomationRole"
#   assume_role_policy = file("iam/codebuild_principals.json")
#   lifecycle {
#     create_before_destroy = false
#   }
# }

# -----------------------------------------------
# AWS Codebuild IAM Policy - Automation
# -----------------------------------------------
# resource "aws_iam_policy" "codebuild_automation_policy" {
#   name   = "${local.project_name_uc}_CodeBuild_AutomationPolicy"
#   policy = file("iam/codebuild_policy_automation.json")
# }

# -----------------------------------------------
# AWS Codebuild IAM Role Policy Attachment - Automation
# -----------------------------------------------
# resource "aws_iam_role_policy_attachment" "codebuild_automation_attach" {
#   role       = aws_iam_role.codebuild_automation_role.name
#   policy_arn = aws_iam_policy.codebuild_automation_policy.arn
# }

