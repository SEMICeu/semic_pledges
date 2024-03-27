output "efs_id" {
  value = aws_efs_file_system.this.id
}

output "raw_output_bucket_id" {
  value = module.AWS-deploy-output-bucket.bucket_id
}