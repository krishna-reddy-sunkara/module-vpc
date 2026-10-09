Module: module-vpc

Inputs

VPC with configurable CIDR block and DNS hostname support
Public, private, and database subnet tiers across multiple Availability Zones
Internet Gateway for public subnets
NAT Gateway (with Elastic IP) for private and database subnet outbound access
Separate route tables for each subnet tier
Optional VPC peering support flag
Fully customizable tags on every resource


##outputs

vpc_id: ID of the VPC.
public_subnet_ids: List of public subnet IDs.
private_subnet_ids: List of private subnet IDs.
database_subnet_ids: List of database subnet IDs.
peering_connection_id: ID of the VPC peering connection, or null when is_peering_required is false.