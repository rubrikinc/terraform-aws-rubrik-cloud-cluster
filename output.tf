output "rubrik_cloud_cluster_ip_addrs" {
  value = local.cluster_node_ips
}

output "rubrik_protected_hosts_security_group_id" {
  value = aws_security_group.rubrik_hosts.id
}