variable "domain_name" {
  default = "cardano-landsaleapi.virtua.com"
}

variable "cache_policy_name" {
  default = "Managed-CachingOptimized"
}

variable "origin_request_policy_name" {
  default = "Managed-CORS-S3Origin"
}

variable "region" {
  default     = "us-east-1"
  type        = string
  description = "Region of the VPC"
}

variable "cidr_block" {
  default     = "10.0.0.0/16"
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_cidr_blocks" {
  default     = ["10.0.0.0/24", "10.0.2.0/24"]
  type        = list
  description = "List of public subnet CIDR blocks"
}

variable "private_subnet_cidr_blocks" {
  default     = ["10.0.1.0/24", "10.0.3.0/24"]
  type        = list
  description = "List of private subnet CIDR blocks"
}

variable "env-s3-bucket" {
  default = "virtua-envs-prod"
}

variable "availability_zones" {
  default     = ["us-east-1a", "us-east-1b"]
  type        = list
  description = "List of availability zones"
}
locals {
  availability_zones = ["${var.region}a", "${var.region}b"]
}
