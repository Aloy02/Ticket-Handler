data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [var.VPC_NAME]
  }
}

data "aws_subnet" "sub1" {
  filter {
    name   = "tag:Name"
    values = [var.SUBNET_1_NAME]
  }
}

data "aws_subnet" "sub2" {
  filter {
    name   = "tag:Name"
    values = [var.SUBNET_2_NAME]
  }
}

resource "aws_iam_role" "exec_role" {
  name = "${var.PREFIX}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "exec_policy" {
  role       = aws_iam_role.exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_security_group" "sg" {
  name   = "${var.PREFIX}-ecs-sg"
  vpc_id = data.aws_vpc.main.id

  ingress {
    from_port   = 5000
    to_port     = 5000
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

data "aws_ecs_cluster" "main" {
  cluster_name = "${var.CLUSTER}"
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.PREFIX}-ticket-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.exec_role.arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.report_generator_repo.repository_url}:latest"
      essential = true
      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
      }]
      environment = [
        { name = "DB_HOST", value = split(":", aws_db_instance.default.endpoint)[0] },
        { name = "DB_NAME", value = var.DB_NAME },
        { name = "DB_USER", value = var.DB_USERNAME },
        { name = "DB_PASSWORD", value = var.DB_PASSWORD },
        { name = "S3_TICKET_BUCKET", value = var.S3_TICKET_BUCKET }
      ]
    }
  ])
}

resource "aws_ecs_service" "app" {
  name            = "${var.PREFIX}-service"
  cluster         = data.aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [data.aws_subnet.sub1.id, data.aws_subnet.sub2.id]
    security_groups  = [aws_security_group.sg.id]
    assign_public_ip = true
  }
}