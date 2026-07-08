locals {
  lambda_role_name = element(reverse(split("/", data.aws_lambda_function.payment.role)), 0)

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

data "aws_lambda_function" "payment" {
  function_name = var.lambda_function_name
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

resource "aws_iam_role_policy" "lambda_sqs_access" {
  count = var.attach_lambda_sqs_policy ? 1 : 0

  name = "${var.queue_name}-sqs-access"
  role = local.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage",
          "sqs:SendMessageBatch"
        ]
        Resource = aws_sqs_queue.main.arn
      }
    ]
  })
}

resource "aws_lambda_event_source_mapping" "payment_queue" {
  event_source_arn                   = aws_sqs_queue.main.arn
  function_name                      = data.aws_lambda_function.payment.function_name
  batch_size                         = var.lambda_sqs_batch_size
  enabled                            = true
  maximum_batching_window_in_seconds = var.lambda_sqs_maximum_batching_window_in_seconds

  depends_on = [
    aws_iam_role_policy.lambda_sqs_access
  ]
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
