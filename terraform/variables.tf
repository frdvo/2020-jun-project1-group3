# This will have all the code that utilize the modules.

variable "aws_region" {
  type    = string
  default = "ap-southeast-2"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "repository_name" {
  description = "the name of the ECR repository to be created."
  type        = string
  default     = "wp-project3"
}

variable "ssh_allowed_cidr" {
  type = string
}

variable "app_image" {
  type    = string
  default = "wp-project3"
}

variable "image_tag" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "hosted_zone_id" {
  type = string
}

variable "acm_cert_arn" {
  type = string
}