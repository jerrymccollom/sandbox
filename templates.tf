
data "template_file" "db_config" {

  count = "${length(var.list_of_sites) * var.nodes_per_site}"

  template = "${file("db.template.yml")}"

  vars {
    ip_addr = "${element(aws_instance.SITE.*.private_ip, count.index)}"
    node_num = "${(count.index % var.nodes_per_site)+1}"
    site_name = "${var.list_of_sites[count.index / var.nodes_per_site]}"
    vail_user_id = "${var.VAIL_USER_ID}"
    vail_user_name = "${var.VAIL_USER_NAME}"
    vail_user_arn = "${var.VAIL_USER_ARN}"
    vail_user_access_key = "${var.VAIL_USER_ACCESS_KEY}"
    vail_user_secret_key = "${var.VAIL_USER_SECRET_KEY}"
  }
}


data "template_file" "vail_config" {
  template = "${file("vail.template.yml")}"

  vars {
    node_name = "${var.list_of_sites[count.index / var.nodes_per_site]}:${(count.index % var.nodes_per_site)+1}"
  }
}


data "template_file" "vail_start" {
  template = "${file("start.sh")}"
  vars {
    migrate_start = "${count.index % var.nodes_per_site == 0}"  # Start the migrator on the first node in a site cluster
  }
}

data "template_file" "aws_config" {
  template = "${file("aws.config.template")}"
  vars {
    region = "${var.AWS_REGION}"
    role_arn = "${var.VAIL_AWS_ROLE_ARN}"
    external_id = "${var.VAIL_AWS_EXTERNAL_ID}"
  }
}

data "template_file" "aws_credentials" {
  template = "${file("aws.credentials.template")}"
  vars {
    access_key = "${var.VAIL_AWS_ACCESS_KEY}"
    secret_key = "${var.VAIL_AWS_SECRET_KEY}"
  }
}
