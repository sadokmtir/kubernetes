variable "node_vpc_id" {
  type = string
}

variable "node_subnet_id" {
  type = string
}

variable "node_instance_type" {
  type = string
}
variable "worker_node_count" {
  description = "The number of worker nodes in the cluster"
  type        = number
  default     = 1
}

variable "control_node_count" {
  description = "The number of worker nodes in the cluster"
  type        = number
  default     = 2
}

variable "use_spot_instances" {
  description = "Whether to use spot instances"
  type        = bool
  default     = true
}

variable "spot_price" {
  description = "The maximum price to pay for spot instances"
  type        = string
  default     = "0.04"
}

variable "my_ip_address" {
  description = "Your external IP address to allow SSH access to the instances"
  default     = "95.91.208.62"
}
