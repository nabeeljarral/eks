output "secret_arn" {
  value       = data.aws_secretsmanager_secret.sindhbank.arn
  description = "ARN of the SindhBank secret."
}
