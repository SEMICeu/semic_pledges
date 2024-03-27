output "bucket_id" {
  value = module.AWS-deploy-bootstrap-bucket.bucket_id
}

output "ddb_table_id" {
  value = aws_dynamodb_table.lock.id
}