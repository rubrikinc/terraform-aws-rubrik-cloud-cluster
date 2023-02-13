output "rubrik_cloud_cluster_ip_addresses" {
  value = local.cluster_node_ips
}

output "rubrik_hosts_sg_id" {
  value = module.rubrik_hosts_sg.security_group_id
}

output "secrets_manager_private_key_name" {
  value = "${var.cluster_name}-private-key"
}

output "secrets_manager_get_ssh_key_command" {
  value = "aws secretsmanager get-secret-value --region ${var.aws_region} --secret-id ${var.cluster_name}-private-key --query SecretString --output text"
}