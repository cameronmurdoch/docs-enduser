provider "openstack" {}

# DNS zone
variable "zone_name" {
   default = "mytestzone.com"
}

# Region in which to create instances
variable "region" {
  default = "bgo"
}

# How many instances to create
variable "node_count" {
  default = "2"
}

# Create instances
resource "openstack_compute_instance_v2" "testserver" {
  region      = var.region
  count       = var.node_count
  name        = "${var.region}-test-${count.index}"
  image_name  = "GOLD CentOS 7"
  flavor_name = "m1.small"

  key_pair = "mykey"
  security_groups = [ "default" ]

  network {
    name = "dualStack"
  }
}

# Find zone info if zone_name is set
data "openstack_dns_zone_v2" "myzone" {
  name = "${var.zone_name}."
}

# Create records for A (IPv4)
resource "openstack_dns_recordset_v2" "a_record" {
  zone_id     = data.openstack_dns_zone_v2.myzone.id
  count       = var.node_count
  name        = "${openstack_compute_instance_v2.testserver[count.index].name}.${var.zone_name}."
  type        = "A"
  records     = [ "${openstack_compute_instance_v2.testserver[count.index].access_ip_v4}" ] 
}

# Create records for AAAA (IPv6)
resource "openstack_dns_recordset_v2" "aaaa_record" {
  zone_id     = data.openstack_dns_zone_v2.myzone.id
  count       = var.node_count
  name        = "${openstack_compute_instance_v2.testserver[count.index].name}.${var.zone_name}."
  type        = "AAAA"
  records     = [ "${openstack_compute_instance_v2.testserver[count.index].access_ip_v6}" ] 
}
