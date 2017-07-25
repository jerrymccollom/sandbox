variable "AWS_ACCESS_KEY" {}
variable "AWS_SECRET_KEY" {}
variable "AWS_REGION" {
  default = "us-west-2"
}
variable "AMIS" {
  type = "map"
  default = {
    us-east-1 = "ami-13be557e"
    us-west-2 = "ami-835b4efa"
    eu-west-1 = "ami-844e0bf7"
  }
}

variable "public_key_path" {
  default = "no-commit/insecure-deployer.pub"
}

variable "private_key_path" {
  default = "no-commit/insecure-deployer"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "~/.ssh/mykey"
}
variable "PATH_TO_PUBLIC_KEY" {
  default = "~/.ssh/mykey.pub"
}
variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "vail_binary" {
    default = "no-commit/vail"
}


variable VAIL_AWS_ACCESS_KEY {}

variable VAIL_AWS_SECRET_KEY {}

variable VAIL_AWS_REGION {
  default = "us-west-2"
}

variable VAIL_AWS_ROLE_ARN {
  default = "arn:aws:iam::055216130054:role/SpectraAssumeDynamoDbRole-103368623127-sdk"
}

variable VAIL_AWS_EXTERNAL_ID {
  default = "spectra-I0M37FTW"
}
