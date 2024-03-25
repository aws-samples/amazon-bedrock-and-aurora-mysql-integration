DROP PROCEDURE IF EXISTS get_rss_product_by_bedrock_claude3_haiku;
DELIMITER //

CREATE PROCEDURE `get_rss_product_by_bedrock_claude3_haiku`()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE v_id INT;
DECLARE v_description text;
DECLARE cursor_description CURSOR FOR
    SELECT id,description FROM t_feed order by id;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_description;

loop_cursor: LOOP
    FETCH cursor_description INTO v_id,v_description;

    IF done THEN
        LEAVE loop_cursor;
    END IF;

    set @question = concat('\"messages\": [{\"role\": \"user\",\"content\": [{\"type\": \"text\", \"text\": \"Please pick up product name only from the following description. ', v_description,' ?\"}]}]}\'),\"$.content[0].text\")) as response_from_bedrock');
    set @parameter = '(\'{\"anthropic_version\": \"bedrock-2023-05-31\",\"max_tokens\": 1024,\"temperature\": 0,\"top_p\": 0, \"top_k\":1, \"stop_sequences\": [],';
    set @request = concat("update t_feed,(select json_unquote(json_extract(claude3_haiku",@parameter,@question,") response set product = response.response_from_bedrock where id =",v_id);

    PREPARE summarize_stmt FROM @request;
    EXECUTE summarize_stmt;
    DEALLOCATE PREPARE summarize_stmt;


END LOOP;
CLOSE cursor_description;
END//

DELIMITER ;
