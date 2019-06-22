# CloudWatchJVM
JVM  metrics for the AWS CloudWatch with jstat.


## Prerequisites

- Amazon Linux 2
- Open JDK 8 (including Amazon Corretto 8)


## Requires

- awscli
- jps
- jstat


## Summary

- A utility shell script to send metrics of JVM to the AWS CloudWatch.


## Configuration

You must to change the value of `NAME` with jar filename shown by jps command.

```
NAME=JARfilenameByJps
```

You can write a part of the jar filename.

## Installation

```
$ sudo cp jvm.sh /usr/local/bin/
$ sudo chmod +x /usr/local/bin/jvm.sh
$ sudo cp jvm_cron /etc/cron.d/jvm
```

You can be suitably change these file names.

## IAM policy

The following policy is required.

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "cloudwatch:PutMetricData",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:ListMetrics",
                "ec2:DescribeTags"
            ],
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
}
```

## Changelog

#### 1.0.0

- initial release

