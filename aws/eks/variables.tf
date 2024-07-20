/*
 * # AWS EKS Module 💡
 * Description
 * ============
 * This tf file provides eks with mostly use k8s resources TF Modules <br>
 * ***Author***: Alfred Valderrama (@redopsbay) <br>
*/

/* Required Variables */
variable "k8s_name" {
  type        = string
  description = "Define the eks cluster name"
}

variable "cluster_version" {
  type        = string
  description = "Define the AWS EKS Cluster version"
}


variable "vpc" {
  type = map(object({
    id            = string
    subnet_ids    = list(string)
    cp_subnet_ids = list(string)
  }))
  description = "VPC Configuration values"
}

variable "worker_nodes" {
  type = list(object({
    min_size       = number
    max_size       = number
    desired_size   = number
    instance_types = list(string)
    capacity_type  = string
  }))
  description = "Worker nodes configuration values"
}

variable "creator_admin" {
  type        = bool
  default     = true
  description = "If creator should be created as eks admin"
}

variable "access_entries" {
  type = list(object({
    kubernetes_groups = list(string)
    principal_arn     = string
    policy_associations = list(object({
      policy_arn   = string
      access_scope = list(string)
      type         = string
    }))
  }))
  default     = null
  description = "access entries"
}

variable "create_access_entry" {
  type        = bool
  default     = false
  description = "If true, create access entry."
}

variable "auth_mode" {
  type        = string
  default     = "API_AND_CONFIG_MAP"
  description = "Authentication mode to set either IAM auth or configmap or both."
}

variable "cloudwatch_enabled" {
  type        = bool
  default     = false
  description = "if cloudwatch must be enabled"
}

variable "cloudwatch" {
  type = object({
    class     = string
    kms_id    = string
    retention = number
    tags      = map(string)

  })
  description = "cloudwatch definition"
  default = {
    class     = "STANDARD"
    kms_id    = null
    retention = 90
    tags      = null
  }
}

# variable "auth_configmap" {
#   type        = bool
#   description = "If auth configmap should be configured."
#   default     = true
# }

# variable "auth_configmap_roles" {
#   type = list(object({
#     role_arn = string
#     username = string
#     groups   = string
#   }))
#   default     = null
#   description = "List of object containing configmap roles. Required: if `auth_configmap` is set to true"
# }

# variable "auth_configmap_users" {
#   type = list(object({
#     user_arn = string
#     username = string
#     groups   = string
#   }))
#   default     = null
#   description = "List of object containing configmap users. Required: if `auth_configmap` is set to true"
# }

variable "k8s_version" {
  type        = string
  default     = "1.29"
  description = "Kubernetes Version"
}

variable "is_api_public" {
  type        = bool
  default     = true
  description = "If API Server will be exposed publicly."
}

# variable "configmap_aws_accounts" {
#   type        = list(string)
#   description = "List of account maps to add to the aws-auth configmap"
# }

variable "k8s_tags" {
  type        = map(any)
  description = "Map of AWS resource tags"
  default = {
    "Provisioner" = "redopsbay"
    "Custodian"   = "redopsbay"
  }
}