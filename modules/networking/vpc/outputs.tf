output "myvpc" {
value = "${aws_vpc.myvpc.id}"
}
output "lbsubnet" {
value = "${aws_subnet.lbsubnet.id}"
}
output "appsubnet" {
value = "${aws_subnet.appsubnet.id}"
}
