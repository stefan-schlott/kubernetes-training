# Specify the provider and access details
provider "aws" {
  profile = "${var.aws_profile}"
  region = "${var.aws_region}"
}

locals {
  # cannot leave this empty as the file() interpolation will fail later on for the private_key local variable
  # https://github.com/hashicorp/terraform/issues/15605
  private_key = "${file(var.ssh_private_key_filename)}"
  agent = "${var.ssh_private_key_filename == "/dev/null" ? true : false}"
}


# Addressable Cluster UUID
data "template_file" "cluster_uuid" {
 template = "tf$${uuid}"

 vars {
    uuid = "${substr(md5(aws_vpc.default.id),0,4)}"
  }
}

# Allow overrides of the owner variable or default to whoami.sh
data "template_file" "cluster-name" {
 template = "$${username}-tf$${uuid}"

  vars {
    uuid = "${substr(md5(aws_vpc.default.id),0,4)}"
    username = "${format("%.10s", var.owner)}"
  }
}

output "ssh_user" {
   value = "${var.ssh_user}"
}
