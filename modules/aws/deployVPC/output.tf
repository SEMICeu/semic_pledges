output "vpc-id" {
  value = aws_vpc.this.id
}

output "igw-id" {
  value = aws_internet_gateway.this.id
}

output "private-subnet-ids" {
  value = aws_subnet.private[*].id
}

output "public-subnet-ids" {
  value = aws_subnet.public[*].id
}

output "first-az-name" {
  value = data.aws_availability_zones.available.names[0]
}

output "private-route-table-ids" {
  value = aws_route_table.private[*].id
}