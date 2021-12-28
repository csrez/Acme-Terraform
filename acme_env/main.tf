
# This main.tf creates acme_env module
## It defines providers for this module, creates public/private subnets, route tables, and sets up the EC2 instances

# Use provider: AWS
provider "aws" {
  region = var.region
  access_key = var.accessKey 
  secret_key = var.secretKey
}

# -------------------------------------------------------------------------------------- #
# Create AWS Virtual Private Cloud
resource "aws_vpc" "module_vpc" {
  cidr_block = var.vpc_cidr_block
  enable_dns_hostnames = true                # enables public-available ec2 hosts to have dns name

  tags = {
      Name="ACME-Excercise-VPC"
  }
}

# -------------------------------------------------------------------------------------- #
# Create Public Subnet 1 in Availability Zone A
resource "aws_subnet" "module_public_subnet_1" {
    cidr_block = var.public_subnet_1_cidr
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}a"        # create in availability zone A

    tags = {
        Name="Public-Subnet-1"
    }
}

# Create Public Subnet 2 in Availability Zone B
resource "aws_subnet" "module_public_subnet_2" {
    cidr_block = var.public_subnet_2_cidr
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}b"        # create in availability zone B

    tags = {
        Name="Public-Subnet-2"
    }
}

# Create Public Subnet 3 in Availability Zone C
resource "aws_subnet" "module_public_subnet_3" {
    cidr_block = var.public_subnet_3_cidr
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}c"        # create in availability zone B

    tags = {
        Name="Public-Subnet-3"
    }
}

# -------------------------------------------------------------------------------------- #
# Create Private Subnet 1 in Availability Zone A
resource "aws_subnet" "module_private_subnet_1" {
    cidr_block = var.private_subnet_1_cidr
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}a"

    tags = {
        Name="Private-Subnet-1"
    }
}

# Create Private Subnet 2 in Availability Zone B
resource "aws_subnet" "module_private_subnet_2" {
    cidr_block = var.private_subnet_2_cidr
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}b"

    tags = {
        Name="Private-Subnet-2"
    }
}

# Create Private Subnet 3 in Availability Zone C
resource "aws_subnet" "module_private_subnet_3" {
    cidr_block = var.private_subnet_3_cidr
    vpc_id = aws_vpc.module_vpc.id
    availability_zone = "${var.region}c"

    tags = {
        Name="Private-Subnet-3"
    }
}

# Create Public Route Table - For Routes in Public Subnets
resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.module_vpc.id

    tags = {
        Name="Public_Route_Table"
    }
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
    vpc_id = aws_vpc.module_vpc.id

    tags = {
        Name="Private_Route_Table"
    }
}

# -------------------------------------------------------------------------------------- #
# Associate Route Tables with Subnets
# Public Route Association - Public Subnet 1
resource "aws_route_table_association" "public-subnet-1-association" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.module_public_subnet_1.id
}

# Public Route Association - Public Subnet 2
resource "aws_route_table_association" "public-subnet-2-association" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.module_public_subnet_2.id
}

# Public Route Association - Public Subnet 3
resource "aws_route_table_association" "public-subnet-3-association" {
    route_table_id = aws_route_table.public_route_table.id
    subnet_id = aws_subnet.module_public_subnet_3.id
}

# Private Route Association - Private Subnet 1
resource "aws_route_table_association" "private-subnet-1-association" {
    route_table_id = aws_route_table.private_route_table.id
    subnet_id = aws_subnet.module_private_subnet_1.id
}

# Private Route Association - Private Subnet 2
resource "aws_route_table_association" "private-subnet-2-association" {
    route_table_id = aws_route_table.private_route_table.id
    subnet_id = aws_subnet.module_private_subnet_2.id
}

# Private Route Association - Private Subnet 3
resource "aws_route_table_association" "private-subnet-3-association" {
    route_table_id = aws_route_table.private_route_table.id
    subnet_id = aws_subnet.module_private_subnet_3.id
}

# -------------------------------------------------------------------------------------- #
#Create Elastic IP Address 
resource "aws_eip" "elastic_ip_for_nat_gw" {
    vpc = true                                      # use for VPC networking = true
    associate_with_private_ip = var.eip_association_address

    tags = {
        Name="ACME-Exercise-EIP"
    }
}

# -------------------------------------------------------------------------------------- #
# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
    allocation_id = aws_eip.elastic_ip_for_nat_gw.id    # bind with elastic ip address
    subnet_id = aws_subnet.module_public_subnet_1.id

    tags = {
        Name="ACME-NAT-GW"
    }
}

# Route table for NAT GW
resource "aws_route" "nat_gateway_route" {
    route_table_id = aws_route_table.private_route_table.id
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
    destination_cidr_block = "0.0.0.0/0"                # must identify allowed destination for NAT GW - allow all
}

