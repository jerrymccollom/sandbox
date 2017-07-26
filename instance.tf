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
        "chmod +x ~/setup.sh",
        "~/setup.sh ${var.list_of_sites[count.index / var.nodes_per_site]} ${(count.index % var.nodes_per_site)+1} ${var.VAIL_AWS_ACCESS_KEY} ${var.VAIL_AWS_SECRET_KEY} ${var.VAIL_AWS_ROLE_ARN} ${var.VAIL_AWS_EXTERNAL_ID} ${self.private_ip}",
    ]
  }
}


