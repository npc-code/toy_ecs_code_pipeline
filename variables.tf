variable "cluster_name" {
  description = "The cluster_name"
}

variable "container_name" {
  description = "Container name"
}

variable "container_port" {
  description = "ALB target port"
}

variable "desired_task_cpu" {
  description = "Task CPU Limit"
}

variable "desired_task_memory" {
  description = "Task Memory Limit"
}

variable "environment_variables" {
  type        = map(string)
  description = "ecs task environment variables"
}

variable "alb_port" {
  description = "ALB listener port"
}

variable "vpc_id" {
  description = "The VPC id"
}

variable "external_ip" {
  type    = string
  default = "74.69.167.125/32"
}

variable "region" {
    type = string
    default = "us-east-2"
}

variable "availability_zones" {
  type        = list(string)
  description = "The azs to use"
}

variable "health_check_path" {
  description = ""
  default     = "/"
}

variable "desired_tasks" {
  description = "Number of containers desired to run the application task"
}

variable "ecr_repo_name" {
    description = "Name of the ecr repo to use"
}
