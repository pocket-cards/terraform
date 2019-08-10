module "S001" {
  source = "github.com/wwalpha/terraform-module-registry/aws/lambda"

  enable_dummy          = true
  enable_xray           = true
  publish               = true
  function_name         = "${local.project_name_uc}-S001"
  handler               = "${local.lambda_handler}"
  runtime               = "${local.lambda_runtime}"
  role_name             = "${local.project_name_uc}-S001"
  layers                = ["${local.xray}", "${local.moment}"]
  log_retention_in_days = "${var.lambda_log_retention_in_days}"
  timeout               = 5
  alias_name            = "${local.alias_name}"
  # trigger_principal     = "dynamodb.amazonaws.com"
  # trigger_source_arn    = "${local.dynamodb_group_words_arn}"

  variables = {
    TABLE_HISTORY     = "${local.dynamodb_history_name}"
    TABLE_USER_GROUPS = "${local.dynamodb_user_groups_name}"
    TZ                = "${local.timezone}"
  }

  role_policy_json = [
    "${data.aws_iam_policy_document.dynamodb_access_policy.json}",
    "${data.aws_iam_policy_document.dynamodb_stream.json}"
  ]
}

# resource "aws_lambda_event_source_mapping" "s001" {
#   batch_size        = 100
#   event_source_arn  = "${local.dynamodb_group_words_stream_arn}"
#   enabled           = false
#   function_name     = "${module.S001.arn}"
#   starting_position = "LATEST"
# }
