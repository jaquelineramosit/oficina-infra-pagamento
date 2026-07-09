output "table_name" {
  description = "Nome da tabela DynamoDB."
  value       = aws_dynamodb_table.main.name
}

output "table_arn" {
  description = "ARN da tabela DynamoDB."
  value       = aws_dynamodb_table.main.arn
}

output "database_name" {
  description = "Nome logico do banco de dados."
  value       = var.database_name
}
