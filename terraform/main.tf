provider "aws" {
  profile         = var.access_key
  region          = var.region
}

# Create EC2
resource "aws_instance" "vpn" {
  #ami             = "ami-0e169fa5b2b2f88ae"   # ubuntu-18.04 Europe (London)
  ami             = "ami-06a550af32c7dda36"   # ubuntu-18.04 South American (São Paulo)
  instance_type   = "t2.micro"
  count           = 1
  security_groups = [aws_security_group.sg.id]
  subnet_id       = aws_subnet.subnet[count.index].id
  key_name        = aws_key_pair.keypair.key_name
  
  tags = {
    "name" = "vpn ec2"
  }
}

# internet gateway
resource "aws_internet_gateway" "gw" {
  vpc_id          = aws_vpc.vpc.id

  tags = {
    "name" = "vpn internet gateway"
  }
}

# route table
resource "aws_route" "internet_access" {
    route_table_id         = aws_vpc.vpc.main_route_table_id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.gw.id
}

# security group
resource "aws_security_group" "sg" {
  name      = "sg"
  vpc_id    = aws_vpc.vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.ingressCIDRblock
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = var.egressCIDRblock
  }

  tags = {
      Name = "vpn security group"
  }
}

# Create VPC
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpcCIDRblock
  enable_dns_hostnames = var.dnsHostNames
  instance_tenancy     = "default"
  
  tags = {
    "name" = "vpn vpc"
  }
}

# data
data "aws_availability_zones" "az" {}

# key pair
resource "aws_key_pair" "keypair" {
  key_name   = "keypair"
  public_key = file("~/.ssh/id_rsa.pub")

  tags = {
    "name" = "vpn keypair"
  }
}

# Create Subnet VPC
resource "aws_subnet" "subnet" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.az.names[count.index]
  map_public_ip_on_launch = true
  
  tags = {
    "name" = "subnet cluster vpn"
  }
}

# output
output "instance_ip_addr" {
  value = aws_instance.vpn.*.private_ip
  description = "The private IP address."
}

output "instance_ips" {
  value = aws_instance.vpn.*.public_ip
  description = "The public IP address."
}