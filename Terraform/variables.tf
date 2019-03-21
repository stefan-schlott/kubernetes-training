variable "ssh_key_name" {
  description = "ssh key name associated with your instances for login"
  default = "default"
}

variable "ssh_private_key_filename" {
 # cannot leave this empty as the file() interpolation will fail later on for the private_key local variable
 # https://github.com/hashicorp/terraform/issues/15605
 default = "/dev/null"
 description = "Path to file containing your ssh private key"
}

variable "ssh_user" {
  description = "Username of the OS. Overwrites the existing ssh user managed by tested oses module"
  default = "ubuntu"
}

variable "aws_ami" {
  description = "Overwrites the existing ami managed by tested oses module. Requires that the AMI already meets the prerequisites."
  # Ubuntu 16.04LTS, HVM:EBS, US-WEST-2 (as of 20190124) - m4 instance types
  #default = "ami-70e90210"
  # Ubuntu 16.04LTS (as of 20190313) - m5 instance types
  default = "ami-0f2016003e1759f35"
}

variable "aws_region" {
  description = "AWS region to launch servers."
  default     = "us-west-2"
}

variable "aws_profile" {
  description = "AWS profile to use"
  default     = ""
}

variable "admin_cidr" {
  description = "Inbound Master Access"
  default     = "0.0.0.0/0"
}

variable "aws_master_instance_type" {
  description = "AWS DC/OS master instance type"
  default = "m3.xlarge"
}

variable "aws_master_instance_disk_size" {
  description = "AWS DC/OS Master instance type default size of the root disk (GB)"
  default = "60"
}

variable "aws_agent_instance_type" {
  description = "AWS DC/OS Private Agent instance type"
  default = "m3.xlarge"
}

variable "aws_agent_instance_disk_size" {
  description = "AWS DC/OS Private Agent instance type default size of the root disk (GB)"
  default = "60"
}

variable "aws_bootstrap_instance_type" {
  description = "AWS DC/OS Bootstrap instance type"
  default = "m3.large"
}

variable "aws_bootstrap_instance_disk_size" {
  description = "AWS DC/OS bootstrap instance type default size of the root disk (GB)"
  default = "60"
}

variable "num_of_private_agents" {
  description = "DC/OS Private Agents Count"
  default = 2
}

variable "num_of_public_agents" {
  description = "DC/OS Public Agents Count"
  default = 1
}

variable "num_of_masters" {
  description = "DC/OS Master Nodes Count (Odd only)"
  default = 3
}

variable "owner" {
  description = "Paired with Cloud Cluster Cleaner will notify on expiration via slack. Default is whoami. Can be overwritten by setting the value here"
  default = "sschlott"
}

variable "expiration" {
  description = "Paired with Cloud Cluster Cleaner will notify on expiration via slack"
  default = "1h"
}

variable "ssh_port" {
 default = "22"
 description = "This parameter specifies the port to SSH to"
}
