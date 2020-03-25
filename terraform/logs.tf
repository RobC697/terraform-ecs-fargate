# logs.tf

# Set up CloudWatch group and log stream and retain logs for 30 days
resource "aws_cloudwatch_log_group" "crossfeed_staging_log_group" {
  name              = "/ecs/crossfeed_staging"
  retention_in_days = 30

  tags = {
    Name = "crossfeed-staging-log-group"
  }
}

resource "aws_cloudwatch_log_stream" "crossfeed_staging_log_stream" {
  name           = "crossfeed-staging-log-stream"
  log_group_name = aws_cloudwatch_log_group.crossfeed_staging_log_group.name
}