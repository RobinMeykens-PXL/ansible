##################################################################################
# VARIABLES
##################################################################################

variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "region" {
  default = "us-east-1"
}
variable "aws_session_token" {}
variable "database_password" {}

##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token = var.aws_session_token
  region     = var.region
}

##################################################################################
# Amazon AMI
##################################################################################

data "aws_ami" "amazon-linux-2" {
 most_recent = true

 filter {
   name   = "name"
   values = ["amzn2-ami-hvm*"]
 }
 owners = ["amazon"]
}

data "aws_iam_policy_document" "PE-CLOUD-IAM-ROLE-POLICY" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com","s3.amazonaws.com","resource-groups.amazonaws.com","dynamodb.amazonaws.com", "codedeploy.amazonaws.com"]
    }
  }
}
##################################################################################
# RESOURCES
##################################################################################

##################################################################################
# VPC
##################################################################################
# In de Amazon Web Services of AWS omgeving wordt er eerst een Virtual Private Network aangemaakt. 
# Dit privaat netwerk heeft als IP adres range 10.0.0.0/24.

resource "aws_vpc" "PE_CLOUD_VPC_WEBAPP" {
  cidr_block       = "10.0.0.0/24"
  instance_tenancy = "default"

  tags = {
    Name = "PE_CLOUD_VPC_WEBAPP"
  }
}

##################################################################################
# PUBLIC SUBNETS
##################################################################################
# In het netwerk segment van de VPC worden 6 subnets aangemaakt. 
# Drie subnets zijn beschikbaar voor de web servers en 3 subnets zijn beschikbaar voor de SQL en/of RDS server. 
# Alle zes de subnets zijn verdeeld over verschillende availability zones.

resource "aws_subnet" "PE_CLOUD_SUBNET_WEBSRV_AZ1" {
  vpc_id     = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  cidr_block = "10.0.0.0/27"
  map_public_ip_on_launch = true
  availability_zone ="us-east-1a"

  tags = {
    Name = "PE_CLOUD_SUBNET_WEBSRV_AZ1"
  }
}

resource "aws_subnet" "PE_CLOUD_SUBNET_WEBSRV_AZ2" {
  vpc_id     = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  cidr_block = "10.0.0.32/27"
  map_public_ip_on_launch = true
  availability_zone ="us-east-1b"

  tags = {
    Name = "PE_CLOUD_SUBNET_WEBSRV_AZ2"
  }
}

resource "aws_subnet" "PE_CLOUD_SUBNET_WEBSRV_AZ3" {
  vpc_id     = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  cidr_block = "10.0.0.64/27"
  map_public_ip_on_launch = true
  availability_zone ="us-east-1c"

  tags = {
    Name = "PE_CLOUD_SUBNET_WEBSRV_AZ3"
  }
}

##################################################################################
# PRIVATE SUBNETS
##################################################################################
# In het netwerk segment van de VPC worden 6 subnets aangemaakt. 
# Drie subnets zijn beschikbaar voor de web servers en 3 subnets zijn beschikbaar voor de SQL en/of RDS server. 
# Alle zes de subnets zijn verdeeld over verschillende availability zones.

resource "aws_subnet" "PE_CLOUD_SUBNET_MYSQLEC2_AZ4" {
  vpc_id     = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  cidr_block = "10.0.0.96/27"
  map_public_ip_on_launch = true
  availability_zone ="us-east-1d"

  tags = {
    Name = "PE_CLOUD_SUBNET_MYSQLEC2_AZ4"
  }
}

resource "aws_subnet" "PE_CLOUD_SUBNET_RDS_AZ5" {
  vpc_id     = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  cidr_block = "10.0.0.128/27"
  map_public_ip_on_launch = true
  availability_zone ="us-east-1e"

  tags = {
    Name = "PE_CLOUD_SUBNET_RDS_AZ4"
  }
}

