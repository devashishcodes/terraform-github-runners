# ---------- Security Group for GitHub Runners ----------
resource "aws_security_group" "runner_sg" {
  name        = "github-runner-sg"
  description = "Security group for GitHub self-hosted runners"
  vpc_id      = aws_vpc.main.id

  # Inbound: kuch nahi (SSH band, SSM use karenge)

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "github-runner-sg"
  }
}