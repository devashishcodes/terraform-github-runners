terraform {
  backend "s3" {
    bucket       = "devashish-tfstate-2026"
    key          = "github-runners/terraform.tfstate"
    region       = "ap-south-1"
    use_lockfile = true
    encrypt      = true
  }
}