# output hosts.yaml for later consumption of Ansible automation scripts
data "template_file" "private_agent_ips" {
  template = "${file("templates/ansible_hosts_block.tpl")}"
  count = "${var.num_of_private_agents}"

  vars {
    ip = "${element(aws_instance.agent.*.public_ip, count.index)}"
  }
}


data "template_file" "master_ips" {
  template = "${file("templates/ansible_hosts_block.tpl")}"
  count = "${var.num_of_masters}"

  vars {
    ip = "${element(aws_instance.master.*.public_ip, count.index)}"
  }
}


data "template_file" "ansible_inventory" {
  template = "${file("templates/ansible_inventory_yaml.tpl")}"

  vars {
//    agent_private_ips="${jsonencode(aws_instance.agent.*.private_ip)}"
//    master_private_ips="${jsonencode(aws_instance.master.*.private_ip)}"

    lb_public_dns="${aws_elb.public-controller-elb.dns_name}"
    lb_private_dns="${aws_elb.private-controller-elb.dns_name}"

    bootstrap_node_public_ip = "${aws_instance.bootstrap_kubectl.public_ip}"

    private_agent_node_ip_block = "${join("\n", data.template_file.private_agent_ips.*.rendered)}"
    master_node_ip_block = "${join("\n", data.template_file.master_ips.*.rendered)}"
  }
}

/*output "ansible_inventory_info" {
  value = "${data.template_file.ansible_inventory.rendered}"
}*/

# also write that stuff to file
resource "local_file" "Ansible_hosts_file" {
  content = "${data.template_file.ansible_inventory.rendered}"
  filename = "../Ansible/hosts.yaml"
}