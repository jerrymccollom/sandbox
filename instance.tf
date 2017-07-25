resource "aws_key_pair" "deployer" {
      key_name = "insecure-deployer"
      public_key = "${file(var.public_key_path)}"
}


variable "list_of_sites" {
  type = "list"
  default = [ "SITE-1", "SITE-2", "SITE-3" ]
#  default = [ "SITE-1"]
}

variable "nodes_per_site" {
#  default = "1"
  default = "3"
}

resource "aws_instance" "SITE" {
  count = "${length(var.list_of_sites) * var.nodes_per_site}"

  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
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
    source      = "no-commit/vail"
    destination = "~/vail"
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "~/setup.sh"
  }

  provisioner "file" {
     source = "vail.template.yml"
     destination = "vail.template.yml"
  }

  provisioner "file" {
     source = "db.template.yml"
     destination = "db.template.yml"
  }

  provisioner "remote-exec" {
      inline = [
        "chmod +x ~/setup.sh",
        "~/setup.sh ${var.list_of_sites[count.index / var.nodes_per_site]} ${(count.index % var.nodes_per_site)+1} ${var.VAIL_AWS_ACCESS_KEY} ${var.VAIL_AWS_SECRET_KEY} ${var.VAIL_AWS_ROLE_ARN} ${var.VAIL_AWS_EXTERNAL_ID} ",
    ]
  }
}


