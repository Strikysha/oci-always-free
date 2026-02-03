// Copyright (c) 2017, 2023, Oracle and/or its affiliates. All rights reserved.
// Licensed under the Mozilla Public License v2.0

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}


# See https://docs.oracle.com/iaas/images/
data "oci_core_images" "test_images" {
  compartment_id           = var.compartment_ocid
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  # operating_system         = "Oracle Linux"
  # operating_system_version = "8"
  shape      = var.instance_shape
  sort_by    = "TIMECREATED"
  sort_order = "DESC"
}

data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = 1
}

/* Network */

resource "oci_core_vcn" "test_vcn" {
  compartment_id = var.compartment_ocid
  display_name   = "testVCN"
  dns_label      = "testvcn"
  cidr_block     = "10.1.0.0/16"
  is_ipv6enabled = true
}

resource "oci_core_subnet" "test_subnet" {
  compartment_id    = var.compartment_ocid
  display_name      = "testSubnet"
  dns_label         = "testsubnet"
  cidr_block        = "10.1.20.0/24"
  ipv6cidr_block    = cidrsubnet(oci_core_vcn.test_vcn.ipv6cidr_blocks[0], 8, 0)
  security_list_ids = [oci_core_security_list.test_security_list.id]
  vcn_id            = oci_core_vcn.test_vcn.id
  route_table_id    = oci_core_route_table.test_route_table.id
  dhcp_options_id   = oci_core_vcn.test_vcn.default_dhcp_options_id
}

resource "oci_core_internet_gateway" "test_internet_gateway" {
  compartment_id = var.compartment_ocid
  display_name   = "testIG"
  vcn_id         = oci_core_vcn.test_vcn.id
}

resource "oci_core_route_table" "test_route_table" {
  compartment_id = var.compartment_ocid
  display_name   = "testRouteTable"
  vcn_id         = oci_core_vcn.test_vcn.id

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
  }

  route_rules {
    destination       = "::/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.test_internet_gateway.id
    route_type        = "STATIC"
  }
}

resource "oci_core_security_list" "test_security_list" {
  compartment_id = var.compartment_ocid
  display_name   = "testSecurityList"
  vcn_id         = oci_core_vcn.test_vcn.id

  egress_security_rules {
    protocol         = "all"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  egress_security_rules {
    protocol         = "all"
    destination      = "::/0"
    destination_type = "CIDR_BLOCK"
  }

  ingress_security_rules {
    protocol = "6"
    source   = "0.0.0.0/0"
    tcp_options {
      max = "22"
      min = "22"
    }
  }

  ingress_security_rules {
    protocol    = "1"
    source      = "0.0.0.0/0"
    source_type = "CIDR_BLOCK"
    icmp_options {
      code = 4
      type = 3
    }
  }

  ingress_security_rules {
    protocol = "1"
    source   = oci_core_vcn.test_vcn.cidr_block
    icmp_options {
      code = -1
      type = 3
    }
  }
}

/* Instances */

resource "oci_core_instance" "free_instance0" {
  compartment_id      = var.compartment_ocid
  display_name        = "freeInstance0"
  availability_domain = data.oci_identity_availability_domain.ad.name
  shape               = var.instance_shape
  shape_config {
    ocpus         = var.instance_ocpus
    memory_in_gbs = var.instance_shape_config_memory_in_gbs
  }
  create_vnic_details {
    subnet_id        = oci_core_subnet.test_subnet.id
    display_name     = "primaryvnic"
    assign_public_ip = true
    assign_ipv6ip    = true
    hostname_label   = "freeinstance0"
  }
  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaaomylr6kmnysurndo37lzq2x2q5teoyoa3oaruqrzfnnb7h5k45hq"
  }
  metadata = {
    ssh_authorized_keys = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.public_key_openssh
  }
}

resource "tls_private_key" "compute_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

output "generated_private_key_pem" {
  value     = (var.ssh_public_key != "") ? var.ssh_public_key : tls_private_key.compute_ssh_key.private_key_pem
  sensitive = true
}
