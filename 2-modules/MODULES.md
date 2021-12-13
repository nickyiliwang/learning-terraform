# Modules
This is a continuation from learning the basics of terraform, we have configured an docker image for deploy (nodered), with dynamic outputs, tfvars for secrets (ext_port), and modular template with count, and workspaces for different deployment environments.

[Project Overview](../0-resources/module-project-overview.png)

## Step one
created /image and init with main.tf files for deployment

Replacing docker image block with module block resource, and reference the image in our module folder (/image)
