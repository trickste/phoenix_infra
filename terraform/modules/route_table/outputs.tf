output "route_table_ids" {   
  value = [for rt in aws_route_table.nfi_route_table : rt.id]
}