resource "aws_subnet" "PE_CLOUD_SUBNET_RDS_AZ6" {
  vpc_id     = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  cidr_block = "10.0.0.160/27"
  map_public_ip_on_launch = true
  availability_zone ="us-east-1f"

  tags = {
    Name = "PE_CLOUD_SUBNET_RDS_AZ5"
  }
}

##################################################################################
# INTERNET GATEWAY
##################################################################################
# Om de webservers in de drie subnetten toegankelijk te maken via het internet, 
# moet er aan de VPC een internet gateway toegevoegd worden.

resource "aws_internet_gateway" "PE_CLOUD_IGW" {
  vpc_id = aws_vpc.PE_CLOUD_VPC_WEBAPP.id

  tags = {
    Name = "PE_CLOUD_IGW"
  }
}

##################################################################################
# PUBLIC ROUTING TABLE
##################################################################################
# Deze routetabel hangt aan de 3 subnetten van de webservers

resource "aws_route_table" "PE_CLOUD_PUBLIC_ROUTE_TABLE" {
  vpc_id = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  route {
    gateway_id = aws_internet_gateway.PE_CLOUD_IGW.id
    cidr_block = "0.0.0.0/0"
  }
  tags = {
    Name = "PE_CLOUD_PUBLIC_ROUTE_TABLE"
  }
}

##################################################################################
# PRIVATE ROUTING TABLE
##################################################################################
# Deze routetabel hangt aan de 3 subnetten van de RDS en de MySQL EC instance

resource "aws_route_table" "PE_CLOUD_PRIVATE_ROUTE_TABLE" {
  vpc_id = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  tags = {
    Name = "PE_CLOUD_PRIVATE_ROUTE_TABLE"
  }
}

##################################################################################
# PUBLIC ROUTE TABLE ASSOCIATION
##################################################################################

resource "aws_route_table_association" "PE_CLOUD_RTA_PUBLIC_AZ1" {
  subnet_id      = aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ1.id
  route_table_id = aws_route_table.PE_CLOUD_PUBLIC_ROUTE_TABLE.id
}

resource "aws_route_table_association" "PE_CLOUD_RTA_PUBLIC_AZ2" {
  subnet_id      = aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ2.id
  route_table_id = aws_route_table.PE_CLOUD_PUBLIC_ROUTE_TABLE.id
}

resource "aws_route_table_association" "PE_CLOUD_RTA_PUBLIC_AZ3" {
  subnet_id      = aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ3.id
  route_table_id = aws_route_table.PE_CLOUD_PUBLIC_ROUTE_TABLE.id
}

##################################################################################
# PRIVATE ROUTE TABLE ASSOCIATION
##################################################################################

resource "aws_route_table_association" "PE_CLOUD_RTA_PRIVATE_AZ4" {
  subnet_id      = aws_subnet.PE_CLOUD_SUBNET_MYSQLEC2_AZ4.id
  route_table_id = aws_route_table.PE_CLOUD_PRIVATE_ROUTE_TABLE.id
}

resource "aws_route_table_association" "PE_CLOUD_RTA_PRIVATE_AZ5" {
  subnet_id      = aws_subnet.PE_CLOUD_SUBNET_RDS_AZ5.id
  route_table_id = aws_route_table.PE_CLOUD_PRIVATE_ROUTE_TABLE.id
}

resource "aws_route_table_association" "PE_CLOUD_RTA_PRIVATE_AZ6" {
  subnet_id      = aws_subnet.PE_CLOUD_SUBNET_RDS_AZ6.id
  route_table_id = aws_route_table.PE_CLOUD_PRIVATE_ROUTE_TABLE.id
}

##################################################################################
# SECURITY GROUPS
##################################################################################
# De security groep voor de publieke HTTP server

resource "aws_security_group" "PE_CLOUD_SG_HTTP_WEB" {
  name        = "PE_CLOUD_SG_HTTP_WEB"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.PE_CLOUD_VPC_WEBAPP.id

  ingress = [
    {
      description      = "PE_CLOUD_SG_HTTP_WEB ingress"
      from_port        = 80
      to_port          = 80
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false      
    }
  ]

  egress = [
    {
      description      = "PE_CLOUD_SG_HTTP_WEB egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false      
    }
  ]

  tags = {
    Name = "PE_CLOUD_SG_HTTP_WEB"
  }
}
##################################################################################
# De security groep voor de publieke SSH server

