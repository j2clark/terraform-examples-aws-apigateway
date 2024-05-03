data "aws_iam_policy_document" "codebuild_policy_document" {
  statement {
    sid = "PassExecutionRole"
    effect = "Allow"
    actions = [
      "iam:GetRole",
      "iam:PassRole"
    ]
    resources = [
#      data.aws_iam_role.execution_role.arn
      aws_iam_role.execution_role.arn
    ]
  }

  statement {
    sid = "DescribeLogs"
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group::log-stream:",
    ]
  }

  statement {
    sid = "Logs"
    effect = "Allow"
    actions = [
      "logs:ListTagsLogGroup",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutRetentionPolicy",
      "logs:DeleteLogGroup",
      "logs:TagResource",
    ]
    resources = [
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:/aws/codebuild/*",
      "arn:aws:logs:${local.region}:${local.account_id}:log-group:API-Gateway-Execution-Logs*/*"
    ]
  }

  statement {
    sid = "CodeBuild"
    effect = "Allow"
    actions = [
      "codebuild:CreateReportGroup",
      "codebuild:CreateReport",
      "codebuild:UpdateReport",
      "codebuild:BatchPutTestCases",
      "codebuild:BatchPutCodeCoverages"
    ]
    resources = [
      "arn:aws:codebuild:${local.region}:${local.account_id}:report-group/${local.name_prefix}*"
    ]
  }

  statement {
    sid     = "ManageLambdas"
    effect  = "Allow"
    actions = [
      "lambda:GetFunction",
      "lambda:GetFunctionCodeSigningConfig",
      "lambda:ListVersionsByFunction",
      "lambda:CreateFunction",
      "lambda:TagResource",
      "lambda:AddPermission",
      "lambda:GetPolicy",
      "lambda:UpdateFunctionCode",
    ]
    resources = [
      "arn:aws:lambda:${local.region}:${local.account_id}:function:${local.name_prefix}*"
    ]
  }

  statement {
    sid = "ManageApiGateway"
    effect = "Allow"
    actions = [
      "apigateway:GET",
      "apigateway:PUT",
      "apigateway:POST",
      "apigateway:PATCH",
      "apigateway:DELETE",
    ]
    resources = [
      "arn:aws:apigateway:${local.region}::*"
    ]
  }

  statement {
    sid = "S3WriteAccessArtifacts"
    effect = "Allow"
    actions = [
      "s3:List*",
      "s3:PutObject*",
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:GetBucket*"
    ]
    resources = [
      aws_s3_bucket.artifacts.arn,
      "${aws_s3_bucket.artifacts.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "codebuild_policy" {
  name = "${local.name_prefix}-codebuild"
  policy = data.aws_iam_policy_document.codebuild_policy_document.json

  tags = local.common_tags
}


resource "aws_iam_role_policy_attachment" "codebuild-role-policy-attachment" {
  role       = aws_iam_role.codebuild_role.name
  policy_arn = aws_iam_policy.codebuild_policy.arn
}