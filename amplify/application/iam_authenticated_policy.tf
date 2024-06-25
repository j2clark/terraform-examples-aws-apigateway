data "aws_iam_policy_document" "authenticated_role_policy" {
  statement {
    sid = "AuthUserApiGateway"
    effect = "Allow"
    actions = [
      "execute-api:Invoke",
    ]
    resources = [
#      "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.restapi.id}/${aws_api_gateway_stage.v1.stage_name}/GET${aws_api_gateway_resource.hello.path}"
      "arn:aws:execute-api:${local.region}:${local.account_id}:${aws_api_gateway_rest_api.restapi.id}/${aws_api_gateway_stage.v1.stage_name}/POST${aws_api_gateway_resource.hello.path}"
    ]
  }
}

resource "aws_iam_role_policy" "authenticated" {
  name   = "${var.name_prefix}-authenticated"
  role   = data.aws_iam_role.authenticated_role.id
  policy = data.aws_iam_policy_document.authenticated_role_policy.json
}