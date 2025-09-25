variable "region" {
  type        = string
  description = "The AWS Region"
  default     = "us-east-1"
}

variable "vpc_cidr" {
  type        = string
  description = "The VPC CIDR block range"
  default     = "10.0.0.0/16"
}

variable "public_sbn_cidr_ranges" {
  type        = list(string)
  description = "Public subnet CIDR block ranges"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "enable_vpn_gateway" {
  description = "Enable a VPN gateway in your VPC."
  type        = bool
  default     = false
}

variable "public_subnet_count" {
  description = "Number of public subnets."
  type        = number
  default     = 2
}

variable "private_subnet_count" {
  description = "Number of private subnets."
  type        = number
  default     = 2
}

variable "public_subnet_cidr_blocks" {
  description = "Available cidr blocks for public subnets"
  type        = list(string)
  default = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24",
    "10.0.6.0/24",
    "10.0.7.0/24",
    "10.0.8.0/24",
  ]
}

variable "private_subnet_cidr_blocks" {
  description = "Available cidr blocks for private subnets"
  type        = list(string)
  default = [
    "10.0.101.0/24",
    "10.0.102.0/24",
    "10.0.103.0/24",
    "10.0.104.0/24",
    "10.0.105.0/24",
    "10.0.106.0/24",
    "10.0.107.0/24",
    "10.0.108.0/24",
  ]
}

variable "enable_blue_env" {
  description = "Enable blue environment"
  type        = bool
  default     = true
}

variable "blue_instance_count" {
  description = "Number of instances in blue environment"
  type        = number
  default     = 2
}

variable "enable_green_env" {
  description = "Enable green environment"
  type        = bool
  default     = true
}

variable "green_instance_count" {
  description = "Number of instances in green environment"
  type        = number
  default     = 2
}

variable "traffic_distribution" {
  description = "Levels of traffic distribution"
  type        = string
}

variable "instance_key" {
  default = "MyWindowsKeyPair"
}

variable "current_blue_version" {
  type        = string
  description = "The current version of the blue environment"
  default     = "version-1.2"
}

variable "current_green_version" {
  type        = string
  description = "The current version of the green environment"
  default     = "version-1.3"
}

variable "log_group_name" {
  description = "The name of the CloudWatch log group"
  type        = string
  default     = "myapp-log-group"
}

variable "retention_days" {
  description = "The number of days to retain the logs in the CloudWatch log group"
  type        = number
  default     = 7
}


locals {
  traffic_dist_map = {
    blue = {
      blue  = 100
      green = 0
    }
    blue-90 = {
      blue  = 90
      green = 10
    }
    split = {
      blue  = 50
      green = 50
    }
    green-90 = {
      blue  = 10
      green = 90
    }
    green = {
      blue  = 0
      green = 100
    }
  }
}



# variable "db_username" {
#   type        = string
#   description = "SQLServer database admin username"
#   sensitive   = true
# }

# variable "db_password" {
#   type        = string
#   description = "SQLServer database admin password"
#   sensitive   = true
# }