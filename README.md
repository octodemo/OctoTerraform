# Terraform with GitHub

There are countless resources on the Internet about GitHub Actions and Terraform. My two favorites so far are Hashicorp's tutorial *[Automate Terraform with GitHub Actions](https://developer.hashicorp.com/terraform/tutorials/automation/github-actions)* and our own *[Friday Deploy! Integrating Terraform into your GitHub Actions with HashiCorp ](https://www.youtube.com/watch?v=RcDePXkRHdw)* video with some friends from Hashicorp. I hear you asking "so then why creating yet another resource"? Glad you ask! 

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

## Using a child module from a private repo 

The module referenced from `main.tf` comes from a private repository. We want to be able to use it while staying away from Personal Access Tokens and changing URLs of each module to include it. 

```js
module "remote_child" {
    source                  = "git::https://github.com/octodemo/OctoTerraform-Module.git//modules?ref=main"
    latest-ubuntu-id        = "${data.aws_ami.latest-ubuntu.id}"
}
``` 

First we need to follow the steps at [peter-murray/workflow-application-token-action](https://github.com/peter-murray/workflow-application-token-action) and store the `APPLICATION_ID` and `APPLICATION_PRIVATE_KEY` as secrets (don't commit the private key file in your repo, just copy/paste its content as a secret). Make sure you give the application the `Contents` repository permission and install it on all your module repositories. 

We then use the action in a distinct `get_workflow_token` job to retrive a token. Note the `outputs` section, so that we can share the token with the `terraform-plan` and `terraform-apply` jobs.  

``` yaml
get_workflow_token:
    runs-on: ubuntu-latest
    outputs:
      token: ${{ steps.get_token.outputs.token }}
    steps: 
    - name: Get Token
      id: get_token
      uses: peter-murray/workflow-application-token-action@v1
      with:
        application_id: ${{ secrets.APPLICATION_ID }}
        application_private_key: ${{ secrets.APPLICATION_PRIVATE_KEY }}
``` 

The `terraform-plan` and `terraform-apply` jobs have to reference the `get_workflow_token` job in the `needs` section in order to access its `token` output. We then use the [fusion-engineering/setup-git-credentials](https://github.com/fusion-engineering/setup-git-credentials) action to set the credentials with this token so that Terraform has the permission to clone the child module repository. 

```yaml
terraform-apply:
    runs-on: ubuntu-latest
    environment: 
      production
    needs: 
      - get_workflow_token 
      - terraform-plan
    steps:
    - uses: fusion-engineering/setup-git-credentials@v2
      with:
        credentials: https://foo:{{needs.get_workflow_token.outputs.token}}@github.com
    - name: Checkout
      uses: actions/checkout@v2
    .... 
``` 

## Security? Help! 

TFSec... 

## What's up? 

Dependabot... 
