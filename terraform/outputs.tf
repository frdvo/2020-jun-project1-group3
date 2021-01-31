# All the outputs go here
output "networking_module" {
  value = module.networking
}

output "efs_module" {
  value = module.efs
}

output "rds_aurora_module" {
  value = module.rds_aurora
}

output "ecr_module" {
  value = module.ecr
}

output "ecs_module" {
  value = module.ecs
}

output "domain_name" {
  value = var.domain_name
}
