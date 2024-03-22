DROP PROCEDURE IF EXISTS get_bedrock_claude3_haiku;
DELIMITER //

Create Procedure get_bedrock_claude3_haiku()
BEGIN

DECLARE done INT DEFAULT FALSE;
DECLARE v_id INT;
DECLARE v_country varchar(52);
DECLARE cursor_bedrock CURSOR FOR
    SELECT id,country FROM t_bedrock order by id;

DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

OPEN cursor_bedrock;

loop_cursor: LOOP
    FETCH cursor_bedrock INTO v_id,v_country;

    IF done THEN
        LEAVE loop_cursor;
    END IF;

    set @question = concat('\"messages\": [{\"role\": \"user\",\"content\": [{\"type\": \"text\", \"text\": \"What is the most popular food in ', v_country,' ?\"}]}]}\'),\"$.content[0].text\")) as response_from_bedrock');
    set @parameter = '(\'{\"anthropic_version\": \"bedrock-2023-05-31\",\"max_tokens\": 1024,\"temperature\": 0,\"top_p\": 0, \"top_k\":1, \"stop_sequences\": [],';
    set @request = concat("update t_bedrock,(select json_unquote(json_extract(claude3_haiku",@parameter,@question,") response set information = response.response_from_bedrock where id =",v_id);

    PREPARE update_stmt FROM @request;
    EXECUTE update_stmt;
    DEALLOCATE PREPARE update_stmt;

END LOOP;

CLOSE cursor_bedrock;
END//

DELIMITER ;
