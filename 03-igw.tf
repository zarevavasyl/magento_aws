resource "aws_internet_gateway" "magento-igw" {
    vpc_id = aws_vpc.magento-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}