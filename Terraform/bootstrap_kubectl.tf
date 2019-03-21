# Deploy the bootstrap instance
resource "aws_instance" "bootstrap_kubectl" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    # The default username for our AMI
    user = "${var.ssh_user}"
    private_key = "${local.private_key}"
    agent = "${local.agent}"

    # The connection will use the local SSH agent for authentication.
  }

  root_block_device {
    volume_size = "${var.aws_bootstrap_instance_disk_size}"
  }

  instance_type = "${var.aws_bootstrap_instance_type}"

  tags {
   owner = "sschlott"
   Name = "${data.template_file.cluster-name.rendered}-bootstrap-kubectl-node"
   cluster = "${data.template_file.cluster-name.rendered}"
  }

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${var.aws_ami}"

  # The name of our SSH keypair we created above.
  key_name = "${var.ssh_key_name}"

  # Our Security group to allow http, SSH, and outbound internet access only for pulling containers from the web
  vpc_security_group_ids = ["${aws_security_group.https.id}", "${aws_security_group.webconsole.id}","${aws_security_group.any_access_internal.id}", "${aws_security_group.ssh.id}", "${aws_security_group.internet-outbound.id}","${aws_security_group.icmp.id}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${aws_subnet.private.id}"

  lifecycle {
    ignore_changes = ["tags.Name"]
  }
}

output "Bootstrap Host Public IP" {
  value = "${aws_instance.bootstrap_kubectl.public_ip}"
}
