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
