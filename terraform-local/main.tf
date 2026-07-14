locals {
  common_tags = {
    Project     = "oficina"
    Environment = "local"
    ManagedBy   = "terraform"
  }
}

resource "aws_sqs_queue" "dlq" {
  for_each = var.queue_names

  name                      = "${each.value}-dlq"
  message_retention_seconds = 1209600

  tags = merge(
    local.common_tags,
    {
      Name  = "${each.value}-dlq"
      Type  = "dlq"
      Queue = each.value
    }
  )
}

resource "aws_sqs_queue" "main" {
  for_each = var.queue_names

  name                       = each.value
  message_retention_seconds  = 345600
  visibility_timeout_seconds = 30
  receive_wait_time_seconds  = 10

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq[each.value].arn
    maxReceiveCount     = 5
  })

  tags = merge(
    local.common_tags,
    {
      Name  = each.value
      Type  = "main"
      Queue = each.value
    }
  )
}

resource "aws_dynamodb_table" "orders" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = var.hash_key_name

  attribute {
    name = var.hash_key_name
    type = "S"
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.table_name
    }
  )
}
