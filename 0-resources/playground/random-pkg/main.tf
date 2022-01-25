
resource "random_id" "asd" {
    byte_length = 2
}

output "asd" {
    value = random_id.asd.
    
}