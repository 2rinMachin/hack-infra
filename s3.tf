resource "aws_s3_bucket" "incident_images" {
  bucket = var.images_bucket_name
}

resource "aws_s3_bucket_policy" "incident_images_policy" {
  bucket = aws_s3_bucket.incident_images.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.incident_images.arn}/*"
      }
    ]
  })
}
