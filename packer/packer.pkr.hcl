source "amazon-ebs" "nfi_web_server_ami" {
  region        = var.region
  instance_type = var.instance_type
  source_ami_filter {
    filters = {
      name                = var.nfi_web_server_ami_filter.name
      root-device-type    = var.nfi_web_server_ami_filter.root-device-type
      virtualization-type = var.nfi_web_server_ami_filter.virtualization-type
    }
    owners      = var.nfi_web_server_owners
    most_recent = true
  }

  vpc_id     = var.vpc_id
  subnet_id  = var.subnet_id
  security_group_ids = [var.packer_sg_id]

  associate_public_ip_address = true

  ssh_username = var.ssh_username
  ami_name     = "${var.company_name}_${var.product}_${var.env}_{{timestamp}}"

  tags = {
    Name        = "${var.company_name}_${var.product}_${var.env}_web_server_ami"
  }
}



build {
  sources = ["source.amazon-ebs.nfi_web_server_ami"]

  provisioner "shell" {
    script = var.script_path
    environment_vars = [
      "GIT_REPO=${var.git_repo}"
    ]
  }
}

