# Learning terraform 

## Notes
1. [Basics on TF](./1-basics/BASICS.md) 
2. [TF Modules](./2-modules/MODULES.md) 
3. [Weather Dashboard Project](./3-weather/WEEATHER.md) 

## Misc
curl command for public ip:
TOKEN=`curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -H "X-aws-ec2-metadata-token: $TOKEN" -v http://169.254.169.254/latest/meta-data/public-ipv4

