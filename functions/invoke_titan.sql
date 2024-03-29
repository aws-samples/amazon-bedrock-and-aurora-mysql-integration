CREATE FUNCTION invoke_titan (request_body TEXT)
RETURNS TEXT
ALIAS AWS_BEDROCK_INVOKE_MODEL
MODEL ID 'amazon.titan-text-express-v1'
CONTENT_TYPE 'application/json'
ACCEPT 'application/json';
