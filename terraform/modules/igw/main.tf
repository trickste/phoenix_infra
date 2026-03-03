resource "aws_internet_gateway" "nfi_igw" {
  count = var.create_igw ? 1 : 0
  vpc_id = var.vpc_id

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.env}_igw"
  }
}