# ------------------------------------------------------------------------------
# Data Sources
# ------------------------------------------------------------------------------

data "aws_vpc" "c26-vpc" {
  filter {
    name   = "tag:Name"
    values = [var.VPC_NAME]
  }
}

data "aws_subnet" "subnet_1" {
  filter {
    name   = "tag:Name"
    values = [var.SUBNET_1_NAME]
  }
}

data "aws_subnet" "subnet_2" {
  filter {
    name   = "tag:Name"
    values = [var.SUBNET_2_NAME]
  }
}

# ------------------------------------------------------------------------------
# Security Group
# ------------------------------------------------------------------------------

resource "aws_security_group" "rds" {
  name        = "${var.PREFIX}-rds-sg"
  description = "Allow inbound PostgreSQL database traffic"
  vpc_id      = data.aws_vpc.c26-vpc.id

  ingress {
    description = "PostgreSQL access from specific IP"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["82.32.184.43/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.PREFIX}-rds-sg"
  }
}

# ------------------------------------------------------------------------------
# DB Subnet Group & RDS Instance
# ------------------------------------------------------------------------------

resource "aws_db_subnet_group" "default" {
  name       = "${var.PREFIX}-rds-subnet-group"
  subnet_ids = [data.aws_subnet.subnet_1.id, data.aws_subnet.subnet_2.id]

  tags = {
    Name = "${var.PREFIX}-rds-subnet-group"
  }
}

resource "aws_db_instance" "default" {
  identifier            = "${var.PREFIX}-db-instance"
  engine                = "postgres"
  instance_class        = "db.t4g.micro"
  allocated_storage     = 20
  max_allocated_storage = 100

  db_name  = var.DB_NAME
  username = var.DB_USERNAME
  password = var.DB_PASSWORD

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible = true
  skip_final_snapshot = true
}