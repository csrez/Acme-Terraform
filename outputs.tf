output "vpc_cidr" {
    value = module.acme_env.vpc_cidr
}

output "public_subnet_1_cidr" {
    value = module.acme_env.pubilc_subnet_1_cidr
}

output "private_subnet_1_cidr" {
    value = module.acme_env.private_subnet_1_cidr
}

output "elastic_ip_NAT_GW" {
    value = module.acme_env.elastic_ip_NAT_GW
}

output "bastion_ip_address" {
    value = module.acme_env.bastion_ip
}

output "amazon_linux_ip_address" {
    value = module.acme_env.amazon-linux1_ip
}

output "centos7_ip_address" {
    value = module.acme_env.centos7_ip
}

output "debian_stretch_ip_address" {
    value = module.acme_env.debian-stretch_ip
}

output "ubnuntu_20_ip_address" {
    value = module.acme_env.ubuntu-20LTS_ip
}

# output "oracle_linux_ip_address" {
#     value = module.acme_env.oracle-linux_ip
# }

output "redhat_linux_ip_address" {
    value = module.acme_env.redhat-linux_ip
}