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


# resource "aws_instance" "webserver" {
# 	ami = "ami-0753e0e42b20e96e3"
# 	instance_type = "t2.micro"
# 	key_name = "mn-key-pair"
# 	subnet_id = "subnet-09ab9c2d03d3b659d"
# 	vpc_security_group_ids = [ aws_security_group.terraform-ssh-access.id ]
# }
# resource "aws_security_group" "terraform-ssh-access" {
# 	name = "terraform-ssh-access"
# 	description = "Allow SSH access from the Internet"
# 	vpc_id = "vpc-0b4f416c15959de1b"
# 	ingress {
# 	from_port = 22
# 	to_port = 22
# 	protocol = "tcp"
# 	cidr_blocks = ["0.0.0.0/0"]
#     }
# 	ingress {
# 	from_port = 80
#         to_port = 80
#         protocol = "tcp"
#         cidr_blocks = ["0.0.0.0/0"]
# 	}

# 	egress {
# 	from_port = 0
# 	to_port = 0
# 	protocol = "-1"
# 	cidr_blocks = ["0.0.0.0/0"]
# 	}	
# }
# output "public_ip_address" {
# 	value = aws_instance.webserver.public_ip
# }
