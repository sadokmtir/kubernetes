resource "aws_security_group" "control_node" {
  name        = "kubernetes-master-sg"
  description = "Security group for Kubernetes control plane"
  vpc_id      = var.node_vpc_id

  # Kubernetes API Server (Used by all)
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24", "${var.my_ip_address}/32"]
  }

  # etcd server, kube-api-server
  ingress {
    from_port   = 2379
    to_port     = 2380
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"]
  }

  # Kubelet API (Used by Control Plane, Self)
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"]
  }

  # Kube-scheduler
  ingress {
    from_port   = 10259
    to_port     = 10259
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"] #used by self
  }

  # Kube-controller-manager
  ingress {
    from_port   = 10257
    to_port     = 10257
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"] #used by self
  }

  tags = {
    Name = "kubernetes-master"
  }
}

# Worker Nodes Security Group
resource "aws_security_group" "worker_node" {
  name        = "kubernetes-worker-sg"
  description = "Security group for Kubernetes worker nodes"
  vpc_id      = var.node_vpc_id

  # Allow Kubelet API communication from the master
  ingress {
    from_port   = 10250
    to_port     = 10250
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"]
  }

  # Allow NodePort Services (External access to services)
  ingress {
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allows external access
  }

  tags = {
    Name = "kubernetes-worker"
  }
}

resource "aws_security_group" "calico_networking" {
  name        = "calico-networking-sg"
  description = "Allow Calico networking across all Kubernetes nodes"
  vpc_id      = var.node_vpc_id

  # Allow Calico BGP (TCP 179)
  ingress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"]
  }
  egress {
    from_port   = 179
    to_port     = 179
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"]
  }

  # Allow Calico IP-in-IP encapsulation (Protocol 4)
  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "4"
    cidr_blocks = ["10.240.100.0/24"]
  }
  egress {
    from_port   = -1
    to_port     = -1
    protocol    = "4"
    cidr_blocks = ["10.240.100.0/24"]
  }

  # Allow Calico VXLAN 
  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.240.100.0/24"]
  }
  egress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "udp"
    cidr_blocks = ["10.240.100.0/24"]
  }

  tags = {
    Name = "calico-networking"
  }
}

resource "aws_security_group" "node_exporter" {
  name        = "node_exporter_sg"
  description = "Prometheus exporter for node metrics"
  vpc_id      = var.node_vpc_id

  ingress {
    from_port   = 9100
    to_port     = 9100
    protocol    = "tcp"
    cidr_blocks = ["10.240.100.0/24"]
  }
}

# module "sg" {
#   source  = "terraform-aws-modules/security-group/aws//modules/ssh"
#   version = "5.3.0"
#   name    = "kubernetes-iac-sg"
#   vpc_id  = var.node_vpc_id

#   ingress_cidr_blocks = ["${var.my_ip_address}/32"]
# }

resource "aws_security_group" "ssh_access" {
  name        = "allow-ssh-access"
  description = "Allow SSH access to EC2 instances"
  vpc_id      = var.node_vpc_id

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip_address}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic #TODO: Change this to specific ports later
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh-access"
  }
}


