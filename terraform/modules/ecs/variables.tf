variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "ap-southeast-2"
}

variable "vpc_id" {
  type        = string
  description = "VPC ID for the ECS cluster"
}

variable "private_subnets" {
  description = "private subnet id list"
  type        = list(string)
}

variable "public_subnets" {
  description = "public subnet id list"
  type        = list(string)
}

variable "ecs_task_execution_role_name" {
  description = "ECS task execution role name"
  default     = "webapp-ecs-task-execution-role"
}

variable "ecs_task_role_name" {
  description = "ECS task role name"
  default     = "webapp-ecs-task-role"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "wordpress"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_port_secure" {
  default = 443
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 2
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "efs_access_point" {
  type = string
}

variable "efs_id" {
  type = string
}

variable "rds_endpoint" {
  type = string
}

variable "rds_database_name" {
  type = string
}

variable "rds_database_username" {
  type = string
}

variable "rds_database_password" {
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
