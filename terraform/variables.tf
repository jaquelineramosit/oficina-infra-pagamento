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

variable "queue_name" {
  description = "Nome da fila SQS principal."
  type        = string

  validation {
    condition = contains([
      "sqs-pagamento-solicitar",
      "sqs-pagamento-recusado",
      "sqs-pagamento-efetuado",
    ], var.queue_name)
    error_message = "queue_name deve ser uma das filas de pagamento permitidas."
  }
}

variable "attach_lambda_sqs_policy" {
  description = "Define se o Terraform deve anexar uma policy inline na role da Lambda para consumir e publicar mensagens na fila."
  type        = bool
  default     = true
}

variable "lambda_sqs_batch_size" {
  description = "Quantidade maxima de mensagens enviadas por lote para a Lambda."
  type        = number
  default     = 10

  validation {
    condition     = var.lambda_sqs_batch_size >= 1 && var.lambda_sqs_batch_size <= 10
    error_message = "lambda_sqs_batch_size deve estar entre 1 e 10."
  }
}

variable "lambda_sqs_maximum_batching_window_in_seconds" {
  description = "Janela maxima em segundos para agrupar mensagens antes de acionar a Lambda."
  type        = number
  default     = 0

  validation {
    condition     = var.lambda_sqs_maximum_batching_window_in_seconds >= 0 && var.lambda_sqs_maximum_batching_window_in_seconds <= 300
    error_message = "lambda_sqs_maximum_batching_window_in_seconds deve estar entre 0 e 300."
  }
}

variable "delay_seconds" {
  description = "Tempo em segundos para atrasar a entrega de mensagens."
  type        = number
  default     = 0

  validation {
    condition     = var.delay_seconds >= 0 && var.delay_seconds <= 900
    error_message = "delay_seconds deve estar entre 0 e 900."
  }
}

variable "max_message_size" {
  description = "Tamanho maximo da mensagem em bytes."
  type        = number
  default     = 262144

  validation {
    condition     = var.max_message_size >= 1024 && var.max_message_size <= 262144
    error_message = "max_message_size deve estar entre 1024 e 262144."
  }
}

variable "message_retention_seconds" {
  description = "Retencao de mensagens da fila principal em segundos."
  type        = number
  default     = 345600

  validation {
    condition     = var.message_retention_seconds >= 60 && var.message_retention_seconds <= 1209600
    error_message = "message_retention_seconds deve estar entre 60 e 1209600."
  }
}

variable "dlq_message_retention_seconds" {
  description = "Retencao de mensagens da DLQ em segundos."
  type        = number
  default     = 1209600

  validation {
    condition     = var.dlq_message_retention_seconds >= 60 && var.dlq_message_retention_seconds <= 1209600
    error_message = "dlq_message_retention_seconds deve estar entre 60 e 1209600."
  }
}

variable "receive_wait_time_seconds" {
  description = "Tempo de long polling da fila em segundos."
  type        = number
  default     = 10

  validation {
    condition     = var.receive_wait_time_seconds >= 0 && var.receive_wait_time_seconds <= 20
    error_message = "receive_wait_time_seconds deve estar entre 0 e 20."
  }
}

variable "visibility_timeout_seconds" {
  description = "Timeout de visibilidade das mensagens em segundos."
  type        = number
  default     = 30

  validation {
    condition     = var.visibility_timeout_seconds >= 0 && var.visibility_timeout_seconds <= 43200
    error_message = "visibility_timeout_seconds deve estar entre 0 e 43200."
  }
}

variable "max_receive_count" {
  description = "Quantidade maxima de recebimentos antes de enviar a mensagem para a DLQ."
  type        = number
  default     = 5

  validation {
    condition     = var.max_receive_count >= 1 && var.max_receive_count <= 1000
    error_message = "max_receive_count deve estar entre 1 e 1000."
  }
}

variable "tags" {
  description = "Tags adicionais para os recursos."
  type        = map(string)
  default     = {}
}

variable "database_name" {
  description = "Nome logico do banco de dados, usado em tags."
  type        = string
  default     = "oficina-pagamento-db"

  validation {
    condition     = length(trimspace(var.database_name)) > 0
    error_message = "database_name nao pode ser vazio."
  }
}

variable "table_name" {
  description = "Nome da tabela DynamoDB."
  type        = string
  default     = "oficina-pagamento-tbl"

  validation {
    condition     = length(trimspace(var.table_name)) > 0
    error_message = "table_name nao pode ser vazio."
  }
}

variable "hash_key_name" {
  description = "Nome do atributo de partition key da tabela."
  type        = string
  default     = "id"
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

variable "attach_lambda_dynamodb_policy" {
  description = "Define se o Terraform deve anexar uma policy inline na role da Lambda para acessar a tabela."
  type        = bool
  default     = true
}

variable "labRole" {
  default = "arn:aws:iam::539963454755:role/LabRole"
}