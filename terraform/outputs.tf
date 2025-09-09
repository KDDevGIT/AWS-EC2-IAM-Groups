output "bucket_name" {
  value = aws_s3_bucket.lab.bucket 
  description = "S3 Bucket"
}

output "instance_id" {
  value = aws_instance.app.id 
  description = "EC2 Instance ID"
}

output "instance_public_ip" {
  value = aws_instance.app.public_ip
  description = "Public IP"
}