# Tableau S3 Connector: AWS testing infrastructure
This terraform code (main.tf) declares the aws resources needed to test the Tableau S3 Connector.  

# Setup

## Prerequisites
In order to use this project, you need [programmatic access](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) to AWS (maybe through okta-aws or another IdP).  You will also need to [install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli#install-terraform), and clone this repo locally to your computer.

## Step 1: Update variables
The top section of main.tf has some variables that you can change.  The most important is to specify the **name** of your IAM user.

## Step 2: Initialize
From terminal, change to the directory with this project and run the following command: `terraform init`

This will scan all the .tf files within the directory and make sure terraform has everything it needs to spin up those resources.

## Step 3: Apply
Now run the following command: `terraform apply`

This will print out all the resources (detailed below) that will get created as a result, and prompt if you want to continue.  Type `yes` and then Return.  Once the job has completed, you should see some outputs below.

## Now what?
Now it's time to test out the connectivity from Tableau Desktop! Open up Tableau Desktop and choose the S3 by Salesforce connector, then enter your connection details.  You may also want to upload your own data files to this new S3 bucket, you can do this via terraform or through the AWS Console.  Terraform also remembers the state of your AWS resources.  WHen you testing is done, you can type `terraform destroy` to clean up all the AWS resource we instantiated for our testing.

# Terraform details

## Variables
Within main.tf, the top section defines the variables needed to spin up the aws resources.  There are defaults set for region and bucket name, but if you want to change them this is the place to do so.  There is also a variable for iam_user_name, which MUST be filled out.  Our security rules prevent the creation of IAM users, except by system admins so that IAM user will need to be created first.  

## AWS Resources

### S3
* S3 bucket - the bucket where Tableau can connect, your data will live here
* Bucket CORS configuration - Some CORS settings need to be specified, in order for Tableau to communicate with your data files
* test_data\county-population-health.csv - a sample data file for testing
* test_data\SuperstoreHospital.xlsx - another sample data file for testing

### IAM
* IAM Group - The group can be associated with one or more IAM Policies
* IAM Group Membership - Adds the IAM user (specified in the variables section) to our new IAM group
* IAM Policy - This defines the permissions, which allow ListBucket & GetObject on the S3 bucket we just created
* IAM Attachment - This attaches the policy to the IAM group

## Outputs
When running this code, terraform will print out the name of the AWS region and S3 bucket.  You will need these (along with your IAM user's Access ID and Access Secret) in order to connect to your data from Tableau
