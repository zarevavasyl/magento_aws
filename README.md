### Terraform variables
Create a terraform.tfvars file (sample file - terraform.tfvars.sample). Specify the following parameters:<br />

* VPC cidr block<br />
vpc_cidr_block = ""<br />

* Subnets cidr block. We will be using ALB and we need to have two subnets to configure it<br />
subnet_cidr_block = ""<br />
subnet_cidr_block2 = ""<br />

* Specify the region in which to deploy the infrastructure<br />
aws_region = ""<br />

* Prefix for the name of the created resources:<br />
env_prefix = ""<br />

* Specify the instance type for Magento and Varnish server:<br />
magento_instance_type = ""<br />
varnish_instance_type = ""<br />

* Specify the path to the private and public keys. It is used to configure servers and to connect them further:<br />
public_key_location = ""<br />
privat_key_location = ""<br />

* Specify the domain name:<br />
domain_name = ""<br />

* Specify the Magento version. From 2.4.4. The project was tested on the version - 2.4.5-p1:<br />
magento_version = ""<br />

* Enter the keys from the Magento Marketplace to install Magento via Composer:<br />
repo_magento_username = ""<br />
repo_magento_password = ""<br />

* Set the parameters for the database:<br />
dbname = ""<br />
dbuser = ""<br />
dbpass = ""<br />

* Set the options for Magento installation:<br />
admin_firstname = ""<br />
admin_lastname = ""<br />
admin_email = ""<br />
admin_user = ""<br />
admin_password = ""<br />
backend_frontname = ""<br />

### The ssl directory contains self-signed certificates for using HTTPS. You can replace it with your own.

### After completing the terraform, you will receive the IP of the load balancer. In the hosts file, add it to the domain you specified.
### Directory with Magento - /home/ubuntu/store/domain_name

