output "table_name" {
  description = "Nome da tabela DynamoDB de orders."
  value       = aws_dynamodb_table.orders.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB de orders."
  value       = aws_dynamodb_table.orders.arn
}
