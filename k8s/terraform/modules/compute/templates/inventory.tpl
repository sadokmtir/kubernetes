[kube_control_plane]
%{ for index, node in control_plane_nodes ~}
node${index + 1} ansible_host=${node.ansible_host} ip=${node.ip} etcd_member_name=etcd${index +1}
%{ endfor ~}

[kube_control_plane:vars]
supplementary_addresses_in_ssl_keys = [${join(", ", [for node in control_plane_nodes : "\"${node.ansible_host}\""])}]

[etcd:children]
kube_control_plane

[kube_node]
%{ for index, node in worker_nodes ~}
worker${index + 1} ansible_host=${node.ansible_host} ip=${node.ip}
%{ endfor ~}
