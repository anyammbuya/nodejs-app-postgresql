# Deploying a secure Two-tier Infrastructure With High Availability (Includes the use nodejs app to retrieve the Postgresql database password from secrets manager using IAM role)

This is an example Terraform configuration the allows the deployment of a two-tier web architecture on AWS.

## What are the resources used in this architecture?

A VPC

Availability Zones

Internet gateway

Two public subnets in two availability zones

Two private subnets in two availability zones

Route tables

Security group for our app instance in the public subnet

Security group for our database in the private subnet

ssh key for our app instance

ec2 instance profile with ec2 role containing policy for actions on secrets manager

secrets manager secret

random password

secrets manager secret version

kms key and policy

RDS - POSTGRESQL instance
