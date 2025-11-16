resource "aws_acm_certificate" "main" {
  domain_name       = "*.${var.domain}"
  validation_method = "DNS"
}

resource "aws_amplify_app" "frontend" {
  name = "mittel-frontend"

  repository  = var.frontend_repo
  oauth_token = var.github_token

  environment_variables = {
    VITE_USERS_URL     = var.users_api_url
    VITE_INCIDENTS_URL = var.incidents_api_url
    VITE_WEBSOCKET_URL = var.websocket_url
    VITE_PUBLIC_URL    = "https://incidentec.${var.domain}"
  }

  custom_rule {
    source = "</^[^.]+$|\\.(?!(css|gif|ico|jpg|jpeg|js|png|mov|webm|webmanifest|txt|svg|woff|woff2|ttf|map|json|webp)$)([^.]+$)/>"
    target = "/index.html"
    status = "200"
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = "main"

  stage             = "PRODUCTION"
  enable_auto_build = true
}

resource "aws_amplify_domain_association" "domain" {
  app_id                = aws_amplify_app.frontend.id
  domain_name           = "incidentec.${var.domain}"
  wait_for_verification = true

  certificate_settings {
    type                   = "CUSTOM"
    custom_certificate_arn = aws_acm_certificate.main.arn
  }

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = ""
  }
}
