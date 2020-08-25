# task4-terraform
# Problem Statement

Perform task-3 with an additional feature to be added that is NAT Gateway to provide the internet access to instances running in the private subnet.

Performing the following steps:
1.  Write an Infrastructure as code using terraform, which automatically create a VPC.
2.  In that VPC we have to create 2 subnets:
    1.   public  subnet [ Accessible for Public World! ] 
    2.   private subnet [ Restricted for Public World! ]
3. Create a public facing internet gateway for connect our VPC/Network to the internet world and attach this gateway to our VPC.
4. Create  a routing table for Internet gateway so that instance can connect to outside world, update and associate it with public subnet.
5.  Create a NAT gateway for connect our VPC/Network to the internet world  and attach this gateway to our VPC in the public network
6.  Update the routing table of the private subnet, so that to access the internet it uses the nat gateway created in the public subnet
7.  Launch an ec2 instance which has Wordpress setup already having the security group allowing  port 80 sothat our client can connect to our wordpress site. Also attach the key to instance for further login into it.
8.  Launch an ec2 instance which has MYSQL setup already with security group allowing  port 3306 in private subnet so that our wordpress vm can connect with the same. Also attach the key with the same.

Note: Wordpress instance has to be part of public subnet so that our client can connect our site. 
mysql instance has to be part of private  subnet so that outside world can't connect to it.
Don't forgot to add auto ip assign and auto dns name assignment option to be enabled.

Try each step first manually and write Terraform code for the same to have a proper understanding of workflow of task.


## Solution for this problem is:
 
Since it is same as [Task 3](https://github.com/sara16play/task3-terraform.git)
So only change is that we have to give the internet access to the mysql instance for the updates in the software running inside it
For that we have to create the NAT gateway and an additional instance which has access to the internet and mysql both so that mysql instance can get internet access.

![](1.png)

![](2.png)

For task3 go through the Github link of task 3 [click here](https://github.com/sara16play/task3-terraform.git)

## Built With

* Terraform
* AWS

## Author

[SAURAV PATEL](https://www.linkedin.com/in/saurav-patel-148539151/)
