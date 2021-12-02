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

## Variables
Input variables are like function arguments.
Parameters for a Terraform modules
Declare variables in the root module

*note: Terraform include environment variables (set by the shell where Terraform runs) 
and expression variables (used to indirectly represent a value in an expression).

variable "ext_port" {}

## Environmental variables
To export an variable, like above, we call "export TF_VAR_ext_port=1880",
you must specify a value when exporting, must start with TF_VAR

to remove it: "unset TF_VAR_ext_port"

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

## tf refresh and output may not reflect actual deployments
resource "docker_container" "nodered_container" {
  name  = join("-", ["nodereeeeeed", random_string.random[count.index].result])
  image = docker_image.nodered_image.latest
}
notice the extra e's added into the resource name after a initial "tf apply"
if we do a tf refresh, the <b>output is changes to nodereeeeeed-<random string></b>

BUT if we do a "docker ps",  nodered-<random string> is still using the name nodered 
without extra e's

*be careful while using "tf refresh", not all deployments are reflected in the outputs

## state rm
scenario: someone deleted the docker pod forcefully but not in the main.tf file, now your 
state file is out of sync with the actual deployments
pod1: nodered-<random_string.random[0]>
pod2: nodered-<random_string.random[1]>

we can update our state list using "tf refresh" command
but our outputs will still contain the second random_string resource (random_string.random[1])

In this case, we can do: "tf state rm random_string.random[1]" to remove the resource 
from our state file.

*note, we are doing this instead of an tf apply to avoid reapplying/removing our pod1

** state rm should ONLY be used in an emergency or something seriously wrong with the deployments

## Variable Validation
making sure a variable value is exactly what we want. ie. int_port of nodered should be 1880

## Hiding variable values inside *.tfvars
*.tfvars should be in a .gitignore file

## Selecting vars files during a tf apply
ie. using different .tfvars for different regions
"tf plan --var-files west.tfvars" will give you a different ext_port value