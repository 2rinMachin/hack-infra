provider "aws" {
  region = var.aws_region
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }

  owners = ["099720109477"]
}

resource "aws_security_group" "apache_airflow" {
  name        = "hack-aa-sg"
  description = "Security groups for the Apache Airflow VM"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 8080"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 8081"
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP 8005"
    from_port   = 8005
    to_port     = 8005
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "apache_airflow" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t2.large"
  key_name               = var.ec2_key_name
  vpc_security_group_ids = [aws_security_group.apache_airflow.id]

  root_block_device {
    volume_size           = 20
    volume_type           = "gp2"
    delete_on_termination = true
  }

  tags = {
    Name = "Apache Airflow VM"
  }
}

# locals {
#   airflow_image = "apache/airflow:2.10.1"
#   project       = "airflow"
#   name_prefix   = "airflow"
#
#   tags = {
#     Project = "airflow"
#   }
# }
#
# resource "aws_s3_bucket" "airflow" {
#   bucket        = "${local.name_prefix}-bucket-${random_id.rand.hex}"
#   force_destroy = true
#   tags          = local.tags
# }
#
# resource "random_id" "rand" {
#   byte_length = 4
# }
#
# resource "aws_ecs_cluster" "main" {
#   name = "${local.name_prefix}-cluster"
#   tags = local.tags
# }
#
# # ------------------------------
# # Security Groups
# # ------------------------------
#
# resource "aws_security_group" "alb" {
#   name   = "${local.name_prefix}-alb"
#   vpc_id = var.vpc_id
#
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   ingress {
#     from_port   = 443
#     to_port     = 443
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = local.tags
# }
#
# resource "aws_security_group" "ecs" {
#   name   = "${local.name_prefix}-ecs"
#   vpc_id = var.vpc_id
#
#   ingress {
#     from_port       = 8080
#     to_port         = 8080
#     protocol        = "tcp"
#     security_groups = [aws_security_group.alb.id]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = local.tags
# }
#
# resource "aws_security_group" "rds" {
#   name   = "${local.name_prefix}-rds"
#   vpc_id = var.vpc_id
#
#   ingress {
#     from_port       = 5432
#     to_port         = 5432
#     protocol        = "tcp"
#     security_groups = [aws_security_group.ecs.id]
#   }
#
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
#
#   tags = local.tags
# }
#
# # ------------------------------
# # RDS Postgres
# # ------------------------------
#
# resource "aws_db_subnet_group" "this" {
#   name       = "${local.name_prefix}-subnets"
#   subnet_ids = [var.subnet_public_a, var.subnet_public_b]
# }
#
# resource "aws_db_instance" "postgres" {
#   identifier             = "${local.name_prefix}-db"
#   engine                 = "postgres"
#   engine_version         = "15"
#   instance_class         = "db.t3.micro"
#   allocated_storage      = 20
#   username               = "airflow"
#   password               = var.airflow_admin_password
#   publicly_accessible    = true
#   db_subnet_group_name   = aws_db_subnet_group.this.name
#   vpc_security_group_ids = [aws_security_group.rds.id]
#   skip_final_snapshot    = true
# }
#
# # ------------------------------
# # ACM
# # ------------------------------
#
# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.domain
#   validation_method = "DNS"
# }
#
# # ------------------------------
# # ALB
# # ------------------------------
#
# resource "aws_lb" "airflow" {
#   name               = "${local.name_prefix}-alb"
#   internal           = false
#   load_balancer_type = "application"
#   security_groups    = [aws_security_group.alb.id]
#   subnets            = [var.subnet_public_a, var.subnet_public_b]
# }
#
# resource "aws_lb_target_group" "airflow" {
#   name        = "${local.name_prefix}-tg"
#   port        = 8080
#   protocol    = "HTTP"
#   target_type = "ip"
#   vpc_id      = var.vpc_id
#
#   health_check {
#     path = "/health"
#   }
# }
#
# resource "aws_lb_listener" "http" {
#   load_balancer_arn = aws_lb.airflow.arn
#   port              = "80"
#   protocol          = "HTTP"
#
#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.airflow.arn
#   }
# }
#
# # ------------------------------
# # Task Definitions
# # ------------------------------
#
# locals {
#   common_env = [
#     {
#       name  = "AIRFLOW__CORE__FERNET_KEY"
#       value = var.airflow_fernet_key
#     },
#     {
#       name  = "AIRFLOW__CORE__EXECUTOR"
#       value = "LocalExecutor"
#     },
#     {
#       name  = "AIRFLOW__DATABASE__SQL_ALCHEMY_CONN"
#       value = "postgresql+psycopg2://airflow:${var.airflow_admin_password}@${aws_db_instance.postgres.address}/airflow"
#     }
#   ]
# }
#
# # Scheduler
# resource "aws_ecs_task_definition" "scheduler" {
#   family                   = "${local.name_prefix}-scheduler"
#   cpu                      = "256"
#   memory                   = "512"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#
#   task_role_arn      = var.labrole_arn
#   execution_role_arn = var.labrole_arn
#
#   container_definitions = jsonencode([
#     {
#       name        = "scheduler"
#       image       = local.airflow_image
#       entryPoint  = ["airflow"]
#       command     = ["scheduler"]
#       essential   = true
#       environment = local.common_env
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-region        = var.aws_region
#           awslogs-group         = "/ecs/${local.name_prefix}-scheduler"
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#     }
#   ])
# }
#
# resource "aws_ecs_service" "scheduler" {
#   name            = "${local.name_prefix}-scheduler"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.scheduler.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#
#   network_configuration {
#     subnets         = [var.subnet_public_a, var.subnet_public_b]
#     security_groups = [aws_security_group.ecs.id]
#   }
# }
#
# # Webserver
# resource "aws_ecs_task_definition" "webserver" {
#   family                   = "${local.name_prefix}-webserver"
#   cpu                      = "512"
#   memory                   = "1024"
#   network_mode             = "awsvpc"
#   requires_compatibilities = ["FARGATE"]
#
#   task_role_arn      = var.labrole_arn
#   execution_role_arn = var.labrole_arn
#
#   container_definitions = jsonencode([
#     {
#       name       = "webserver"
#       image      = local.airflow_image
#       entryPoint = ["airflow"]
#       command    = ["webserver"]
#       essential  = true
#       portMappings = [
#         {
#           containerPort = 8080
#           protocol      = "tcp"
#         }
#       ]
#       environment = concat(local.common_env, [
#         {
#           name  = "AIRFLOW__WEBSERVER__RBAC"
#           value = "True"
#         },
#         {
#           name  = "AIRFLOW__WEBSERVER__SECRET_KEY"
#           value = var.airflow_fernet_key
#         }
#       ])
#       logConfiguration = {
#         logDriver = "awslogs"
#         options = {
#           awslogs-region        = var.aws_region
#           awslogs-group         = "/ecs/${local.name_prefix}-web"
#           awslogs-stream-prefix = "ecs"
#         }
#       }
#     }
#   ])
# }
#
# resource "aws_ecs_service" "webserver" {
#   name            = "${local.name_prefix}-webserver"
#   cluster         = aws_ecs_cluster.main.id
#   task_definition = aws_ecs_task_definition.webserver.arn
#   desired_count   = 1
#   launch_type     = "FARGATE"
#
#   network_configuration {
#     subnets         = [var.subnet_public_a, var.subnet_public_b]
#     security_groups = [aws_security_group.ecs.id]
#   }
#
#   load_balancer {
#     target_group_arn = aws_lb_target_group.airflow.arn
#     container_name   = "webserver"
#     container_port   = 8080
#   }
#
#   depends_on = [aws_lb_listener.http]
# }
