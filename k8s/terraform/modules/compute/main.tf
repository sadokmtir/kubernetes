data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  spot_price                      = var.use_spot_instances ? var.spot_price : null
  control_node_security_group_ids = [aws_security_group.ssh_access.id, aws_security_group.control_node.id, aws_security_group.calico_networking.id, aws_security_group.node_exporter.id]
  worker_node_security_group_ids  = [aws_security_group.ssh_access.id, aws_security_group.worker_node.id, aws_security_group.calico_networking.id, aws_security_group.node_exporter.id]
}

module "keypair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.2"
  key_name           = "kubernetes-iac-key"
  create_private_key = true
}

# control nodes
module "control_nodes" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "5.7.1"
  count                       = var.control_node_count
  name                        = "control-node-${count.index}"
  instance_type               = var.node_instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = module.keypair.key_pair_name
  vpc_security_group_ids      = local.control_node_security_group_ids
  subnet_id                   = var.node_subnet_id
  associate_public_ip_address = true
  create_iam_instance_profile = true

  // Instances provisioned by Spot are the same as
  // regular instances with a caveat that they get shut down if the
  // instance type's regular price exceeds your spot price.
  # Spot instance configuration 
  create_spot_instance      = var.use_spot_instances
  spot_price                = var.use_spot_instances ? var.spot_price : null
  spot_type                 = var.use_spot_instances ? "persistent" : null
  spot_wait_for_fulfillment = var.use_spot_instances ? true : null
}

# worker nodes
module "worker_nodes" {
  source                      = "terraform-aws-modules/ec2-instance/aws"
  version                     = "5.7.1"
  count                       = var.worker_node_count
  name                        = "worker-node-${count.index}"
  instance_type               = var.node_instance_type
  ami                         = data.aws_ami.ubuntu.id
  key_name                    = module.keypair.key_pair_name
  vpc_security_group_ids      = local.worker_node_security_group_ids
  subnet_id                   = var.node_subnet_id
  associate_public_ip_address = true
  create_iam_instance_profile = true
  # Spot instance configuration 
  create_spot_instance      = var.use_spot_instances
  spot_price                = var.use_spot_instances ? var.spot_price : null
  spot_type                 = var.use_spot_instances ? "persistent" : null
  spot_wait_for_fulfillment = var.use_spot_instances ? true : null

}

resource "local_file" "rsa_private_key" {
  content         = "${module.keypair.private_key_openssh}\n"
  filename        = "${path.module}/../../../ansible/inventories/dev/.ssh/id_rsa"
  file_permission = "0500"
}

locals {
  control_node_inventory = [
    for instance in module.control_nodes : {
      ansible_host = instance.public_ip
      ip           = instance.private_ip
  }]
  worker_node_inventory = [
    for instance in module.worker_nodes : {
      ansible_host = instance.public_ip
      ip           = instance.private_ip
  }]
}

resource "local_file" "inventory_file" {
  content = templatefile("${path.module}/templates/inventory.tpl", {
    control_plane_nodes = coalesce(local.control_node_inventory, [])
    worker_nodes        = coalesce(local.worker_node_inventory, [])
  })
  filename        = "${path.module}/../../../ansible/inventories/dev/inventory"
  file_permission = "0644"

  depends_on = [
    module.control_nodes,
    module.worker_nodes
  ]
}
output "control_nodes_debug" {
  value = module.control_nodes
}

output "worker_nodes_debug" {
  value = module.worker_nodes
}

