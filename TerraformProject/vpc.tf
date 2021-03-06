# Creates the VPC
resource "aws_vpc" "webserver_vpc" {
  cidr_block       = "10.0.0.0/16"
  tags = {
    Name = "WebServer"
  }
}


# Creates the subnet
resource "aws_subnet" "subnet_webserver" {
  vpc_id                  = aws_vpc.webserver_vpc.id 
  cidr_block              = "10.0.0.0/24"
  availability_zone       = "eu-central-1c"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebServer"
  }
}

# Creates a subnet for the ASG
resource "aws_subnet" "subnet_webserver_asg" {
  vpc_id                  = aws_vpc.webserver_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-central-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "WebServer_ASG"
  }
}



# Sets a gateway
resource "aws_internet_gateway" "gw" {
  vpc_id        = aws_vpc.webserver_vpc.id
}


# Sets a routing table pointing to the gateway
resource "aws_route_table" "webserver_route_table" {
  vpc_id        = aws_vpc.webserver_vpc.id

  route {
     cidr_block = "0.0.0.0/0"
     gateway_id = aws_internet_gateway.gw.id
}

  tags = {
     Name = "WebServer"
  }
}


# Associates the subnets with the route table
resource "aws_route_table_association" "webserver_route_table_association" {
   subnet_id      = aws_subnet.subnet_webserver.id
   route_table_id = aws_route_table.webserver_route_table.id
}

resource "aws_route_table_association" "webserver_asg_route_table_association" {
   subnet_id      = aws_subnet.subnet_webserver_asg.id
   route_table_id = aws_route_table.webserver_route_table.id
}


# Creates a Security Group
resource "aws_security_group" "webserver_allow_http_sg" {
   name        = "allow_http"
   description = "Allows HTTP traffic"
   vpc_id      = aws_vpc.webserver_vpc.id


# Allows https inbound traffic
ingress {
     description = "HTTPS"
     from_port   = 443
     to_port     = 443
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

}

# Allows http inbound traffic
ingress {
     description = "HTTP"
     from_port   = 80
     to_port     = 80
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

}

# Allows SSH
ingress {
     description = "SSH"
     from_port   = 22
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}

# Allows Prometheus traffic 

ingress { 
     description  = "Prometheus"
     from_port   = 9090
     to_port     = 9090
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}

# Allows all egress traffic
egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}

tags = {
  Name = "allow_SSH_HTTP"
  }
}

