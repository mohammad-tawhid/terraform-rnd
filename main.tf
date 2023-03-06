

resource "aws_vpc" "rnd-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "rnd-vpc"
  }
}

resource "aws_subnet" "rnd-public-subnet" {
  vpc_id     = aws_vpc.rnd-vpc.id
  cidr_block = "10.0.1.0/24"
  #availability_zone = "ap-southeast-1a"
  map_public_ip_on_launch = "true"

  tags = {
    Name = "public-subnet"
  }
}


resource "aws_subnet" "rnd-private-subnet" {
  vpc_id     = aws_vpc.rnd-vpc.id
  cidr_block = "10.0.2.0/24"
  #availability_zone = "ap-southeast-1a"

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


# data "aws_ami" "ubuntu20" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"] # Canonical
# }

# data "aws_ami" "amazon-2" {
#   most_recent = true

#   filter {
#     name = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-ebs"]
#   }
#   owners = ["amazon"]
# }

resource "aws_iam_role" "ssm-role-for-ect-login" {
  name = "ec2_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "RoleForEC2"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_key_pair" "rnd-key" {
  key_name   = "rnd-key"
  public_key = "c2gtcnNhIEFBQUFCM056YUMxeWMyRUFBQUFEQVFBQkFBQUJBUURCY0kvVTRvN0I2WmFmb3lQMTRVYlBSdGpMNWJleHpEbXhTYUhucFU2YUF4dmhIazZxYXpDaGxYWk9UaEgvS1gzalJtSHBqYVFHc0xRME8rUnBtUlQyYW5wZjBBTUhpeVRvRE1zNDBzd0h0T0RHeTRCREdxNm95bUVnWnNWUDdxUFhqWWhZYURURlZLWUlGWDRXU3dQNUlpL0JybWxtUHlzREdPZ3d0U3lDV2NBQnBzUk5Vc0YrMTZkYTBzMGhyZDNxbHFDREpibThxNG0wYi8vR2JrVVhCZkl6OUpVSW1QVm5uQ1Z3ZW5jSFVwVHhpelBpWDFDdFlYSkw0bytUTkwyanNpNEY5eExHdE8rRFJBNDltcU8rWllOUTg0cVdHVEJmL0h0UFhHcnV2UDJ3bEt2K1pIQjFHQTdPNEF4ZVdQUlZFdjY1eWpqeUN3ajQrWlBJRk9SaiByb290QGlwLTE3Mi0zMS02Mi05LmVjMi5pbnRlcm5hbA=="
}
resource "aws_iam_role_policy_attachment" "iam_role_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.ssm-role-for-ect-login.name
}

resource "aws_iam_instance_profile" "ssm-profile-for-ec2" {
  name = "ssm-profile-for-ec2"
  role = aws_iam_role.ssm-role-for-ect-login.name
}

resource "aws_instance" "rnd-vm-1" {
	ami           = "ami-006dcf34c09e50022"
	instance_type = "t2.micro"
	key_name = aws_key_pair.rnd-key.key_name
	subnet_id = aws_subnet.rnd-public-subnet.id
	vpc_security_group_ids = [ aws_security_group.terraform-ssh-access.id ]
  iam_instance_profile = aws_iam_instance_profile.ssm-profile-for-ec2.name

	tags = {
      Name = "rnd-vm-1"
    }
	depends_on = [
	  aws_security_group.terraform-ssh-access,
	  aws_key_pair.rnd-key
	]

    user_data = <<EOF
#!/bin/bash
apt-get install apache2 -y
systemctl start apache2
systemctl enable apache2
echo “This is a test page okk" > /var/www/html/index.html
echo "<h1>Deployed via Terraform</h1>" | sudo tee /var/www/html/index.html
EOF
 
	# user_data = <<EOF
	# 	#!/bin/bash
	# 	yum update -y
	# 	yum install -y httpd.x86_64
	# 	systemctl start httpd.service
	# 	systemctl enable httpd.service
	# 	echo "Hello World from $(hostname -f)" > /var/www/html/index.html
	# EOF
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
	depends_on = [
	  aws_instance.rnd-vm-1
	]
}
