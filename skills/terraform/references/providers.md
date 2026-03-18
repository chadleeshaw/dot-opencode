# Terraform Providers Reference

## Provider Configuration Best Practices

### Always pin provider versions in the root module

```hcl
# environments/prod/versions.tf
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"   # allow 5.x, block 6.0
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}
```

Modules use loose constraints (`>= 5.0, < 6.0`); root configs use pessimistic (`~>`) to pin minor.

### Commit `terraform.lock.hcl`

The lock file records exact provider checksums. Commit it so every team member and CI uses identical provider binaries.

```bash
# Update lock file after version changes
terraform providers lock -platform=linux_amd64 -platform=darwin_arm64
```

---

## Provider Configuration

```hcl
# Configure once in the root module, never in child modules
provider "aws" {
  region = var.region

  default_tags {
    tags = local.common_tags
  }

  # Assume role for cross-account deployments
  assume_role {
    role_arn     = "arn:aws:iam::123456789012:role/TerraformDeploy"
    session_name = "terraform-${var.environment}"
  }
}
```

**Rule:** Never put `provider` blocks inside modules. Modules inherit from the root.

---

## Provider Aliases (Multi-Region / Multi-Account)

```hcl
# Two regions in the same config
provider "aws" {
  region = "us-east-1"
  alias  = "use1"
}

provider "aws" {
  region = "eu-west-1"
  alias  = "euw1"
}

# Pass alias into a module
module "replica" {
  source = "../../modules/rds-replica"

  providers = {
    aws = aws.euw1
  }
}

# Use alias directly on a resource
resource "aws_s3_bucket" "eu_backup" {
  provider = aws.euw1
  bucket   = "${local.name_prefix}-eu-backup"
}
```

### Alias in a module (declaring provider requirements)

```hcl
# modules/rds-replica/versions.tf
terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = ">= 5.0"
      configuration_aliases = [aws.replica]
    }
  }
}

# modules/rds-replica/main.tf
resource "aws_db_instance" "replica" {
  provider            = aws.replica
  replicate_source_db = var.source_arn
}
```

---

## Default Tags (AWS)

Set tags once on the provider to avoid repeating them on every resource:

```hcl
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
```

Resources can still add their own tags with `tags = { Name = "..." }` — they merge automatically.

---

## Common Provider Patterns

### Data-only providers (no resources)

```hcl
# Read-only AWS account info
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
```

### Multiple AWS accounts

```hcl
provider "aws" {
  alias  = "shared"
  region = "us-east-1"
  assume_role { role_arn = "arn:aws:iam::111111111111:role/TerraformDeploy" }
}

provider "aws" {
  alias  = "workload"
  region = "us-east-1"
  assume_role { role_arn = "arn:aws:iam::222222222222:role/TerraformDeploy" }
}
```

### Kubernetes / Helm providers (depends on cluster existing first)

```hcl
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

# Explicitly declare the dependency
resource "helm_release" "ingress" {
  depends_on = [module.eks]
  # ...
}
```

---

## Version Constraint Operators

| Operator | Example | Meaning |
|---|---|---|
| `=` | `= 5.30.0` | Exact version only |
| `!=` | `!= 5.0.0` | Exclude this version |
| `>`, `>=` | `>= 5.0` | Minimum version |
| `<`, `<=` | `< 6.0` | Maximum version |
| `~>` | `~> 5.30` | Allow `5.30.x`, block `5.31` |
| `~>` | `~> 5.0` | Allow `5.x`, block `6.0` |

Use `~>` (pessimistic constraint) in root modules. Use `>= x.y, < z.0` in reusable modules for wider compatibility.
