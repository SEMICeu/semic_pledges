# Info

A module to deploy a standard VPC with:
* 3 x public subnet with cidr based on the variable `public_cidrs` that should be a /
* 3 x private subnet with cidr based on the variable `private_cidrs` that should be a /
* public route table
* private route table
* IGW
* Single NAT
* dns resolution
* trailing
* default SG blank with suffix: -do-not-use
* flowlogs are activated at VPC level and are stored in CloudWatch