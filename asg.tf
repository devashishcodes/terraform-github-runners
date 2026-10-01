# ---------- Latest Amazon Linux 2023 AMI ----------
data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

# ---------- Launch Template ----------
resource "aws_launch_template" "runner_lt" {
  name_prefix   = "github-runner-lt-"
  image_id      = data.aws_ssm_parameter.al2023.value
  instance_type = "t3.micro"

  iam_instance_profile {
    name = aws_iam_instance_profile.runner_profile.name
  }

  vpc_security_group_ids = [aws_security_group.runner_sg.id]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    dnf update -y
    dnf install -y docker git jq libicu
    systemctl enable --now docker

    # GitHub runner install (token baad mein manually ya secret se denge)
    mkdir -p /opt/actions-runner && cd /opt/actions-runner
    curl -o runner.tar.gz -L https://github.com/actions/runner/releases/download/v2.328.0/actions-runner-linux-x64-2.328.0.tar.gz
    tar xzf runner.tar.gz
    echo "Runner downloaded. Registration pending." > /opt/actions-runner/STATUS.txt
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "github-runner"
    }
  }
}

# ---------- Auto Scaling Group ----------
resource "aws_autoscaling_group" "runner_asg" {
  name                = "github-runner-asg"
  min_size            = 1
  max_size            = 2
  desired_capacity    = 1
  vpc_zone_identifier = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  launch_template {
    id      = aws_launch_template.runner_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "github-runner"
    propagate_at_launch = true
  }
}