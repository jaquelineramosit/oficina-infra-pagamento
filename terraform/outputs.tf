output "queue_arn" {
  description = "ARN da fila SQS principal."
  value       = aws_sqs_queue.main.arn
}

output "queue_name" {
  description = "Nome da fila SQS principal."
  value       = aws_sqs_queue.main.name
}

output "queue_url" {
  description = "URL da fila SQS principal."
  value       = aws_sqs_queue.main.url
}

output "dlq_arn" {
  description = "ARN da DLQ."
  value       = aws_sqs_queue.dlq.arn
}

output "dlq_name" {
  description = "Nome da DLQ."
  value       = aws_sqs_queue.dlq.name
}

output "dlq_url" {
  description = "URL da DLQ."
  value       = aws_sqs_queue.dlq.url
}

output "lambda_event_source_mapping_uuid" {
  description = "UUID do event source mapping entre a fila SQS e a Lambda."
  value       = aws_lambda_event_source_mapping.payment_queue.uuid
}

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