output "public_ip" {
      description = "The public IP address"
      value       = aws_instance.ec2_instance.public_ip
}

output "elastic_ip" {
      description = "The elastic IP address"
      value = aws_eip.ec2_eip.public_ip
}
