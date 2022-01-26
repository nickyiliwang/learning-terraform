
resource "random_id" "test" {
    byte_length = 2
}

output "asd" {
    value = random_id.test.dec
}