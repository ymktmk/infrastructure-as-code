# expensive_moduleで利用するもの
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1a_id" {
  value = aws_subnet.public_subnet_1a.id
}

output "route53_zone_id" {
  value = aws_route53_zone.primary.zone_id
}
