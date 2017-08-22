resource "aws_key_pair" "deployer" {
      key_name = "insecure-deployer"
      public_key = "${file(var.public_key_path)}"
}


resource "aws_instance" "SITE" {
  count = "${length(var.list_of_sites) * var.nodes_per_site}"

  ami = "${var.AMI}"
  instance_type = "t2.micro"
  key_name = "${aws_key_pair.deployer.key_name}"
  
  tags {
    Name = "${var.list_of_sites[count.index / var.nodes_per_site]}:${(count.index % var.nodes_per_site)+1}"
  }

  connection {
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
  }
 
  # Our Security group to allow HTTP and SSH access
  vpc_security_group_ids = ["${element(aws_security_group.default.*.id, count.index / var.nodes_per_site)}"]

  # We're going to launch into the same subnet as our ELB. In a production
  # environment it's more common to have a separate private subnet for
  # backend instances.
  subnet_id = "${element(aws_subnet.default.*.id, count.index / var.nodes_per_site)}"

  provisioner "file" {
    source      = "no-commit/vail.gz"
    destination = "~/vail.gz"
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "~/setup.sh"
  }

  provisioner "file" {
    source      = "start.sh"
    destination = "~/start.sh"
  }

  provisioner "file" {
    source      = "stop.sh"
    destination = "~/stop.sh"
  }

  provisioner "file" {
     source = "vail.template.yml"
     destination = "~/vail.template.yml"
  }

  provisioner "file" {
     source = "db.template.yml"
     destination = "~/db.template.yml"
  }

  provisioner "remote-exec" {
      inline = [
        "sudo mkdir /tmp/vail",
        "echo ${element(aws_efs_file_system.efs.*.id, count.index / var.nodes_per_site)}",
        "chmod +x ~/setup.sh",
        "~/setup.sh ${var.list_of_sites[count.index / var.nodes_per_site]} ${(count.index % var.nodes_per_site)+1} ${var.VAIL_AWS_ACCESS_KEY} ${var.VAIL_AWS_SECRET_KEY} ${var.VAIL_AWS_ROLE_ARN} ${var.VAIL_AWS_EXTERNAL_ID} ${self.private_ip} ${count.index / var.nodes_per_site} ${element(aws_efs_mount_target.vail.*.dns_name, count.index / var.nodes_per_site)}"
    ]
  }
}


resource "aws_efs_mount_target" "vail" {
  count = "${length(var.list_of_sites)}"
  file_system_id = "${element(aws_efs_file_system.efs.*.id, count.index)}"
  security_groups = ["${element(aws_security_group.default.*.id, count.index)}"]
  subnet_id = "${element(aws_subnet.default.*.id, count.index)}"
}

resource "aws_efs_file_system" "efs" {
    count = "${length(var.list_of_sites)}"
    creation_token = "spectra-site-${count.index}-efs"
    tags {
        Name = "spectra-site-${count.index}-efs"
        Terraform = "true"
        Site = "${var.list_of_sites[count.index]}"
    }
}