# -------------------------------------------------------------------------------------- #
# Create Internet Gateway for Public Routes
resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.module_vpc.id

    tags = {
        Name="ACME-Intenet-Gateway"
    }
}

# Create Route for IGW and
resource "aws_route" "igw_route" {
    route_table_id = aws_route_table.public_route_table.id
    gateway_id = aws_internet_gateway.internet_gateway.id
    destination_cidr_block = "0.0.0.0/0"
}

# --------------------------------- EC2 ----------------------------------------------------- #
# Create EC2 Instances
## AmazonLinux, RedHat, Centos, Debian, Oracle, Bastion (Centos)


resource "aws_instance" "amazon-linux1" {
    ami = "ami-002068ed284fb165b"
    instance_type = var.ec2_instance_type
    key_name = var.ec2_keypair
    security_groups = [aws_security_group.ec2-security-group.id]
    subnet_id = aws_subnet.module_private_subnet_1.id

    user_data = <<-EOF
        #!/bin/bash
        yum install -y mariadb git wget
        amazon-linux-extras install -y nginx1
        yum install -y python3 docker log4j
        yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
        yum install -y ruby
        yum install -y nodejs 
        gems install -y rails
        systemctl start docker
        systemctl enable docker
        systemctl enable httpd
        systemctl start nginx
        systemctl enable nginx
        systemctl start httpd
        # VULNERABLE DOCKER IMAGES
        curl -s -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
        chmod +x /usr/local/sbin/docker-compose
        git clone https://github.com/csrez/vulhub.git /root/vulhub
        docker-compose -f "/root/vulhub/log4j/CVE-2021-44228/docker-compose.yml" up -d
        docker-compose -f "/root/vulhub/log4j/CVE-2017-5645/docker-compose.yml" up -d
    EOF

    tags = {
        Name="Amazon-Linux2"
    }

    # file to install software/configure box
    #user_data = "<file>"
}

resource "aws_instance" "redhat-linux8" {
    ami = "ami-0ba62214afa52bec7"
    instance_type = var.ec2_instance_type
    key_name = var.ec2_keypair
    security_groups = [aws_security_group.ec2-security-group.id]
    subnet_id = aws_subnet.module_private_subnet_1.id
    
    user_data = <<-EOF
        #!/bin/bash
        dnf install -y git
        # VULNERABLE DOCKER IMAGES
        dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
        dnf install docker-ce --nobest -y
        systemctl start docker
        systemctl enable docker
        curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
        chmod +x /usr/local/sbin/docker-compose
        git clone https://github.com/csrez/vulhub.git /root/vulhub
        docker-compose -f "/root/vulhub/weblogic/CVE-2017-10271/docker-compose.yml" up -d
        docker-compose -f "/root/vulhub/tomcat/CVE-2017-12615/docker-compose.yml" up -d
    EOF



    tags = {
        Name="RedHat-Linux8"
    }

    # file to install software/configure box
    #user_data = "<file>"
}

resource "aws_instance" "debian-stretch9" {
    ami = "ami-08d3197b48e755ddb"
    instance_type = var.ec2_instance_type
    key_name = var.ec2_keypair
    security_groups = [aws_security_group.ec2-security-group.id]
    subnet_id = aws_subnet.module_private_subnet_1.id

    user_data = <<-EOF
        #!/bin/bash
        apt install -y git
        apt-get install -y software-properties-common
        # VULNERABLE DOCKER IMAGES
        apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
        apt-get update
        apt-get install -y docker-ce
        systemctl start docker
        systemctl enable docker
        curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
        chmod +x /usr/local/sbin/docker-compose
        git clone https://github.com/csrez/vulhub.git /root/vulhub
        docker-compose -f "/root/vulhub/saltstack/CVE-2020-11651/docker-compose.yml" up -d
    EOF

    tags = {
        Name="Debian-Stretch9"
    }

    # file to install software/configure box
    #user_data = "<file>"
}

resource "aws_instance" "ubunutu-20LTS" {
    ami = "ami-0fb653ca2d3203ac1"
    instance_type = var.ec2_instance_type
    key_name = var.ec2_keypair
    security_groups = [aws_security_group.ec2-security-group.id]
    subnet_id = aws_subnet.module_private_subnet_1.id

    user_data = <<-EOF
        #!/bin/bash
        apt install -y git
        apt-get install -y software-properties-common
        # VULNERABLE DOCKER IMAGES
        apt-get install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
        curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
        add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/debian stretch stable"
        apt-get update
        apt-get install -y docker-ce
        systemctl start docker
        systemctl enable docker
        curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
        chmod +x /usr/local/sbin/docker-compose
        git clone https://github.com/csrez/vulhub.git /root/vulhub
        docker-compose -f "/root/vulhub/openssh/CVE-2018-15473/docker-compose.yml" up -d
        docker-compose -f "/root/vulhub/node/CVE-2017-16082/docker-compose.yml" up -d
    EOF

    tags = {
        Name="Ubuntu-20.04LTS"
    }

    # file to install software/configure box
    #user_data = "<file>"
}

