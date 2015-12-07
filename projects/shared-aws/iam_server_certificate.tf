resource "aws_iam_server_certificate" "example" {
  name = "example_cert"
  certificate_body = "${file("certs/example.crt")}"
  private_key = "${file("certs/example.key")}"
}
