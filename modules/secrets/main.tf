data "aws_secretsmanager_secret" "sindhbank" {
  name = var.secret_name
}

data "aws_secretsmanager_secret_version" "sindhbank" {
  secret_id = data.aws_secretsmanager_secret.sindhbank.id
}
