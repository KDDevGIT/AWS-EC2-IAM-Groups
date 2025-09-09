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

# IAM Role for EC2
data "aws_iam_policy_document" "assume_ec2" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "${local.name_prefix}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_ec2.json 
}

# Attach SSM Core (No SSH Keys)
resource "aws_iam_role_policy_attachment" "ssm" {
  role = aws_iam_role.ec2_role.name 
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Inline S3 Policy S3 Bucket Template
data "aws_iam_policy_document" "s3_bucket_access" {
  statement {
    sid = "ListBucket"
    actions = ["s3:ListBucket"]
    resources = [
        "arn:aws:s3:::${aws_s3_bucket.lab.bucket}"
    ]
  }
  statement {
    sid = "ObjectRW"
    actions = ["s3:GetObject","s3:PutObject","s3:DeleteObject"]
    resources = [
        "arn:aws:s3:::${aws_s3_bucket.lab.bucket}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_bucket_access" {
  name = "${local.name_prefix}-s3-access"
  policy = data.aws_iam_policy_document.s3_bucket_access.json 
}

resource "aws_iam_role_policy_attachment" "s3_attach" {
  role = aws_iam_role.ec2_role.name 
  policy_arn = aws_iam_policy.s3_bucket_access.arn 
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name_prefix}-instance-profile"
  role = aws_iam_role.ec2_role.name 
}

# Simple Networking
data "aws_vpc" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# SG with Outbound Open, Inbound SSH 
resource "aws_security_group" "ec2_sg" {
  name = "${local.name_prefix}-sg"
  description = "EC2 Security Group"
  vpc_id = data.aws_vpc.default.id 

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  dynamic "ingress" {
    for_each = var.allow_ssh ? [1] : []
    content {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = [var.my_ip_cidr]
      description = "Inbound SSH"
    }
  }
}

# Linux 2023 AMI
data "aws_ami" "al2023" {
  most_recent = true 
  owners = ["137112412989"]
  filter {
    name = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}