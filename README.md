# IAM Role for EC2 + S3 (No Static Credentials)

Deploys EC2 Instance with IAM Role for secure S3 access (no static credentials). Includes Terraform configs, IAM Role + Policy, and User Data to validate role-based S3 writing.

No access keys on the box. Also enables SSM Session Manager (no SSH keys needed).

## What is deployed
- S3 bucket (unique per run)
- IAM Role + Policy with least-privilege to that bucket
- Instance Profile attached to an EC2 instance
- User data that installs AWS CLI and proves access (writes a file to S3)
- SSM access via AmazonSSMManagedInstanceCore

## Prereqs
- Terraform ≥ 1.5
- AWS CLI configured (an admin profile is fine for lab work)
- An AWS account & region

## Quick start
```bash
cd terraform
terraform init
terraform plan -var="project_suffix=$(date +%s)"
terraform apply -auto-approve -var="project_suffix=$(date +%s)"
```
## Start a shell on the instance (no keypair required)
```bash
aws ssm start-session --target $(terraform output -raw instance_id)
```
## Inside Session
```bash
aws sts get-caller-identity
aws s3 ls s3://$(terraform output -raw bucket_name)/
aws s3 cp /etc/os-release s3://$(terraform output -raw bucket_name)/proof/os-release.txt
```
## Clean up
### Empty the bucket first (Terraform won’t destroy non-empty buckets)
```bash
aws s3 rm s3://$(terraform output -raw bucket_name) --recursive
```
## Then destroy
```bash
terraform destroy -auto-approve
```