variable "Region" {
	default ="us-east-1"
}
variable "AWSNATAMI" {
    default = "ami-54cf5c3d"
}

variable "KeyName" {
	default =""
}
variable "VPC" {
	default =""
}
variable "VpcCidr" {
	default ="10.0.0.0/16"
}
variable "PublicSubnet1" {
	default =""
}
variable "PublicSubnet2" {
	default =""
}
variable "PrivateRouteTable1" {
	default =""
}
variable "PrivateRouteTable2" {
	default =""
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