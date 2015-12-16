variable "Region" {
	default ="us-east-1"
}
variable "AWSNATAMI" {
    default = "ami-54cf5c3d"
}

variable "KeyName" {
	default ="jameel_nv"
}
variable "VPC" {
	default ="vpc-b86ef7dc"
}
variable "VpcCidr" {
	default ="10.0.0.0/16"
}
variable "PublicSubnet1" {
	default ="subnet-825947a9"
}
variable "PublicSubnet2" {
	default ="subnet-06b27870"
}
variable "PrivateRouteTable1" {
	default ="rtb-4e58092a"
}
variable "PrivateRouteTable2" {
	default ="rtb-4f58092b"
}
variable "NATNodeInstanceType" {
	default ="m1.small"
}
variable "NumberOfPings" {
	default ="3"
}
variable "PingTimeout" {
	default ="1"
}
variable "WaitBetweenPings" {
	default ="2"
}
variable "WaitForInstanceStop" {
	default ="60"
}
variable "WaitForInstanceStart" {
	default ="300"
}