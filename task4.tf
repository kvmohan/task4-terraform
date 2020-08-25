provider "aws" {
  region     = "ap-south-1"
}

//key-pair

resource "tls_private_key" "taskkey" {
 algorithm = "RSA"
 rsa_bits = 4096
}
resource "aws_key_pair" "key" {
 key_name = "task4key"
 public_key = "${tls_private_key.taskkey.public_key_openssh}"
 depends_on = [
    tls_private_key.taskkey
]
}
resource "local_file" "key1" {
 content = "${tls_private_key.taskkey.private_key_pem}"
 filename = "task4key.pem"
  depends_on = [
    aws_key_pair.key
   ]
}

//network.tf

resource "aws_vpc" "task4" {
   cidr_block = "192.168.0.0/16"
   enable_dns_hostnames = true
   enable_dns_support = true
   tags ={
     Name = "vpc_task4"
   }
 }

resource "aws_subnet" "private" {
   vpc_id = "${aws_vpc.task4.id}"
   cidr_block = "192.168.1.0/24"
   availability_zone = "ap-south-1b"
 }
resource "null_resource" "nulllocal1"  {
depends_on = [
    aws_vpc.task4,
	aws_subnet.public,
  ]
 }

resource "aws_subnet" "public" {
   vpc_id = "${aws_vpc.task4.id}"
   map_public_ip_on_launch = "true"
   cidr_block = "192.168.0.0/24"
   availability_zone = "ap-south-1a"
 }
resource "null_resource" "nulllocal2"  {
depends_on = [
    aws_vpc.task4,
  ]
 }

resource "aws_eip" "example" {
  vpc = true
}

resource "aws_nat_gateway" "gw" {
  allocation_id = "${aws_eip.example.id}"
  subnet_id     = "${aws_subnet.public.id}"
}
resource "null_resource" "nulllocal3"  {
depends_on = [
    aws_eip.example,
  ]
 }

resource "aws_eip_association" "eip_assoc" {
  network_interface_id = "${aws_nat_gateway.gw.id}"
  allocation_id = "${aws_eip.example.id}"
}
resource "null_resource" "nulllocal4"  {
depends_on = [
    aws_nat_gateway.gw,
  ]
 }

resource "aws_route_table" "route-table-bastion" {
  vpc_id = "${aws_vpc.task4.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_nat_gateway.gw.id}"
  }
tags ={
    Name = "nat-gateway-route-table"
  }
}
resource "null_resource" "nulllocal5"  {
depends_on = [
    aws_eip_association.eip_assoc,
  ]
 }

resource "aws_route_table_association" "subnet-private-association" {
  subnet_id      = "${aws_subnet.private.id}"
  route_table_id = "${aws_route_table.route-table-bastion.id}"
}
resource "null_resource" "nulllocal6"  {
depends_on = [
    aws_route_table.route-table-bastion,
 ]
}

//security-group

resource "aws_security_group" "public-sg" {
  vpc_id = "${aws_vpc.task4.id}"
  name        = "task4-sg"
  ingress {
    description = "TCP"
    from_port   = 80	
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  ingress {
     description = "SSH"
     from_port   = 22	
     to_port     = 22
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
}
  egress {
     from_port   = 0	
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}  
  tags = {
    Name = "task4-sg"
  }
}
resource "null_resource" "nulllocal7"  {
depends_on = [
    aws_vpc.task4,
 ]
}

resource "aws_security_group" "private-sg" {
  vpc_id = "${aws_vpc.task4.id}"
  name        = "task4-sgp"
 ingress {
    description = "TCP"
    from_port   = 3306	
    to_port     = 3306
    protocol    = "tcp"
    security_groups = ["${aws_security_group.public-sg.id}","${aws_security_group.ssh.id}"]
}
  egress {
     from_port   = 0	
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}  
  tags = {
    Name = "task4-sgp"
  }
}
resource "null_resource" "nulllocal8"  {
depends_on = [
    aws_vpc.task4,
    aws_security_group.ssh,
	aws_security_group.public-sg,
  ]
}

resource "aws_security_group" "ssh" {
  vpc_id = "${aws_vpc.task4.id}"
  name        = "task4ssh"
 ingress {
    description = "TCP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
}
  egress {
     from_port   = 0	
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]
}  
  tags = {
    Name = "task4ssh"
  }
}
resource "null_resource" "nulllocal9"  {
depends_on = [
    aws_vpc.task4,
  ]
}

resource "aws_internet_gateway" "test-env-gw" {
  vpc_id = "${aws_vpc.task4.id}"
tags ={
    Name = "test-env-gw"
  }
}
resource "null_resource" "nulllocal10"  {
depends_on = [
    aws_vpc.task4,
  ]
}

resource "aws_route_table" "route-table-test-env" {
  vpc_id = "${aws_vpc.task4.id}"
route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.test-env-gw.id}"
  }
tags ={
    Name = "test-env-route-table"
  }
}
resource "null_resource" "nulllocal11"  {
depends_on = [
    aws_internet_gateway.test-env-gw,
  ]
}

resource "aws_route_table_association" "subnet-association" {
  subnet_id      = "${aws_subnet.public.id}"
  route_table_id = "${aws_route_table.route-table-test-env.id}"
}
resource "null_resource" "nulllocal12"  {
depends_on = [
    aws_route_table.route-table-test-env,
    aws_internet_gateway.test-env-gw,
	aws_subnet.public,
	]
}

resource "aws_instance" "word" {
  ami           = "ami-000cbce3e1b899ebd"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.public-sg.id}"]
  key_name = "task4key"
tags ={
    Name = "wordpress"
  }
}
resource "null_resource" "nulllocal13"  {
depends_on = [
    aws_route_table_association.subnet-association,
	local_file.key1,
  ]
}

resource "aws_instance" "bastion" {
  ami           = "ami-0732b62d310b80e97"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.public.id}"
  vpc_security_group_ids = ["${aws_security_group.ssh.id}"]
  key_name = "task4key"
tags ={
    Name = "bastion"
  }
}
resource "null_resource" "nulllocal14"  {
depends_on = [
    local_file.key1,
	aws_route_table_association.subnet-private-association,
  ]
}

resource "aws_instance" "mysql" {
  ami           = "ami-08706cb5f68222d09"
  instance_type = "t2.micro"
  subnet_id = "${aws_subnet.private.id}"
  vpc_security_group_ids = ["${aws_security_group.private-sg.id}","${aws_security_group.ssh.id}"]
  key_name = "task4key"
tags ={
    Name = "mysql"
  }
}

resource "null_resource" "nulllocal15"  {
depends_on = [
    aws_route_table_association.subnet-association,
	local_file.key1,
  ]
}

resource "null_resource" "nulllocal16"  {
	provisioner "local-exec" {
	    command = "chrome  ${aws_instance.word.public_ip}"
  	}
}
resource "null_resource" "nulllocal17"  {
depends_on = [
    aws_instance.word,
	aws_instance.bastion,
	aws_instance.mysql,
  ]
}
