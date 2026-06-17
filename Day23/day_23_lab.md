# Day 23 Lab – DevSecOps, Monitoring & Observability

**Date:** 17-Jun-2026  
**Modules:** 6 & 7 – DevSecOps, Monitoring & Observability  
**Lab Level:** Beginner  
**Tools:** AWS CLI, Amazon GuardDuty, AWS Security Hub, Amazon CloudWatch Logs, Metrics, Alarms, Dashboards

---

## Lab Goal

In this lab, you will build a simple AWS security monitoring and observability setup using AWS CLI commands.

You will learn how to:

- Verify AWS CLI configuration
- Enable Amazon GuardDuty
- Enable AWS Security Hub
- Create a CloudWatch Log Group
- Push sample application logs
- Create a CloudWatch Metric Filter
- Create a CloudWatch Alarm
- Create a CloudWatch Dashboard
- Validate monitoring resources
- Clean up resources after the lab

---

## Architecture Overview

```text
Application / System Logs
        |
        v
CloudWatch Logs
        |
        v
Metric Filter
        |
        v
CloudWatch Alarm
        |
        v
CloudWatch Dashboard

Security Events
        |
        v
GuardDuty + Security Hub
```

---

## Prerequisites

Before starting, make sure you have:

1. An AWS account
2. AWS CLI installed
3. AWS CLI configured
4. IAM permissions for:
   - GuardDuty
   - Security Hub
   - CloudWatch Logs
   - CloudWatch Metrics
   - CloudWatch Alarms
   - CloudWatch Dashboards

Check AWS CLI version:

```bash
aws --version
```
---

## Important Notes

- This lab uses simple AWS CLI commands.
- Some services may create small charges depending on your AWS account usage.
- Always clean up resources after completing the lab.
- Run all commands in the same AWS Region.

Set your AWS Region:

```bash
export AWS_REGION=us-east-1
export AWS_PROFILE=devops
```

Verify Region:

```bash
echo $AWS_REGION
```

---

# Part 1 – Enable Amazon GuardDuty

## What is GuardDuty?

Amazon GuardDuty is a threat detection service. It continuously monitors your AWS account for suspicious activity.

It can detect:

- Suspicious API calls
- Credential compromise
- Unauthorized access
- Malware-related behavior
- Crypto mining activity

---

## Step 1.1 – Check if GuardDuty is already enabled
Check current AWS identity:

```bash
aws sts get-caller-identity --profile $AWS_PROFILE
```

Expected output should show:

```text
Account
UserId
Arn
```

```bash
aws guardduty list-detectors \
  --region $AWS_REGION --profile $AWS_PROFILE
```

If GuardDuty is already enabled, you will see a Detector ID:

```json
{
  "DetectorIds": [
    "12abc345d6e789example"
  ]
}
```

If it is not enabled, the list will be empty:

```json
{
  "DetectorIds": []
}
```

---

## Step 1.2 – Enable GuardDuty

Run this command only if GuardDuty is not already enabled:

```bash
aws guardduty create-detector \
  --enable \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Save the Detector ID:

```bash
export DETECTOR_ID=$(aws guardduty list-detectors \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'DetectorIds[0]' \
  --output text)
```

Verify:

```bash
echo $DETECTOR_ID
```

---

## Step 1.3 – Generate sample GuardDuty findings

This creates test findings for learning purposes only.

```bash
aws guardduty create-sample-findings \
  --detector-id $DETECTOR_ID \
  --finding-types UnauthorizedAccess:IAMUser/ConsoleLogin \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 1.4 – List GuardDuty findings

```bash
aws guardduty list-findings \
  --detector-id $DETECTOR_ID \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Save one finding ID:

```bash
export FINDING_ID=$(aws guardduty list-findings \
  --detector-id $DETECTOR_ID \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query 'FindingIds[0]' \
  --output text)
```

View finding details:

```bash
aws guardduty get-findings \
  --detector-id $DETECTOR_ID \
  --finding-ids $FINDING_ID \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## What did you learn?

You learned how to:

- Enable GuardDuty
- Generate sample security findings
- View suspicious activity using AWS CLI

---

# Part 2 – Enable AWS Security Hub

## What is Security Hub?

AWS Security Hub provides a central place to view security findings from AWS security services.

It integrates with:

- GuardDuty
- Inspector
- IAM Access Analyzer
- AWS Config
- Third-party security tools

---

## Step 2.1 – Enable Security Hub

```bash
aws securityhub enable-security-hub \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

If Security Hub is already enabled, you may see an error saying it is already subscribed. That is okay.

---

## Step 2.2 – Enable AWS Foundational Security Best Practices standard

Get available security standards:

```bash
aws securityhub describe-standards \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Enable AWS Foundational Security Best Practices:

```bash
export STANDARD_ARN=$(aws securityhub describe-standards \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --query "Standards[?contains(Name, 'AWS Foundational Security Best Practices')].StandardsArn | [0]" \
  --output text)
```

```bash
aws securityhub batch-enable-standards \
  --standards-subscription-requests StandardsArn=$STANDARD_ARN \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 2.3 – View Security Hub findings

```bash
aws securityhub get-findings \
  --region $AWS_REGION \
  --profile $AWS_PROFILE \
  --max-results 5
