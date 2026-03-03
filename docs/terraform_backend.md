# Terraform Backend – Full Flexibility Guide

This folder creates the **remote state backend** used by all other Terraform layers in this project: an **S3 bucket** for storing state files and a **DynamoDB table** for state locking. You must create this backend **first**, before running network, application, or validation Terraform; the other layers reference this bucket and table in their `backend "s3"` blocks.

**Important:** This configuration itself does **not** use a remote backend. It runs with **local state** (or whatever backend you configure here). Only after this is applied do the other stacks use the S3 bucket and DynamoDB table it creates.

**Directory:** `terraform/resources/terraform_backend`

---

## Contents

1. [File and module overview](#1-file-and-module-overview)
2. [Provider](#2-provider)
3. [Backend module (S3 + DynamoDB)](#3-backend-module-s3--dynamodb)
4. [Resource naming](#4-resource-naming)
5. [Create, modify, destroy](#5-create-modify-destroy)
6. [Common commands](#6-common-commands)
7. [Key variables reference](#7-key-variables-reference)
8. [Sample plan output](#8-sample-plan-output)

---

**About the modules:** The existing module in this folder creates the backend with sensible defaults; you can use it as-is. For a different naming scheme, extra buckets, or custom options, add a **new** module block or a new module under `terraform/modules/`—do not feel limited to the specific example in this doc. This guide describes the provided setup for reference.

---

## 1. File and module overview

| File | Purpose |
|------|--------|
| `provider.tf` | AWS provider (region, profile). No backend block – state is local for this stack. |
| `main.tf` | Invokes the `terraform_state_backend` module with company, cloud, and env. |

**Module:** `terraform_backend` (from `terraform/modules/terraform_state_backend`).

The module creates:

- S3 bucket (with versioning, server-side encryption, public access block)
- DynamoDB table (single attribute `LockID`, used by Terraform for locking)

---

## 2. Provider

**File:** `provider.tf`

- **AWS provider:** `region = "eu-central-1"`, `profile = "default"`.
- **Backend:** None specified – Terraform uses local state by default. The **other** stacks (network, application, validation) use the S3 bucket and DynamoDB table created by this stack.

To use a different region or profile, change the provider block or use variable overrides if you switch to variables for region/profile.

---

## 3. Backend module (S3 + DynamoDB)

**File:** `main.tf`

Single module block:

```hcl
module "terraform_backend" {
  source       = "../../modules/terraform_state_backend"
  company_name = "nfi"
  cloud_name   = "aws"
  env          = "dev"
}
```

**Module resources:**

| Resource | Purpose |
|----------|--------|
| `aws_s3_bucket.nfi_terraform_state` | Bucket for Terraform state files. |
| `aws_s3_bucket_versioning.versioning` | Enables versioning on the bucket (default: Enabled). |
| `aws_s3_bucket_server_side_encryption_configuration.encryption` | SSE (default: AES256). |
| `aws_s3_bucket_public_access_block.block_public` | Blocks public ACLs and public bucket policies. |
| `aws_dynamodb_table.nfi_dynamodb_terraform_lock` | Table for state lock (hash key `LockID`). |

With default variables (`company_name = "nfi"`, `cloud_name = "aws"`, `env = "dev"`), the bucket name is `nfi-aws-dev-terraform-state-backend` and the DynamoDB table name is `nfi_aws_dev_terraform_state_backend_dynamo_db`. These names are hardcoded in the other stacks’ `backend "s3"` and `dynamodb_table` config.

---

## 4. Resource naming

Names are derived from the module variables:

| Variable | Default | Used in |
|----------|---------|--------|
| `company_name` | `"nfi"` | Bucket name, table name, tags |
| `cloud_name` | `"aws"` | Bucket name, table name, tags |
| `env` | `"dev"` | Bucket name, table name, tags |

- **S3 bucket:** `"${company_name}-${cloud_name}-${env}-terraform-state-backend"` → e.g. `nfi-aws-dev-terraform-state-backend`
- **DynamoDB table:** `"${company_name}_${cloud_name}_${env}_terraform_state_backend_dynamo_db"` → e.g. `nfi_aws_dev_terraform_state_backend_dynamo_db`

If you change these values, you must update the `backend "s3"` and `dynamodb_table` in `network_architecture/dev`, `application_architecture/dev`, and `validation_architecture/dev` to match.

---

## 5. Create, modify, destroy

### Create (first time)

```bash
cd terraform/resources/terraform_backend
terraform init
terraform plan
terraform apply
```

After apply, the bucket and table exist. Other stacks can then use `terraform init` with their S3 backend config.

### Modify

Change `company_name`, `cloud_name`, or `env` in `main.tf` (or pass `-var`), then:

```bash
terraform plan
terraform apply
```

**Warning:** Changing names may create new resources and leave old ones in place (e.g. new bucket, old bucket still there). Plan carefully; you may need to migrate state or destroy the old backend after switching other stacks to the new bucket/table.

### Destroy

Destroy this stack **only after** all other stacks (validation, application, network) have been destroyed and their state is no longer needed (or has been migrated).

```bash
terraform destroy
```

Empty the S3 bucket first if it contains state files you want to remove; Terraform may not delete a non-empty bucket depending on configuration.

---

## 6. Common commands

```bash
cd terraform/resources/terraform_backend
terraform init
terraform validate
terraform plan
terraform apply
terraform destroy
```

Override module variables:

```bash
terraform plan -var="company_name=nfi" -var="cloud_name=aws" -var="env=dev"
terraform apply -var="company_name=nfi" -var="cloud_name=aws" -var="env=dev"
```

---

## 7. Key variables reference

These are the **module** variables (defined in `terraform/modules/terraform_state_backend/variables.tf`). The root module in this folder only passes `company_name`, `cloud_name`, and `env`; the rest use module defaults.

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `company_name` | string | *(required)* | Company/prefix for resource names. |
| `cloud_name` | string | *(required)* | Cloud identifier (e.g. aws). |
| `env` | string | *(required)* | Environment (e.g. dev). |
| `s3_enable_versioning` | string | `"Enabled"` | S3 versioning status. |
| `s3_sse_algorithm` | string | `"AES256"` | Server-side encryption algorithm. |
| `s3_block_public_acls` | bool | `true` | Block public ACLs. |
| `s3_block_public_policy` | bool | `true` | Block public bucket policy. |
| `s3_ignore_public_acls` | bool | `true` | Ignore public ACLs. |
| `s3_restrict_public_buckets` | bool | `true` | Restrict public buckets. |
| `dynamodb_billing_mode` | string | `"PAY_PER_REQUEST"` | DynamoDB billing mode. |
| `dynamodb_hash_key` | string | `"LockID"` | DynamoDB hash key name. |
| `dynamodb_attribute` | object | `{ name = "LockID", type = "S" }` | Hash key attribute definition. |

---

## 8. Sample plan output

After `terraform init` and `terraform plan`, you should see something like:

```
Terraform will perform the following actions:

  # module.terraform_backend.aws_dynamodb_table.nfi_dynamodb_terraform_lock will be created
  # module.terraform_backend.aws_s3_bucket.nfi_terraform_state will be created
  # module.terraform_backend.aws_s3_bucket_public_access_block.block_public will be created
  # module.terraform_backend.aws_s3_bucket_server_side_encryption_configuration.encryption will be created
  # module.terraform_backend.aws_s3_bucket_versioning.versioning will be created

Plan: 5 to add, 0 to change, 0 to destroy.
```

After apply, other stacks can reference:

- **Bucket:** `nfi-aws-dev-terraform-state-backend` (with default vars)
- **DynamoDB table:** `nfi_aws_dev_terraform_state_backend_dynamo_db`
- **Region:** `eu-central-1` (must match the region in other stacks’ backend blocks)
