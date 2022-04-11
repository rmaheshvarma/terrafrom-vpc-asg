resource "aws_security_group" "mydb1" {
  name = "mydb1"

  description = "RDS postgres servers (terraform-managed)"
  vpc_id = aws_vpc.default.id

  # Only postgres in
  ingress {
    from_port = 5432
    to_port = 5432
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic.
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}



resource "aws_subnet" "rds" {
  count = length(var.rds_private_subnet_cidr_blocks)

  vpc_id            = aws_vpc.default.id
  cidr_block        = var.rds_private_subnet_cidr_blocks[count.index]
  availability_zone = var.availability_zones[count.index]
}


resource "aws_db_subnet_group" "db-subnet" {
name = "post-db-subnet-group"
subnet_ids = aws_subnet.rds.*.id

}



resource "aws_db_instance" "mydb1" {
  allocated_storage        = 256 # gigabytes
  backup_retention_period  = 7   # in days
  db_subnet_group_name     = "${aws_db_subnet_group.db-subnet.name}"
  engine                   = "postgres"
  engine_version           = "9.6.22"
  identifier               = "mydb1"
  instance_class           = "db.t2.micro"
  multi_az                 = false
  name                     = "mydb1"
  password                 = "Password"
  port                     = 5432
  publicly_accessible      = false
  storage_encrypted        = false # you should always do this
  storage_type             = "gp2"
  username                 = "mydb1"
  vpc_security_group_ids   = ["${aws_security_group.mydb1.id}"]
}