# resource "aws_instance" "oracle-linux7" {
#     ami = "ami-0becfb005e038ca42"
#     instance_type = var.ec2_instance_type
#     key_name = var.ec2_keypair
#     security_groups = [aws_security_group.ec2-security-group.id]
#     subnet_id = aws_subnet.module_private_subnet_1.id

#     user_data = <<-EOF
#         #!/bin/bash
#         yum -y update
#         yum install -y git httpd
#         yum install -y python3 docker
#         yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
#         yum install -y ruby
#         curl -sL https://rpm.nodesource.com/setup_16.x > /usr/local/sbin/my_node.sh
#         chmod +x /usr/local/sbin/my_node.sh
#         my_node.sh
#         yum install -y nodejs 
#         systemctl start docker
#         systemctl enable docker
#         systemctl enable httpd
#         systemctl start httpd  
#         curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
#         chmod +x /usr/local/sbin/docker-compose
#         git clone https://github.com/csrez/vulhub.git /root/vulhub
# 		docker-compose -f "/root/vulhub/openssh/CVE-2018-15473/docker-compose.yml" up -d
#         docker run -dp 5000:5000 varsubham/sample_node
#     EOF

#     tags = {
#         Name="Oracle-Linux7"
#     }

#     # file to install software/configure box
#     #user_data = "<file>"
# }

resource "aws_instance" "centos7" {
    ami = "ami-02cae3195fa1622a8"
    instance_type = "t2.small"
    key_name = var.ec2_keypair
    security_groups = [aws_security_group.ec2-security-group.id]
    subnet_id = aws_subnet.module_private_subnet_1.id

    user_data = <<-EOF
        #!/bin/bash
        yum install -y httpd git
        yum install -y python3 docker
        yum install -y git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
        yum install -y ruby
        curl -sL https://rpm.nodesource.com/setup_16.x > /usr/local/sbin/my_node.sh
        chmod +x /usr/local/sbin/my_node.sh
        my_node.sh
        yum install -y nodejs 
        systemctl start docker
        systemctl enable docker
        systemctl enable httpd
        systemctl start httpd
        curl -L "https://github.com/docker/compose/releases/download/1.24.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/sbin/docker-compose
        chmod +x /usr/local/sbin/docker-compose
        git clone https://github.com/csrez/vulhub.git /root/vulhub
        docker-compose -f "/root/vulhub/spring/CVE-2018-1270/docker-compose.yml" up -d
        docker run -dp 5000:5000 varsubham/sample_node
    EOF

    tags = {
        Name="Centos7"
    }

    # file to install software/configure box
    #user_data = "<file>"
}

resource "aws_instance" "bastion" {
    ami = "ami-02cae3195fa1622a8"
    instance_type = var.ec2_instance_type
    security_groups = [aws_security_group.bastion-sg.id]
    subnet_id = aws_subnet.module_public_subnet_1.id
    associate_public_ip_address = true
    key_name = var.ec2_keypair

    user_data = <<-EOF
        #!/bin/bash
        curl https://raw.githubusercontent.com/csrez/terraform-Acme/main/acme_env/blue-key.pem > /home/centos/.ssh/blue-key.pem
        chown centos:centos /home/centos/blue-key.pem
        chmod 400 ~/blue-key.pem
    EOF

    tags = {
        Name="Bastion"
    }
}

# Create Security Group
resource "aws_security_group" "bastion-sg" {
    name = "Bastion-SG"
    vpc_id = aws_vpc.module_vpc.id

    ingress {
        protocol = "tcp"
        from_port = 22
        to_port = 22
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_security_group" "ec2-security-group" {
    name = "EC2-Instance-SG"
    vpc_id = aws_vpc.module_vpc.id

    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

output "vpc_cidr" {
    value = aws_vpc.module_vpc.cidr_block
}

output "pubilc_subnet_1_cidr" {
    value = aws_subnet.module_public_subnet_1.cidr_block
}

output "private_subnet_1_cidr" {
    value = aws_subnet.module_private_subnet_1.cidr_block
}

output "elastic_ip_NAT_GW" {
    value = aws_eip.elastic_ip_for_nat_gw.public_ip
}

output "bastion_ip" {
    value = aws_instance.bastion.public_ip
}

output "amazon-linux1_ip" {
    value = aws_instance.amazon-linux1.private_ip
}

output "centos7_ip" {
    value = aws_instance.centos7.private_ip
}

output "debian-stretch_ip" {
    value = aws_instance.debian-stretch9.private_ip
}

output "ubuntu-20LTS_ip"{
    value = aws_instance.ubunutu-20LTS.private_ip
}

# output "oracle-linux_ip" {
#     value = aws_instance.oracle-linux7.private_ip
# }

output "redhat-linux_ip" {
    value = aws_instance.redhat-linux8.private_ip
}