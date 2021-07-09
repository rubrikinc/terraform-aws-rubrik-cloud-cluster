output "rubrik_cloud_cluster_ip_addrs" {
  value = aws_instance.rubrik_cluster.*.private_ip
}

output "rubrik_protected_hosts_security_group_id" {
  value = aws_security_group.rubrik_hosts.id
}