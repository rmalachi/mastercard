# mastercard
Senior DevOps Technical Exam


## Exam Overview
This exam assesses your ability to design and implement a secure, automated, and scalable infrastructure and deployment pipeline for an IIS-based application hosted on AWS. You will use Terraform for infrastructure provisioning and Ansible for deployment orchestration, with a focus on blue-green deployment, secrets management, and AWS-native authentication.

## Scenario
You are tasked with automating a manually-deployed .NET application to AWS. The application runs on IIS hosted on Windows Server and connects to a SQL Server database. The deployment must be fully automated using Terraform and Ansible.

## Part 1: Terraform Infrastructure
Provision the following resources using Terraform:
    • Requared AWS infrastructure
    • EC2 instances (Windows Server) for blue-green deployment
    • Application Load Balancer (ALB) with health checks for IIS
    • RDS SQL Server instance
    • Security groups for HTTPS and SQL access
    • AWS Secrets Manager for storing sensitive credentials
    • IAM roles and policies for secure access to secrets and SSM

## Part 2: Ansible Deployment Pipeline
Create an Ansible playbook that:
    • Connects to EC2 instances via WinRM
    • Installs and configures IIS and required Windows features
    • Deploys the application to the green instance
    • Configures IIS (bindings, app pool settings)
    • Retrieves secrets from AWS Secrets Manager
    • Connects to RDS and runs SQL migration scripts
    • Validates deployment and switches ALB traffic from blue to green
    • Logs deployment status and errors
    
## Part 3: Monitoring & Validation
    • Validate IIS health via ALB
    • Check SQL connectivity and schema
    • Log success/failure to CloudWatch
    • Optionally send alerts via SNS

## Bonus Requirements
Use Ansible Vault for fallback secrets
Implement rollback logic if deployment fails
Use AWS SSM Session Manager for secure EC2 access
Use IAM roles for authentication (no hardcoded credentials)
Implement an auto-scaling group for future scalability



## Appendix A: Application & IIS Configuration Requirements

### IIS futures and requarements:

        "Web-Server"
        
        "Web-Mgmt-Console"
        
        "NET-Framework-Features"
        
        "Web-Asp-Net45"
        
        "NET-WCF-TCP-PortSharing45"
        
        "Web-Asp"
        
        "Web-Windows-Auth"
        
        "Web-Http-Redirect"
        
        “dotnet-hosting-8.0.16-win”
        
        “AWS CLI v.2”
        
### Local environment variables on sytem level:

      __Variable__ name: “CQ_DB_LIST”
      
      __Variable__ value: “{"Secrets":[{"Name": "secrets key name","Region": "us-east-2}]}”
      
### Secrets key must contains:

     “username”: ”RDS admin user”
     “password”: “RDS password”
     “port”: ”RDS db access port”
     “url”: ”RDS db DNS address”
     “name”: ”RDS db instance name”
### IIS application configutarion:

   wwwroot\LogViewer\appConfig.json
   
    {
        "apiUrl": "https://load balancer external DNS domain name /CytegicLoggerAPI/api",
        "version":  "1.0.0.1"
    }

Artifact:
     LogViewer.zip

