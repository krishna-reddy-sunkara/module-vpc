resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = local.igw_final_tags
}

resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr_block)  
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_cidr_block[count.index]
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true # Makes it a public subnet

  tags = {
    Name = "public-subnet-1a"
  }
}