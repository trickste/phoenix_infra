resource "aws_route_table" "nfi_route_table" {
  count = var.create_route_table ? length(var.subnets_cidr_ids)  : 0

  vpc_id   = var.vpc_id

  dynamic "route" {
    for_each = var.subnet_type == "public" ? [1] : []
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = var.igw_id
    }
  }

  tags = {
    Name = "${var.company_name}_${var.cloud_name}_${var.env}_${var.subnet_type}_subnet_${var.azs[count.index]}"
  }
}

resource "aws_route_table_association" "public" {
  count = var.create_route_table ? length(var.subnets_cidr_ids)  : 0

  subnet_id      = var.subnets_cidr_ids[count.index]
  route_table_id = aws_route_table.nfi_route_table[count.index].id
}