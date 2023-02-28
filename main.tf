resource "aws_s3_bucket" "mn-test-bucket" {
	bucket = "mn-bucket-27022023"
}
resource "aws_s3_bucket" "mn-test-bucket-2" {
	bucket = "mn-bucket-27022023ok-final"
}

resource "aws_vpc" "rnd-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "rnd-vpc"
  }
}

resource "aws_subnet" "rnd-public-subnet" {
  vpc_id     = aws_vpc.rnd-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "rnd-private-subnet" {
  vpc_id     = aws_vpc.rnd-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-southeast-1a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.rnd-vpc.id

  tags = {
    Name = "rnd-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.rnd-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "default-route-for-public-subnet"
  }
}

resource "aws_route_table_association" "public-subnet-to-igw" {
  subnet_id     = aws_subnet.rnd-public-subnet.id
  route_table_id = aws_route_table.public.id
}


data "aws_ami" "ubuntu20" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


resource "aws_instance" "rnd-vm-1" {
	ami           = data.aws_ami.ubuntu20.id
	instance_type = "t2.micro"
	key_name = "mn-new-key"
	subnet_id = aws_subnet.rnd-public-subnet.id
	vpc_security_group_ids = [ aws_security_group.terraform-ssh-access.id ]

	tags = {
      Name = "rnd-vm-1"
    }
	depends_on = [
	  aws_security_group.terraform-ssh-access
	]

	user_data = <<EOF
#!/bin/bash
apt-get update
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
echo “This is a test page" > /var/www/html/index.html
EOF
}

resource "aws_security_group" "terraform-ssh-access" {
	name = "terraform-ssh-access"
	description = "Allow SSH access from the Internet"
	vpc_id = aws_vpc.rnd-vpc.id

	ingress {
	from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}
	
	ingress {
	from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
	}

	egress {
	from_port = 0
	to_port = 0
	protocol = "-1"
	cidr_blocks = ["0.0.0.0/0"]
	}
	depends_on = [
	  aws_vpc.rnd-vpc
	]
}
output "public_ip_address" {
	value = aws_instance.rnd-vm-1.public_ip
}
