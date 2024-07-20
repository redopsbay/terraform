/*
 * # AWS EKS Module 💡
 * Description
 * ============
 * This tf file contains the module configuration of eks cluster. <br>
 * ***Author***: Alfred Valderrama (@redopsbay) <br>
*/

data "aws_caller_identity" "current" {}


module "eks" {
  #checkov:skip=CKV_TF_1:"Ensure Terraform module sources use a commit hash"
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = var.k8s_name
  cluster_version = var.k8s_version

  cluster_endpoint_public_access = var.is_api_public

  ## TODO: cluster_addons = {}

  for_each                 = var.vpc
  vpc_id                   = each.value.id
  subnet_ids               = each.value.subnet_ids
  control_plane_subnet_ids = try(each.value.cp_subnet_ids, each.value.subnet_ids)

  // EKS Managed Node Group(s)
  eks_managed_node_groups = local.eks_nodegroups

  // If eks creator must be set to eks admin

  enable_cluster_creator_admin_permissions = var.creator_admin

  authentication_mode = var.auth_mode

  access_entries = local.access_entry

  create_cloudwatch_log_group = var.cloudwatch_enabled

  cloudwatch_log_group_class             = var.cloudwatch_enabled ? var.cloudwatch.class : null
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_enabled ? var.cloudwatch.kms_id : null
  cloudwatch_log_group_retention_in_days = var.cloudwatch_enabled ? var.cloudwatch.retention : null
  cloudwatch_log_group_tags              = var.cloudwatch_enabled ? var.cloudwatch.tags : null

  # # aws-auth configmap
  # manage_aws_auth_configmap = var.auth_configmap

  # aws_auth_roles = [for i, v in var.auth_configmap_roles : {
  #   role_arn = v.role_arn
  #   username = v.username
  #   groups   = v.groups
  # } if var.auth_configmap == true]

  # aws_auth_users = [for i, v in var.auth_configmap_users : {
  #   user_arn = v.user_arn
  #   username = v.username
  #   groups   = v.groups
  # } if var.auth_configmap == true]

  # aws_auth_accounts = try(var.configmap_aws_accounts, ["${data.aws_caller_identity.current.account_id}"], null)

  tags = var.k8s_tags
}


// TODO: Comment's & Description

locals {

  eks_nodegroups = {
    for i, v in var.worker_nodes : "${var.k8s_name}-worker-${i}" => {
      min_size       = try(v.min_size, 2)
      max_size       = try(v.max_size, 2)
      desired_size   = try(v.desired_size, 2)
      instance_types = try(tolist(v.instance_types), ["t3.medium"])
      capacity_type  = try(v.capacity_type, "SPOT")
    }
  }

  access_entry = var.create_access_entry ? {
    for i, v in var.access_entries : "${var.k8s_name}-access-entries-${i}" => {
      kubernetes_groups = v.kubernetes_groups
      principal_arn     = v.principal_arn
      policy_associations = {
        for k, kv in v.policy_associations : "${var.k8s_name}-policy-assoc-${k}" => {
          policy_arn   = kv.policy_arn
          access_scope = kv.access_scope
          type         = kv.type
        }
      }
    }
  } : {}
}