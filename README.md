# terraform-Acme
 Create AWS EC2 environment to simulate client env for POV.

 

 ![ACME Exercise Network](https://raw.githubusercontent.com/csrez/Acme-Terraform/main/env.jpg)



 You will need your Access Key ID and Secret Key from your AWS user - see IAM in AWS

 Instructions:

 1. Install Terraform on your desktop: https://www.terraform.io/downloads

 2. Copy the files in this git to a directory on your machine

 3. Open a terminal window and change into the directory you copied the files into

 4. Run:  `terraform init`

 5. Run:  `terraform plan --var-file=./acme.tfvars`

 6. Ensure there are no errors from the previous command.

 7. Run: `terraform apply --var-file=./acme.tfvars`
 
    You will be asked to type in "yes" to continue. Once you enter "yes", terraform will spin up your environment in AWS.

 8. The only ec2 host accessible from the Internet is the Bastion host. 
    The IP of the Bastion host will print out once step 7 is complete. SSH to this host on port 22 using the blue-key.pem file:

    `ssh -i blue-key.pem centos@<bastion-ip>`

 9. From the bastion, you can SSH to any of the other machines. You'll find the ssh key in the .ssh directory of the centos user.


