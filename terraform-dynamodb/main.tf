locals {
  lambda_role_name = element(reverse(split("/", data.aws_lambda_function.payment.role)), 0)

  common_tags = merge(
    {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
      Database    = var.database_name
    },
    var.tags
  )
}

data "aws_lambda_function" "payment" {
  function_name = var.lambda_function_name
}

resource "aws_dynamodb_table" "main" {
  name         = var.table_name
  billing_mode = var.billing_mode
  hash_key     = var.hash_key_name

  attribute {
    name = var.hash_key_name
    type = var.hash_key_type
  }

  point_in_time_recovery {
    enabled = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.table_name
    }
  )
}

resource "aws_iam_role_policy" "lambda_dynamodb_access" {
  count = var.attach_lambda_dynamodb_policy ? 1 : 0

  name = "${var.table_name}-dynamodb-access"
  role = local.lambda_role_name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchGetItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = [
          aws_dynamodb_table.main.arn,
          "${aws_dynamodb_table.main.arn}/index/*"
        ]
      }
    ]
  })
}
