# Application Architecture – Full Flexibility Guide

This folder defines the **application layer** of an infrastructure setup in a given environment. It provisions:

* Application Load Balancer (ALB)
* Target Group
* Auto Scaling Group (ASG)
* Security Groups (for ALB and ASG)

It uses the same Terraform backend as the rest of the project and depends on:

* A **network layer** (VPC and subnets)
* An **AMI** (built via Packer or provided manually)

---

## Prerequisites

* Terraform backend (S3 + DynamoDB) already exists.
* Network layer (`terraform/resources/network_architecture/{env}`) has been applied (VPC and subnets available).
* An AMI exists:

  * Either built via Packer with a predictable tag naming scheme, or
  * Provided explicitly via `ami_id` variable.

**Directory:**
`terraform/resources/application_architecture/{env}`

---

# Contents

1. File and module overview
2. Provider and backend
3. Data sources
4. Target group
5. Security groups
6. Application Load Balancer
7. Auto Scaling Group
8. Outputs
9. Common commands
10. Key variables reference

---

## 1. File and Module Overview

| File                | Purpose                                   |
| ------------------- | ----------------------------------------- |
| `provider.tf`       | AWS provider and S3 backend configuration |
| `data.tf`           | Data sources (AMI, VPC, subnets)          |
| `target_group.tf`   | Target group definition                   |
| `security_group.tf` | Security groups for ALB and ASG           |
| `alb.tf`            | Application Load Balancer                 |
| `asg.tf`            | Auto Scaling Group                        |
| `variables.tf`      | Input variables                           |
| `output.tf`         | Outputs                                   |

### About Modules

The module blocks provided here create resources with sensible defaults.

For custom behavior (custom ports, multiple target groups, internal ALB, custom scaling policies, etc.), you can:

* Add new module blocks, or
* Create reusable modules under `terraform/modules/`

You are not limited to the default setup described here.

---

## 2. Provider and Backend

**File:** `provider.tf`

* AWS provider:

  * `region = var.region`
  * `profile = var.aws_profile` (if used)

* Backend:

  * S3 bucket
  * State key per environment
  * DynamoDB table for state locking

The backend must already exist before running this layer.

---

## 3. Data Sources

**File:** `data.tf`

Data sources are optional and allow resolving infrastructure automatically via tags.

### Typical Resolution Pattern

* `local.base_name` → Used for AMI tag lookup
* `local.network_base_name` → Used for VPC/subnet tag lookup

Possible data sources:

* `data.aws_ami` – Latest AMI matching tag pattern
* `data.aws_vpc` – VPC by Name tag
* `data.aws_subnets` – Subnets filtered by tag + VPC

If your environment does not follow tag conventions, pass explicitly:

* `vpc_id`
* `subnet_ids`
* `ami_id`

This disables reliance on data lookups.

---

## 4. Target Group

**File:** `target_group.tf`

Creates an ALB target group.

Purpose:

* ALB forwards traffic to this target group.
* ASG registers EC2 instances into this group.

Configurable:

* Port
* Protocol
* Health check path
* Health thresholds
* Interval and timeout
* Matcher

Example:

```bash
terraform plan -target=module.target_group
terraform apply -target=module.target_group
```

---

## 5. Security Groups

**File:** `security_group.tf`

Two security groups are typically created:

### ALB Security Group

* Allows inbound traffic (e.g., HTTP 80 / HTTPS 443).
* Outbound usually open.

### ASG Security Group

* Allows traffic from ALB.
* Allows internal VPC communication if required.

Ingress and egress rules are configurable via variables.

Example:

```bash
terraform plan -target=module.alb_security_group -target=module.asg_security_group
terraform apply -target=module.alb_security_group -target=module.asg_security_group
```

---

## 6. Application Load Balancer

**File:** `alb.tf`

Creates an ALB inside a VPC using selected subnets.

Input logic pattern:

* `vpc_id`:

  * Use `var.vpc_id` if provided.
  * Else use data source.

* `subnet_ids`:

  * Use `var.subnet_ids` if provided.
  * Else use data source.

Configurable options:

* Internal or internet-facing
* Deletion protection
* Listener ports
* SSL (if configured)

Example:

```bash
terraform plan -target=module.alb
terraform apply -target=module.alb
```

---

## 7. Auto Scaling Group

**File:** `asg.tf`

Creates:

* Launch Template
* Auto Scaling Group
* Scaling policies (e.g., CPU-based target tracking)

AMI selection logic:

* Use `var.ami_id` if provided.
* Else use `data.aws_ami` (latest tagged AMI).

Subnets:

* Use `var.subnet_ids` if provided.
* Else use data source.

Configurable:

* Instance type
* Min / max / desired capacity
* Health check grace period
* Scaling policy thresholds
* Cooldown

Example:

```bash
terraform plan -target=module.asg
terraform apply -target=module.asg
```

---

## 8. Outputs

**File:** `output.tf`

Common outputs:

| Output         | Description     |
| -------------- | --------------- |
| `alb_dns_name` | DNS name of ALB |
| `vpc_id`       | VPC ID used     |
| `subnet_ids`   | Subnets used    |

Example:

```bash
terraform output alb_dns_name
terraform output vpc_id
```

---

## 9. Common Commands

From the environment directory:

```bash
cd terraform/resources/application_architecture/{env}
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

### Override Network

```bash
terraform apply \
  -var="vpc_id=vpc-xxxxxxxx" \
  -var='subnet_ids=["subnet-aaa","subnet-bbb","subnet-ccc"]'
```

### Override AMI

```bash
terraform apply -var="ami_id=ami-xxxxxxxx"
```

---

## 10. Key Variables Reference

| Variable                     | Type         | Description                    |
| ---------------------------- | ------------ | ------------------------------ |
| `region`                     | string       | AWS region                     |
| `company_name`               | string       | Naming prefix                  |
| `cloud_name`                 | string       | Cloud identifier               |
| `product`                    | string       | Application or service name    |
| `env`                        | string       | Environment name               |
| `vpc_id`                     | string       | VPC ID (optional override)     |
| `subnet_ids`                 | list(string) | Subnet IDs (optional override) |
| `ami_id`                     | string       | AMI ID (optional override)     |
| `instance_type`              | string       | EC2 instance type              |
| `min_size`                   | number       | ASG minimum size               |
| `max_size`                   | number       | ASG maximum size               |
| `desired_capacity`           | number       | ASG desired capacity           |
| `health_check_grace_period`  | number       | ASG grace period (seconds)     |
| `target_group_port`          | number       | Target group port              |
| `target_group_protocol`      | string       | Target group protocol          |
| `target_group_healthcheck`   | object       | Health check configuration     |
| `enable_deletion_protection` | bool         | Enable ALB deletion protection |
| `create_security_group`      | bool         | Toggle SG creation             |

Ingress and egress rule structures are defined in `variables.tf` as lists of objects.
