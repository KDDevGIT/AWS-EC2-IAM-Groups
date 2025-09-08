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

variable "instance_type" {
  description = "EC2 Instance Type"
  type = string
  default = "t3.micro"
}

variable "allow_ssh" {
  description = "Toggle to open SSH to IP (NA for SSM)"
  type = bool
  default = false
}

variable "my_ip_cidr" {
  description = "IP/CIDR if Allow SSH is enabled"
  type = string
  default = "0.0.0.0/0"
}