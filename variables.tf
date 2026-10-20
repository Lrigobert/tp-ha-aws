variable "region" {
  description = "AWS Region"
  default     = "eu-north-1"
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "db_password" {
  description = "RDS Password"
  sensitive   = true
  default     = "Admin123456!"
}
