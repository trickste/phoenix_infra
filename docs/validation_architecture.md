# Validation Architecture –  Full Flexibility Guide

The **validation layer** provides a Lambda function that runs inside a VPC and calls an internal or external Application Load Balancer (ALB) (or any HTTP endpoint). It is used to verify that the application layer is reachable and responding correctly (e.g., for automated checks, health validation, or evaluation purposes).

---

## Prerequisites

* Terraform backend (S3 + DynamoDB) already exists.
* Network layer has been applied (VPC and protected subnets available).
* Application layer has been applied (ALB or target endpoint exists).


Lambda source code typically lives in:

```
terraform/resources/validation_architecture/lambda_function_code/
```

---

# Contents

1. Folder and file overview
2. Provider and backend
3. Data sources
4. Lambda security group
5. Lambda function
6. Lambda function code
7. Common commands
8. Key variables reference

---

## 1. Folder and File Overview

### Example Layout

```
validation_architecture/
├── VALIDATION_ARCHITECTURE.md
├── lambda_function_code/
│   └── lambda_function.py
└── {env}/
    ├── provider.tf
    ├── variables.tf
    ├── data.tf
    ├── security_group.tf
    └── lambda.tf
```

### Module Responsibility

The Lambda module typically handles:

* Lambda function creation
* IAM role and policies
* VPC configuration
* Environment variables

For custom behavior (multiple Lambdas, additional validation flows, different runtimes), you can:

* Add additional module blocks, or
* Create reusable modules under `terraform/modules/`

---

## 2. Provider and Backend

**File:** `provider.tf`

* AWS provider:

  * `region = var.region`
  * Optional `profile = var.aws_profile`

* Backend:

  * S3 bucket for Terraform state
  * Environment-specific key
  * DynamoDB table for locking

The backend must already exist.

---

## 3. Data Sources

**File:** `data.tf`

Data sources optionally resolve:

* VPC
* Protected subnets
* ALB (or other endpoint)

Common pattern:

* `local.base_name` → Used for resource name lookup
* `local.network_base_name` → Used for VPC/subnet tag lookup

Possible data sources:

* `data.aws_vpc`
* `data.aws_subnets`
* `data.aws_lb`
* `data.aws_lb_listener`
* `data.aws_lb_target_group`

If naming conventions differ, provide values explicitly via variables:

* `vpc_id`
* `subnet_ids`
* `alb_dns_name`

---

## 4. Lambda Security Group

**File:** `security_group.tf`

Creates a security group for the Lambda function when deployed inside a VPC.

Typical configuration:

* Ingress: usually none required.
* Egress: allow outbound HTTPS/HTTP to reach ALB or other services.

VPC ID resolution pattern:

* Use `var.vpc_id` if provided.
* Else use data source.

Deploy independently if needed:

```bash
terraform plan -target=module.lambda_security_group
terraform apply -target=module.lambda_security_group
```

---

## 5. Lambda Function

**File:** `lambda.tf`

Creates the Lambda function with:

* Runtime (e.g., Python, Node.js)
* Handler
* Deployment package (ZIP file)
* Timeout
* Memory size
* VPC configuration (subnets + security group)
* Environment variables (e.g., ALB DNS)

Typical environment variable:

```
ALB_DNS = <ALB DNS name>
```

IAM role includes:

* `AWSLambdaVPCAccessExecutionRole`
* Basic execution permissions
* Optional custom policies

Deploy:

```bash
terraform plan -target=module.validation_lambda
terraform apply -target=module.validation_lambda
```

---

## 6. Lambda Function Code

**File:** `lambda_function_code/lambda_function.py`

### Typical Behavior

* Read `ALB_DNS` (or other endpoint) from environment.
* Perform HTTP GET request.
* Return:

  * `200` with response body on success.
  * `500` on failure or missing configuration.

Example flow:

1. Read environment variable.
2. Send request to `http://<ALB_DNS>`.
3. Return structured JSON response.

---

### Building the Deployment Package

From the Lambda code directory:

```bash
cd terraform/resources/validation_architecture/lambda_function_code
zip -j lambda.zip lambda_function.py
```

Ensure `lambda.zip` exists before running `terraform apply`.

---

## 7. Common Commands

### Build Lambda ZIP

```bash
cd terraform/resources/validation_architecture/lambda_function_code
zip -j lambda.zip lambda_function.py
```

### Deploy Validation Layer

```bash
cd ../{env}
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

### Override Default Resource Discovery

```bash
terraform apply \
  -var="vpc_id=vpc-xxxxxxxx" \
  -var='protected_subnet_ids=["subnet-aaa","subnet-bbb"]' \
  -var="alb_dns_name=my-alb-123.region.elb.amazonaws.com"
```

---

## 8. Key Variables Reference

| Variable                              | Type         | Description                                             |
| ------------------------------------- | ------------ | ------------------------------------------------------- |
| `region`                              | string       | AWS region                                              |
| `company_name`                        | string       | Naming prefix                                           |
| `cloud_name`                          | string       | Cloud identifier                                        |
| `product`                             | string       | Application or service name                             |
| `env`                                 | string       | Environment name                                        |
| `vpc_id`                              | string       | VPC ID (optional override)                              |
| `protected_subnet_ids`                | list(string) | Subnet IDs for Lambda                                   |
| `alb_dns_name`                        | string       | ALB DNS name or endpoint                                |
| `lambda_timeout`                      | number       | Lambda timeout (seconds)                                |
| `lambda_memory_size`                  | number       | Lambda memory (MB)                                      |
| `lambda_handler`                      | string       | Lambda handler (e.g., `lambda_function.lambda_handler`) |
| `lambda_runtime`                      | string       | Lambda runtime (e.g., `python3.11`)                     |
| `create_lambda_security_group`        | bool         | Whether to create Lambda SG                             |
| `lambda_security_group_ingress_rules` | list(object) | Ingress rules                                           |
| `lambda_security_group_egress_rules`  | list(object) | Egress rules                                            |

The Lambda module expects the ZIP file at `lambda_zip_path`. Ensure the file exists before running `terraform apply`.


It is designed to integrate cleanly with the network and application layers while remaining independently deployable.
