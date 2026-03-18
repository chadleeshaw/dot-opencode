# Terraform State Reference

## Remote Backend Configuration

Always use a remote backend for team work. Local state is only acceptable for solo prototyping.

### AWS S3 + DynamoDB (most common)

```hcl
# environments/prod/backend.tf
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-state-lock"
  }
}
```

```hcl
# One-time bootstrap for the S3 bucket and lock table
resource "aws_s3_bucket" "state" {
  bucket = "mycompany-terraform-state"
}

resource "aws_s3_bucket_versioning" "state" {
  bucket = aws_s3_bucket.state.id
  versioning_configuration { status = "Enabled" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state" {
  bucket = aws_s3_bucket.state.id
  rule {
    apply_server_side_encryption_by_default { sse_algorithm = "AES256" }
  }
}

resource "aws_dynamodb_table" "lock" {
  name         = "terraform-state-lock"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### Terraform Cloud / HCP Terraform

```hcl
terraform {
  cloud {
    organization = "my-org"
    workspaces {
      name = "prod"
    }
  }
}
```

### GCS (Google Cloud)

```hcl
terraform {
  backend "gcs" {
    bucket = "mycompany-tf-state"
    prefix = "prod"
  }
}
```

---

## State Key Strategy

Use different state keys per environment to isolate blast radius:

```
s3://mycompany-terraform-state/
├── global/terraform.tfstate       # shared resources (DNS, IAM)
├── dev/terraform.tfstate
├── staging/terraform.tfstate
└── prod/terraform.tfstate
```

Or split by module/team:
```
prod/networking/terraform.tfstate
prod/compute/terraform.tfstate
prod/database/terraform.tfstate
```

---

## Remote State Data Sources

Share state outputs between independent root modules:

```hcl
# In the compute root module, read networking state
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "mycompany-terraform-state"
    key    = "prod/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "web" {
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
}
```

**Warning:** This creates a hard coupling between state files. Prefer passing values via a shared data store (SSM Parameter Store, Consul) for loose coupling at scale.

---

## State Commands

```bash
# List all resources in state
terraform state list

# Show details of a specific resource
terraform state show aws_instance.web

# Move a resource (rename without destroy/create)
terraform state mv aws_instance.web aws_instance.this

# Remove from state without destroying the real resource
terraform state rm aws_instance.web

# Import an existing resource into state
terraform import aws_instance.web i-0abc1234def56789

# Pull current state as JSON
terraform state pull | jq '.resources[] | select(.type=="aws_instance")'

# Force-unlock a stuck lock
terraform force-unlock LOCK_ID
```

---

## Workspaces

Workspaces share the same backend but use different state keys. Use only for minor config variations (like feature flags), **not** for full environment separation — use separate root modules for that.

```bash
terraform workspace new dev
terraform workspace select prod
terraform workspace list
terraform workspace show    # current workspace name
```

```hcl
# Reference current workspace in config
locals {
  env           = terraform.workspace
  instance_type = terraform.workspace == "prod" ? "t3.medium" : "t3.micro"
}
```

**When to use workspaces:** Testing a change in isolation using the same infra code.
**When NOT to use workspaces:** prod/staging/dev environment separation — use separate directories and state files instead.

---

## Sensitive State Data

Terraform state contains all resource attributes, **including secrets in plaintext**. Always:

1. Enable encryption at rest on your state backend (S3 `encrypt = true`, GCS CMEK).
2. Enable encryption in transit (HTTPS backends enforce this).
3. Restrict access to state with bucket policies / IAM.
4. Enable versioning on the state bucket for rollback.
5. Never store state in VCS.
