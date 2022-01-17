# Deployment on AWS

[What we are building](../0-resources/AWS-3-tier-infra.png) 

<!--https://rancher.com/docs/k3s/latest/en/-->
1. Rancher K3s: lighter version of K8
2. 1 K3s control plane + 1 K3s node for master master replication
3. 2 K3s => connected to an ALB 
4. K3s nodes are in the public subnet because we want to avoid provisioning an NAT GW, but private sn is best practice
5. K3s allows for mySQL or postgresSQL which means we can use Amazon RDS
6. Amazon RDS instance in the private sn
7. Amazon RDS accessable through private route table
8. we also have an public route table deployed with TF techs: Dynamic Blocks, for Each etc.
9. VPC and IGW for internet traffic
10. "remote" ? provisioners for copying k3s.yaml files from the local machine (cloud9 node workspace machine) to k3s control node


## Using Terraform cloud to monitor state setup
1. have an TF account, create an organization
2. copy CLI-driven runs config into working dir, paste it in a tf file (backend.tf)
3. in cli: <tf login> and login with api
4.  In the tf organization general settings page, change from remote to local
    a. Your plans and applies occur on machines you control. Terraform Cloud is only used to store and synchronize state.
5. setup providers and region

## Setting up a AWS VPC
<!--https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc-->



