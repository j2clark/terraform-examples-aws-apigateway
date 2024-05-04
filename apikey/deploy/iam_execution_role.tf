data "aws_iam_policy_document" "assumes_role_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = [
        "lambda.amazonaws.com",
      ]
    }
    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "execution_role" {
  name = "${local.name_prefix}-execution"
  assume_role_policy = data.aws_iam_policy_document.assumes_role_document.json
}

