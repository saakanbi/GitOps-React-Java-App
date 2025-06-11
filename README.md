# GitOps React + Java App

This project implements a multi-tier application using GitOps with ArgoCD. It includes:

- Terraform for provisioning EKS and ArgoCD
- Frontend (React) and backend (Java) applications with Helm charts
- Kubernetes Ingress for internet exposure
- Prometheus and Grafana for monitoring

## Project Structure

```
GitOps-React-Java-App/
├── argocd/                  # ArgoCD application manifests
├── backend/                 # Java backend application
├── frontend/                # React frontend application
├── helm/                    # Helm charts for applications
└── terraform/               # Infrastructure as Code
```

## Getting Started

### Prerequisites

- AWS CLI configured with appropriate permissions
- Terraform installed
- kubectl installed
- Helm installed

### Deployment Steps

1. **Provision Infrastructure**

   ```bash
   cd terraform/eks
   terraform init
   terraform apply
   ```

2. **Configure kubectl**

   ```bash
   aws eks update-kubeconfig --region us-east-1 --name gitops-eks-cluster
   ```

3. **Access ArgoCD**

   After deployment, get the ArgoCD server URL:
   ```bash
   kubectl get svc argocd-server -n argocd
   ```

   The default username is `admin`. Get the password:
   ```bash
   kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
   ```

4. **Deploy Applications**

   ArgoCD will automatically sync and deploy the applications based on the configuration in the `argocd/applications` directory.

5. **Access Applications**

   Get the ALB URLs:
   ```bash
   kubectl get ingress -A
   ```

6. **Monitor with Prometheus and Grafana**

   Access Grafana:
   ```bash
   kubectl get svc prometheus-grafana -n monitoring
   ```

   Default credentials:
   - Username: admin
   - Password: prom-operator

## CI/CD Pipeline

This project uses GitOps principles:
- Git repository is the single source of truth
- ArgoCD monitors the repository and applies changes automatically
- Infrastructure changes are managed through Terraform

## Architecture

- **Frontend**: React application served through an ALB
- **Backend**: Java application exposed via API endpoints
- **Infrastructure**: EKS cluster with AWS Load Balancer Controller
- **Monitoring**: Prometheus for metrics collection and Grafana for visualization