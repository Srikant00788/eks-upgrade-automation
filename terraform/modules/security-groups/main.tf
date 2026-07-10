resource "aws_security_group" "cluster" {

  name = "${var.project_name}-${var.environment}-cluster"

  vpc_id = var.vpc_id

  ingress {

    protocol = "tcp"

    from_port = 443

    to_port = 443

    cidr_blocks = [

      "10.0.0.0/16"

    ]

  }

  egress {

    protocol = "-1"

    from_port = 0

    to_port = 0

    cidr_blocks = [

      "0.0.0.0/0"

    ]

  }

  tags = merge(

    var.common_tags,

    {

      Name = "${var.project_name}-cluster-sg"

    }

  )

}
resource "aws_security_group" "worker" {

  name = "${var.project_name}-${var.environment}-worker"

  vpc_id = var.vpc_id

  ingress {

    protocol = "-1"

    from_port = 0

    to_port = 0

    self = true

  }

  ingress {

    protocol = "tcp"

    from_port = 443

    to_port = 443

    security_groups = [

      aws_security_group.cluster.id

    ]

  }

  egress {

    protocol = "-1"

    from_port = 0

    to_port = 0

    cidr_blocks = [

      "0.0.0.0/0"

    ]

  }

  tags = merge(

    var.common_tags,

    {

      Name = "${var.project_name}-worker-sg"

    }

  )

}
