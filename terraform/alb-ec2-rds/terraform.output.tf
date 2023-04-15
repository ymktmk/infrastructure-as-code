output "lb_dns_name" {
  description = "The DNS name of the load balancer."
  value       = aws_lb.alb.dns_name
}

output "public_ip" {
  description = "The public IP address"
  value       = aws_instance.ec2_instance.public_ip
}

output "rds_endpoint" {
  description = "The RDS endpoint."
  value       = aws_db_instance.db_instance.endpoint
}
