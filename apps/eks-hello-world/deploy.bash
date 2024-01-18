# Login
aws ecr --profile admin get-login-password | docker login --username AWS --password-stdin 983510677257.dkr.ecr.us-east-1.amazonaws.com

# Build Image
docker build -t 983510677257.dkr.ecr.us-east-1.amazonaws.com/eks-hello-world:dev .

# Push Image to ECR
docker push 983510677257.dkr.ecr.us-east-1.amazonaws.com/eks-hello-world:dev
