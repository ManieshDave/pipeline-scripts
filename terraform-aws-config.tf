provider "aws" {
	region = "ap-south-1"
	access_key = "AKIAXSUQ7IRA5FDOKNM7"
	secret_key = "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"
}
resource "aws_vpc" "terra-vpc" {
	cidr_block = "10.10.0.0/16"
	tags = {
	Name = "my-vpc"
	}
}
resource "aws_subnet" "terra-subnet1" {
	vpc_id = "${aws_vpc.terra-vpc.id}"
	cidr_block = "10.10.0.0/24"
	availability_zone = "ap-south-1a"
	tags = {
	Name = "subnet-1"
	}
}
resource "aws_subnet" "terra-subnet2" {
        vpc_id = "${aws_vpc.terra-vpc.id}"
        cidr_block = "10.10.1.0/24"
        availability_zone = "ap-south-1b"
        tags = {
        Name = "subnet-2"
        }
}
resource "aws_internet_gateway" "terra-igw" {
	vpc_id = "${aws_vpc.terra-vpc.id}"
	tags = {
	Name = "my-igw"
	}
}
resource "aws_route_table" "terra-rt" {
	vpc_id = "${aws_vpc.terra-vpc.id}"
	route {
	cidr_block = "0.0.0.0/0"
	gateway_id = "${aws_internet_gateway.terra-igw.id}"
	}
}
resource "aws_route_table_association" "the-asctn1" {
	subnet_id = "${aws_subnet.terra-subnet1.id}"
	route_table_id = "${aws_route_table.terra-rt.id}"
}
resource "aws_route_table_association" "the-asctn2" {
        subnet_id = "${aws_subnet.terra-subnet2.id}"
        route_table_id = "${aws_route_table.terra-rt.id}"
}
resource "aws_instance" "terra-instance" {
	ami = "ami-01a4f99c4ac11b03c"
	instance_type = "t2.micro"
	key_name = "key"
	subnet_id = "${aws_subnet.terra-subnet1.id}"
	associate_public_ip_address = true
	vpc_security_group_ids = [aws_security_group.terra-sg.id]
	user_data = <<-EOF
		    #!/bin/bash
		    sudo su -
	            yum install httpd -y
		    echo "hello from Terraform" > /var/www/html/index.html
	            systemctl start httpd
		    systemctl enable httpd
                EOF
	tags = {
	Name = "my-instance"
	}
}
resource "aws_security_group" "terra-sg" {
	vpc_id = "${aws_vpc.terra-vpc.id}"
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
}

