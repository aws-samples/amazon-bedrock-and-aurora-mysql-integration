CREATE FUNCTION claude3_haiku (request_body TEXT)
RETURNS TEXT
ALIAS AWS_BEDROCK_INVOKE_MODEL
MODEL ID 'anthropic.claude-3-haiku-20240307-v1:0' 
CONTENT_TYPE 'application/json'
ACCEPT 'application/json';