resource "aws_security_group" "PE_CLOUD_SG_SSH_WEB" {
  name        = "PE_CLOUD_SG_SSH_WEB"
  description = "Allow SSH inbound traffic"
  vpc_id      = aws_vpc.PE_CLOUD_VPC_WEBAPP.id

  ingress = [
    {
      description      = "PE_CLOUD_SG_SSH_WEB ingress"
      from_port        = 22
      to_port          = 22
      protocol         = "tcp"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false      
    }
  ]

  egress = [
    {
      description      = "PE_CLOUD_SG_SSH_WEB egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false      
    }
  ]

  tags = {
    Name = "PE_CLOUD_SG_SSH_WEB"
  }
}
##################################################################################
# De security groep voor de private PostgreSQL server

resource "aws_security_group" "PE_CLOUD_SG_RDS_MYSQL" {
  name        = "PE_CLOUD_SG_RDS_MYSQL"
  description = "Allow PostgreSQL inbound traffic"
  vpc_id      = aws_vpc.PE_CLOUD_VPC_WEBAPP.id

  ingress = [
    {
      description      = "PE_CLOUD_SG_RDS_MYSQL ingress"
      from_port        = 3306
      to_port          = 3306
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.PE_CLOUD_VPC_WEBAPP.cidr_block]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false      
    }
  ]

  egress = [
    {
      description      = "PE_CLOUD_SG_RDS_MYSQL egress"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = []
      security_groups  = []
      self             = false      
    }
  ]

  tags = {
    Name = "PE_CLOUD_SG_RDS_MYSQL"
  }
}
##################################################################################
# APPLICATION LOAD BALANCER
##################################################################################
#De application load balancer PE-CLOUD-LBR verdeelt de HTTP load over de 3 webservers. 
#Deze verdeelt de load over de availability zones (en dus subnetten).

resource "aws_lb" "PE-CLOUD-LBR" {
  name               = "PE-CLOUD-LBR"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.PE_CLOUD_SG_SSH_WEB.id, aws_security_group.PE_CLOUD_SG_HTTP_WEB.id]
  subnets            = [aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ1.id, aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ2.id, aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ3.id]
}

##################################################################################
# AMI COPY
##################################################################################

resource "aws_ami_copy" "PE_CLOUD_WEBSERVER_AMI_IMAGE" {
  name              = "PE_CLOUD_WEBSERVER_AMI_IMAGE"
  description       = "PE_CLOUD_WEBSERVER_AMI_IMAGE"
  source_ami_id     = "${data.aws_ami.amazon-linux-2.id}"
  source_ami_region = "us-east-1"

  tags = {
    Name = "PE_CLOUD_WEBSERVER_AMI_IMAGE"
  }
}
##################################################################################
# IAM role
##################################################################################
resource "aws_iam_role" "PE-CLOUD-IAM-ROLE" {
  name = "PE-CLOUD-IAM-ROLE"
  assume_role_policy = data.aws_iam_policy_document.PE-CLOUD-IAM-ROLE-POLICY.json
}

