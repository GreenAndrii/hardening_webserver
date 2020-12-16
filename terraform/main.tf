provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_ami" "latest-rhel7" {
  most_recent = true
  # owners      = ["309956199498"] # Red Hat
  owners      = ["679593333241"] # Centos 7
  filter {
    name   = "name"
    # values = ["RHEL-7.9_HVM_GA-*-x86_64-*-GP2"]
    values = ["CentOS Linux 7 x86_64 HVM EBS ENA*"]

  }
}

module "ec2" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 2.0"

  name                   = "interview_task"
  instance_count         = var.instance_count
  ami                    = data.aws_ami.latest-rhel7.id
  instance_type          = "t2.micro"
  key_name               = var.key_name
  subnet_id              = tolist(data.aws_subnet_ids.all.ids)[0]
  vpc_security_group_ids = ["sg-094a93a7a7ea8e4b7"] # RHEL7-sg

  tags = {
    Terraform   = "true"
    Environment = "hardening_RHEL7"
  }
}

# generate Ansible inventory file
resource "local_file" "inventory" {
  content = templatefile("${path.module}/templates/inventory.tpl",
    {
      hw1_stack        = module.ec2.public_ip
      ssh_user         = var.ssh_user
      key_name         = var.key_name
      instances_number = length(module.ec2.public_ip)
    }
  )
  directory_permission = "0755"
  file_permission      = "0644"
  filename             = "../ansible/inventory.yaml"
}
