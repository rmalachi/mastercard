## Part 1: Terraform Infrastructure

    • Requared AWS infrastructure    **_Done_**  
    
    • EC2 instances (Windows Server) for blue-green deployment    **Done**
    
    • Application Load Balancer (ALB) with health checks for IIS    **Done**
    
    • RDS SQL Server instance    **Done**
    
    • Security groups for HTTPS and SQL access    **Done Partially -  I had some HTTPS issue, so some requirememts could not be completed !!**
    
    • AWS Secrets Manager for storing sensitive credentials    **Not Fully Completed**
    
    • IAM roles and policies for secure access to secrets and SSM    **Not Fully Completed**


## Part 2: Ansible Deployment Pipeline

    • Connects to EC2 instances via WinRM    **Not Fully Completed due the HTTPS issue**
    
    • Installs and configures IIS and required Windows features    **Done through Data User with Terraform !!**
    
    • Deploys the application to the green instance    **Done by Data user (Terraform) it is not application but html static file**
    
    • Configures IIS (bindings, app pool settings)    **Not Done - I couldn't connect remotely due to HTTPS issue**
    
    • Retrieves secrets from AWS Secrets Manager    **Not Done - I didn't operate the AWS Secrets Manager**
    
    • Connects to RDS and runs SQL migration scripts    **I haven't real operate the DB, no Schema or data were injected**
    
    • Validates deployment and switches ALB traffic from blue to green    **Done**
    
    • Logs deployment status and errors    **CloudWatch been operated**
    
## Part 3: Monitoring & Validation

    • Validate IIS health via ALB    **Done**
    
    • Check SQL connectivity and schema    **Done Partially**
    
    • Log success/failure to CloudWatch    **Done Partially**
    
    • Optionally send alerts via SNS    **Not Done**


# Summary

It was a detailed project with lots of subtasks. 

I didn't complete all of requirements but the most and critical of them

The reason for that is time limitation and HTTPS issue 

I didn't complete the following parts:

    • Secrets

    • Ansible in which I had created just the basic files but not the full implementation !!




