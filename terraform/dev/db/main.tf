resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "rds_ip_whitelist" {
  name        = "rds_ip_whitelist"
  description = "TCP inbound traffic whitelist"
  vpc_id      = aws_default_vpc.default.id

  ingress {
    description = "TCP from VPC"
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [
      aws_default_vpc.default.cidr_block,
      "162.196.182.124/32",
      "47.44.240.109/32",
      "71.95.183.58/32"
    ]
  }

  tags = {
    Name = "rds_tcp_whitelist"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "postgres"
  engine_version       = "11.5"
  instance_class       = "db.t2.micro"
  name                 = var.DB_NAME
  username             = var.DB_USERNAME
  password             = var.DB_PASSWORD
  parameter_group_name = "default.postgres11"

  publicly_accessible = true
  vpc_security_group_ids = [
    aws_security_group.rds_ip_whitelist.id,
    aws_default_security_group.default.id
  ]

  skip_final_snapshot = true
  performance_insights_enabled = true
  max_allocated_storage = 16384
  copy_tags_to_snapshot = true
  enabled_cloudwatch_logs_exports = [
    "postgresql",
    "upgrade"
  ]
  deletion_protection = true
}
