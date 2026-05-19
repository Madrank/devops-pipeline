output "instance_id" {
  description = "ID de l'instance EC2"
  value       = aws_instance.app.id
}

output "instance_public_ip" {
  description = "IP publique de l'instance EC2"
  value       = aws_eip.app.public_ip
}

output "instance_public_dns" {
  description = "DNS public de l'instance EC2"
  value       = aws_instance.app.public_dns
}

output "app_url" {
  description = "URL d'acces a l'application"
  value       = "http://${aws_eip.app.public_ip}"
}
