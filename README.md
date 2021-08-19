# Terraform with GitHub

There are countless resources on the Internet about GitHub Actions and Terraform. My two favorites so far are Hashicorp's tutorial *[Automate Terraform with GitHub Actions](Automate Terraform with GitHub Actions)* and our own *[Friday Deploy! Integrating Terraform into your GitHub Actions with HashiCorp ](https://www.youtube.com/watch?v=RcDePXkRHdw)* video with some friends from Hashicorp. I hear you asking "so then why creating yet another resource"? Glad you ask! 

First of all, this is a GitHub repo. It means you can fork it and start playing with it right away. A quick fork is always faster than scrambling with copypasta. It's also an alternative way of using both GitHub and Terraform as it does not use Terraform Cloud. Last, I wanted to also highlight other capabilities such as Dependabot and Advanced Security in the context of Terraform. 

## The basics

We have a simple Terraform file, `main.tf`, with its variables being stored in `production.tfvars`. Our `Deploy with approval` GitHub Actions workflow (in `.github/workflows/deploy.yml`) will take care of executing it with two jobs. The first job will compute the plan and store it as an artifact. The second job will wait for you to review the plan and then execute it. 

## Does the plan comes together? 

The terraform plan is computed and saved in `~/terraform-output/plan`. As this plan is not human readable, we also save it to a file, using the `stdout` output of the `plan` step. This is possible because the `hashicorp/setup-terraform` action has the `terraform_wrapper` property enabled. 

```yaml
 - name: Terraform Plan
      id: plan
      run: |
        mkdir ~/terraform-output
        terraform plan -no-color -out ~/terraform-output/plan -var-file="production.tfvars"
      env:
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID}}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY}} 

    - name: Log plan as plain text
      run: | 
        echo "${{ steps.plan.outputs.stdout }}" > ~/terraform-output/plan.txt
```
## Security? Help! 

TFSec... 

## What's up? 

Dependabot... 