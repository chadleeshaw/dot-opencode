# Terraform Variables, Locals & Outputs Reference

## Variable Declaration Best Practices

### Always include `description` and `type`

```hcl
# Good
variable "instance_type" {
  description = "EC2 instance type for the web tier"
  type        = string
  default     = "t3.micro"
}

# Bad — no description, untyped
variable "instance_type" {
  default = "t3.micro"
}
```

### Use complex types for structured data

```hcl
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnets" {
  description = "List of subnet CIDR blocks"
  type        = list(string)
}

variable "listeners" {
  description = "ALB listener configurations"
  type = list(object({
    port     = number
    protocol = string
    ssl_policy = optional(string, "ELBSecurityPolicy-TLS13-1-2-2021-06")
  }))
}
```

### Validate inputs at the variable level

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "Must be a valid CIDR block (e.g. 10.0.0.0/16)."
  }
}
```

### Mark sensitive variables

```hcl
variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}
```

Sensitive variables are redacted in `plan` and `apply` output. Pass them via `TF_VAR_db_password` env vars or a secrets manager — never in `.tfvars` committed to VCS.

---

## Locals: Where to Use Them

Locals are computed once and referenced everywhere. They are the primary DRY tool.

```hcl
locals {
  # Derived naming convention
  name_prefix = "${var.project}-${var.environment}"

  # Assembled tag map — define once, use everywhere
  common_tags = merge(var.tags, {
    Project     = var.project
    Environment = var.environment
    Region      = var.region
    ManagedBy   = "terraform"
  })

  # Conditional value
  instance_type = var.environment == "prod" ? "t3.medium" : "t3.micro"

  # Transform a list into a map for for_each
  subnet_map = { for s in var.subnets : s.name => s }
}

resource "aws_instance" "web" {
  instance_type = local.instance_type
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-web" })
}
```

### Use locals, not repeated inline expressions

```hcl
# Bad — repeated expression
resource "aws_s3_bucket" "logs" {
  bucket = "${var.project}-${var.environment}-logs"
  tags   = { Project = var.project, Environment = var.environment }
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${var.project}-${var.environment}-artifacts"
  tags   = { Project = var.project, Environment = var.environment }
}

# Good — defined once in locals
locals {
  name_prefix  = "${var.project}-${var.environment}"
  common_tags  = { Project = var.project, Environment = var.environment }
}

resource "aws_s3_bucket" "logs" {
  bucket = "${local.name_prefix}-logs"
  tags   = local.common_tags
}

resource "aws_s3_bucket" "artifacts" {
  bucket = "${local.name_prefix}-artifacts"
  tags   = local.common_tags
}
```

---

## Outputs: What to Expose and How

### Always include `description`

```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}
```

### Mark sensitive outputs

```hcl
output "connection_string" {
  description = "Database connection string (sensitive)"
  value       = "postgresql://${var.db_user}:${aws_db_instance.this.password}@${aws_db_instance.this.endpoint}/${var.db_name}"
  sensitive   = true
}
```

### Expose structured output for complex modules

```hcl
output "network" {
  description = "Network resource identifiers"
  value = {
    vpc_id             = aws_vpc.this.id
    public_subnet_ids  = [for s in aws_subnet.public : s.id]
    private_subnet_ids = [for s in aws_subnet.private : s.id]
    nat_gateway_ip     = aws_eip.nat.public_ip
  }
}
```

Then in the caller:
```hcl
module.networking.network.vpc_id
module.networking.network.private_subnet_ids
```

---

## Variable Layering Pattern (Multi-Environment)

```
environments/
├── dev/
│   └── terraform.tfvars        # dev-specific overrides
├── prod/
│   └── terraform.tfvars        # prod-specific overrides
└── shared.auto.tfvars          # common values (loaded automatically)
```

```hcl
# shared.auto.tfvars
project = "myapp"
region  = "us-east-1"

# environments/prod/terraform.tfvars
environment   = "prod"
instance_type = "t3.medium"
min_size      = 3
max_size      = 10

# environments/dev/terraform.tfvars
environment   = "dev"
instance_type = "t3.micro"
min_size      = 1
max_size      = 2
```

---

## `optional()` in Object Types (Terraform ≥ 1.3)

```hcl
variable "alb_config" {
  type = object({
    internal        = bool
    certificate_arn = optional(string, null)
    idle_timeout    = optional(number, 60)
  })
}
```

Callers can omit optional fields; Terraform fills in the defaults automatically.
