data "terraform_remote_state" "remote-state" {
  backend = "s3"
  config {
    bucket     = "tutorialterraformstate"
    key        = "/terraformstate"
    region     = "${var.aws_region}"
  }
}
