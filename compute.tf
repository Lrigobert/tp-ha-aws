data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_launch_template" "pritunl" {
  name_prefix   = "tp-ha-pritunl-"
  image_id      = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = "tp-ec2-key" # On réutilise la clé créée précédemment

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    sudo apt-get update
    sudo apt-get install -y gnupg wget apt-transport-https

    # Pritunl GPG Key (Corrected)
    sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7AE645C0CF8E292A
    echo "deb http://repo.pritunl.com/stable/apt jammy main" | sudo tee /etc/apt/sources.list.d/pritunl.list

    # MongoDB 6.0 GPG Key
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

    sudo apt-get update
    sudo apt-get install -y mongodb-org pritunl

    sudo systemctl start mongod pritunl
    sudo systemctl enable mongod pritunl
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "Pritunl-HA" }
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity    = 2
  max_size            = 4
  min_size            = 2
  target_group_arns   = [aws_lb_target_group.alb_tg.arn]
  vpc_zone_identifier = aws_subnet.private[*].id

  launch_template {
    id      = aws_launch_template.pritunl.id
    version = "$Latest"
  }
}
