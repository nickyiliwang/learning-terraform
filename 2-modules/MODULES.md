# Modules
This is a continuation from learning the basics of terraform, we have configured an docker image for deploy (nodered), with dynamic outputs, tfvars for secrets (ext_port), and modular template with count, and workspaces for different deployment environments.

[Project Overview](../0-resources/module-project-overview.png)

## Basic module
created /image and init with main.tf files for deployment

Replacing docker image block with module block resource, and reference the image in our module folder (/image)

## Module variables
Pass in variables from root module into child module for consumption
*child modules should be touched as infrequently as possible

### Variable flow from root => /image
root-variables => root-main ("image_in") => used by image-variables => ref by image-main ("name = var.image-in")

## Terraform Graph
Diagnostic tool
<!--sudo apt install graphviz-->
1. coupled with graphviz it becomes a dependency visualization graph

<!-- tf graph | dot -Tpdf graph-plan.pdf -->

2. we can pipe tf graph output into the graphviz program and produce an pdf visual

<!-- tf graph --type=destroy | dot -Tpdf > graph-plan-destroyed.pdf
 -->
3. we can output planned destroyed resources for the next tf plan, there are other --type flags we can use

## implicit vs. explicit dependencies
In this template we need the noderedvol volume to done creating before we can move files into it and use it in a docker container.

### implicitly 
by stating the noderedvol id in the join funciton in the docker_container resource name, we are telling the container resource to wait for the noderedvol finish creating. Implicitly.

### explicity
<!--depends_on = [null_resource.dockervolume]-->
by using the depends_on property within docker_container resource

## removing null_resource
by reomving null-resource (and the depends_on in the container module root main.tf file).
we are moving the volume provisioned to store nodered data into the container module
In this case:
1. Volume is tightly coupled with the container 
    a. Volume destroys with its container
2. Less typing and extra scripts

## why do we need a docker_volume resource
When we stop using null-resources as a nodered volume
and placed it in the container module
like such:
 volumes {
    container_path = var.vol_container_path_in
    // replaces host_path
    volume_name = "${var.name_in}-volume"
  }

Issue:
Even when we do a tf destroy command, 
if we do: docker volume ls
the volumes are not destoyed with the container
this is unintended behavior

Solution:
We use docker_volume resource instead
Use meta-arguments => lifecycles

## for_each
for_each uses the value of the map instead of an index
which makes deployment outputs much more readable and identifiable

## Container volume backup with the self object
<!--https://www.terraform.io/language/resources/provisioners/syntax#the-self-object-->
<!--https://www.howtogeek.com/248780/how-to-compress-and-extract-files-using-the-tar-command-on-linux/-->
<!--https://registry.terraform.io/providers/kreuzwerker/docker/latest/docs/resources/volume#read-only-->
<!--reference to the self.mountpoint-->
this tar command gips the volumes mountpoint and moves it into the backup folder
command = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"

## Why this echo didn't work
Error:
│     ├────────────────
│     │ count.index is 2
│     │ self.ports is list of object with 1 element

 provisioner "local-exec" {
    command = "echo ${self.name}: ${self.ip_address}:${self.ports[count.index]["external"]} >> containers.txt"
    on_failure = fail
  }
  
Solution:
join fn + for loop for each external port
"<same as above>${join("", [for x in self.ports[*]["external"] : x])} >> containers.txt"

## Dynamic blocks
<!--https://www.terraform.io/language/expressions/dynamic-blocks-->
Usecase here:
1. grafana has multiple container_paths we want to expose
2. ie. /etc/grafana
3. we can only expose on path right now, ref: locals.tf

## inspecting multiple docker volumes
docker inspect $(docker ps -a -q) | grep volume

## Volume nesting
Why:
1. When we provision multiple grafana containers with 2 volumes each
2. One set of volumes exits prematuresly
3. 2 docker containers should have 4 volumes, 2 each

module nesting

## Locals
<!--https://learn.hashicorp.com/tutorials/terraform/locals?in=terraform/configuration-language-->
1. Locals don't change values during or between Terraform runs such as plan, apply, or destroy. 
2. You can use locals to give a name to the result of any Terraform expression, and re-use that name throughout your configuration. 
3. Unlike input variables, locals are not set directly by users of your configuration.