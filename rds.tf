resource "aws_db_subnet_group" "rds" {
  name       = "tp-ha-rds-subnet-group"
  subnet_ids = aws_subnet.private[*].id
}

resource "aws_db_instance" "mysql" {
  allocated_storage      = 20
  engine                 = "mysql"
  engine_version         = "8.0"
  instance_class         = "db.t3.micro"
  db_name                = "tphadb"
  username               = "admin"
  password               = var.db_password
  parameter_group_name   = "default.mysql8.0"
  skip_final_snapshot    = true
  multi_az               = true
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
}
