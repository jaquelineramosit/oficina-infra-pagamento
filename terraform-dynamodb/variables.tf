variable "aws_region" {
  description = "Regiao AWS onde os recursos serao criados."
  type        = string

  validation {
    condition     = length(trimspace(var.aws_region)) > 0
    error_message = "aws_region nao pode ser vazio."
  }
}

variable "project_name" {
  description = "Nome do projeto usado em tags."
  type        = string
  default     = "oficina"
}

variable "environment" {
  description = "Ambiente da infraestrutura."
  type        = string
  default     = "dev"
}

variable "table_name" {
  description = "Nome da tabela DynamoDB de orders."
  type        = string
  default     = "orders"

  validation {
    condition     = length(trimspace(var.table_name)) > 0
    error_message = "table_name nao pode ser vazio."
  }
}

variable "hash_key_name" {
  description = "Nome do atributo de partition key da tabela."
  type        = string
  default     = "order_id"
}

variable "hash_key_type" {
  description = "Tipo do atributo de partition key (S, N ou B)."
  type        = string
  default     = "S"

  validation {
    condition     = contains(["S", "N", "B"], var.hash_key_type)
    error_message = "hash_key_type deve ser S, N ou B."
  }
}

variable "billing_mode" {
  description = "Modo de cobranca da tabela DynamoDB."
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PAY_PER_REQUEST", "PROVISIONED"], var.billing_mode)
    error_message = "billing_mode deve ser PAY_PER_REQUEST ou PROVISIONED."
  }
}

variable "tags" {
  description = "Tags adicionais para os recursos."
  type        = map(string)
  default     = {}
}
