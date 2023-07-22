variable "awsprops" {
  type = map(string)
  default = {
    region       = "us-east-1"
    vpc          = "vpc-08f3e40a007b8983d"
    ami          = "ami-053b0d53c279acc90"
    itype        = "t2.micro"
    subnet       = "subnet-094e855fe54781a56"
    publicip     = true
    keyname      = "infra"
    secgroupname = "Test-Sec-Group"
  }
}

provider "aws" {
  region     = lookup(var.awsprops, "region")
  access_key = "AKIARZMWIIENINCRJTFA"
  secret_key = "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"
}

resource "aws_security_group" "test-iac-sg" {
  name        = lookup(var.awsprops, "secgroupname")
  description = lookup(var.awsprops, "secgroupname")
  vpc_id      = lookup(var.awsprops, "vpc")

  // To Allow SSH Transport
  ingress {
    from_port   = 22
    protocol    = "tcp"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_instance" "test" {
  ami                         = lookup(var.awsprops, "ami")
  instance_type               = lookup(var.awsprops, "itype")
  subnet_id                   = lookup(var.awsprops, "subnet")
  associate_public_ip_address = lookup(var.awsprops, "publicip")
  key_name                    = lookup(var.awsprops, "keyname")


  vpc_security_group_ids = [
    aws_security_group.test-iac-sg.id
  ]
  root_block_device {
    delete_on_termination = true
    iops                  = 300
    volume_size           = 300
    volume_type           = "gp3"
  }
  tags = {
    Name        = "DD-INSTANCE"
    Environment = "DD"
    OS          = "UBUNTU"
    Managed     = "IAC"
  }

  depends_on = [aws_security_group.test-iac-sg]
}


output "ec2instance" {
  value = aws_instance.test.public_ip
}
