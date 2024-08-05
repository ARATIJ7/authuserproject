provider "aws" {
  region = "us-east-2"  # Specify your desired region
}

resource "aws_instance" "mongodb_instance_2" {
  ami           = "ami-024ebc7de0fc64e44"  # Amazon Linux 2 AMI
  instance_type = "t2.micro"  # Use a free-tier instance type or your desired instance type

  user_data = <<-EOM
              #!/bin/bash
              # Update the package list
              sudo yum update -y

              # Install MongoDB
              sudo tee /etc/yum.repos.d/mongodb-org-4.4.repo <<EOF
              [mongodb-org-4.4]
              name=MongoDB Repository
              baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/4.4/x86_64/
              gpgcheck=1
              enabled=1
              gpgkey=https://www.mongodb.org/static/pgp/server-4.4.asc
              EOF

              sudo yum install -y mongodb-org

              # Start MongoDB
              sudo systemctl start mongod
              sudo systemctl enable mongod

              # Wait for MongoDB to start
              sleep 10

              # Create MongoDB user for db2
              mongo <<EOD
              use db2
              db.createUser({
                user: "user2",
                pwd: "password2",
                roles: [{ role: "dbAdmin", db: "db2" }]
              })
              EOD
              EOM

  tags = {
    Name = "MongoDBInstance2"
  }

  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name               = "project"
}

resource "aws_security_group" "mongodb_sg" {
  name        = "mongodb_sg"
  description = "Allow SSH and MongoDB access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
