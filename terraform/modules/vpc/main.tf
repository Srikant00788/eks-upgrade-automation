resource "aws_vpc" "this" {

  cidr_block           = var.vpc_cidr

  enable_dns_hostnames = true

  enable_dns_support   = true

  tags = merge(
  var.common_tags,
  {
    Name = "${var.project_name}-${var.environment}-vpc"
  }
)

}
resource "aws_internet_gateway" "this" {

  vpc_id = aws_vpc.this.id

  tags = merge(
  var.common_tags,
  {
    Name = "${var.project_name}-${var.environment}-igw"
  }
)
}
resource "aws_subnet" "public" {

  for_each = var.public_subnets

  vpc_id = aws_vpc.this.id

  cidr_block = each.value.cidr

  availability_zone = each.value.az

  map_public_ip_on_launch = true

  tags = merge(
    var.common_tags,
    {
      Name = each.key

      "kubernetes.io/role/elb" = "1"
    }
  )

}
resource "aws_subnet" "private" {

  for_each = var.private_subnets

  vpc_id = aws_vpc.this.id

  cidr_block = each.value.cidr

  availability_zone = each.value.az

  tags = merge(
    var.common_tags,
    {
      Name = each.key

      "kubernetes.io/role/internal-elb" = "1"
    }
  )

}
resource "aws_eip" "nat" {

  domain = "vpc"

  depends_on = [
    aws_internet_gateway.this
  ]

}
resource "aws_nat_gateway" "this" {

  allocation_id = aws_eip.nat.id

  subnet_id = aws_subnet.public["public-1"].id
  tags = merge(
  var.common_tags,
  {

    Name = "${var.project_name}-nat"

  }
)
}
resource "aws_route_table" "public" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    gateway_id = aws_internet_gateway.this.id

  }

}
resource "aws_route_table" "private" {

  vpc_id = aws_vpc.this.id

  route {

    cidr_block = "0.0.0.0/0"

    nat_gateway_id = aws_nat_gateway.this.id

  }

}
resource "aws_route_table_association" "public" {

  for_each = aws_subnet.public

  subnet_id = each.value.id

  route_table_id = aws_route_table.public.id

}
resource "aws_route_table_association" "private" {

  for_each = aws_subnet.private

  subnet_id = each.value.id

  route_table_id = aws_route_table.private.id

}

