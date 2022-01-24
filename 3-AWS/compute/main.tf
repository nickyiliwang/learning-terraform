# compute/main.tf

# ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20211129
data "aws_ami" "k3_server_ami" {
    // everything is found on the ec2 console
    most_recent = true
    owners = ["099720109477"]
    
    filter {
    // always get the ami with the latest date 
        name = "name"
        values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
    }
}