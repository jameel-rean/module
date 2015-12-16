provider "aws" {
    
    region = "us-east-1"
}




####################################################
#
# Creating  role with  policy
#
####################################################

resource "aws_iam_instance_profile" "NATRoleProfile" {
    name = "NATRoleProfile"
    roles = ["${aws_iam_role.NATRole.name}"]
}


resource "aws_iam_role_policy" "NAT_Takeover" {
    name = "NAT_Takeover"
    role = "${aws_iam_role.NATRole.id}"
    policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
                        "ec2:DescribeInstances",
                        "ec2:DescribeRouteTables",
                        "ec2:CreateRoute",
                        "ec2:ReplaceRoute",
                        "ec2:StartInstances",
                        "ec2:StopInstances"
                   ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "NATRole" {
    name = "NATRole"
    assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}


####################################################
#
# Creating  EIP with NAT instances
#
####################################################




resource "aws_eip" "NAT1" {
    instance = "${aws_instance.NAT1.id}"
    vpc = true
}

resource "aws_eip" "NAT2" {
    instance = "${aws_instance.NAT2.id}"
    vpc = true
}

resource "template_file" "nat1" {
  filename = "templates/nat1.sh.tpl"
  vars {
    Region = "${var.Region}"
    PrivateRouteTable2 = "${var.PrivateRouteTable2}"
    PrivateRouteTable1 = "${var.PrivateRouteTable1}"
    NumberOfPings = "${var.NumberOfPings}"
    PingTimeout = "${var.PingTimeout}"
    WaitBetweenPings = "${var.WaitBetweenPings}"
    WaitForInstanceStop = "${var.WaitForInstanceStop}"
    PrivateRouteTable1 = "${var.PrivateRouteTable1}"
    WaitForInstanceStart = "${var.WaitForInstanceStart}"
  }
  
}


####################################################
#
# Creating NAT instance1
#
####################################################
resource "aws_instance" "NAT1" {
    ami = "${var.AWSNATAMI}"
	source_dest_check ="false"
    instance_type = "${var.NATNodeInstanceType}"
	subnet_id="${var.PublicSubnet1}"
	associate_public_ip_address="true"
	security_groups=["${aws_security_group.NATSecurityGroup.id}"]
	iam_instance_profile="${aws_iam_instance_profile.NATRoleProfile.id}"
    user_data = "${template_file.nat1.rendered}"
    tags {
        Name = "NAT1"
    }
	key_name = "${var.KeyName}"
}


resource "template_file" "nat2" {
  filename = "templates/nat2.sh.tpl"
  vars {
    NAT1Instance = "${aws_instance.NAT1.id}"
    Region = "${var.Region}"
    PrivateRouteTable2 = "${var.PrivateRouteTable2}"
    PrivateRouteTable1 = "${var.PrivateRouteTable1}"
    NumberOfPings = "${var.NumberOfPings}"
    PingTimeout = "${var.PingTimeout}"
    WaitBetweenPings = "${var.WaitBetweenPings}"
    WaitForInstanceStop = "${var.WaitForInstanceStop}"
    PrivateRouteTable1 = "${var.PrivateRouteTable1}"
    WaitForInstanceStart = "${var.WaitForInstanceStart}"
  }
  
}
####################################################
#
# Creating NAT instance2
#
####################################################
resource "aws_instance" "NAT2" {
    ami = "${var.AWSNATAMI}"
	source_dest_check ="false"
    instance_type = "${var.NATNodeInstanceType}"
	subnet_id="${var.PublicSubnet2.id}"
	associate_public_ip_address="true"
	security_groups=["${aws_security_group.NATSecurityGroup.id}"]
	iam_instance_profile="${aws_iam_instance_profile.NATRoleProfile.id}"
    user_data = "${template_file.nat2.rendered}"
    tags {
        Name = "NAT2"
    }
	key_name = "${var.KeyName}"
}

########################
#Nat SG
########################
resource "aws_security_group" "NATSecurityGroup" {
    name = "NATSecurityGroup"
    vpc_id ="${var.VPC}"
    description = "Allow all inbound traffic"
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["${var.VpcCidr}"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    tags {
        Name = "NATSecurityGroup"
    }
}
