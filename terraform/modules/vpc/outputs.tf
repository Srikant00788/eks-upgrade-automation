output "vpc_id" {

  value = aws_vpc.this.id

}
output "public_subnets" {

  value = {
    for name, subnet in aws_subnet.public :
    name => subnet.id
  }

}
output "private_subnets" {

  value = {
    for name, subnet in aws_subnet.private :
    name => subnet.id
  }

}

