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
coupled with graphviz it becomes a dependency visualization graph
<!-- tf graph | dot -Tpdf graph-plan.pdf -->
we can pipe tf graph output into the graphviz program and produce an pdf visual