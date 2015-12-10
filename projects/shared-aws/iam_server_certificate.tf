resource "aws_iam_server_certificate" "example" {
  name = "example_cert"
  certificate_body = "${file("certs/example.crt")}"
  private_key = "${file("certs/example.key")}"

//  provisioner "local-exec" {
//    command = <<EOF
//      echo # Sleep 10 secends so that mycert is propagated by aws iam service
//      echo # See https://github.com/hashicorp/terraform/issues/2499 (terraform ~v0.6.1)
//      sleep 10
//EOF
//  }
}
