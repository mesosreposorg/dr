output "websg" {
value = "${aws_security_group.websg.id}"
}
#output "appserver_publicip" {
#value = "${aws_instance.appserver.public_ip}"
#}
#output "dbserver_publicip" {
#value = "${aws_instance.dbserver.public_ip}"
#}
