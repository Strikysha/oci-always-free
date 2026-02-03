# Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
# Licensed under the Mozilla Public License v2.0

variable "tenancy_ocid" {
  type        = string
  description = "The OCID of the tenancy."
}

variable "user_ocid" {
  type        = string
  description = "The OCID of the user."
}

variable "fingerprint" {
  type        = string
  description = "The fingerprint of the API key."
}

variable "private_key_path" {
  type        = string
  description = "The path to the private key file."
}

variable "ssh_public_key" {
  type        = string
  description = "The public SSH key to be used for the instances."
  default     = ""
}

variable "compartment_ocid" {
  type        = string
  description = "The OCID of the compartment to create resources in."
}

variable "region" {
  type        = string
  description = "The OCI region to create resources in."
}

variable "instance_shape" {
  type        = string
  description = "The shape of the compute instance."
  default     = "VM.Standard.E2.1.Micro"
}

variable "instance_ocpus" {
  type        = number
  description = "The number of OCPUs for the compute instance."
  default     = 1
}

variable "instance_shape_config_memory_in_gbs" {
  type        = number
  description = "The amount of memory in GBs for the compute instance."
  default     = 1
}
