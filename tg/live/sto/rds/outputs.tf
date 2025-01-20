output "rds" {
  value = {
    writer_endpoint = module.rds.cluster_endpoint
    reader_endpoint = module.rds.cluster_reader_endpoint
    cluster_id      = module.rds.cluster_id
  }
}

# output "rds_parameter_group_ids" {
#   value = {
#     cluster  = module.rds.db_cluster_parameter_group_id
#     instance = module.rds.db_parameter_group_id
#   }
# }

output "rds_password" {
  value     = random_password.password.result
  sensitive = true
}
