resource "aws_instance" "rubrik_cluster" {
  for_each = var.node_names
  instance_type = var.node_config.instance_type
  ami           = var.node_config.ami_id
  vpc_security_group_ids = var.node_config.sg_ids
  subnet_id = var.node_config.subnet_id
  key_name  = var.node_config.key_pair_name
  lifecycle {
    ignore_changes = [ami]
  }
  tags = merge({
    Name = each.value },
    var.node_config.tags
  )

  disable_api_termination = var.node_config.disable_api_termination
  iam_instance_profile    = var.node_config.iam_instance_profile
  root_block_device {
    encrypted = true
    tags = {Name = "${each.value}-sda"}
  }

}

resource "aws_ebs_volume" "ebs_block_device" {
  for_each = var.disks
  availability_zone = var.node_config.availability_zone
  type = each.value.type
  size = each.value.size
  tags = merge(
    {Name = each.key},
    var.node_config.tags
  )
  encrypted   = true
}

resource "aws_volume_attachment" "ebs_att" {
  for_each = var.disks
  device_name = each.value.device
  volume_id   = aws_ebs_volume.ebs_block_device[each.key].id
  instance_id = aws_instance.rubrik_cluster[each.value.instance].id
}

output "instances" {
  value = aws_instance.rubrik_cluster
}