# Terraform Modules Reference

## What Belongs in a Module vs. a Root Config

| Put in a **module** | Put in the **root/environment** |
|---|---|
| Resource creation logic | Backend configuration |
| Data source lookups specific to a resource group | Provider configuration |
| Internal locals (derived names, tags) | Module calls with env-specific values |
| Outputs the parent environment may need | `terraform.tfvars` values |
| Validation rules | Workspace / env branching logic |

A module should be **opinionated about how** a resource is created but **not about what** values it receives. Pass everything that varies as a variable.

---

## Module Source Types

```hcl
# Local path (development / monorepo)
module "networking" {
  source = "../../modules/networking"
}

# Terraform Registry (pin the version)
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"
}

# Git (pin the ref)
module "compute" {
  source = "git::https://github.com/org/infra-modules.git//compute?ref=v1.4.0"
}

# S3 (private registry alternative)
module "rds" {
  source  = "s3::https://s3.amazonaws.com/my-bucket/modules/rds.zip"
}
```

---

## Composing Modules: Passing Outputs Between Modules

```hcl
# environments/prod/main.tf

module "networking" {
  source  = "../../modules/networking"
  vpc_cidr = var.vpc_cidr
  tags     = local.common_tags
}

module "compute" {
  source = "../../modules/compute"

  # Pass outputs from networking directly
  vpc_id     = module.networking.vpc_id
  subnet_ids = module.networking.private_subnet_ids
  tags       = local.common_tags
}

module "database" {
  source = "../../modules/database"

  subnet_ids         = module.networking.private_subnet_ids
  app_security_group = module.compute.security_group_id
  tags               = local.common_tags
}
```

Terraform resolves the dependency graph automatically — no explicit `depends_on` needed when using module outputs as inputs.

---

## Module Internal Structure Best Practices

### Use a `versions.tf` for provider requirements

```hcl
# modules/compute/versions.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0, < 6.0"
    }
  }
  required_version = ">= 1.5.0"
}
```

Modules declare **required** versions; the root config pins the **exact** version via `version = "~> 5.x"`.

### Use `for_each` for multi-instance resources

```hcl
variable "subnets" {
  description = "Map of subnet name → CIDR block"
  type        = map(string)
  default = {
    "public-a"  = "10.0.1.0/24"
    "private-a" = "10.0.2.0/24"
  }
}

resource "aws_subnet" "this" {
  for_each          = var.subnets
  vpc_id            = var.vpc_id
  cidr_block        = each.value
  availability_zone = "${var.region}a"

  tags = merge(var.tags, { Name = each.key })
}

output "subnet_ids" {
  value = { for k, s in aws_subnet.this : k => s.id }
}
```

### Refactoring with `moved` blocks

When renaming a resource inside a module, add a `moved` block instead of manually running `terraform state mv`:

```hcl
# modules/compute/main.tf
moved {
  from = aws_instance.server
  to   = aws_instance.this
}

resource "aws_instance" "this" {
  # ...
}
```

---

## Anti-Patterns to Avoid

- **Mega-modules** — If a module has 30+ resources across unrelated services, split it.
- **Hardcoded environment logic inside modules** — Don't `if var.env == "prod"` inside a module. The caller decides.
- **Modules that output everything** — Only expose what callers actually need.
- **Nested modules deeper than 2 levels** — `root → module → submodule` is the practical limit. Deeper = hard to debug.
- **Using `count` for optional resources** — Use `for_each = var.create ? toset(["this"]) : toset([])` or a boolean `count = var.create ? 1 : 0` consistently.
