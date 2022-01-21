# Deployment on AWS

[What we are building](../0-resources/AWS-3-tier-infra.png) 

## Resource referencing
Most Resources are referenced by id
ie. aws_vpc.my_vpc.id


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

## VPC DNS support provided settings 
Instance launched into the VPC receives a public DNS hostname 
if it is assigned a public IPv4 address or an Elastic IP address at creation. 
If you enable both attributes for a VPC that didn't previously have them both enabled, 
instances that were already launched into that VPC receive public DNS hostnames if they have a public IPv4 address or an Elastic IP address.

Attributes:
enable_dns_hostnames = true
enable_dns_support   = true

## Subnetting
Review for dividing networks
[Sunny's Video](https://www.youtube.com/watch?v=ecCuyq-Wprc) 
[Sunny's table](https://o.quizlet.com/1XQN.GACbk3TWNRitGHrfg.jpg) 
[Subnetting /16](https://www.youtube.com/watch?v=OQ-r_IfeB8c) 
[Practice](https://docs.google.com/spreadsheets/d/1U7h3xOY5FKOsHedjIOsJKQMobHrAHZcW9MCSxRyjVYE/edit#gid=0) 

Example:
1. if you need 3 subnetworks from the ip: 192.168.4.0/24
2. According to the table, we can split it into 4 subnets to satisfy the 3
3. We will have 64 host IDs (uniquely identifies a host on a given TCP/IP network)
4. 64 also includes the network and broadcast id 
5. /26 is the new subnet masks
6. Network id will be divided into [ _0/26, _64/26, _128/26, _192/26]
7. ie. 192.168.4.0/26 => Host ID Range: 192.168.1 - 192.168.4.62, #Hosts: 62, BroadcastID: _63

### Host vs. Network address
Host has a single IP address, and a network has several.
Example:
Host address for one of the servers here in my house is 
192.168. 1.249. It's a single address which is 
part of the network address block based on 192.168.

## cidrsubnet() function 
<!--https://www.terraform.io/language/functions/cidrsubnet-->
cidrsubnet(prefix, newbits, netnum)

newbits is the number of additional bits with which to extend the prefix.

netnum is a whole number that can be represented 
as a binary integer with no more than newbits binary digits, 
which will be used to populate the additional bits added to the prefix.

> cidrsubnet("172.16.0.0/12", 4, 2)
172.18.0.0/16
> cidrsubnet("10.1.2.0/24", 4, 15)
10.1.2.240/28

## subnetting function
[for i in range(1,6,2) : cidrsubnet("10.123.0.0/16", 8, i)]

1. range(min, max-1, increment) => range(1,6,2) => 1 , 3 , 5
2. for loops the max range, and increments on the 3rd octat, + 8 newbits
3. OUTPUTS: [
  "10.123.1.0/24",
  "10.123.3.0/24",
  "10.123.5.0/24",
]

## TF Data Sources - aws_availability_zones
<!--https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones-->
  we can refrence this value in our aws_subnet resource without hardcoding all available zones
  availability_zone = data.aws_availability_zones.available.names[count.index]

## Spread out subnet deployment into AZs with random_shuffle
<!--https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/shuffle-->
resource "random_shuffle" "az" {
  input        = ["us-west-1a", "us-west-1c", "us-west-1d", "us-west-1e"]
  result_count = 2
}

### for_each would also work here
1. In the root main.tf we could have an locals map, mapping the number of 
   public and private subnets we need 


### We could use a for loop and produce a list that's more round robin rather than random
we use a for loop to loop over the number of times we want to repeat this list value (5),
and we only want the values from the result, hence we use values function to get the 
duple and flatten it into an array.

flatten(values({for i in range(5): i => var.az_list}))

[Example](/0-resources/playground/duplicating_an_array_x_times.tf)

## *important default route and default route table
In network/main.tf
we are directing all traffic in the public route table towards the internet gateway for internet
with: resource "aws_route" "default_route" 

The following resource block specifies that the private route table is using the default
route table created when the vpc is created, thus referencing aws_vpc.my_vpc.default_route_table_id

resource "aws_default_route_table" "tf_private_rt" {
  default_route_table_id = aws_vpc.tf_vpc.default_route_table_id
}

## aws_route_table
<!--https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table-->
1. main associated rt is private so nothing is accidently exposed
2. The subnets in the vpc will be implicitly associated with this rt

## Lifecycle policy and IGW
if the vpc cidr changes and the whole stack needs to be recreated
Problem:
Internet Gateway isn't recreated, it's reassociated (updated in place) to the new vpc
which isn't created yet

Solution:
Lifecycle policy should be added on the VPC, and the "create_before_destroy" set to true 

## Security Groups
<!--https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group-->
dynamic "ingress" {
  for_each = each.value.ingress
  content {
    from_port = ingress.value.from
  }
}
this dynamnic block is nested within the tf_sg for_each block, so it has access to
security_groups variable, the "each keyword" is looping "public"/"private" objects
each.value.ingress => security_groups.public.ingress
ingress.value.from => ingress.[dynamic value].from => ingress.ssh.from

## Creating a subnet group(of 3) for rds to use 
  db_subnet_group = true
  count = var.db_subnet_group ? 1 : 0
Using conditionals tells the sn group to provision or not

*accessing the output will be tricky
output "tf_rds_subnet_group_name_out" {
  value = aws_db_subnet_group.tf_rds_subnet_group[0].name
}

## Adding a load balancer (ALB)
<!--https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb-->
1. provisioned a alb resource
2. took the public security group ids
    aws_security_group.tf_sg["public"].id
    we took the public security group id by using the "public" index value and got the id
3. took all the subnet ids from the networking module
   aws_subnet.tf_public_subnet.*.id
4. using all the output values we can populate "public_sg" and public_subnets so the
   "load-balancing" module can make use of it




