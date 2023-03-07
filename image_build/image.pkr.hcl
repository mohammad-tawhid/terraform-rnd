source "amazon-ebs" "my-website" {
        ssh_username = "ec2-user"
        ami_name     = "mn-custom-image-{{timestamp}}"
        source_ami   = "ami-006dcf34c09e50022"
        instance_type = "t2.micro"
}

build {
    sources = ["source.amazon-ebs.my-website"]
    provisioner "shell" {
        execute_command = "sudo -S env {{ .Vars }} {{ .Path }}" 
        inline = [
            "yum update -y",
            "yum install -y httpd",
            "systemctl start httpd",
            "systemctl enable httpd",
            "echo '<h1>Hello World from $(hostname -f)</h1>' > /var/www/html/index.html"
   ]
 }
}

