resource "aws_eip" "magentoapp-network-lb-ip" {
  vpc = true
    
  tags = {
      Name: "${var.env_prefix}-eip"
  }
}