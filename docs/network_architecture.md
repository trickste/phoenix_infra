# Network Architecture – Full Flexibility Guide

This folder defines the **networking layer** for an environment. It provisions:

* VPC
* Public and protected subnets
* Internet Gateway (IGW)
* Route tables
* Network ACLs (NACLs)
* Security group for AMI builds (optional)

All resources are created via reusable Terraform modules and can be deployed independently or together.

---

## Prerequisite

The Terraform backend (S3 + DynamoDB) must already exist before using this configuration.
Run the backend setup first from:

```
terraform/resources/terraform_backend
```


---

# Contents

1. File and module overview
2. Provider and backend
3. VPC
4. Internet Gateway
5. Public subnets
6. Protected subnets
7. AMI security group
8. Route tables
9. Network ACLs
10. Outputs
11. Common commands
12. Key variables reference

---

## 1. File and Module Overview

| File                                         | Purpose                                |
| -------------------------------------------- | -------------------------------------- |
| `provider.tf`                                | AWS provider and backend configuration |
| `vpc.tf`                                     | VPC module                             |
| `igw.tf`                                     | Internet Gateway                       |
| `public_subnet.tf`                           | Public subnets                         |
| `protected_subnet.tf`                        | Protected subnets                      |
| `security_group.tf`                          | Security group for AMI builds          |
| `route_table.tf`                             | Route tables                           |
| `nacl.tf`                                    | Network ACLs                           |
| `variables.tf`                               | Input variables                        |
| `output.tf`                                  | Outputs                                |

### About Modules

The existing module blocks provide sensible defaults.

For custom behavior (different CIDRs, multiple VPCs, NAT gateways, different naming schemes, etc.), you can:

* Add additional module blocks, or
* Create reusable modules under `terraform/modules/`

This guide describes a reference setup only.

---

## 2. Provider and Backend

**File:** `provider.tf`

* AWS provider:

  * `region = var.region`
  * Optional `profile = var.aws_profile`

* Backend:

  * S3 bucket for state
  * Environment-specific state key
  * DynamoDB table for locking

Override region if needed:

```bash
terraform plan -var="region=us-east-1"
```

---

## 3. VPC

**File:** `vpc.tf`

### Create a New VPC

With default variables:

```bash
cd terraform/resources/network_architecture/{env}
terraform init
terraform plan -target=module.vpc
terraform apply -target=module.vpc
```

Common defaults:

* `vpc_cidr = "10.0.0.0/16"`
* DNS support enabled
* DNS hostnames enabled

### Customize VPC

```bash
terraform apply \
  -var="vpc_cidr=10.1.0.0/16" \
  -var="vpc_enable_dns_support=true" \
  -var="vpc_enable_dns_hostnames=true"
```

### Use an Existing VPC

Set:

```bash
create_vpc = false
vpc_id     = "vpc-xxxxxxxx"
```

When using an existing VPC, ensure subnet IDs are provided if not creating new subnets.

---

## 4. Internet Gateway

**File:** `igw.tf`

Creates and attaches an Internet Gateway to the VPC.

```bash
terraform plan -target=module.igw
terraform apply -target=module.igw
```

If using an existing VPC, ensure `vpc_id` is set.

---

## 5. Public Subnets

**File:** `public_subnet.tf`

Creates one public subnet per availability zone.

Typical defaults:

* Multiple AZs
* CIDRs defined via `public_subnets_cidrs`
* Route table associated with IGW

Customize:

```bash
terraform apply \
  -var='subnet_azs=["us-east-1a","us-east-1b"]' \
  -var='public_subnets_cidrs=["10.0.1.0/24","10.0.2.0/24"]'
```

To use existing public subnets:

```bash
create_public_subnets = false
public_subnet_ids     = ["subnet-aaa","subnet-bbb"]
```

---

## 6. Protected Subnets

**File:** `protected_subnet.tf`

Creates protected subnets (no direct IGW route).

Defaults:

* One per AZ
* CIDRs defined via `protected_subnets_cidrs`

```bash
terraform plan -target=module.protected_subnets
terraform apply -target=module.protected_subnets
```

