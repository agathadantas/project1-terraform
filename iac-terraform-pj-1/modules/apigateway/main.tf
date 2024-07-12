resource "aws_api_gateway_rest_api" "apigateway_rest_api" {
  name = "pj-cd-acloud-${var.project}-${var.environment}-apigateway"

  tags = {
    Name        = "pj-cd-acloud-${var.project}-${var.environment}-apigateway"
    Entity      = "pj"
    Unit        = "cd"
    Team        = "acloud"
    Project     = "${var.project}"
    Environment = "${var.environment}"
    Region      = "${var.region}"
    Repository  = "${var.repository}"
  }
}