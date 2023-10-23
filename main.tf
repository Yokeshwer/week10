resource "aws_vpc" "week10test" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "ROR-HOSTING"
  }
}
resource "aws_security_group" "web" {
  name        = "web-ror-sg"
  description = "Week10_ror"
  vpc_id = aws_vpc.week10test.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_subnet" "public" {
  vpc_id                 = aws_vpc.week10test.id
  cidr_block             = "10.0.1.0/24"
  availability_zone      = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public"
  }
}
resource "aws_subnet" "private" {
  vpc_id                 = aws_vpc.week10test.id
  cidr_block             = "10.0.2.0/24"
  availability_zone      = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "private"
  }
}

resource "aws_internet_gateway" "weeklytest" {
  vpc_id = aws_vpc.week10test.id
  tags = {
    Name = "test-ror"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.week10test.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.weeklytest.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}
resource "aws_launch_configuration" "weeklytest" {
  name_prefix          = "test-lc"
  image_id             = "ami-0fc5d935ebf8bc3bc"
  instance_type        = "t2.micro"
  security_groups      = [aws_security_group.web.id]
   associate_public_ip_address = true
}

resource "aws_autoscaling_group" "ags-weeklytest" {
  name                 = "ror-asg"
  launch_configuration = aws_launch_configuration.weeklytest.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public.id]
}

resource "aws_lb" "rorweb" {
  name          = "ror-lb"
  internal      = false
  load_balancer_type = "application"
  security_groups  = [aws_security_group.web.id]
  subnets          = [aws_subnet.public.id,aws_subnet.private.id]
  enable_http2     = true
}

resource "aws_lb_target_group" "webror" {
  name = "webror-targetgroup"
  port = 80
  protocol = "HTTP"
  target_type = "instance"
  vpc_id  = aws_vpc.week10test.id

  health_check {
    enabled = true
    interval = 30
    protocol = "HTTP"
    path = "/"
    timeout = 5
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "web-ror" {
  load_balancer_arn = aws_lb.rorweb.arn
  port  = 80
  protocol  = "HTTP"
  default_action {
    type  = "fixed-response"
    fixed_response {
        content_type = "text/plain"
        status_code = "200"
        }
    }
}
resource "aws_lb_listener_rule" "ror_alb" {
 listener_arn = aws_lb_listener.web-ror.arn
 action {
        type = "forward"
        target_group_arn = aws_lb_target_group.webror.arn
        }

 condition {
 path_pattern {
        values = ["/"]
  }
 }
}

resource "aws_autoscaling_attachment" "ror_attachment" {
 lb_target_group_arn = aws_lb_target_group.webror.arn
 autoscaling_group_name = aws_autoscaling_group.ags-weeklytest.name
}
resource "aws_security_group" "web-rds-sg" {
  name        = "rds-ror-sg"
  description = "Week10_ror"
  vpc_id = aws_vpc.week10test.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
 name = "db-rds-group"
 subnet_ids = [aws_subnet.public.id,aws_subnet.private.id]
}

resource "aws_db_instance" "db_post" {
 allocated_storage       = 20
 storage_type            = "gp2"
 engine                  = "postgres"
 engine_version          = "15.3"
 instance_class          = "db.t3.micro"
 db_name                 = "yokesh_db"
 username                = "yokesh"
 password                = "yokesh123"
 parameter_group_name    = "default.postgres15"
 skip_final_snapshot     = true
 publicly_accessible     = false
 multi_az                = false
 backup_retention_period = 7
 apply_immediately       = true
 db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
 vpc_security_group_ids  = [aws_security_group.web-rds-sg.id]
 tags = {
        Name = "database-postgres"
 }
}

