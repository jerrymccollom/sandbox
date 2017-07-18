resource "aws_instance" "site-1" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  provisioner "local-exec" {
     command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
  }
}

resource "aws_instance" "site-2" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "t2.micro"
  provisioner "local-exec" {
     command = "echo ${aws_instance.example.private_ip} >> private_ips.txt"
  }
}

output "ip" {
    value = "${aws_instance.site-1.public_ip}"
    value = "${aws_instance.site-2.public_ip}"
}
