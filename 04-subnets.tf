resource "aws_subnet" "magento-subnet-1" {
    vpc_id = aws_vpc.magento-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = "${var.aws_region}a"
    tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}

resource "aws_subnet" "magento-subnet-2" {
    vpc_id = aws_vpc.magento-vpc.id
    cidr_block = var.subnet_cidr_block2
    availability_zone = "${var.aws_region}b"
    tags = {
        Name: "${var.env_prefix}-subnet-2"
    }
}