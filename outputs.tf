# output "blue_ec2_public_ip" {
#   value = aws_instance.blue.public_ip
# }

# output "green_ec2_public_ip" {
#   value = aws_instance.green.public_ip
# }

# output "db_instance_address" {
#   value = aws_db_instance.sql_server_instance.address
# }

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.app.dns_name
}

output "db_endpoint" {
  value = aws_db_instance.sql_server_instance.endpoint
}