resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "${var.prefix}-${var.service_name}-codecommit-rule"
  description = var.eventbridge_rule_description
  role_arn = var.eventbridge_role_arn

  event_pattern = jsonencode({
    source = [
      "aws.codecommit"
    ],
    detail-type = [
      "CodeCommit Repository State Change"
    ],
    resources = [
      "arn:aws:codecommit:eu-west-1:${var.codecommit_account}:${var.source_repository_name}"
    ],
    detail = {
        referenceType = [
        "branch"
        ],
        referenceName = [
        var.source_branch
        ],
    }
  })
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  arn       = aws_codepipeline.pipeline.arn
  role_arn = var.eventbridge_role_arn
}