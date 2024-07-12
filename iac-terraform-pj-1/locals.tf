# --- root/locals.tf ---
locals {
  security_groups = {
    public = {
      name        = "pj-cd-acloud-${module.networking.project_name}-${module.networking.env}-alb-sg"
      description = "Security Group for Public Access"
      ingress = {
        http = {
          description = "Security Group used to Application"
          from        = 80
          to          = 80
          protocol    = "tcp"
          cidr_blocks = ["95.136.98.85/32"]
        }
        https = {
          from        = 443
          to          = 443
          protocol    = "tcp"
          cidr_blocks = ["95.136.98.85/32"]
        }
      }
    }
  }
}