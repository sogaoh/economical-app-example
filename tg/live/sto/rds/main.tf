module "rds" {
  source = "terraform-aws-modules/rds-aurora/aws"

  tags = {
    Managed_by = "Terragrunt"
  }

  name = local.db_identifier

  database_name = local.db_name

  engine         = "aurora-mysql"
  engine_version = "8.0.mysql_aurora.3.08.0"

  manage_master_user_password = false
  master_username             = local.db_username
  master_password             = random_password.password.result

  storage_encrypted = false //true
  #kms_key_id        = module.crypt_key.key_arn


  instance_class = "db.t4g.medium"
  instances = {
    1 = {
      identifier = "${local.db_identifier}-01"
    }
    # 2 = {
    #   identifier     = "${local.db_identifier}-02"
    # }
  }

  vpc_id = local.vpc_id //data.terraform_remote_state.net_vpc.outputs.vpc.id

  vpc_security_group_ids = [
    local.sg_id, //data.terraform_remote_state.net_sg.outputs.sg_storage.id,
  ]

  create_security_group = false

  # DB subnet group
  create_db_subnet_group = false
  db_subnet_group_name   = local.subnet_group_name //data.terraform_remote_state.net_vpc.outputs.subnet.db_subnet_group_name

  apply_immediately   = true
  skip_final_snapshot = true //false
  monitoring_interval = 30   //10 //second

  # Performance Insight
  performance_insights_enabled = false
  //performance_insights_retention_period = 7 //7 days or 731 (2 years)

  # Database Deletion Protection
  deletion_protection = false //true

  backup_retention_period = 1             //7 //days
  preferred_backup_window = "18:30-19:30" //:UTC <-> JST:3:30-4:30

  # Update CA Certificate 'rds-ca-2019' (2024-08-22 EOL) to 'rds-ca-rsa2048-g1'
  # refs https://docs.aws.amazon.com/ja_jp/AmazonRDS/latest/UserGuide/UsingWithRDS.SSL.html
  ca_cert_identifier = "rds-ca-rsa2048-g1"

  # Cluster Parameter Group
  create_db_cluster_parameter_group          = false
  db_cluster_parameter_group_name            = "default.aurora-mysql8.0"
  db_cluster_parameter_group_use_name_prefix = false
  db_cluster_parameter_group_family          = "aurora-mysql8.0"

  # Instance Parameter Group
  create_db_parameter_group          = false
  db_parameter_group_name            = "default.aurora-mysql8.0"
  db_parameter_group_use_name_prefix = false
  db_parameter_group_family          = "aurora-mysql8.0"

  # Log relates
  create_cloudwatch_log_group = true
  enabled_cloudwatch_logs_exports = [
    "error",
    "slowquery",
    #"audit"
  ]
  cloudwatch_log_group_retention_in_days = 1
}

# module "crypt_key" {
#   source = "terraform-aws-modules/kms/aws"
#
#   tags = {
#     Managed_by = "Terragrunt"
#     Env        = "stg"
#   }
#
#   deletion_window_in_days = 7
#
#   description         = "KMS key for DB storage encrypt/decrypt"
#   enable_key_rotation = true
#   key_usage           = "ENCRYPT_DECRYPT"
#
#   aliases = ["db-cryption-key"]
# }

resource "random_password" "password" {
  length           = 20
  special          = true
  override_special = "!#$%*()-_=+[]{}<>:?"
}