To use existing protected subnets:

```bash
create_protected_subnets = false
protected_subnet_ids     = ["subnet-ccc","subnet-ddd"]
```

---

## 7. Security Group (AMI)

**File:** `security_group.tf`

Optional security group for:

* Packer AMI builds
* Temporary build instances
* SSH access (restricted to your IP)

Rules are configurable via variables.

```bash
terraform plan -target=module.ami_security_group
terraform apply -target=module.ami_security_group
```

Output can be used by a Packer pipeline.

---

## 8. Route Tables

**File:** `route_table.tf`

Typical setup:

### Public Route Table

* Default route to Internet Gateway
* Associated with public subnets

### Protected Route Table

* No IGW route
* Optionally routes to NAT Gateway (if implemented)

Deploy individually:

```bash
terraform plan -target=module.public_route_table
terraform apply -target=module.public_route_table

terraform plan -target=module.protected_route_table
terraform apply -target=module.protected_route_table
```

---

## 9. Network ACLs (NACLs)

**File:** `nacl.tf`

Optional custom NACLs for:

* Public subnets
* Protected subnets

Rules are defined via variables:

* `public_nacl_ingress_rules`
* `public_nacl_egress_rules`
* `protected_nacl_ingress_rules`
* `protected_nacl_egress_rules`

Deploy:

```bash
terraform plan -target=module.public_nacl
terraform apply -target=module.public_nacl

terraform plan -target=module.protected_nacl
terraform apply -target=module.protected_nacl
```

---

## 10. Outputs

**File:** `output.tf`

Common outputs:

| Output                  | Description                   |
| ----------------------- | ----------------------------- |
| `vpc_id`                | VPC ID used                   |
| `public_subnet_ids`     | Public subnet IDs             |
| `protected_subnet_ids`  | Protected subnet IDs            |
| `ami_security_group_id` | Security group for AMI builds |

Examples:

```bash
terraform output vpc_id
terraform output -json protected_subnet_ids
terraform output -raw ami_security_group_id
```

---

## 11. Common Commands

From the environment directory:

```bash
cd terraform/resources/network_architecture/{env}
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

Target specific module:

```bash
terraform plan -target=module.vpc
terraform apply -target=module.vpc
```

Apply with overrides:

```bash
terraform apply \
  -var="region=us-east-1" \
  -var="vpc_cidr=10.0.0.0/16"
```

---

## 12. Key Variables Reference

| Variable                     | Type         | Description                       |
| ---------------------------- | ------------ | --------------------------------- |
| `region`                     | string       | AWS region                        |
| `company_name`               | string       | Naming prefix                     |
| `cloud_name`                 | string       | Cloud identifier                  |
| `product`                    | string       | Product or service name           |
| `env`                        | string       | Environment name                  |
| `create_vpc`                 | bool         | Create a new VPC                  |
| `vpc_id`                     | string       | Existing VPC ID (if not creating) |
| `vpc_cidr`                   | string       | VPC CIDR block                    |
| `vpc_enable_dns_support`     | bool         | Enable DNS support                |
| `vpc_enable_dns_hostnames`   | bool         | Enable DNS hostnames              |
| `subnet_azs`                 | list(string) | Availability zones                |
| `public_subnets_cidrs`       | list(string) | CIDRs for public subnets          |
| `protected_subnets_cidrs`    | list(string) | CIDRs for protected subnets       |
| `create_public_subnets`      | bool         | Create public subnets             |
| `create_protected_subnets`   | bool       | Create protected subnets            |
| `public_subnet_ids`          | list(string) | Existing public subnet IDs        |
| `protected_subnet_ids`       | list(string) | Existing protected subnet IDs     |
| `create_security_group`      | bool         | Create AMI security group         |
| `create_public_route_table`  | bool         | Create public route table         |
| `create_protected_route_table` | bool         | Create protected route table    |
| `create_public_nacl`         | bool         | Create public NACL                |
| `create_protected_nacl`        | bool         | Create protected NACL               |

Security group and NACL rules are defined in `variables.tf` as lists of objects for full customization.
