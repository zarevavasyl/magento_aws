resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.magento-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.magento-igw.id
    }
    
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_route_table_association" "a-rtb-subnet" {
    subnet_id = aws_subnet.magento-subnet-1.id
    route_table_id = aws_default_route_table.main-rtb.id
}