resource "aws_iam_role_policy_attachment" "PE_CLOUD_POLICY_ATTACHMENT1" {
  role       = aws_iam_role.PE-CLOUD-IAM-ROLE.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_iam_role_policy_attachment" "PE_CLOUD_POLICY_ATTACHMENT2" {
  role       = aws_iam_role.PE-CLOUD-IAM-ROLE.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

resource "aws_iam_role_policy_attachment" "PE_CLOUD_POLICY_ATTACHMENT3" {
  role       = aws_iam_role.PE-CLOUD-IAM-ROLE.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSCodeDeployRole"
}

resource "aws_iam_instance_profile" "PE_CLOUD_IAM_INSTANCE_PROFILE" {
  name = "PE_CLOUD_IAM_INSTANCE_PROFILE"
  role = aws_iam_role.PE-CLOUD-IAM-ROLE.name
}

##################################################################################
# LAUNCH CONFIGURATION
##################################################################################

resource "aws_launch_configuration" "PE_CLOUD_LAUNCH_CONFIG" {
  name_prefix   = "pe-cloud-"
  image_id      = "${aws_ami_copy.PE_CLOUD_WEBSERVER_AMI_IMAGE.id}"
  instance_type = "t2.micro"
  security_groups = ["${aws_security_group.PE_CLOUD_SG_SSH_WEB.id}", "${aws_security_group.PE_CLOUD_SG_HTTP_WEB.id}"]
  key_name        = "Key-groep1"
  iam_instance_profile = "${aws_iam_instance_profile.PE_CLOUD_IAM_INSTANCE_PROFILE.name}"
}

##################################################################################
# AUTOSCALING CONFIGURATION
##################################################################################
#De tag van de autoscaling group wordt opgepikt door de inventory van Ansible

resource "aws_autoscaling_group" "PE_CLOUD_AUTOSCALINGGROUP" {
  name                 = "PE_CLOUD_AUTOSCALINGGROUP"
  launch_configuration = aws_launch_configuration.PE_CLOUD_LAUNCH_CONFIG.name
  min_size             = 1
  max_size             = 3
  desired_capacity     = 3 
  vpc_zone_identifier  = [aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ1.id, aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ2.id, aws_subnet.PE_CLOUD_SUBNET_WEBSRV_AZ3.id]
  tag {
    key                 = "group"
    value               = "www"
    propagate_at_launch = true
  }
}

##################################################################################
# LOADBALANCER TARGET GROUP
##################################################################################

resource "aws_lb_target_group" "PE-CLOUD-LDR-TARGETGRP" {
  name     = "PE-CLOUD-LDR-TARGETGRP"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
}

##################################################################################
# LOADBALANCER Listener
##################################################################################

resource "aws_lb_listener" "PE-CLOUD-LB_LISTENER" {
  load_balancer_arn = aws_lb.PE-CLOUD-LBR.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.PE-CLOUD-LDR-TARGETGRP.arn
  }
}

##################################################################################
# LOADBALANCER Autoscaling attachment
##################################################################################

resource "aws_autoscaling_attachment" "PE-CLOUD_AUTOSCALING-ATTACHMENT" {
  autoscaling_group_name = aws_autoscaling_group.PE_CLOUD_AUTOSCALINGGROUP.id
  alb_target_group_arn   = aws_lb_target_group.PE-CLOUD-LDR-TARGETGRP.arn
}

##################################################################################
# RDS server DB subnet
##################################################################################

resource "aws_db_subnet_group" "pe-cloud-db-subnet" {
  name       = "pe-cloud-db-subnet"
  subnet_ids = [aws_subnet.PE_CLOUD_SUBNET_RDS_AZ5.id, aws_subnet.PE_CLOUD_SUBNET_RDS_AZ6.id]
}

##################################################################################
# RDS server
##################################################################################

resource "aws_db_instance" "pe-cloud-rds" {
  identifier                = "pe-cloud-rds"
  engine                    = "mysql"
  engine_version            = "8.0.23"
  instance_class            = "db.t2.micro"
  allocated_storage         = 5
  name                      = "admin"
  username                  = "admin"
  password                  = "${var.database_password}"
  db_subnet_group_name      = "${aws_db_subnet_group.pe-cloud-db-subnet.id}"
  vpc_security_group_ids    = ["${aws_security_group.PE_CLOUD_SG_RDS_MYSQL.id}"]
  skip_final_snapshot       = true
  multi_az                  = false
}

##################################################################################
# S3 bucket
##################################################################################

