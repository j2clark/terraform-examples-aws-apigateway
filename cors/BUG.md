# Terraform OPTIONS has a bug

Creating an OPTIONS method in Terraform seems to be broken

Test the OPTIONS method in the API Gateway console and you see a 500 parsing exception

Delete and recreate (Easiest to select resource and choose Enable CORS only for this resource)

Every deployment will require this to be done