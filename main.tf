# Required Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# =====  VPC
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name = "main-vpc"
  cidr = var.vpc_cidr

  azs             = data.aws_availability_zones.available.names
  private_subnets = slice(var.private_subnet_cidr_blocks, 0, var.private_subnet_count)
  public_subnets  = slice(var.public_subnet_cidr_blocks, 0, var.public_subnet_count)

  enable_nat_gateway = false
  enable_vpn_gateway = var.enable_vpn_gateway
}

# =====  Security Groups
resource "aws_security_group" "app_sg" {
  name        = "public-sg"
  description = "Allow web and ssh traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    description = "HTTPS"
    self        = true
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # egress {
  #   from_port   = 1433
  #   to_port     = 1433
  #   protocol    = "tcp"
  #   security_groups = [aws_security_group.sql_server_sg.id]
  # }
}

# =====  ALB
resource "random_pet" "app" {
  length    = 2
  separator = "-"
}

resource "aws_lb" "app" {
  name               = "main-app-${random_pet.app.id}-lb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets

  # security_groups    = [module.lb_security_group.this_security_group_id]
  security_groups    = [aws_security_group.app_sg.id]  
}

################################################################################
# =====  Orig Listener
################################################################################
resource "aws_lb_listener" "app" {
  load_balancer_arn = aws_lb.app.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
      forward {
        target_group {
          arn    = aws_lb_target_group.blue_tg.arn
          weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
        }

        target_group {
          arn    = aws_lb_target_group.green_tg.arn
          weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
        }

        stickiness {
          enabled  = false
          duration = 1
        }
      }
  }
}

################################################################################
# =====  New Listener
################################################################################

# =====  Create ACM Certificate with suggested domain name
# resource "aws_acm_certificate" "mycert_acm" {
#   domain_name       = "mcproj.com"  # aws_lb.app.dns_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# =====  Route53 Zone
# data "aws_route53_zone" "selected_zone" {
#   name         = aws_acm_certificate.mycert_acm.domain_name
#   private_zone = false
# }

# =====  Route53 Record for DNS validation    changed !!
# resource "aws_route53_record" "cert_validation_record" {
#   for_each = {
#     for dvo in aws_acm_certificate.mycert_acm.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.selected_zone.zone_id
# }

# =====  DNS valiadtion of Certificate
# resource "aws_acm_certificate_validation" "cert_validation" {
#   timeouts {
#     create = "25m"
#   }
#   certificate_arn         = aws_acm_certificate.mycert_acm.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation_record : record.fqdn]
# }

# =====  Create Route53 Record
# resource "aws_route53_record" "route53_A_record" {
#   zone_id = data.aws_route53_zone.selected_zone.zone_id
#   name    = "ec2.mcproj.com"
#   type    = "A"
#   alias {
#     name                   = aws_lb.app.dns_name
#     zone_id                = aws_lb.app.zone_id
#     evaluate_target_health = true
#   }
# }

# =====  HTTPS Listener for ALB
# resource "aws_lb_listener" "https_listener" {
#   load_balancer_arn = aws_lb.app.id
#   port              = 443
#   protocol          = "HTTPS"

#   certificate_arn   = aws_acm_certificate_validation.cert_validation.certificate_arn

#   # default_action {
#   #   type             = "forward"
#   #   target_group_arn = aws_lb_target_group.alb_target_group.id
#   # }
#   default_action {
#     type             = "forward"
#       forward {
#         target_group {
#           arn    = aws_lb_target_group.blue_tg.arn
#           weight = lookup(local.traffic_dist_map[var.traffic_distribution], "blue", 100)
#         }

#         target_group {
#           arn    = aws_lb_target_group.green_tg.arn
#           weight = lookup(local.traffic_dist_map[var.traffic_distribution], "green", 0)
#         }

#         stickiness {
#           enabled  = false
#           duration = 1
#         }
#       }
#   }
# }

# =====   HTTP to HTTPS Redirect Listener
# resource "aws_lb_listener" "http_redirect" {
#   load_balancer_arn = aws_lb.app.arn
#   port              = 80
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

