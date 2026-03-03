resource "aws_subnet" "nfi_public_subnet" {
  count = var.create_public_subnets ? length(var.public_subnets_cidrs)  : 0

  vpc_id                  = var.vpc_id
  cidr_block              = var.public_subnets_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  map_public_ip_on_launch = var.public_subnet_map_public_ip_on_launch

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.env}_public_subnet_${count.index}"
  }
}