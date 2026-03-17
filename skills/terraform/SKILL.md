---
name: terraform
description: >
  Expert Terraform assistance for writing, structuring, and optimizing infrastructure as code.
  Use this skill whenever the user asks about Terraform, HCL, modules, variables, locals,
  outputs, providers, state management, workspaces, data sources, resource dependencies,
  or any terraform CLI commands. Also trigger for questions about structuring a Terraform
  project, separating environments (dev/staging/prod), module composition, variable
  validation, or migrating from flat configs to a modular structure. If the user mentions
  `.tf` files, `terraform.tfvars`, `backend`, `plan`, `apply`, `state`, `remote state`,
  or anything that smells like Terraform infrastructure — use this skill.
---

# Terraform Skill

You are an expert Terraform practitioner. Help the user write, structure, and optimize
Terraform configurations. Always produce idiomatic, production-quality HCL with a focus
on modularity, DRY code, and maintainability.

## Quick Reference: When to Load Reference Files

| Topic | Load |
|---|---|
| Module structure, composition, calling modules | `references/modules.md` |
| Variables, locals, outputs, validation | `references/variables.md` |
| State, backends, workspaces, remote state | `references/state.md` |
| Providers, aliases, version constraints | `references/providers.md` |

Read the relevant reference file before answering complex structural questions.
For simple resource-writing tasks the inline content below is sufficient.

---

## Core Concepts (Inline)

### Canonical Project Layout

```
infra/
├── environments/
│   ├── dev/
│   │   ├── main.tf          # root module: calls child modules
│   │   ├── variables.tf     # input declarations for this env
│   │   ├── outputs.tf       # outputs from this env
│   │   ├── terraform.tfvars # actual values (never secrets)
│   │   └── backend.tf       # remote state config
│   ├── staging/
│   │   └── ...
│   └── prod/
│       └── ...
└── modules/
    ├── networking/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── compute/
    │   ├── main.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── database/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

**Rules:**
- Environments own the root module; modules own reusable logic.
- Never hardcode values in modules — everything is a variable with a sensible default.
- One `terraform.tfvars` per environment, never committed with secrets.
- Always use a remote backend; never rely on local state for team work.

### The Three Files Every Module Must Have

```hcl
# variables.tf  — what the module accepts
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t3.small", "t3.medium"], var.instance_type)
    error_message = "Must be a supported instance type."
  }
}

# main.tf  — resources and data sources
resource "aws_instance" "this" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  tags          = var.tags
}

# outputs.tf  — what the module exposes
output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.this.id
}
```

### Calling a Module from an Environment

```hcl
# environments/prod/main.tf
module "compute" {
  source = "../../modules/compute"

  instance_type = var.instance_type
  vpc_id        = module.networking.vpc_id
  tags          = local.common_tags
}
```

### Locals for DRY Logic

```hcl
locals {
  env  = terraform.workspace
  name = "${var.project}-${local.env}"

  common_tags = {
    Project     = var.project
    Environment = local.env
    ManagedBy   = "terraform"
  }
}
```

Use `locals` to:
- Build compound names (`"${local.name}-web"`)
- Consolidate repeated tag maps
- Compute derived values once instead of inline everywhere

### Variable Precedence (lowest → highest)

| Source | Notes |
|---|---|
| `default` in `variable {}` | Fallback |
| `terraform.tfvars` | Committed, non-secret env values |
| `*.auto.tfvars` | Auto-loaded, use for defaults override |
| `-var-file=foo.tfvars` | CI/CD injection |
| `-var="key=val"` | One-off CLI override |
| `TF_VAR_name` env var | Secrets, CI/CD pipelines |

---

## Output Style Guidelines

- **Always show complete, real `.tf` files** — no pseudocode or abbreviated snippets.
- **Separate concerns into the three canonical files** — `main.tf`, `variables.tf`, `outputs.tf`.
- **Include `description`** on every `variable` and `output` block — it's the in-code documentation.
- **Use `locals` liberally** to avoid duplicating expressions.
- **Never hardcode** region, account ID, or environment names in modules.
- **Always suggest a remote backend** when helping with new projects.
- **Always advise `terraform plan`** before `apply`, especially for destructive changes.
- When designing module structure, read `references/modules.md` first.
- When designing variable/output hierarchy, read `references/variables.md` first.

---

## Common CLI Workflow

```bash
# Initialize (download providers, configure backend)
terraform init

# Format all files consistently
terraform fmt -recursive

# Validate syntax and config
terraform validate

# Preview changes
terraform plan -var-file=environments/prod/terraform.tfvars

# Apply changes
terraform apply -var-file=environments/prod/terraform.tfvars

# Target a single resource
terraform apply -target=module.compute.aws_instance.this

# Destroy environment
terraform destroy -var-file=environments/prod/terraform.tfvars

# State inspection
terraform state list
terraform state show aws_instance.web
terraform output -json

# Workspace management
terraform workspace new staging
terraform workspace select prod
terraform workspace list
```

---

## Gotchas & Best Practices

1. **`count` vs `for_each`** — Prefer `for_each` with a map/set of strings. `count` creates index-based addresses (`aws_instance.this[0]`), so removing an element in the middle forces recreation of everything after it. `for_each` uses stable keys.

2. **Module versioning** — Pin modules from the registry with `version = "~> 5.0"`. Never use `source` without a version in production.

3. **Sensitive outputs** — Mark outputs that contain secrets with `sensitive = true`. They'll be redacted in logs but still accessible via `terraform output -json`.

4. **`depends_on` is a last resort** — Use data source dependencies and resource references to establish implicit dependency ordering. Explicit `depends_on` hides intent and can cause unnecessary re-plans.

5. **Avoid `terraform.tfvars` for secrets** — Use `TF_VAR_*` environment variables or a secrets manager. Never commit secrets to VCS.

6. **State locking** — Use a DynamoDB table (AWS) or equivalent for state locking to prevent concurrent applies corrupting state.

7. **Lifecycle blocks** — Use `prevent_destroy = true` for critical resources (databases, S3 buckets). Use `ignore_changes` sparingly and with a comment explaining why.

8. **One resource type per file is optional** — Grouping related resources (`security_group.tf`, `iam.tf`) is better than everything in `main.tf` once a module grows beyond ~100 lines.

9. **`data` sources are not free** — Every `data` source makes an API call on every plan. Cache results in `locals` if used more than once.

10. **`moved` blocks over state mv** — When refactoring resource addresses, use `moved {}` blocks so the change is tracked in VCS and applied automatically.
