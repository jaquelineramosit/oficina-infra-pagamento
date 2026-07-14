variable "queue_names" {
  description = "Nomes das filas SQS principais do dominio de pagamento."
  type        = set(string)
  default = [
    "sqs-pagamento-solicitar",
    "sqs-pagamento-efetuado",
    "sqs-pagamento-recusado",
  ]
}

variable "table_name" {
  description = "Nome da tabela DynamoDB de orders."
  type        = string
  default     = "orders"
}

variable "hash_key_name" {
  description = "Nome do atributo de partition key da tabela."
  type        = string
  default     = "order_id"
}
