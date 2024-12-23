# AWS EKS

## Summary
This repository is designed to:
- provision a VPC (default region: us-east-1) with three availability zones.
- set up an EKS cluster (k8s v1.31) including a default node group with one "t3.large" instance.
- deploy an autoscaler (https://github.com/kubernetes/autoscaler/releases).
- deploy a publicly accessible Nginx service with an HPA (Horizontal Pod Autoscaler) policy.

To test autoscaling, you can modify the replica count by editing the deployment configuration available at https://github.com/iomatters/aws-vpc-eks/blob/main/kustomize/nginx/base/deployment.yaml#L7.

Triggering the HPA is not straightforward; you would need to generate sufficient traffic to push Nginx's CPU utilization above 60%.

## Setup
 1. Create an AWS account.
 2. Navigate to the AWS Console and create an IAM user.
 3. Assign "AdministratorAccess" permissions to the user.
 4. Generate security credentials for the user.
 5. Set the security credentials as environment variables in your terminal session:
```
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="your-region"
```
 6. Install tooling (for Mac users):
```
brew install git awscli terraform kustomize kubectl
```
6. Verify AWS credentials:
```
aws sts get-caller-identity
```
## Deploy EKS Cluster
###  VPC & EKS
1. Download repository
```
git clone https://github.com/iomatters/aws-vpc-eks.git && cd aws-vpc-eks
```
2. Define aws region and cluster_name in `demo.tfvars`
3. Initialize a Terraform working directory:
```
terraform init
```
4. Create an execution plan for Terraform:
```
terraform plan -var-file=demo.tfvars
```
5. Apply the changes:
```
terraform apply -var-file=demo.tfvars
```
6. Update kubeconfig:
```
aws eks update-kubeconfig --region <YOUR_AWS_REGION> --name <YOUR_EKS_CLUSTER>
```
7. Make sure you can access EKS:
```
kubectl get nodes
```
### Autoscaler
1. Build & apply:
```
kustomize build kustomize/autoscaler/overlays/demo |kubectl apply -f -
```
2. Check logs:
```
kubectl logs -l app=cluster-autoscaler -n kube-system -f
```
## Deploy Nginx
1. Build & apply:
```
kustomize build kustomize/nginx |kubectl apply -f -
```
2. Retrieve the External IP:
```
kubectl get svc -n nginx --output=custom-columns=:status.loadBalancer.ingress[0].ip --no-headers
```
3. Check Nginx endpoint:
```
curl http://<External IP> -D -
```
## Considerations for Production
### Terraform
- Maintain tfstate in S3 storage.
- Production changes through PRs.
- Consider developing a proprietary module.
- Shift some module variables to a higher level.
- Design an arbitrary amount of EKS node groups.
- Design dual-stack EKS.
- Consider designing EKS to be private-facing, with access through a Bastion host.

### EKS
- ALB Ingress / Nginx ingress.
- ExternalDNS.
- Metric server.
- EFS CSI driver.
- EBS CSI driver.
- Fluentbit / OpenSearch.
- VictoriaMetrics / Prometheus.
- Istio *if required*;
- Let's Encrypt CertBot manager *if required*.
- Velero (STS backups) *if required*.