```

---

## What did you learn?

You learned how to:

- Enable Security Hub
- Enable a security standard
- View centralized security findings

---

# Part 3 – Create CloudWatch Log Group

## What is CloudWatch Logs?

CloudWatch Logs stores and monitors logs from applications, systems, containers, and AWS services.

In this part, you will create a log group and send sample logs.

---

## Step 3.1 – Create a log group

```bash
aws logs create-log-group \
  --log-group-name /sunil-day23/devsecops/app \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

If the log group already exists, you may see an error. That is okay.

---

## Step 3.2 – Set log retention

This keeps logs for 7 days.

```bash
aws logs put-retention-policy \
  --log-group-name /sunil-day23/devsecops/app \
  --retention-in-days 7 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 3.3 – Create a log stream

```bash
aws logs create-log-stream \
  --log-group-name /sunil-day23/devsecops/app \
  --log-stream-name app-server-1 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 3.4 – Push sample logs

Create a timestamp variable:

```bash
export LOG_TIME=$(date +%s000)
```

Send sample logs:

```bash
aws logs put-log-events \
  --log-group-name /sunil-day23/devsecops/app \
  --log-stream-name app-server-1 \
  --log-events timestamp=$LOG_TIME,message="INFO User login successful" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Send an error log:

```bash
export LOG_TIME=$(date +%s000)

aws logs put-log-events \
  --log-group-name /day23/devsecops/app \
  --log-stream-name app-server-1 \
  --log-events timestamp=$LOG_TIME,message="ERROR Payment service failed" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 3.5 – View log events

```bash
aws logs get-log-events \
  --log-group-name /day23/devsecops/app \
  --log-stream-name app-server-1 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## What did you learn?

You learned how to:

- Create a CloudWatch Log Group
- Create a Log Stream
- Send logs using AWS CLI
- View logs using AWS CLI

---

# Part 4 – Create CloudWatch Metric Filter

## What is a Metric Filter?

A metric filter searches log data for a pattern and converts matching log entries into CloudWatch metrics.

Example:

```text
If logs contain ERROR, count them as ErrorCount.
```

---

## Step 4.1 – Create a metric filter for ERROR logs

```bash
aws logs put-metric-filter \
  --log-group-name /sunil-day23/devsecops/app \
  --filter-name sunil-Day23ErrorMetricFilter \
  --filter-pattern "ERROR" \
  --metric-transformations \
      metricName=sunil-Day23ErrorCount,metricNamespace=sunil-Day23DevSecOps,metricValue=1 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 4.2 – Generate more ERROR logs

```bash
export LOG_TIME=$(date +%s000)

aws logs put-log-events \
  --log-group-name /sunil-day23/devsecops/app \
  --log-stream-name app-server-1 \
  --log-events timestamp=$LOG_TIME,message="ERROR Database connection timeout" \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 4.3 – Check metric data

Wait 1–2 minutes, then run:

```bash
aws cloudwatch list-metrics \
  --namespace sunil-Day23DevSecOps \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## What did you learn?

You learned how to:

- Search logs using a pattern
- Convert log events into metrics
- Create custom CloudWatch metrics

---

# Part 5 – Create CloudWatch Alarm

## What is a CloudWatch Alarm?

A CloudWatch Alarm watches a metric and triggers when a threshold is reached.

Example:

```text
If ErrorCount >= 1, change alarm state to ALARM.
```

---

## Step 5.1 – Create alarm for error logs

```bash
aws cloudwatch put-metric-alarm \
  --alarm-name sunil-Day23-App-Error-Alarm \
  --alarm-description "Alarm when application ERROR logs are detected" \
  --namespace sunil-Day23DevSecOps \
  --metric-name sunil-Day23ErrorCount \
  --statistic Sum \
  --period 60 \
  --threshold 1 \
  --comparison-operator GreaterThanOrEqualToThreshold \
  --evaluation-periods 1 \
  --treat-missing-data notBreaching \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 5.2 – Check alarm status

```bash
aws cloudwatch describe-alarms \
  --alarm-names sunil-Day23-App-Error-Alarm \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

Look for:

```text
StateValue
```

Possible values:

- OK
- ALARM
- INSUFFICIENT_DATA

---

## What did you learn?

You learned how to:

- Create CloudWatch Alarms
- Monitor custom metrics
- Detect operational issues automatically

---

# Part 6 – Create CloudWatch Dashboard

## What is a CloudWatch Dashboard?

A CloudWatch Dashboard provides visual monitoring for metrics and alarms.

Dashboards help teams see:

- Application health
- Error trends
- Alarm status
- Operational visibility

---

## Step 6.1 – Create dashboard JSON file

Create a file named `day23-dashboard.json`:

```bash
cat > sunil-day23-dashboard.json <<EOF_DASHBOARD
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 12,
      "height": 6,
      "properties": {
        "metrics": [
          [ "sunil-Day23DevSecOps", "sunil-Day23ErrorCount" ]
        ],
        "period": 60,
        "stat": "Sum",
        "region": "$AWS_REGION",
        "title": "sunil-Day23 Application Error Count"
      }
    },
    {
      "type": "text",
      "x": 0,
      "y": 7,
      "width": 12,
      "height": 3,
      "properties": {
        "markdown": "# sunil-Day 23 DevSecOps Dashboard\\nMonitoring application errors from CloudWatch Logs."
      }
    }
  ]
}
EOF_DASHBOARD
```

---

## Step 6.2 – Create CloudWatch dashboard

```bash
aws cloudwatch put-dashboard \
  --dashboard-name sunil-Day23-DevSecOps-Dashboard \
  --dashboard-body file://sunil-day23-dashboard.json \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Step 6.3 – View dashboard details

```bash
aws cloudwatch get-dashboard \
  --dashboard-name sunil-Day23-DevSecOps-Dashboard \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

You can also open the AWS Console:

```text
CloudWatch > Dashboards > Day23-DevSecOps-Dashboard
```

---

## What did you learn?

You learned how to:

- Create a dashboard definition
- Deploy a dashboard using AWS CLI
- Visualize custom metrics

---

# Part 7 – Simple Security Monitoring Workflow

This is the basic DevSecOps security monitoring flow:

```text
1. Enable security services
2. Collect logs
3. Detect suspicious or failed activity
4. Convert logs into metrics
5. Create alarms
6. Visualize results in dashboards
7. Review and improve continuously
```

---

## Example Real-World Use Cases

| Use Case | AWS Service | Example Action |
|---|---|---|
| Threat detection | GuardDuty | Detect suspicious login |
| Security posture | Security Hub | Check compliance findings |
| Log collection | CloudWatch Logs | Store app logs |
| Error detection | Metric Filter | Count ERROR logs |
| Alerting | CloudWatch Alarm | Trigger on errors |
| Visibility | Dashboard | View app health |

---

# Part 8 – Validation Checklist

Run these commands to validate your lab.

## Check GuardDuty

```bash
aws guardduty list-detectors \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
  
```

## Check Security Hub

```bash
aws securityhub get-enabled-standards \
  --region $AWS_REGION 
  --profile $AWS_PROFILE
```

## Check CloudWatch Log Group

```bash
aws logs describe-log-groups \
  --log-group-name-prefix /sunil-day23/devsecops/app \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

## Check Metric Filter

```bash
aws logs describe-metric-filters \
  --log-group-name /sunil-day23/devsecops/app \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

## Check Alarm

```bash
aws cloudwatch describe-alarms \
  --alarm-names sunil-Day23-App-Error-Alarm \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

## Check Dashboard

```bash
aws cloudwatch list-dashboards \
  --dashboard-name-prefix sunil-Day23 \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

# Part 9 – Troubleshooting

## Problem: AWS CLI is not configured

Error example:

```text
Unable to locate credentials
```

Fix:

```bash
aws configure
```

---

## Problem: Access denied

Error example:

```text
AccessDeniedException
```

Fix:

Ask your AWS administrator to provide the required IAM permissions.

---

## Problem: Log group already exists

Error example:

```text
ResourceAlreadyExistsException
```

Fix:

This is not a problem. Continue with the next step.

---

## Problem: Metric does not appear immediately

Reason:

CloudWatch custom metrics can take a few minutes to appear.

Fix:

Wait 1–2 minutes and run:

```bash
aws cloudwatch list-metrics \
  --namespace sunil-Day23DevSecOps \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

# Part 10 – Cleanup

Use cleanup commands to avoid unwanted charges.

## Delete CloudWatch Alarm

```bash
aws cloudwatch delete-alarms \
  --alarm-names sunil-Day23-App-Error-Alarm \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Delete CloudWatch Dashboard

```bash
aws cloudwatch delete-dashboards \
  --dashboard-names Day23-DevSecOps-Dashboard \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Delete CloudWatch Log Group

```bash
aws logs delete-log-group \
  --log-group-name /day23/devsecops/app \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Optional: Disable Security Hub

Only do this in a training or sandbox account.

```bash
aws securityhub disable-security-hub \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

## Optional: Disable GuardDuty

Only do this in a training or sandbox account.

```bash
aws guardduty delete-detector \
  --detector-id $DETECTOR_ID \
  --region $AWS_REGION \
  --profile $AWS_PROFILE
```

---

# Lab Summary

In this lab, you completed a simple DevSecOps monitoring and observability workflow.

You created:

- Amazon GuardDuty threat detection
- AWS Security Hub centralized security visibility
- CloudWatch Log Group
- CloudWatch Log Stream
- Sample application logs
- CloudWatch Metric Filter
- CloudWatch Alarm
- CloudWatch Dashboard

You also learned how security automation and observability work together to improve:

- Threat detection
- Operational visibility
- Compliance monitoring
- Faster incident response

---

# Review Questions

1. What is the purpose of GuardDuty?
2. Why do we use Security Hub?
3. What are the three pillars of observability?
4. What is the difference between logs and metrics?
5. Why are CloudWatch alarms useful?
6. Why should logs have retention policies?
7. Why is cleanup important after a lab?

---

# End of Lab

