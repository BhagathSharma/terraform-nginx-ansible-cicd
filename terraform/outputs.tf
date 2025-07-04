output "nginx_ip" {
  description = "Public IP of the nginx server"
  value       = aws_instance.nginx.public_ip
}
