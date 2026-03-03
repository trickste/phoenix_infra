variable "region" {
    description = "AWS region where the AMI will be built"
    type    = string
    default = "eu-central-1"
}

variable "instance_type" {
    description = "EC2 instance type to use for building the AMI"
    type    = string
    default = "t3.micro"
}

variable "company_name" {
    description = "Name prefix"
    type        = string
    default     = "nfi"
}

variable "cloud_name" {
    description = "Cloud name"
    type        = string
    default     = "aws"
}

variable "product" {
    description = "Product name"
    type        = string
    default     = "phoenix"
}

variable "env" {
    description = "Environment name"
    type        = string
    default     = "dev"
}

variable "ssh_username" {
    description = "SSH username for the EC2 instance"
    type    = string
    default = "ec2-user"
}

variable "nfi_web_server_ami_filter" {
    description = "Filters to find the base AMI for the web server"
    type    = object({
        name                = string
        root-device-type    = string
        virtualization-type = string
    })
    default = {
        name                = "amzn2-ami-hvm-*-x86_64-gp2"
        root-device-type    = "ebs"
        virtualization-type = "hvm"
    }
}

variable "nfi_web_server_owners" {
    description = "Owners to filter the base AMI for the web server"
    type    = list(string)
    default = ["amazon"]
}

variable "script_path" {
    description = "Path to the provisioning script"
    type    = string
    default = "scripts/bootstrap_phoenix.sh"
}

variable "git_repo" {
    description = "Git repository URL for the application code"
    type    = string
    default = "https://gitlab.com/nfi_aws_phoenix/phoenix_app.git"
}

variable "vpc_id" {
    description = "VPC ID where the EC2 instance will be launched"
    type    = string
    default = null
}

variable "subnet_id" {
    description = "Subnet ID where the EC2 instance will be launched"
    type    = string
    default = null
}

variable "packer_sg_id" {
    description = "Security Group ID to associate with the EC2 instance during AMI creation"
    type    = string
    default = null
}
