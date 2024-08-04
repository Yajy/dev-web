resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.public_subnet_cidr
  availability_zone = "eu-north-1a" 

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.private_subnet_cidr
  availability_zone = "eu-north-1a"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_instance" "frontend" {
  ami           = "ami-07c8c1b18ca66bb07"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public.id
  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "backend" {
  ami           = "ami-07c8c1b18ca66bb07" 
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private.id
  tags = {
    Name = "backend"
  }
}

resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

