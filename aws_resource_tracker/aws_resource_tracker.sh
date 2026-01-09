#!/bin/bash


########################################
# Author : Harini
# Date : 09th-Jan
#
# Version: V1
#
# this script will report the aws resource usage
#
#########################################

#AWS S3
#AWS EC2
#AWS Lambda
#AWS IAM users

#list the s3 Buckets
echo "Print list of s3 buckets"
aws s3 ls | jq

#list EC2 instances
echo "Print list of ec2 instances"
aws describe-instances | jq '.Reservations[].Instances[].InstancesId[]'

#list AWS Lambda Functions
echo "Print list of Lambda functions"
aws lambda list-function | jq

#List IAM users
echo "Print list of IAM users"
aws iam list-users | jq
