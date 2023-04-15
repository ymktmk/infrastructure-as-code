output "ec2_1_public_ip" {
  description = "The EC2 Instance 1 Public IP"
  value       = aws_instance.ec2_instance_1.public_ip
}

output "ec2_1_private_ip" {
  description = "The EC2 Instance 1 Public IP"
  value       = aws_instance.ec2_instance_1.private_ip
}

output "ec2_2_private_ip" {
  description = "The EC2 Instance 2 Public IP"
  value       = aws_instance.ec2_instance_2.private_ip
}

output "nat_gateway_public_ip" {
  value = aws_eip.nat_gateway_eip.public_ip
}

output "nat_gateway_private_ip" {
  value = aws_eip.nat_gateway_eip.private_ip
}