resource "aws_s3_bucket" "pe-cloud-s3-bucket-0001" {
  bucket = "pe-cloud-s3-bucket-0001"
  acl    = "private"
  force_destroy = true

  tags = {
    Name        = "pe-cloud-s3-bucket-0001"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_object" "assets" {
    bucket = "${aws_s3_bucket.pe-cloud-s3-bucket-0001.id}"
    acl    = "private"
    key    = "assets/"
    content_type = "application/x-directory"
}

resource "aws_s3_bucket_object" "images" {
    bucket = "${aws_s3_bucket.pe-cloud-s3-bucket-0001.id}"
    acl    = "private"
    key    = "assets/images/"
    content_type = "application/x-directory"
}

##################################################################################
# S3 bucket access point
##################################################################################

resource "aws_s3_access_point" "pe-cloud-s3-accesspoint" {
  bucket = aws_s3_bucket.pe-cloud-s3-bucket-0001.id
  name   = "pe-cloud-s3-accesspoint"
}

##################################################################################
# VPC endpoint to S3 bucket
##################################################################################

resource "aws_vpc_endpoint" "PE_CLOUD_VPC_S3_ENDPOINT" {
  vpc_id       = aws_vpc.PE_CLOUD_VPC_WEBAPP.id
  service_name = "com.amazonaws.us-east-1.s3"
}

##################################################################################
# S3 bucket policy
##################################################################################

resource "aws_s3_bucket_policy" "PE_CLOUD_S3_POLICY" {
  bucket = aws_s3_bucket.pe-cloud-s3-bucket-0001.id
  policy = jsonencode({
    Version = "2012-10-17"
    Id      = "PE_CLOUD_S3_POLICY"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource = [
          aws_s3_bucket.pe-cloud-s3-bucket-0001.arn,
          "${aws_s3_bucket.pe-cloud-s3-bucket-0001.arn}/*",
        ]
      },
    ]
  })
}

##################################################################################
# VPC TO S3 BUCKET
##################################################################################

resource "aws_vpc_endpoint_route_table_association" "PE_CLOUD_VPC_TO_S3_BUCKET" {
  route_table_id = aws_route_table.PE_CLOUD_PUBLIC_ROUTE_TABLE.id
  vpc_endpoint_id = aws_vpc_endpoint.PE_CLOUD_VPC_S3_ENDPOINT.id
}


##################################################################################
# AWS CODEDEPLOY APP
##################################################################################
resource "aws_codedeploy_app" "PE_CLOUD_APP" {
  compute_platform = "Server"
  name = "PE_CLOUD_APP"
}

##################################################################################
# AWS CODEDEPLOY DEPLOYMENT GROUP
##################################################################################
resource "aws_codedeploy_deployment_group" "PE_CLOUD_DEPLOY_GRP" {
  app_name              = aws_codedeploy_app.PE_CLOUD_APP.name
  deployment_group_name = "PE_CLOUD_DEPLOY_GRP"
  service_role_arn      = aws_iam_role.PE-CLOUD-IAM-ROLE.arn
  autoscaling_groups = ["${aws_autoscaling_group.PE_CLOUD_AUTOSCALINGGROUP.name}"]

  ec2_tag_set {
    ec2_tag_filter {
      key   = "group"
      type  = "KEY_AND_VALUE"
      value = "www"
    }
  }
}

##################################################################################
# AWS CLOUD WATCH
##################################################################################

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "Dashboard-Christof-Frederick"

  dashboard_body = <<EOF

  {
   "start": "-PT9H",
   "periodOverride": "inherit",
   "widgets": [
     
        {
        "type": "text",
        "x": 0,
        "y": 7,
        "width": 3,
        "height": 3,
        "properties": {
          "markdown": "Hello Christof and Frederick, welcome to Cloudwatch to monitor your AWS application"
        }
      },
      {
         "type":"metric",
         "x":0,
         "y":0,
         "width":18,
         "height":9,
         "properties":{
            "metrics":[
               [ { "expression": "SEARCH('{AWS/EC2,InstanceId} MetricName=\"CPUUtilization\"', 'Average', 300)", "id": "e1" } ]
            ],
            "view": "timeSeries",
            "stacked": false,
            "region":"us-east-1",
            "title":"EC2 Instance CPU"
         }
      }
   ]
}
EOF
}
