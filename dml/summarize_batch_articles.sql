-- This is sample of batch summarization.

set session group_concat_max_len = 1048576; 
set session aurora_ml_inference_timeout = 30000;

-- set @all = (select group_concat(description) from t_feed);
set @all = (select group_concat(top50.description) from (select description from t_feed limit 50) top50);

set @question = concat('\"messages\": [{\"role\": \"user\",\"content\": [{\"type\": \"text\", \"text\": \"Please categorize and tell me what kind of services improvement being talked about based on the following content.  ', @all,' ?\"}]}]}\'),\"$.content[0].text\")) as response_from_bedrock');
set @parameter = '(\'{\"anthropic_version\": \"bedrock-2023-05-31\",\"max_tokens\": 1024,\"temperature\": 0,\"top_p\": 0, \"top_k\":1, \"stop_sequences\": [],';
set @request = concat("select json_unquote(json_extract(claude3_haiku",@parameter,@question);

PREPARE select_stmt FROM @request;
EXECUTE select_stmt\G
DEALLOCATE PREPARE select_stmt;
