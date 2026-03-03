# Phoenix Web Server AMI – Technical Documentation

## 1. Purpose

This Packer configuration builds a reusable Amazon Machine Image (AMI) for the Phoenix web server. The AMI contains:

* Amazon Linux 2 base
* Python 3 and Git
* Flask dependency
* Phoenix application code
* systemd service configuration
* Local endpoint validation

The resulting AMI is intended to be used by an Auto Scaling Group for consistent instance provisioning.

---

# 2. Packer Builder Configuration

## 2.1 Builder Type

**Builder:** `amazon-ebs`
**Plugin:** `github.com/hashicorp/amazon >= 1.0.0`

Defined in:

```
packer/versions.pkr.hcl
```

---

## 2.2 Base AMI Selection

The base AMI is selected dynamically using filters:

* Name: `amzn2-ami-hvm-*-x86_64-gp2`
* Root device type: `ebs`
* Virtualization type: `hvm`
* Owner: `amazon`
* `most_recent = true`

This ensures the latest Amazon Linux 2 AMI is used at build time.

---

## 2.3 Instance Configuration

| Parameter      | Value                                          |
| -------------- | ---------------------------------------------- |
| Region         | `var.region`                                   |
| Instance Type  | `var.instance_type` (default: `t3.micro`)      |
| SSH Username   | `var.ssh_username` (default: `ec2-user`)       |
| Public IP      | Enabled (`associate_public_ip_address = true`) |
| VPC            | `var.vpc_id`                                   |
| Subnet         | `var.subnet_id`                                |
| Security Group | `var.packer_sg_id`                             |

---

## 2.4 AMI Naming

AMI name format:

```
${company_name}_${product}_${env}_{{timestamp}}
```

Example:

```
nfi_phoenix_dev_1700000000
```

Tag applied:

```
Name = nfi_phoenix_dev_web_server_ami
```

---

# 3. Provisioning Configuration

Provisioner type: `shell`

Script path:

```
var.script_path
```

Environment variable passed to the script:

```
GIT_REPO=${var.git_repo}
```

---

# 4. Bootstrap Script – Technical Breakdown

## 4.1 System Update

```bash
sudo yum update -y
```

Updates all installed packages.

---

## 4.2 Dependency Installation

```bash
sudo yum install -y python3 git
sudo pip3 install flask
```

Installs:

* Python 3
* Git
* Flask (globally via pip3)

---

## 4.3 Application Deployment

```bash
sudo mkdir -p /opt/phoenix_app
cd /opt/phoenix_app
sudo git clone "${GIT_REPO}" .
```

* Creates application directory
* Clones repository into `/opt/phoenix_app`

---

## 4.4 systemd Configuration

```bash
sudo mv /opt/phoenix_app/systemd/service.service /etc/systemd/system/nfi_phoenix.service
sudo systemctl daemon-reload
sudo systemctl enable nfi_phoenix.service
sudo systemctl start nfi_phoenix.service
```

Actions performed:

* Registers the service
* Enables it on boot
* Starts it immediately

---

## 4.5 Application Validation

```bash
curl -f http://127.0.0.1:8080
```

* Verifies the service is running locally
* Causes Packer build to fail if the endpoint is unreachable

---

# 5. Variables

## 5.1 Core Variables

| Variable      | Type   | Default                      |
| ------------- | ------ | ---------------------------- |
| region        | string | eu-central-1                 |
| instance_type | string | t3.micro                     |
| company_name  | string | nfi                          |
| cloud_name    | string | aws                          |
| product       | string | phoenix                      |
| env           | string | dev                          |
| ssh_username  | string | ec2-user                     |
| git_repo      | string | GitLab URL                   |
| script_path   | string | scripts/bootstrap_phoenix.sh |

---

## 5.2 AMI Filter Object

```
variable "nfi_web_server_ami_filter" {
  type = object({
    name                = string
    root-device-type    = string
    virtualization-type = string
  })
}
```

Default values:

* name: `amzn2-ami-hvm-*-x86_64-gp2`
* root-device-type: `ebs`
* virtualization-type: `hvm`

---

## 5.3 Networking Variables

| Variable     | Description                       |
| ------------ | --------------------------------- |
| vpc_id       | VPC where build instance launches |
| subnet_id    | Subnet for temporary EC2          |
| packer_sg_id | Security Group for build instance |

These must be provided if building inside a specific VPC.

---

# 6. Build Execution

## Initialize Plugins

```
packer init .
```

## Validate Template

```
packer validate .
```

## Build AMI

```
packer build .
```

With variable overrides:

```
packer build \
  -var "region=eu-central-1" \
  -var "vpc_id=vpc-xxxx" \
  -var "subnet_id=subnet-xxxx" \
  -var "packer_sg_id=sg-xxxx" \
  .
```

---

# 7. Build Lifecycle

1. Temporary EC2 instance is launched.
2. Bootstrap script executes.
3. Application and service are configured.
4. Local endpoint validation runs.
5. AMI is created from instance.
6. Temporary EC2 instance is terminated.

---

# 8. Output

Upon successful build:

* AMI ID is printed in Packer output.
* AMI is available in the specified region.
* AMI can be used by Launch Templates or Auto Scaling Groups.

---

# 9. Notes

* Flask is installed globally via pip3.
* Public IP is required during build due to `associate_public_ip_address = true`.
* systemd ensures the application auto-starts on instance launch.
* Build fails if the local endpoint validation fails.

---

This configuration produces a fully baked, reusable AMI suitable for immutable infrastructure deployment.
