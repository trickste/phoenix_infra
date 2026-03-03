resource "aws_subnet" "nfi_protected_subnet" {
  count = var.create_protected_subnets ? length(var.protected_subnets_cidrs)  : 0

  vpc_id                  = var.vpc_id
  cidr_block              = var.protected_subnets_cidrs[count.index]
  availability_zone       = var.azs[count.index]
  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.env}_protected_subnet_${count.index}"
  }
}