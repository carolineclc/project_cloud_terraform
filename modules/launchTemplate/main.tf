#USER DATA vai ser uma api de megadados externa 

resource "aws_launch_template" "launch_template" {
  name_prefix                 = "my-launch-template"
  image_id                    = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.key_pair_name
  user_data = base64encode(templatefile("user_data.tftpl", {db_host=var.rds_instance_address, db_name = var.db_name, db_username = var.db_username, db_password = var.db_password}))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "my-launch-template"
    }
  }

  network_interfaces {
    associate_public_ip_address = true
    subnet_id                   = var.vpc_public_subnets
    security_groups             = var.instance_security_group
  }
}