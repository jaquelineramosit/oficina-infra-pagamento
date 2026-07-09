locals {

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Queue       = var.queue_name
    },
    var.tags
  )
}

resource "aws_sqs_queue" "dlq" {
  name                      = "${var.queue_name}-dlq"
  message_retention_seconds = var.dlq_message_retention_seconds
  sqs_managed_sse_enabled   = true

  tags = merge(
    local.common_tags,
    {
      Name = "${var.queue_name}-dlq"
      Type = "dlq"
    }
  )
}

resource "aws_sqs_queue" "main" {
  name                       = var.queue_name
  delay_seconds              = var.delay_seconds
  max_message_size           = var.max_message_size
  message_retention_seconds  = var.message_retention_seconds
  receive_wait_time_seconds  = var.receive_wait_time_seconds
  visibility_timeout_seconds = var.visibility_timeout_seconds
  sqs_managed_sse_enabled    = true

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = merge(
    local.common_tags,
    {
      Name = var.queue_name
      Type = "main"
    }
  )
}

# 1. Cria a política com permissões para o SQS
resource "aws_iam_policy" "sqs_developer_policy" {
  name        = "${var.project_name}-sqs-pagamento-policy"
  description = "Permite gerenciar as filas SQS do projeto oficina"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:CreateQueue",
          "sqs:DeleteQueue",
          "sqs:GetQueueAttributes",
          "sqs:SetQueueAttributes",
          "sqs:ListQueues",
          "sqs:SendMessage",
          "sqs:ReceiveMessage"
        ]
        Resource = "arn:aws:sqs:*:539963454755:${var.project_name}-*"
      }
    ]
  })
}

# 2. Cria a Role que seu pipeline/usuário precisará assumir
resource "aws_iam_role" "sqs_developer_role" {
  name = "${var.project_name}-sqs-developer-role"

  # Define quem tem permissão de "assumir" essa role (assume_role)
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          # Permite que o seu usuário atual do laboratório assuma esta nova role
          AWS = "arn:aws:iam::539963454755:root" 
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# 3. Conecta a Política na Role
resource "aws_iam_role_policy_attachment" "attach_sqs" {
  role       = aws_iam_role.sqs_developer_role.name
  policy_arn = aws_iam_policy.sqs_developer_policy.arn
}