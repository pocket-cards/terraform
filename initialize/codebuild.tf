# -----------------------------------------------
# AWS Codebuild
# -----------------------------------------------
resource "aws_codebuild_project" "initialize" {
  depends_on = ["aws_iam_role.codebuild_role"]

  name          = "${local.project_name_uc}-Initialize"
  build_timeout = "30"
  service_role  = "${aws_iam_role.codebuild_role.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    type                        = "${local.build_type}"
    compute_type                = "${local.build_compute_type}"
    image                       = "${local.build_image}"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "ENVIRONMENT"
      value = "${local.environment}"
    }

    environment_variable {
      name  = "TF_CLI_ARGS_plan"
      value = "${local.parallelism}"
    }

    environment_variable {
      name  = "TF_CLI_ARGS_apply"
      value = "${local.parallelism}"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = "buildspec.yml"
  }
}

# -----------------------------------------------
# AWS Codebuild IAM Role
# -----------------------------------------------
resource "aws_iam_role" "codebuild_role" {
  name               = "${local.project_name_uc}_CodeBuild_InitializeRole"
  assume_role_policy = "${file("iam/codebuild_principals.json")}"
  lifecycle {
    create_before_destroy = false
  }
}

# -----------------------------------------------
# AWS Codebuild IAM Policy
# -----------------------------------------------
resource "aws_iam_role_policy_attachment" "codebuild_policy" {
  role       = "${aws_iam_role.codebuild_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
