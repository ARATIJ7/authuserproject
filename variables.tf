variable "aws_region" {
  description = "AWS region"
  default     = "ap-southeast-2"
}

variable "ami_id" {
  description = "AMI ID for Amazon Linux 2"
  default     = "ami-0feb005db42d9695c"
}

variable "instance_type" {
  description = "EC2 instance type"
  default     = "t2.micro"
}

variable "key_name" {
  description = "Key pair name for SSH access"
  default     = "syd"
}
