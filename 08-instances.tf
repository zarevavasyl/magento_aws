resource "aws_instance" "magento-server" {
    ami = "ami-01a2825a801771f57"
    instance_type = var.magento_instance_type
    subnet_id = aws_subnet.magento-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = "${var.aws_region}a"
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name: "${var.env_prefix}-server"
    }

#Connection section
    connection {
        user = "ubuntu"
        type = "ssh"
        private_key = file(var.privat_key_location)
        timeout = "3m"
        host = self.public_ip
}

#Additional script
    provisioner "file" {
        source = "./magento_conf/magento-server.sh"
        destination = "/tmp/magento-server.sh"
    }

    provisioner "file" {
        source = "./magento_conf/magento.conf"
        destination = "/tmp/magento.conf"
    }

    provisioner "remote-exec" {
        inline = [
            "export domain_name=${var.domain_name} && export magento_version=${var.magento_version} && export repo_magento_username=${var.repo_magento_username} && export repo_magento_password=${var.repo_magento_password} && export dbname=${var.dbname} && export dbuser=${var.dbuser} export dbpass=${var.dbpass} export admin_firstname=${var.admin_firstname} && export admin_lastname=${var.admin_lastname} && export admin_email=${var.admin_email} && export admin_user=${var.admin_user} && export admin_password=${var.admin_password} && export backend_frontname=${var.backend_frontname}",
            "sudo apt-get update",
            "sudo chmod u+x /tmp/magento-server.sh && /tmp/magento-server.sh"        ]
    }
}

resource "aws_instance" "varnish-magento-server" {
    ami = "ami-01a2825a801771f57"
    instance_type = var.varnish_instance_type
    subnet_id = aws_subnet.magento-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = "${var.aws_region}a"
    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    tags = {
        Name: "${var.env_prefix}-varnish-server"
    }

#Connection section
    connection {
        user = "ubuntu"
        type = "ssh"
        private_key = file(var.privat_key_location)
        timeout = "3m"
        host = self.public_ip
}

#Additional script
    provisioner "file" {
        source = "./varnish_conf/varnish-server.sh"
        destination = "/tmp/varnish-server.sh"
    }

    provisioner "file" {
        source = "./varnish_conf/varnish.service"
        destination = "/tmp/varnish.service"
    }

    provisioner "file" {
        source = "./varnish_conf/default.vcl"
        destination = "/tmp/default.vcl"
    }

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update",
            "sudo chmod u+x /tmp/varnish-server.sh && /tmp/varnish-server.sh"
        ]
    }
 }

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}

resource "aws_iam_server_certificate" "domain_cert" {
  name             = "domain_cert"
  certificate_body = file("./ssl/public.pem")
  private_key      = file("./ssl/private.pem")
}


resource "null_resource" "after-magento-server" {

    depends_on = [
        aws_instance.varnish-magento-server,
        aws_instance.magento-server
    ]

#Connection section
    connection {
        user = "ubuntu"
        type = "ssh"
        private_key = file(var.privat_key_location)
        timeout = "3m"
        host = aws_instance.magento-server.public_ip
    }

#Additional script
    provisioner "remote-exec" {
        inline = [
            "cd /home/ubuntu/store/${var.domain_name}",
            "bin/magento setup:config:set --http-cache-hosts=${aws_instance.varnish-magento-server.private_ip}:80",
            "bin/magento c:c"
        ]
    }
}

resource "null_resource" "after-varnish-magento-server" {

    depends_on = [
        aws_instance.varnish-magento-server,
        aws_instance.magento-server
    ]

#Connection section
    connection {
        user = "ubuntu"
        type = "ssh"
        private_key = file(var.privat_key_location)
        timeout = "3m"
        host = aws_instance.varnish-magento-server.public_ip
    }

#Additional script
    provisioner "file" {
        source = "./varnish_conf/varnish-server-after.sh"
        destination = "/tmp/varnish-server-after.sh"
    }

    provisioner "remote-exec" {
        inline = [
            "export magento_private_ip=${aws_instance.magento-server.private_ip}",
            "sudo chmod u+x /tmp/varnish-server-after.sh && /tmp/varnish-server-after.sh"
        ]
    }
}