provider "aws" {
  region = "eu-north-1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  description = "CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "Type of instance to use"
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "AMI ID for the instances"
  type        = string
  default     = "ami-07c8c1b18ca66bb07"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "web-dev-keyPair"
}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "my_vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "eu-north-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public_subnet"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = var.private_subnet_cidr
  availability_zone = "eu-north-1a"

  tags = {
    Name = "private_subnet"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my_igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "frontend_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
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
    Name = "frontend_sg"
  }
}

resource "aws_security_group" "backend_sg" {
  vpc_id = aws_vpc.my_vpc.id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.my_vpc.cidr_block]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "backend_sg"
  }
}

resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  tags = {
    Name = "frontend"
  }

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  provisioner "file" {
    source      = "../frontend.sh"
    destination = "/tmp/frontend.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu" 
      private_key = file("/var/lib/jenkins/web-dev-keyPair.pem")
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/frontend.sh",
      "sudo /tmp/frontend.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/var/lib/jenkins/web-dev-keyPair.pem")
      host        = self.public_ip
    }
  }
}

resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.private.id
  key_name      = var.key_name
  tags = {
    Name = "backend"
  }

  vpc_security_group_ids = [aws_security_group.backend_sg.id]

 provisioner "file" {
  source      = "../backend.sh"
  destination = "/tmp/backend.sh"

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/var/lib/jenkins/web-dev-keyPair.pem")
    host        = aws_instance.bastion.public_ip
    bastion_host = aws_instance.bastion.public_ip
  }
}

provisioner "remote-exec" {
  inline = [
    "chmod +x /tmp/backend.sh",
    "sudo /tmp/backend.sh"
  ]

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("/var/lib/jenkins/web-dev-keyPair.pem")
    host        = aws_instance.backend.private_ip
    bastion_host = aws_instance.bastion.public_ip
  }
}
}

resource "aws_instance" "bastion" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.public.id
  key_name      = var.key_name
  tags = {
    Name = "bastion"
  }

  vpc_security_group_ids = [aws_security_group.frontend_sg.id]

  provisioner "remote-exec" {
    inline = [
      "echo 'Bastion host is up'"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/var/lib/jenkins/web-dev-keyPair.pem")
      host        = self.public_ip
    }
  }
}


output "frontend_public_ip" {
  value = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  value = aws_instance.backend.private_ip
}
