variable "aws_region" {
  type        = string
  description = "AWS region to use"
  default     = "us-east-1"
}

variable "ec2_key_name" {
  type        = string
  description = "SSH key to use on EC2 instances"
  default     = "vockey"
}

variable "labrole_arn" {
  type        = string
  description = "ARN of the LabRole to assume for lambda functions and similar"
}

variable "domain" {
  type        = string
  description = "Domain to use for SSL certificates"
}
