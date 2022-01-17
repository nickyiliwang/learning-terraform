# Learning terraform 

## Notes
1. [Basics on TF](./1-basics/BASICS.md) 
2. [TF Modules](./2-modules/MODULES.md) 
3. [Deploy on AWS](./3-AWS/AWS.md) 

## Misc
curl command for public ip:
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4

## debugging
1. Use tf console to play around stuff (ie. relative file paths with path.module)

## important using terraform cloud and tfvars
<!--https://discuss.hashicorp.com/t/values-from-tfvars-not-getting-loaded/24040-->
Problem: When you use Terraform Cloud, the per-workspace Variables stored as part of the workspace settings replace the functionality of the terraform.tfvars file.

Solutions:
1. Store the settings in Terraform Cloud rather than in your repository.
2. Create a file with an .auto.tfvars suffix. 