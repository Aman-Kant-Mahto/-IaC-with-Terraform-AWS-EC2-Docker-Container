# **Terraform AWS EC2 Docker Container Deployment**

## **Project Overview**

This project demonstrates **Infrastructure as Code (IaC)** using **Terraform** to provision an **AWS EC2 instance** with **Docker installed** and an **Nginx container running**.

The entire infrastructure is automated, including VPC, Subnet, Security Group, Internet Gateway, and Route Table, ensuring a fully working public-facing Nginx web server.

---

## **Technologies Used**

* **Terraform** – Infrastructure provisioning
* **AWS** – EC2, VPC, Security Groups, Subnet, Internet Gateway, Route Tables
* **Docker** – Containerization
* **Nginx** – Web server

---

## **Architecture Diagram**

```
Internet
   |
[Internet Gateway]
   |
[Public Subnet] -> [Security Group: Allow 22,80]
   |
[EC2 Instance] -> [Docker Nginx Container: Port 80]
```

---

## **Terraform Workflow**

1. **Initialize Terraform**

```bash
terraform init
```

2. **Plan**

```bash
terraform plan
```

3. **Apply**

```bash
terraform apply -auto-approve
```

4. **Output**

* Terraform prints the **public IP** of the EC2 instance.
* Test in browser: `http://<EC2_PUBLIC_IP>`

5. **Destroy Infrastructure**

```bash
terraform destroy -auto-approve
```

---

## **User Data Script**

```bash
#!/bin/bash
yum update -y
amazon-linux-extras enable docker
amazon-linux-extras install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
docker run -d -p 80:80 --name nginx nginx:latest
```

This ensures Docker is installed and the Nginx container runs on startup.

---

## **Execution Steps with Screenshots**

### 1️⃣ Terraform Apply Logs

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/a70ea3a8-e3e1-445e-92bc-6310578142f4" />


### 2️⃣ EC2 Instance & Docker Container Verification

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/7a19ee61-c14d-4f59-8c39-d863abeb4079" />


### 3️⃣ Nginx Webpage

<img width="1366" height="768" alt="image" src="https://github.com/user-attachments/assets/67c59519-2ea6-4f4e-bcde-8453ab5af422" />


---

## **Key Learnings**

* Automated provisioning of **AWS infrastructure** using Terraform.
* Learned how to use **`user_data` scripts** to install Docker and run containers.
* Ensured proper **VPC, subnet, route tables, and security group setup** for internet access.
* Validated containerized applications running on EC2 automatically.

---

