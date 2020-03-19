provider "aws" {
  region = "us-east-1"
  access_key = "AKIAQ2AEEA2GMYJ5GXO2"
  secret_key = "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"
}
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

tags = {
    Name = "dev-acs-test"
  }
}
resource "aws_subnet" "priya" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"

   tags = {
      name="subnet"
  }
}
resource "aws_internet_gateway" "Internet" {
vpc_id ="${aws_vpc.main.id}"
tags = {
      Name="Internet"
}
}
resource "aws_route_table" "RT" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "10.0.1.1/24"
    gateway_id = "${aws_internet_gateway.Internet.id}"
}   
}
 resource "aws_route_table_association" "ART" {
  subnet_id      = "aws_subnet.priya.id"
  route_table_id = "aws_route_table.RT.id"
}
resource "aws_security_group" "allow_tls" {
  name        = "sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = "${aws_vpc.main.id}"

  tags = {
    Name = "allow_tls"
  }
}
 resource "aws_instance" "Sai" {
  instance_type = "t2.micro"
  ami = "ami-0fc61db8544a617ed"
  subnet_id              = "${aws_subnet.priya.id}"
  

  tags = {
    Name = "saipriya"
  }
}
