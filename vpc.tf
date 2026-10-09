resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"
  enable_dns_hostnames = true

  tags = local.vpc_final_tags
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id  # vpc association

  tags = local.igw_final_tags
}

#public subnets
resource "aws_subnet" "public_subnet" {
  count = length(var.public_cidr_block)  
  vpc_id                  = aws_vpc.main.id  #"aws_vpc" "main"
  cidr_block              = var.public_cidr_block[count.index]
  availability_zone       = local.az_name[count.index]
  map_public_ip_on_launch = true # Makes it a public subnet

  tags = merge(
    local.common_tags,
    #roboshop-public-us-east-1a
    {
        Name = "${var.project}-${var.environment}-public-${local.az_name[count.index]}"
    },
    var.public_subnet_tags
  )
}

#privat subnets
resource "aws_subnet" "private_subnet" {
  count = length(var.public_cidr_block)  
  vpc_id                  = aws_vpc.main.id #"aws_vpc" "main"
  cidr_block              = var.private_cidr_block[count.index]
  availability_zone       = local.az_name[count.index]
  

  tags = merge(
    local.common_tags,
    #roboshop-databse-us-east-1a
    {
        Name = "${var.project}-${var.environment}-private-${local.az_name[count.index]}"
    },
    var.private_subnet_tags
  )
}

#database subnets
resource "aws_subnet" "database_subnet" {
  count = length(var.public_cidr_block)  
  vpc_id                  = aws_vpc.main.id #"aws_vpc" "main"
  cidr_block              = var.database_cidr_block[count.index]
  availability_zone       = local.az_name[count.index]
  

  tags = merge(
    local.common_tags,
    #roboshop-database-us-east-1a
    {
        Name = "${var.project}-${var.environment}-database-${local.az_name[count.index]}"
    },
    var.database_subnet_tags
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id #"aws_vpc" "main"
  tags =merge(
    local.common_tags,
    #roboshop-dev-public
    {
        Name = "${var.project}-${var.environment}-public"
    },
    var.public_route_table_tags
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id #"aws_vpc" "main"
  tags =merge(
    local.common_tags,
    #roboshop-dev-private
    {
        Name = "${var.project}-${var.environment}-private"
    },
    var.private_route_table_tags
  )
}

resource "aws_route_table" "database" {
  vpc_id = aws_vpc.main.id #"aws_vpc" "main"
  tags =merge(
    local.common_tags,
    #roboshop-dev-database
    {
        Name = "${var.project}-${var.environment}-database"
    },
    var.database_route_table_tags
  )
}

resource "aws_route" "public" {
  route_table_id            = aws_route_table.public.id  #"aws_route_table" "public"
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.main.id #"aws_internet_gateway" "main"
}

resource "aws_eip" "nat" {
  domain                    = "vpc"
  tags = merge(
    local.common_tags,
  
    {
        Name = "${var.project}-${var.environment}-nat"
    },
    var.eip_tags
  )
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id # "aws_eip" "nat"
  subnet_id     = aws_subnet.public_subnet[0].id  # "aws_subnet" "public_subnet" us-east-1a

  tags = merge(
    local.common_tags,
  
    {
        Name = "${var.project}-${var.environment}"
    },
    var.nat_gateway_tags
  )

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.main]  #nat gateway depends on igw "aws_internet_gateway" "main"
}

resource "aws_route" "private" {
  route_table_id            = aws_route_table.private.id  #"aws_route_table" "private"
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id  #"aws_nat_gateway" "main"
}

resource "aws_route" "database" {
  route_table_id            = aws_route_table.database.id  #aws_route_table" "database
  destination_cidr_block    = "0.0.0.0/0"
  nat_gateway_id = aws_nat_gateway.main.id #"aws_nat_gateway" "main"
}

resource "aws_route_table_association" "public" {
  count = length(var.public_cidr_block)  #["10.0.1.0/24", "10.0.2.0/24"]
  subnet_id      = aws_subnet.public_subnet[count.index].id  #"aws_subnet" "public_subnet"
  route_table_id = aws_route_table.public.id   #aws_route_table" "public"
}

resource "aws_route_table_association" "private" {
  count = length(var.private_cidr_block) ##["10.0.11.0/24", "10.0.12.0/24"]
  subnet_id      = aws_subnet.private_subnet[count.index].id #"aws_subnet" "private_subnet"
  route_table_id = aws_route_table.private.id   #aws_route_table" "private"
}

resource "aws_route_table_association" "database" {
  count = length(var.database_cidr_block) #["10.0.21.0/24", "10.0.22.0/24"]
  subnet_id      = aws_subnet.database_subnet[count.index].id #"aws_subnet" "database_subnet"
  route_table_id = aws_route_table.database.id   #aws_route_table" "database"
}









