# ---------- IAM Role for EC2 Runners ----------
resource "aws_iam_role" "runner_role" {
  name = "github-runner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "github-runner-role"
  }
}

# SSM access (SSH ki jagah browser/CLI se connect karne ke liye)
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.runner_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ---------- Instance Profile ----------
resource "aws_iam_instance_profile" "runner_profile" {
  name = "github-runner-profile"
  role = aws_iam_role.runner_role.name
}