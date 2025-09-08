variable "region" {
  description = "AWS Region"
  type = string
  default = "us-west-1"
}

variable "profile" {
  description = "AWS CLI Profile"
  type = string
  default = null
}

variable "project_name" {
  description = "Project prefix for Names"
  type = string
  default = "ec2-iamrole-s3"
}

variable "project_suffix" {
  description = "Unique suffix for global names"
  type = string
  default = "dev"
}