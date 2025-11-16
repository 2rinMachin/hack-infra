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


variable "frontend_repo" {
  type        = string
  description = "Repository URL for the frontend"
  default     = "https://github.com/2rinMachin/hack-front"
}

variable "github_token" {
  type        = string
  description = "GitHub access token for the frontend"
}

variable "users_api_url" {
  type = string
}

variable "incidents_api_url" {
  type = string
}

variable "websocket_url" {
  type = string
}

variable "images_bucket_name" {
  type = string
}
