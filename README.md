# Terraform Course



## Commands

<!--Initialize-->
terraform init

<!--Plan and Apply-->
terraform plan
terraform apply

<!--Formating-->
terraform fmt

<!--Listing resources-->
<!--*we are using a jq terminal package for json fmt-->
<!--shows the tfstate file in the terminal-->
tf show -json | jq
<!--Shows resources provisioned, ie. docker container -->
tf state list

## Functions
join("-", [thing1, thing2])
<!--outputs: thing1-thing2-->

## Providers
<!--using providers we can provision resources with UIDs for multi pod docker deployments-->
resource "random_string" "random" {
  length           = 16
  special          = true
  override_special = "/@£$"
}

<!--splat gets all containers created with count-->
docker_container.nodered_container[*].name

## Replacing degraded/damaged resources
terraform apply -replace="aws_instance.example[0]"

##  Handling unlocked state-lock file error 

Cause: unlocked state(tf state-lock:false) when tf apply causing a corrupted state from
       multi applies in different consoles
Issue: having 2 running docker containers while only one container shows up in state, can't remove
Solution: Manually import the running docker container

resource "docker_container" "nodered_container2" {
  name = "nodered-<randomly generated string>"
  image = docker_image.nodered_image.latest
}

lastly, run this command:
<!--The command might be outdated but the idea is to import the docker container manually-->
terraform import docker_conatiner.foo $(docker inspect -f {{.ID}} foo)
