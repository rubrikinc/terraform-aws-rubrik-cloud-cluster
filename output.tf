output "rubrik_cloud_cluster_ip_addrs" {
  value = local.cluster_node_ips
}

output "rubrik_hosts_sg_id" {
  value = module.rubrik_hosts_sg.security_group_id
}

output "s3_bucket" {
  value = module.s3_bucket.s3_bucket_id
}