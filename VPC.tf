#### VPC ####
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags {
    Name = "main"
  }
}



 ### Subnets #####
resource "aws_subnet" "subnet1" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.1.0/24"
  availability_zone = "${var.availability_zone1}"


  tags {
    Name = "app-subnet-1"
    }
}
resource "aws_subnet" "subnet2" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.0.2.0/24"
  availability_zone = "${var.availability_zone2}"


  tags {
    Name = "DB-subnet-2"
  }
}


#s3 


resource "aws_vpc_endpoint" "s3" {
  vpc_id       = "${aws_vpc.main.id}"
  service_name = "com.amazonaws.us-west-2.s3"

  tags = {
    Environment = "test"
  }
}


#  app instances

resource "aws_instance" "app_instances" {
  ami                    = "${lookup(var.images, var.region)}"
  instance_type          = "t2.large"
  key_name               = "myprivate"
  subnet_id              = "${aws_subnet.subnet1.id}"
  count                  = "3"
  user_data              = "${file("install_apache.sh")}"


    tags {
    Name = "app"
    }
}



install_httpd.sh

#! /bin/bash
sudo yum update
sudo yum install -y httpd
sudo chkconfig httpd on
sudo systemctl start httpd


# Create load balancer elb

resource "aws_elb" "app-elb" {
  name               = "app-elb"
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
  instances                   = ["${aws_instance.subnet1.id}"]
  cross_zone_load_balancing   = true

    

  listener {
    instance_port     = 8000
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }


  tags {
    Name = "app-elb"
  }
}

#  DB instances


#  app instances

resource "aws_instance" "db_instances" {
  ami                    = "${lookup(var.images, var.region)}"
  instance_type          = "t2.large"
  key_name               = "myprivate"
  subnet_id              = "${aws_subnet.subnet2.id}"
  count                  = "2"
  user_data              = "${file("install_mongodb.sh")}"


    tags {
    Name = "app"
    }
}



install_mongodb.sh

#! /bin/bash
sudo yum update
sudo yum install -y mongodb-org
sudo yum install -y mongodb-org-4.2.5 mongodb-org-server-4.2.5 mongodb-org-shell-4.2.5 mongodb-org-mongos-4.2.5 mongodb-org-tools-4.2.5
exclude=mongodb-org,mongodb-org-server,mongodb-org-shell,mongodb-org-mongos,mongodb-org-tools   
sudo systemctl start mongod


