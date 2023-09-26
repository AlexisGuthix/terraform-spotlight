resource "aws_s3_bucket" "speedlight-terraform-bucket" {
  bucket = "speedlight-terraform-bucket"
}


resource "aws_s3_bucket_ownership_controls" "speedlight-terraform-access" {
  bucket = aws_s3_bucket.speedlight-terraform-bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "speedlight-terraform-access" {
  bucket = aws_s3_bucket.speedlight-terraform-bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "speedlight-terraform-access" {
  depends_on = [
    aws_s3_bucket_ownership_controls.speedlight-terraform-access,
    aws_s3_bucket_public_access_block.speedlight-terraform-access,
  ]

  bucket = aws_s3_bucket.speedlight-terraform-bucket.id
  acl    = "public-read"
}


resource "aws_s3_bucket_website_configuration" "speedlight-terraform-bucket2" {
  bucket = aws_s3_bucket.speedlight-terraform-bucket.id

  index_document {
    suffix = "speedlightterra.html"
  }
}

resource "aws_s3_bucket_policy" "speedlight-terraform-policy" {
  bucket = "speedlight-terraform-bucket"
  policy = file("${path.module}/policy.json")
  depends_on = [aws_s3_bucket_acl.speedlight-terraform-access, aws_s3_bucket_public_access_block.speedlight-terraform-access, aws_s3_bucket_ownership_controls.speedlight-terraform-access]  # Assurez-vous que les objets dépendent du bucket 
}

# resource "aws_s3_bucket_object" "speedlight-terraform-export-html" {
#   depends_on = [aws_s3_bucket.speedlight-terraform-bucket]  # Assurez-vous que les objets dépendent du bucket
#   for_each = fileset("./html/", "**")
#   bucket = aws_s3_bucket.speedlight-terraform-bucket.id  # Utilisez l'ID du bucket créé
#   key = each.value
#   source = "./html/${each.value}"
#   etag = filemd5("./html/${each.value}")
#   content_type = "text/html"
# }

