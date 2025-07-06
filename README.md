# Automated Docker App Deployment on AWS Using Terraform, Ansible, and GitHub Actions

This repository implements a complete DevOps pipeline for deploying a containerized web application to AWS. The solution covers all stages from infrastructure provisioning and server configuration to container deployment and CI/CD automation.

## Tech Stack

| Layer              | Tool                         |
| ------------------ | ---------------------------- |
| Infrastructure     | Terraform                    |
| Configuration Mgmt | Ansible                      |
| Containerization   | Docker + Custom HTML (NGINX) |
| CI/CD Pipeline     | GitHub Actions               |
| Cloud Provider     | AWS (EC2, VPC, Security)     |

## Project Structure

```
automated-deployment/
├── terraform/                 # Infrastructure as Code using Terraform
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars
│
├── ansible/                  # Ansible playbook for post-deploy setup
│   ├── playbook.yml
│   └── inventory.ini         # Generated during workflow runtime
│
├── app/                      # HTML application and Docker setup
│   ├── Dockerfile
│   └── index.html
│
└── .github/
    └── workflows/
        └── deploy.yml        # GitHub Actions CI/CD pipeline
```




## Getting Started

This section outlines the full setup process from local development to production deployment.

### Prerequisites

Ensure the following tools are installed and available in your local development environment:

* [Terraform](https://developer.hashicorp.com/terraform/downloads) – Infrastructure as Code tool for cloud provisioning
* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) – Agentless configuration management tool
* [Docker](https://docs.docker.com/get-docker/) – Containerization engine to build and run applications
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) – Command-line interface for AWS service access
* [Git](https://git-scm.com/downloads) – Distributed version control system

An active [AWS account](https://aws.amazon.com/free/) with IAM credentials is also required.



### 1. SSH Key Generation

Generate a new SSH key pair if you don’t already have one:

```bash
ssh-keygen
```

This creates the following files:

* `~/.ssh/id_rsa` (private key)
* `~/.ssh/id_rsa.pub` (public key)

The public key will be injected into the EC2 instance via Terraform. The private key is used for SSH access and by GitHub Actions.

### 2. Infrastructure Provisioning with Terraform

Navigate to the `terraform/` directory and edit the `terraform.tfvars` file to set your environment variables:

```hcl
region            = "us-east-1"
key_name          = "ssh-key"
public_key_path   = "~/.ssh/id_rsa.pub"
allowed_ssh_cidr  = "0.0.0.0/0"
```

To deploy the infrastructure:

```bash
cd terraform
terraform init
terraform apply
```

This process provisions:

* A VPC and default subnet
* A security group allowing SSH and HTTP traffic
* An EC2 instance with Amazon Linux 2023
* Key pair injection using your public SSH key

The EC2 instance’s public IP will be output at the end. Save it for later use.

### 3. GitHub Secrets Configuration

Go to your repository’s **Settings > Secrets > Actions**, and add the following secrets:

| Name          | Description                          |
| ------------- | ------------------------------------ |
| `EC2_HOST`    | Public IP of the EC2 instance        |
| `EC2_SSH_KEY` | Private SSH key from `~/.ssh/id_rsa` |

Make sure the private key has no passphrase and is in raw text format.

### 4. HTML App and Dockerfile Setup

Inside the `app/` directory, a minimal static HTML page is provided. The Dockerfile is configured to serve it using NGINX:

```dockerfile
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/index.html
```

To test locally:

```bash
cd app
docker build -t webapp .
docker run -p 80:80 webapp
```

Visit `http://localhost` to verify it is served correctly.

### 5. Ansible Configuration

The `ansible/playbook.yml` is designed to:

* Install Docker, Git, and Python
* Enable Docker service
* Add `ec2-user` to the `docker` group
* Pull the container image from GitHub Container Registry (GHCR)
* Run the container with port mapping and restart policy

Ensure the `docker_image` variable inside the playbook matches your GHCR repository name and tag.

### 6. GitHub Actions CI/CD Pipeline

The pipeline defined in `.github/workflows/deploy.yml` automates the following:

* Docker image build from `app/` directory
* Push to GitHub Container Registry
* Image signing using Cosign
* SSH connection to the EC2 instance
* Remote deployment using Ansible

This automation ensures that any changes pushed to the `main` branch trigger a full deployment process without manual steps.

### 7. Deployment Flow

Once all setup steps are complete:

1. Push changes to the `main` branch
2. GitHub Actions builds and signs the Docker image
3. The image is pushed to GHCR
4. GitHub Actions SSHs into the EC2 instance
5. Ansible runs the playbook to install Docker and launch the container

### 8. Troubleshooting

* If Ansible fails due to permissions, ensure your SSH key has `chmod 600` applied.
* Confirm the EC2 instance has a public IP and port 22/80 are open.
* Verify GitHub Secrets are correctly set and the private key is valid.
* Use `terraform destroy` to tear down the infrastructure if needed.

## Future Improvements

* Add HTTPS support with Let’s Encrypt
* Configure DNS using Route53 and Cloudflare
* Add Prometheus and Grafana for monitoring
* Migrate to Docker Compose or ECS for multi-container deployments
* Introduce Load Balancer for scalability

## License

This project is open-source and licensed for educational or production use. You are free to fork and adapt it for your own needs.

## Authors

* Bhagath Sharma Bhadra Kumar Suma Devi
* Chiranth chirayil
* Alby Mareena Varghese


Developed as part of a DevOps pipeline demonstration combining Terraform, Ansible, Docker, and GitHub Actions for full-stack automation.
