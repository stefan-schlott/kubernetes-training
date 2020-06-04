output "cluster_prefix" {
  value = "${data.template_file.cluster-name.rendered}"
}

output "bootstrap_public_ips" {
  value = "${aws_instance.bootstrap_kubectl.public_ip}"
}

output "bootstrap_private_ips" {
  value = "${aws_instance.bootstrap_kubectl.private_ip}"
}

output "master_public_ips" {
  value = ["${aws_instance.master.*.public_ip}"]
}

output "master_private_ips" {
  value = "${aws_instance.master.*.private_ip}"
}

output "lb_external_masters" {
  value = "${aws_elb.public-controller-elb.dns_name}"
}

output "lb_internal_masters" {
  value = "${aws_elb.private-controller-elb.dns_name}"
}

output "agent_public_ips" {
  value = ["${aws_instance.agent.*.public_ip}"]
}

output "dns_search" {
  value = "${var.aws_region}.compute.internal"
}



output "ip_detect" {
  value = "aws"
}
