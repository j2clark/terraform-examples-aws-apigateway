resource aws_s3_bucket "artifacts" {
  bucket = "${local.name_prefix}-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
  tags = local.common_tags
}