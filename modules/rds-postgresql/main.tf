
resource "aws_db_instance" "instance_name" {
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.12"
  instance_class         = "db.t3.micro"
  identifier             = "zeus-db-instance"
  username               = "foo"
  password               = var.secret_string
  db_name                = "webappdb"
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  parameter_group_name   = "default.postgres12"
  skip_final_snapshot    = true
  
  vpc_security_group_ids = [
    var.security_group_id_dbtier
  ]
  tags = var.tags
}



resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "${var.project_name}-db-subnet-group"
  subnet_ids = var.subnet_id_private
}

// Using the postgres client installed by running: sudo apt-get install -y postgresql-client
// psql -h zeus-db-instance.cpo2sm6moz1z.us-east-2.rds.amazonaws.com -p 5432 -U foo postgres

