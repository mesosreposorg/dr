############### VPC Creation ##############
resource "aws_vpc" "myvpc"{
cidr_block = "172.31.0.0/16"
tags ={
Name = "myvpc"
}
}

resource "aws_internet_gateway" "myigw"{
vpc_id = "${aws_vpc.myvpc.id}"
tags={
Name = "myigw"
}
}

resource "aws_nat_gateway" "myngw" {
  allocation_id = "${aws_eip.ngweip.id}"
  subnet_id     = "${aws_subnet.lbsubnet.id}"
  tags = {
    Name = "myngw"
  }
}

resource "aws_eip" "ngweip"{
vpc = true
}
############################################ Public Subnets ###############################3
resource "aws_subnet" "lbsubnet"{
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "172.31.1.0/24"
#availability_zone = "${element(split(",", var.azs_lst), count.index)}"
tags={
Name = "lbsubnet"
}
}

resource "aws_route_table" "publicrtb"{
vpc_id = "${aws_vpc.myvpc.id}"
tags = {
Name = "publicrtb"
}
}

resource "aws_route" "publicrt"{
route_table_id = "${aws_route_table.publicrtb.id}"
destination_cidr_block = "0.0.0.0/0"
gateway_id = "${aws_internet_gateway.myigw.id}"
}
 
resource "aws_route_table_association" "publicrtba"{
route_table_id = "${aws_route_table.publicrtb.id}"
subnet_id = "${aws_subnet.lbsubnet.id}"
}

############################################ Private Subnets ###############################3


resource "aws_subnet" "appsubnet"{
vpc_id = "${aws_vpc.myvpc.id}"
cidr_block = "172.31.2.0/24"
#availability_zone = "${element(split(",", var.azs_lst), count.index)}"
tags={
Name = "appsubnet"
}
}

resource "aws_route_table" "privatertb"{
vpc_id = "${aws_vpc.myvpc.id}"
tags = {
Name = "privatertb"
}
}

resource "aws_route" "privatert"{
route_table_id = "${aws_route_table.privatertb.id}"
destination_cidr_block = "0.0.0.0/0"
nat_gateway_id = "${aws_nat_gateway.myngw.id}"
}


resource "aws_route_table_association" "privatertba"{
route_table_id = "${aws_route_table.privatertb.id}"
subnet_id = "${aws_subnet.appsubnet.id}"
}
