# AWS Resource Usage Report Script

## Overview

This Bash script collects and displays usage information for key AWS services using the AWS CLI and `jq`. It provides a quick snapshot of:

- S3 Buckets  
- EC2 Instances  
- Lambda Functions  
- IAM Users  

This is useful for DevOps engineers and cloud administrators who want a fast overview of AWS account resources.

---

## Script Details

| Field | Value |
|------|-------|
| Author | Harini |
| Version | V1 |
| Date | 09-Jan |
| Language | Bash |

---

## Prerequisites

Before running this script, ensure the following are installed and configured:

### 1. AWS CLI

```bash
aws --version
````

If not installed:

```bash
sudo apt install awscli -y
```

Configure credentials:

```bash
aws configure
```

---

### 2. jq (JSON Parser)

```bash
jq --version
```

If not installed:

```bash
sudo apt install jq -y
```

---

## Script Functionality

| AWS Service | Command Used                 |
| ----------- | ---------------------------- |
| S3          | `aws s3 ls`                  |
| EC2         | `aws ec2 describe-instances` |
| Lambda      | `aws lambda list-functions`  |
| IAM         | `aws iam list-users`         |

---

## How to Run

1. Save the script as:

```bash
aws-resource-report.sh
```

2. Grant execution permission:

```bash
chmod +x aws-resource-report.sh
```

3. Execute the script:

```bash
./aws-resource-report.sh
```

---

## Sample Output

```bash
Print list of s3 buckets
<list of buckets>

Print list of ec2 instances
<list of instance IDs>

Print list of Lambda functions
<list of lambda functions>

Print list of IAM users
<list of IAM users>
```

---

## Notes

* Ensure your AWS IAM user has the necessary permissions:

  * `AmazonS3ReadOnlyAccess`
  * `AmazonEC2ReadOnlyAccess`
  * `AWSLambda_ReadOnlyAccess`
  * `IAMReadOnlyAccess`

* This script does not modify any AWS resources. It is read-only.

---

## Future Improvements

* Add AWS CloudWatch resource monitoring.
* Export output to a CSV or HTML report.
* Support multi-region scanning.

---

This script is safe to use in production as it performs only read operations.

```

