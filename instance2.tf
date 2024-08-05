resource "aws_instance" "mongodb_instance_2" {
  ami           = var.ami_id
  instance_type = var.instance_type

  user_data = <<-EOM
              #!/bin/bash
              sudo yum update -y
              sudo tee /etc/yum.repos.d/mongodb-org-6.0.repo <<EOF
              [mongodb-org-6.0]
              name=MongoDB Repository
              baseurl=https://repo.mongodb.org/yum/amazon/2/mongodb-org/6.0/x86_64/
              gpgcheck=1
              enabled=1
              gpgkey=https://www.mongodb.org/static/pgp/server-6.0.asc
              EOF

              sudo yum install -y mongodb-org
              sudo systemctl start mongod
              sudo systemctl enable mongod
              sleep 10
              mongo <<EOD
              use db2
              db.createUser({
                user: "user2",
                pwd: "password2",
                roles: [{ role: "read", db: "db2" }]
              })
              EOD
              EOM

  tags = {
    Name = "MongoDBInstance2"
  }

  vpc_security_group_ids = [aws_security_group.mongodb_sg.id]
  key_name               = var.key_name
}
