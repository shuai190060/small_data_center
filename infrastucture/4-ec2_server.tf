resource "aws_key_pair" "ansible_ec2" {
  key_name   = "ansible_ec2"
  public_key = file("~/.ssh/ansible.pub")

}

//haproxy server
resource "aws_instance" "load_balancer_node" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.load_balancer_server.id]
  associate_public_ip_address = true

  #   source_dest_check = false # for calico



  key_name = "ansible_ec2"
  #   iam_instance_profile = 

  tags = {
    Name = "master_node"
  }
}


resource "aws_instance" "pgbouncer_server" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.pgbouncer_sg.id]
  associate_public_ip_address = true


  key_name = "ansible_ec2"
  #   iam_instance_profile = 

  tags = {
    Name = "pgbouncer_server"
  }
}

resource "aws_instance" "primary_server" {
  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_1.id
  vpc_security_group_ids      = [aws_security_group.server_node_sg.id]
  associate_public_ip_address = true


  key_name = "ansible_ec2"
  #   iam_instance_profile = 

  tags = {
    Name = "primary_server"
  }
}





variable "instances" {
  description = "Map of instances with their details"
  type        = map(any)
  default = {
    server_1 = {
      name   = "server_1"
    }
    server_2 = {
      name   = "server_2"
    }
  }
}

locals {
  subnets = {
    server_1 = aws_subnet.public_1.id
    server_2 = aws_subnet.public_2.id
  }
}

resource "aws_instance" "server" {
  for_each = var.instances

  ami                         = "ami-053b0d53c279acc90"
  instance_type               = "t2.micro"
  subnet_id                   = local.subnets[each.key]
  vpc_security_group_ids      = [aws_security_group.server_node_sg.id]
  associate_public_ip_address = true
  key_name                    = "ansible_ec2"
  tags                        = { Name = each.value.name }
}




output "load_balancer_node" {
  value = aws_instance.load_balancer_node.public_ip
}

output "load_balancer_private" {
  value = aws_instance.load_balancer_node.private_ip
}

output "primary_server" {
  value = aws_instance.primary_server.public_ip
}

output "pgbouncer_public" {
  value = aws_instance.pgbouncer_server.public_ip

}

output "pgbouncer_private" {
  value = aws_instance.pgbouncer_server.private_ip

}

output "server_ips" {
  value       = { for inst in aws_instance.server : inst.tags["Name"] => { public_ip = inst.public_ip, private_ip = inst.private_ip } }
  description = "Public and Private IP addresses of the servers"
}


