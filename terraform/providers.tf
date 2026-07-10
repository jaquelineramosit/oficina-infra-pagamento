provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }

  assume_role {
    # Insira aqui o ARN completo da role que você encontrou
    role_arn     = "arn:aws:iam::539963454755:role/LabRole"
    session_name = "TerraformSQSDeployment"
  }
}