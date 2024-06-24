data aws_s3_bucket "artifacts" {
  bucket = "${var.name_prefix}-${data.aws_caller_identity.current.account_id}"
}

data "aws_iam_role" "execution_role" {
  name = "${var.name_prefix}-execution"
}

data "aws_iam_role" "authenticated_role" {
  name = "${var.name_prefix}-authenticated"
}