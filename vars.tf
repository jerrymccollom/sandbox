#
# The sites you want to create by site ID
#
variable "list_of_sites" {
  type = "list"
#  default = [ "SITE-1", "SITE-2", "SITE-3", "SITE-4", "SITE-5" ]
 #  default = [ "SITE-1" ]
  #  default = [ "SITE-1", "SITE-2" ]
  default = [ "SITE-1", "SITE-2", "SITE-3" ]
}


#
# The number of nodes to create for each site.
#
variable "nodes_per_site" {
  default = "3"
#  default = "2"
}

#
# AWS permissions for deploying the EC2 instances.  Set these
# in terraform.tfvars
#
variable "AWS_ACCESS_KEY" {}

variable "AWS_SECRET_KEY" {}

variable "AWS_REGION" {
  description = "AWS region to launch servers."
  default = "us-west-2"
}


#
# The AMI to use as the base for the instance.
#
variable "AMI" {
  # Latest Ubuntu  in us-west-2
  # default = "ami-835b4efa"

  # This is base image with everything we need, created from above
  default = "ami-900ae6e8"
}

#
# The keys which will allow SSH access to each created instance.
#
variable "public_key_path" {
  default = "no-commit/insecure-deployer.pub"
}

variable "private_key_path" {
  default = "no-commit/insecure-deployer"
}

variable "INSTANCE_USERNAME" {
  default = "ubuntu"
}

variable "vail_binary" {
    default = "no-commit/vail"
}

#
# The credentials that the instance will use when running vail for vail to access AWS.
# This account has the assume role permission with the Spectra account.
#
variable VAIL_AWS_ACCESS_KEY {}

variable VAIL_AWS_SECRET_KEY {}

variable VAIL_AWS_REGION {
  default = "us-west-2"
}

variable VAIL_AWS_ROLE_ARN {}

variable VAIL_AWS_EXTERNAL_ID {}

#
# Set these to the user credentials that will be used by clients to access vail.  Be
# sure the VAIL_USER_ID, VAIL_USER_NAME, and VAIL_USER_ARN are true IAM values. The
#
variable VAIL_USER_ID {}
variable VAIL_USER_NAME {}
variable VAIL_USER_ARN {}
variable VAIL_USER_ACCESS_KEY {}
variable VAIL_USER_SECRET_KEY {}

