# Terraform Infrastructure Deployment – DevOps Assignment

## Project Overview

This project demonstrates infrastructure provisioning using **Terraform on AWS** across three deployment approaches. It progresses from deploying multiple applications on a single EC2 instance to using separate EC2 instances, and finally deploying containerized applications using Amazon ECS, Amazon ECR, and an Application Load Balancer.

## Technologies Used

- Terraform
- Amazon Web Services (AWS)
- Amazon EC2
- Amazon VPC, subnets, route tables, and security groups
- Docker
- Amazon ECR
- Amazon ECS with AWS Fargate
- Application Load Balancer (ALB)
- AWS CloudWatch Logs
- Python, Flask, Node.js, and Express
- Git and GitHub

## Project Structure

```text
Teraform_KrishnaShinde/
├── single_ec2/       # Part 1: Applications on one EC2 instance
├── separate_ec2/     # Part 2: Applications on separate EC2 instances
├── docker_ec2/       # Part 3: Containerized ECS deployment
├── backend/          # Flask backend application
├── frontend/         # Express frontend application
├── screenshots/      # Assignment screenshots
└── README.md         # Project documentation
```

## Part 1: Deploy Flask and Express on a Single EC2 Instance

### Objective

Deploy the Flask backend and Express frontend on a single Amazon EC2 instance using Terraform.

### Implementation Steps

1. Configure the AWS provider and required variables in Terraform.

2. Define the EC2 instance and required networking and security group resources.

3. Configure the instance to run the Flask backend and Express frontend.

4. Allow the required application ports through the security group.

5. Initialize Terraform:

   ```bash
   terraform init
   ```

6. Validate the Terraform configuration:

   ```bash
   terraform validate
   ```

7. Review the proposed infrastructure changes:

   ```bash
   terraform plan
   ```

8. Create the infrastructure:

   ```bash
   terraform apply
   ```

9. Access the application using the EC2 public IP address and verify the services.

### Outcome

The Flask backend and Express frontend are deployed on a single EC2 instance, demonstrating basic infrastructure provisioning and application hosting.

## Part 2: Deploy Flask and Express on Separate EC2 Instances

### Objective

Deploy the Flask backend and Express frontend on separate EC2 instances, with networking and security configured using Terraform.

### Implementation Steps

1. Configure the AWS provider, variables, and networking resources.

2. Create a VPC and the required subnets, routing, and internet connectivity.

3. Define security groups to control inbound and outbound traffic.

4. Provision separate EC2 instances for the Flask backend and Express frontend.

5. Configure each instance to run its respective application.

6. Initialize and validate Terraform:

   ```bash
   terraform init
   terraform validate
   ```

7. Review the infrastructure plan:

   ```bash
   terraform plan
   ```

8. Apply the configuration:

   ```bash
   terraform apply
   ```

9. Test the frontend and verify that it can communicate with the backend.

### Outcome

The applications run on separate EC2 instances, demonstrating service separation, networking, and security group configuration.

## Part 3: Deploy Docker Containers Using Amazon ECS and ECR

### Objective

Build and publish Docker images for the Flask backend and Express frontend to Amazon ECR, then deploy both applications on Amazon ECS using AWS Fargate.

### AWS Region

`ap-southeast-2` (Asia Pacific – Sydney)

### Implementation Steps

1. Create Dockerfiles for the Flask backend and Express frontend.

2. Build and test both Docker images locally.

3. Create or use Amazon ECR repositories for the application images.

4. Authenticate Docker with Amazon ECR.

5. Tag and push both images to their respective ECR repositories.

6. Configure Terraform resources for:

   - VPC, public subnets, internet gateway, and route table
   - Security groups
   - Application Load Balancer and listeners
   - Target groups for the frontend and backend
   - ECS cluster, task definitions, and services
   - IAM task execution role
   - CloudWatch log groups

7. Initialize and validate Terraform:

   ```bash
   terraform init
   terraform validate
   ```

8. Review the proposed infrastructure:

   ```bash
   terraform plan
   ```

9. Deploy the infrastructure:

   ```bash
   terraform apply
   ```

10. Retrieve the application URLs:

    ```bash
    terraform output
    ```

11. Verify the ECS services and running tasks in the AWS Management Console.

12. Open the frontend URL and test the backend integration.

13. Inspect CloudWatch logs if troubleshooting is required.

### Outcome

The Flask backend and Express frontend are containerized and deployed as ECS Fargate services. An Application Load Balancer routes requests to the appropriate target groups, and CloudWatch captures application logs.

## Terraform Commands Reference

Run these commands from the relevant part's Terraform directory.

| Command              | Purpose                                       |
| -------------------- | --------------------------------------------- |
| `terraform init`     | Initialize the working directory              |
| `terraform fmt`      | Format Terraform files                        |
| `terraform validate` | Validate configuration syntax                 |
| `terraform plan`     | Preview infrastructure changes                |
| `terraform apply`    | Create or update resources                    |
| `terraform output`   | Display configured outputs                    |
| `terraform destroy`  | Remove resources managed by the configuration |

## Security and Cost Considerations

- Never commit AWS access keys, secret keys, credentials, or sensitive Terraform variables.
- Do not commit Terraform state files, plan files, or the local `.terraform` directory.
- Review security group rules before exposing services publicly.
- Restrict permissions according to the principle of least privilege.
- AWS resources such as EC2 instances, load balancers, and running ECS tasks may incur charges.
- After collecting the required screenshots and completing testing, destroy resources that are no longer needed.

## Conclusion

This project demonstrates three approaches to AWS application deployment using Terraform: a single EC2 instance, separate EC2 instances, and a container-based ECS Fargate architecture. It provides practical experience with infrastructure as code, networking, Docker, container registries, load balancing, and cloud logging.

## GitHub Repository

Repository: [GitHub](https://github.com/krishna-280792shinde/teraform)