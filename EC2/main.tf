module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  azs  = ["ap-northeast-2a", "ap-northeast-2c"]
  cidr = "10.0.0.0/16"

  enable_nat_gateway = true
  single_nat_gateway = true

  public_subnets = ["10.0.0.0/24"]

  private_subnets = ["10.0.10.0/24"]

  database_subnets = ["10.0.20.0/24", "10.0.21.0/24"]              

  create_database_subnet_route_table     = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  map_public_ip_on_launch = true
}

resource "aws_instance" "ws" {
  subnet_id = module.vpc.public_subnets[0]

  ami = "ami-0ac9b8202b45eeb08"
  instance_type = "t3.medium"
  key_name = "ver3_key"

  user_data = file("./scripts/ws.sh")

  vpc_security_group_ids = [ aws_security_group.ws_sg.id ]

  tags = {
    Name = "ws"
  }
}

output "ws_ip" {
  value = aws_instance.ws.public_ip
}

resource "aws_instance" "was" {
  subnet_id = module.vpc.private_subnets[0]

  ami = "ami-0ac9b8202b45eeb08"
  instance_type = "t3.medium"
  key_name = "ver3_key"

  user_data = file("./scripts/was.sh")

  vpc_security_group_ids = [ aws_security_group.was_sg.id ]

  tags = {
    Name = "was"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  
  name = "db-subnet-group"

  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "db-subnet-group"
  }
}

resource "aws_db_instance" "my_db" {
  identifier = "my-db"

  storage_type = "gp3"
  allocated_storage = 100

  engine = "mariadb"
  engine_version = "10.11.6"
  instance_class = "db.t3.small"
  db_name = "apidb"
  username = "root"
  password = "rds!!#root123"

  skip_final_snapshot = true

  vpc_security_group_ids = [ aws_security_group.db_sg.id ]
  
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
}


resource "aws_security_group" "ws_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ws-sg"
  }
}

resource "aws_security_group" "was_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "was-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [ aws_security_group.was_sg.id, aws_security_group.ws_sg.id ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}