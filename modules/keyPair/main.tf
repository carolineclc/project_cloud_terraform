resource "aws_key_pair" "key_pair" {
  key_name   = "nome-da-chave"
  public_key = file("./../nome-da-chave.pub")
}