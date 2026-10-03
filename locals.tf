locals {
    common_tags = {
        Project = var.project
        Environment = var.environment
        Terraform = true
    }

  vpc_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    },
    var.vpc_tags
  )
  igw_final_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    },
    var.igw_tags
  )
  az_name = slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_tags = merge(
    local.common_tags,
    {
        Name = "${var.project}-${var.environment}"
    },
    var.public_subnet_tags
  )
}



