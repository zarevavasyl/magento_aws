output "envoy_eip" {
  description = "Elastic ip address. In the hosts file, add it to the domain you specified."
  value       = aws_eip.magentoapp-network-lb-ip.public_ip
}