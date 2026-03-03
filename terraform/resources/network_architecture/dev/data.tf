data "aws_internet_gateway" "vpc_igw" {
  count = var.vpc_id != null ? 1 : 0
  filter {
    name   = "attachment.vpc-id"
    values = [var.vpc_id]
  }
}