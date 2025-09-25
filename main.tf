provider "aws" {
  region = "ap-south-1"
}

# 🔑 Key Pair (use your own public key path)
resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

# 🌐 VPC
resource "aws_vpc" "terraform_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "terraform-vpc"
  }
}

# 🛜 Subnet
resource "aws_subnet" "terraform_subnet" {
  vpc_id                  = aws_vpc.terraform_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "terraform-subnet"
  }
}

# 🌍 Internet Gateway
resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id
}

# 📜 Route Table
resource "aws_route_table" "terraform_rt" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
}

# 🔗 Associate Subnet with Route Table
resource "aws_route_table_association" "terraform_rta" {
  subnet_id      = aws_subnet.terraform_subnet.id
  route_table_id = aws_route_table.terraform_rt.id
}

# 🔒 Security Group inside custom VPC
resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow HTTP and SSH"
  vpc_id      = aws_vpc.terraform_vpc.id   # ✅ ensures same VPC

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
}

# 💻 EC2 Instance with Docker + Nginx
resource "aws_instance" "docker_ec2" {
  ami                         = "ami-01b6d88af12965bb6" # Amazon Linux 2 in ap-south-1
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.terraform_key.key_name
  subnet_id                   = aws_subnet.terraform_subnet.id
  vpc_security_group_ids      = [aws_security_group.allow_http.id]
  associate_public_ip_address = true   # ✅ ensures public IP

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install docker -y
              sudo systemctl start docker
              sudo systemctl enable docker
              sudo usermod -aG docker ec2-user
              sudo docker run -d -p 80:80 --name nginx nginx:latest
              EOF

  tags = {
    Name = "Terraform-Docker-EC2"
  }
}

# 📤 Output Public IP
output "ec2_public_ip" {
  value = aws_instance.docker_ec2.public_ip
}
