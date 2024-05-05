data "aws_iam_policy_document" "codebuild_role_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "codebuild.amazonaws.com",
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "codebuild_role" {
  name = "${local.name_prefix}-codebuild"
  assume_role_policy = data.aws_iam_policy_document.codebuild_role_document.json

  tags = local.common_tags
}