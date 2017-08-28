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
}


resource "null_resource" "SITE" {

  count = "${length(var.list_of_sites) * var.nodes_per_site}"

  triggers {
      node_ip_address = "${element(aws_instance.SITE.*.private_ip, count.index)}"
  }

  connection {
    user = "ubuntu"
    private_key = "${file(var.private_key_path)}"
    host = "${element(aws_instance.SITE.*.public_ip, count.index)}"
  }



  # Setup directories, mount point, and mount the EFS
  provisioner "remote-exec" {
    inline = [
      "mkdir ~/.vail",
      "mkdir ~/.aws",
      "sudo mkdir /tmp/vail",
      "sudo chmod 755 /tmp/vail",
      "until ping -c3  ${element(aws_efs_mount_target.vail.*.dns_name, count.index / var.nodes_per_site)} &>/dev/null; do echo -n .; sleep 1; done",
      "until sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2  ${element(aws_efs_mount_target.vail.*.dns_name, count.index / var.nodes_per_site)}:/ /tmp/vail; do echo -n .; sleep 1; done",
      "sudo su -c \"echo  ${element(aws_efs_mount_target.vail.*.dns_name, count.index / var.nodes_per_site)}:/ /tmp/vail nfs defaults,vers=4.1 0 0 >> /etc/fstab\""
    ]
  }

  # Install vail executable
  provisioner "file" {
    source      = "no-commit/vail.gz"
    destination = "~/vail.gz"
  }
  provisioner "remote-exec" {
    inline = [
      "gunzip vail.gz"
    ]
  }

  # install vail config files
  provisioner "file" {
    content = "${element(data.template_file.vail_config.*.rendered, count.index)}"
    destination = "~/.vail/vail.yml"
  }

  provisioner "file" {
    content = "${element(data.template_file.db_config.*.rendered, count.index)}"
    destination = "~/.vail/db.yml"
  }

  # install aws config files
  provisioner "file" {
    content = "${data.template_file.aws_config.rendered}"
    destination = "~/.aws/config"
  }

  provisioner "file" {
    content = "${data.template_file.aws_credentials.rendered}"
    destination = "~/.aws/credentials"
  }

  # Install control scripts
  provisioner "file" {
    content = "${data.template_file.vail_start.rendered}"
    destination = "~/start.sh"
  }

  provisioner "file" {
    source      = "stop.sh"
    destination = "~/stop.sh"
  }

  # Launch vail
  provisioner "remote-exec" {
    inline = [
      "chmod +x ~/vail ~/*.sh",
      "~/vail db load ~/.vail/db.yml",
      "nohup ~/start.sh"
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

output "load_balancers" {
  value = "${list(aws_elb.web.*.dns_name)}"
}
