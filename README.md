
# 🚀 Automated Docker App Deployment on AWS using Terraform, Ansible & GitHub Actions

This repository automates infrastructure provisioning, server configuration, Docker image deployment, and CI/CD delivery of a web application using the following tools:

---

## 📦 Tech Stack

| Layer                | Tool                         |
|----------------------|------------------------------|
| Infrastructure       | Terraform                    |
| Configuration Mgmt   | Ansible                      |
| Containerization     | Docker + Custom HTML (Nginx) |
| CI/CD Pipeline       | GitHub Actions               |
| Cloud Provider       | AWS (EC2, VPC, Security)     |

---

## 🛠️ Project Structure

```

automated-deployment/
├── terraform/          # Terraform IaC for EC2 setup
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── ansible/            # Ansible for post-deploy configuration
│   ├── playbook.yml
│   └── inventory.ini (generated at runtime)
│
├── app/                # Your HTML app and Dockerfile
│   ├── Dockerfile
│   └── index.html
│
└── .github/workflows/  # GitHub Actions CI/CD workflow
└── deploy.yml

````

---

## ✅ Step-by-Step Setup

---

### 1️⃣ Prerequisites

Install these tools on your local machine:

- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
- [Docker](https://docs.docker.com/get-docker/)
- AWS Account with IAM credentials

---

### 2️⃣ SSH Key Generation (One-Time)

```bash
ssh-keygen 
````

This creates:

* `~/.ssh/id_rsa` (private key)
* `~/.ssh/id_rsa.pub` (public key)

Keep the private key safe. You’ll upload the **public key to AWS** via Terraform.

---

### 3️⃣ Terraform – Infrastructure Provisioning (One-Time)

Navigate to the `terraform/` directory and update `terraform.tfvars`:

```hcl
region            = "us-east-1"
key_name          = "ssh-key"
public_key_path   = "~/.ssh/id_rsa.pub"
allowed_ssh_cidr  = "0.0.0.0/0"
```

Then initialize and apply:

```bash
cd terraform
terraform init
terraform apply
```

> ☑️ This sets up a VPC, subnet, security group, key pair, and launches an EC2 instance with Amazon Linux.

---

### 4️⃣ Add GitHub Secrets

Go to **GitHub Repo → Settings → Secrets → Actions** and add the following:

| Secret Name   | Description                           |
| ------------- | ------------------------------------- |
| `EC2_HOST`    | EC2 Public IP (output from Terraform) |
| `EC2_SSH_KEY` | Paste the contents of `~/.ssh/id_rsa`   |

---

### 5️⃣ Custom Docker App (`app/`)

**Dockerfile**:

```Dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```


---

### 6️⃣ Ansible Playbook (`ansible/playbook.yml`)

Installs Docker, ensures it's running, pulls the image from GHCR, and runs the container:


---

### 7️⃣ GitHub Actions Workflow (`.github/workflows/deploy.yml`)

This pipeline:

* Builds and pushes Docker image to GitHub Container Registry
* Signs the image (optional)
* Connects to EC2 and runs Ansible for remote deployment

> Be sure to update the `docker_image` variable in `playbook.yml` to match the pushed image tag.

---

### ✅ To Deploy Automatically

Whenever you push to `main`, the workflow will:

1. Build and sign your Docker image
2. Push it to `ghcr.io`
3. SSH into the EC2 instance
4. Use Ansible to pull the image and run it via Docker

---

## 📌 Troubleshooting

* If Ansible says SSH key permissions are wrong, ensure `.pem` has `chmod 600`
* Make sure your EC2 instance has a public IP
* Open port 80 and 22 in your AWS security group

---

## 📈 Future Improvements

* Route53 + Cloudflare DNS + SSL
* HTTPS via Let's Encrypt
* Multi-container orchestration (e.g., Docker Compose)
* Monitoring (e.g., Prometheus + Grafana)

---

## 🙌 Credits

Made with Terraform, Ansible, Docker, GitHub Actions

```
