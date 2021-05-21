output "rubrik_cloud_cluster_ip_addrs" {
    value = aws_instance.rubrik_cluster.*.private_ip
}