# 🐍 Python Flask App on AWS with EFS, ECS, ALB, and Route 53

This guide will help you deploy a Python Flask app that uploads files to an EFS volume using ECS Fargate behind an Application Load Balancer (ALB), all wired up with Route 53 and CloudWatch logging.

---

## 📁 Project Structure

```
.
├── app/
│   ├── app.py
│   ├── Dockerfile
│   ├── requirements.txt
│   └── README.md  <-- you are here
└── infra/
    └── terraform/
        ├── main.tf
        ├── variables.tf
        └── outputs.tf
```

---

## 🚀 1. Prerequisites

- AWS CLI configured (`aws configure`)
- Terraform installed
- Docker installed
- An available Route 53 hosted zone (e.g. `example.com`)

---

## 🛠️ 2. Infrastructure Setup (Terraform)

1. Edit `infra/terraform/variables.tf` and set your domain name:
   ```hcl
   variable "domain_name" {
     default = "example.com"
   }
   ```

2. Initialize Terraform:
   ```bash
   cd infra/terraform
   terraform init
   ```

3. Apply the infrastructure:
   ```bash
   terraform apply
   ```

4. Take note of outputs:
   - `alb_dns_name`
   - `vpc_id`
   - `efs_id`
   - `ecs_cluster_name`

---

## 🐳 3. Build and Push Docker Image to ECR

1. Create a new ECR repository:
   ```bash
   aws ecr create-repository --repository-name flask-efs-app
   ```

2. Authenticate Docker:
   ```bash
   aws ecr get-login-password | docker login --username AWS --password-stdin <account-id>.dkr.ecr.<region>.amazonaws.com
   ```

3. Build and push:
   ```bash
   cd app
   docker build -t flask-efs-app .
   docker tag flask-efs-app:latest <account-id>.dkr.ecr.<region>.amazonaws.com/flask-efs-app:latest
   docker push <account-id>.dkr.ecr.<region>.amazonaws.com/flask-efs-app:latest
   ```

---

## ⚙️ 4. Create ECS Task + Service

1. Create IAM roles for ECS (or use Terraform)
2. Define a task definition that:
   - Uses your image
   - Mounts EFS
   - Sends logs to CloudWatch

3. Create ECS service:
   - Launch type: Fargate
   - Load Balancer: ALB created by Terraform
   - Subnets: private
   - Security group: allow traffic from ALB

---

## 🌐 5. Route 53 Setup

Terraform already creates a `CNAME` record:
- `api.example.com` ➜ ALB DNS name

Ensure your domain's nameservers point to Route 53.

---

## 🧪 6. Test the App

1. Visit: `http://api.example.com/files`
2. Upload using `curl` or Postman:
   ```bash
   curl -F "file=@test.jpg" http://api.example.com/upload
   ```

3. Verify file is in EFS via `/files` route.

---

## 📋 Notes

- Flask app runs on port 5000 inside the container
- ALB routes external port 80 to 5000
- EFS mount target is `/mnt/efs`
- CloudWatch logs are enabled (define log group in task definition)

---

Happy deploying! 🎉