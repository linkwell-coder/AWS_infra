
provider "aws"{
   region  = "us-east-2"
   access_key = 
   secret_key = 
}

  resource "aws_vpc" "main" {
  cidr_block       = "192.168.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "main"
  }
}

resource "aws_internet_gateway" "InternetGateway" {
  vpc_id = "${aws_vpc.main.id}"

   tags = {
    Name ="InternetGateway"
  }
}

  resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "192.168.1.0/24"
  availability_zone = "us-east-2c"

  tags = {
    Name = "Subnet1"
  }
}

resource "aws_route_table" "RouteTable"{
   vpc_id = "${aws_vpc.main.id}"

   route{
       cidr_block = "0.0.0.0/0"
       gateway_id = "${aws_internet_gateway.InternetGateway.id}"
       }
 
}

resource "aws_route_table_association" "RTassociate" {
  subnet_id = "${aws_subnet.subnet1.id}"
  route_table_id = "${aws_route_table.RouteTable.id}"
}
 # security group to access instances over ssh and HTTP

resource "aws_security_group" "sg_allow" {
  name        = "instance_sg"
  description = "Allow mentioned port in the terraform"
  vpc_id      = "${aws_vpc.main.id}"

#SSH access from anywhere

  ingress{
    from_port  =22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

# outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Our elb security group to access
# the ELB over HTTP
resource "aws_security_group" "sg_elb" {
  name        = "elb_sg"
  description = "Used in the terraform"

  vpc_id = "${aws_vpc.main.id}"

  # HTTP access from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ensure the VPC has an Internet gateway or this step will fail
  depends_on = ["aws_internet_gateway.InternetGateway"]
}


resource "aws_elb" "web" {
  name = "example-elb"

  # The same availability zone as our instance
  subnets = ["${aws_subnet.subnet1.id}"]

  security_groups = ["${aws_security_group.sg_elb.id}"]

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 30
  }

 # The instance is registered automatically

  instances                   = ["${aws_instance.web.id}"]
  cross_zone_load_balancing   = true
  idle_timeout                = 400
  connection_draining         = true
  connection_draining_timeout = 400
}
resource "aws_lb_cookie_stickiness_policy" "default" {
  name                     = "lbpolicy"
  load_balancer            = "${aws_elb.web.id}"
  lb_port                  = 80
  cookie_expiration_period = 600
}

resource "aws_instance" "web" {
  instance_type = "t2.micro"
  ami = "ami-0998bf58313ab53da"
  vpc_security_group_ids = ["${aws_security_group.sg_elb.id}"]
  subnet_id              = "${aws_subnet.subnet1.id}"

  #Instance tags

  tags = {
    Name = "elb-example-shanti"
  }
}
