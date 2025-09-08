locals {
    name_prefix = "${var.project_name}-${var.project_suffix}"
}

# S3 Bucket
resource "aws_s3_bucket" "lab" {
  bucket = replace(lower("${local.name_prefix}-bucket"), "_","-")
  force_destroy = false 
}

# Disable Public Access to S3 Bucket 
resource "aws_s3_bucket_public_access_block" "lab" {
  bucket = aws_s3_bucket.lab.id 
  block_public_acls = true 
  block_public_policy = true
  ignore_public_acls = true 
  restrict_public_buckets = true 
}

