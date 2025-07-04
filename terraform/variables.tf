variable "region" {
  default = "us-east-1"
}

variable "key_name" {
  description = "Name of your existing AWS key pair"
}

variable "public_key_path" {
  description = "Path to your public SSH key"
}

variable "allowed_ssh_cidr" {
  description = "Restrict SSH to your IP"
}
