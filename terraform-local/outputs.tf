output "queue_urls" {
  description = "URL de cada fila SQS, por nome."
  value       = { for name, q in aws_sqs_queue.main : name => q.url }
}

output "dlq_urls" {
  description = "URL de cada DLQ, por nome da fila principal correspondente."
  value       = { for name, q in aws_sqs_queue.dlq : name => q.url }
}

output "table_name" {
  description = "Nome da tabela DynamoDB de orders."
  value       = aws_dynamodb_table.orders.name
}