#################################################################################################################
#################################################################################################################

# =====  Instances
data "aws_ami" "windows-2019" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["Windows_Server-2019-English-Full-Base*"]
  }
}

# ===== EC2 Instances WebServer Blue
resource "aws_instance" "blue" {
  count = var.enable_blue_env ? var.blue_instance_count : 0

  ami                         = data.aws_ami.windows-2019.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  
  # vpc_security_group_ids      = [module.app_security_group.this_security_group_id]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]

  associate_public_ip_address = true
  key_name                    = "MyWindowsKeyPair"

  user_data       = file("blue_userdata.tpl")

  tags = {
    Name = "blue-env-${var.current_blue_version}-${count.index}"
  }
}

# ALB target group
resource "aws_lb_target_group" "blue_tg" {
  name     = "blue-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

# Target Attachment 1
resource "aws_lb_target_group_attachment" "blue_tga" {
  count            = length(aws_instance.blue)
  
  target_group_arn = aws_lb_target_group.blue_tg.arn
  target_id        = aws_instance.blue[count.index].id
  port             = 80
}

# ===== EC2 Instances WebServer Green
resource "aws_instance" "green" {
  count = var.enable_green_env ? var.green_instance_count : 0

  ami                         = data.aws_ami.windows-2019.id
  instance_type               = "t2.micro"
  subnet_id                   = module.vpc.public_subnets[count.index % length(module.vpc.public_subnets)]
  
  # vpc_security_group_ids      = [module.app_security_group.this_security_group_id]
  vpc_security_group_ids      = [aws_security_group.app_sg.id]  
  
  associate_public_ip_address = true
  key_name                    = "MyWindowsKeyPair"

  user_data                   = file("green_userdata.tpl")

  tags = {
    Name = "green-env-${var.current_green_version}-${count.index}"
  }
}

# =====  LB Target Group Green
resource "aws_lb_target_group" "green_tg" {
  name     = "green-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.vpc.vpc_id

  health_check {
    port     = 80
    protocol = "HTTP"
    timeout  = 5
    interval = 10
  }
}

# =====  Target Attachment Green
resource "aws_lb_target_group_attachment" "green_tga" {
  count            = length(aws_instance.green)

  target_group_arn = aws_lb_target_group.green_tg.arn
  target_id        = aws_instance.green[count.index].id
  port             = 80
}

# =====  DB Subnet Group
resource "aws_db_subnet_group" "db_subnet" {
  name       = "db-subnet"
  subnet_ids =  module.vpc.private_subnets
}

# =====  DB Instance SQL Server
resource "aws_db_instance" "sql_server_instance" {
  allocated_storage      = 20
  max_allocated_storage  = 100
  engine                 = "sqlserver-se"
  engine_version         = "15.00"
  # instance_class         = "db.m5.large"  # Choose an appropriate instance class
  instance_class         = "db.t3.xlarge"
  identifier             = "mssql-server"

  username               = "admin"
  password               = "admin12345" # Consider using Secrets Manager for production

  db_subnet_group_name   = aws_db_subnet_group.db_subnet.id
  vpc_security_group_ids = [aws_security_group.sql_server_sg.id]

  parameter_group_name   = "default.sqlserver-se-15.0" # Adjust based on engine and version
  skip_final_snapshot    = true
  publicly_accessible    = false # Set to true if needed, but generally not recommended for production
  multi_az               = false # Set to true for high availability
  storage_type           = "gp2" # Or io1, gp3
  license_model          = "license-included" # Required for SQL Server
}

# =====  Security Group for SQL Server
resource "aws_security_group" "sql_server_sg" {
  name        = "sql-server-sg"
  description = "Allow inbound traffic to SQL Server"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 1433
    to_port     = 1433
    protocol    = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_cloudwatch_log_group" "log_group" {
  name              = var.log_group_name
  retention_in_days = var.retention_days
}

resource "aws_cloudwatch_log_stream" "log_stream" {
  name           = "myapp-log-stream"
  log_group_name = aws_cloudwatch_log_group.log_group.name
}