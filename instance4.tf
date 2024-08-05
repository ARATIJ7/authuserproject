resource "aws_instance" "mongodb_instance_4" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = <<-EOM
              #!/bin/bash
              # Update the package list
              sudo yum update -y

              # Add MongoDB 6.0 repository
              sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
              [mongodb-org-6.0]
              name=MongoDB Repository
              baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
              gpgcheck=1
              enabled=1
              gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
              EOF

              # Install MongoDB
              sudo yum install -y mongodb-org

              # Start MongoDB
              sudo systemctl start mongod
              sudo systemctl enable mongod

              # Wait for MongoDB to start
              sleep 10

              # Create MongoDB users with different roles
              mongo <<EOD
              use db4
              
              # User with read role
              db.createUser({
                user: "read_user",
                pwd: "read_password",
                roles: [{ role: "read", db: "db4" }]
              })

              # User with readWrite role
              db.createUser({
                user: "readWrite_user",
                pwd: "readWrite_password",
                roles: [{ role: "readWrite", db: "db4" }]
              })

              # User with dbAdmin role
              db.createUser({
                user: "dbAdmin_user",
                pwd: "dbAdmin_password",
                roles: [{ role: "dbAdmin", db: "db4" }]
              })

              # User with userAdmin role
              db.createUser({
                user: "userAdmin_user",
                pwd: "userAdmin_password",
                roles: [{ role: "userAdmin", db: "db4" }]
              })

              # User with clusterAdmin role
              db.createUser({
                user: "clusterAdmin_user",
                pwd: "clusterAdmin_password",
                roles: [{ role: "clusterAdmin", db: "admin" }]
              })
              EOD
              EOM

  tags = {
    Name = "MongoDBInstance4"
  }

  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name               = var.key_name
}
