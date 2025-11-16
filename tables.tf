resource "aws_dynamodb_table" "users" {
  name         = "hack-users"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "username"
    type = "S"
  }


  global_secondary_index {
    name            = "email-idx"
    hash_key        = "email"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "username-idx"
    hash_key        = "username"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "user_tokens" {
  name         = "hack-user-tokens"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "token"

  attribute {
    name = "token"
    type = "S"
  }

  attribute {
    name = "user_id"
    type = "S"
  }

  global_secondary_index {
    name            = "user-id-idx"
    hash_key        = "user_id"
    projection_type = "ALL"
  }
}

resource "aws_dynamodb_table" "incidents" {
  name         = "hack-incidents"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_dynamodb_table" "incident_subscriptions" {
  name         = "hack-incident-subscriptions"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "connection_id"

  attribute {
    name = "connection_id"
    type = "S"
  }
}

