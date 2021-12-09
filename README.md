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

*function calls are not allowed in variables

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

## Using Input Variables during apply
terraform apply -var="image_id=ami-abc123"

## Using Sensistive flag
<!--Hiding variables from CLIs, ie. CICD with Gitlab, we don't want to leak secrets-->
output "local-ip-plus-external-ports" {
  value       =  <local ip value >
  sensitive = true
}
<!--Using it with variables-->
variable "ext_port" {
  type      = number
  sensitive = true
}

*note that tf-state isn't hiding this information

## Data persistence with Bind mount and Local-exec
*Local-exec provisioner isn't the BEST, Ansible is better, use this as Last resort or unimportant things 

in this example:

<!--We provisioned a null resource and a Local-exec provisioner to store the data from node-red -->
resource "null_resource" "dockervolume" {
  provisioner "local-exec" {
    command = "mkdir noderedvol/ || true && sudo chown -R 1000:1000 noderedvol/"
  }
}

<!--In the container resource we specified where host and data folder is-->
  volumes {
    // host /home/pi/.node-red directory is bound to the container /data directory.
    container_path = "/data"
    host_path = "/home/ubuntu/environment/noderedvol"
  }
  

## Assigning more predictable external ports for multiple pods
We want to have a port for every container provisioned using "count"

1. tfvars ext_port value becomes a list
2. docker_container resource external port change to: var.ext_port[count.index]

## Local Values 
Assigns a name to an expression
Like a function's temporary local varaibles
"Local Values" supports function calls unlike "variable resource"

<!--We want to get the list from our tfvars file -->
locals {
  container_count = length(var.ext_port)
}

## Resource Validation within a list
  validation {
  <!--since it's a list, we are spreading the values and validating against the min/max range-->
    condition     = max(var.ext_port...) <= 65535 &&  min(var.ext_port...) > 0
    error_message = "Must provide valid external port range 0 - 65535."
  }
  
## String interpolation
<!--https://www.terraform.io/docs/configuration-0-11/interpolation.html-->
<!--Using it in a conditional-->
resource "aws_instance" "web" {
  subnet = "${var.env == "production" ? var.prod_subnet : var.dev_subnet}"
}

## Using lookup() to deploy to different environments
<!--https://www.terraform.io/docs/language/functions/lookup.html-->
<!--lookup(map, key, default)-->
lookup({dev="image1", prod = "image2"}, "prod")
OUTPUT "image2"

## TF Workspaces
- Have a different folder for where persistent data like: Terraform state
- Some backend allows multiple states to be associated with a single configuration. 
- The config still has only one backend, but multiple distinct instances of that config
- No need to setup a new backend or changing authentication credentials.

Scenario:
I can deploy and manage my DEV environment and PROD environment separatly
Switching to DEV environment and delpoying/destroying only affects that workspace

<!--Example with S3-->
<!--https://www.terraform.io/docs/language/settings/backends/s3.html-->
Does work with AWS S3
<!--Commands-->
tf workspace new <insert name here>
new, list, show, select, and delete

### Referencing workspaces
If we can ref our workspaces in our script, there's no need for the ENV variable

variable "ENV" {
  type        = string
  description = "environment to deploy to"
  default     = "DEV"
}