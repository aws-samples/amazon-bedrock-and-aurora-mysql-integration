# Amazon Bedrock and Aurora MySQL Integration

- Aurora version

```
mysql> select @@aurora_version,@@version;
+------------------+-----------+
| @@aurora_version | @@version |
+------------------+-----------+
| 3.06.0           | 8.0.34    |
+------------------+-----------+
1 row in set (0.00 sec)

```

### This is sample Scripts

- Create sample tables
- Create Functions for integrate with Bedrock
- Obtain Sample Data from RSS

Note: In this script use CURRENT_USER() as default value of modify_user column.
It is work after [MySQL 8.0.34](https://dev.mysql.com/doc/relnotes/mysql/8.0/en/news-8-0-34.html#mysqld-8-0-34-sql-syntax ).



### Basic functions

- invoke titan (run invoke_titan.sql for invoke_titan function)

```
select json_unquote(json_extract(invoke_titan(
'{
"inputText": "Put your Request here",
"textGenerationConfig": {
"maxTokenCount": 1024,
"stopSequences": [],
"temperature":0,
"topP":1
}
}'
),"$.results[0].outputText")) as bedrock_response\G
```

- example

```
mysql> select json_unquote(json_extract(invoke_titan(
    -> '{
    '> "inputText": "What is the proportion of land and sea on Earth?",
    '> "textGenerationConfig": {
    '> "maxTokenCount": 1024,
    '> "stopSequences": [],
    '> "temperature":0,
    '> "topP":1
    '> }
    '> }'
    -> ),"$.results[0].outputText")) as bedrock_response\G
*************************** 1. row ***************************
bedrock_response:
The proportion of land and sea on Earth is approximately 71% for land and 29% for water.
1 row in set (1.31 sec)
```

- invoke Claude 3 (run claude3_haiku.sql for cloude3_haiku function)

```
select json_unquote(json_extract(claude3_haiku(
'{
"anthropic_version": "bedrock-2023-05-31",
"max_tokens": 1024,
"messages": [{"role": "user","content": [{"type": "text", "text": "Put your request here"}]}],
"temperature": 0,
"top_p": 0,
"top_k":1,
"stop_sequences": []
}'),"$.content[0].text")) as response_from_bedrock\G
```

- example
```
mysql> select json_unquote(json_extract(claude3_haiku(
    -> '{
    '> "anthropic_version": "bedrock-2023-05-31",
    '> "max_tokens": 1024,
    '> "messages": [{"role": "user","content": [{"type": "text", "text": "What is the proportion of land and sea on Earth?"}]}],
    '> "temperature": 0,
    '> "top_p": 0,
    '> "top_k":1,
    '> "stop_sequences": []
    '> }'),"$.content[0].text")) as response_from_bedrock\G
*************************** 1. row ***************************
response_from_bedrock: The proportion of land and sea on Earth is approximately:
- Land: 29.2% of the Earth's surface
- Oceans and Seas: 70.8% of the Earth's surface
In other words, the Earth's surface is about 70% water and 30% land.
The total surface area of the Earth is approximately 510 million square kilometers (197 million square miles). Of this, the land area is around 148 million square kilometers (57 million square miles), while the ocean area is around 362 million square kilometers (140 million square miles).
This uneven distribution of land and water is a key feature of the Earth's geography and has significant impacts on climate, weather patterns, and the distribution of life on the planet. The large expanse of oceans plays a major role in regulating the Earth's temperature and weather systems.
1 row in set (2.09 sec)
```


### You can do two demonstrations.

##### Add information to exsisting column information.

- 1: t_bedrock.sql for creating t_bedrock table. (sample table)
- 2: sample_data_for_t_bedrock.sql for add sample data to t_bedrock.
- 3: get_bedrock_claude3_haiku.sql for create procedure to obtain popular food in each country.

```
call get_bedrock_claude3_haiku();
```


##### Import data from RSS feed. Then pickup service name and summarize it.

- 1: t_feed.sql for creating t_feed table. (Create sample table)
- 2: It require Python 3.7 and newer for using pymysql. (pip install -r requirements.txt)
- 3: use feed.py for obtaining data from rss feed. (You can modify target feed url)
- 4: For obtain data by runing ``` python feed.py ``` or ``` python3 feed.py ```
- 5: get_rss_product_by_bedrock_claude3_haiku.sql for picking up product name from feed. (It takes approx 40 sec)

```
mysql> call get_rss_product_by_bedrock_claude3_haiku();
Query OK, 0 rows affected (39.20 sec)
```

- 5: get_rss_summary_by_bedrock_claude3_haiku.sql for summarizing long text description. (It takes approx 1 min)

```
mysql> call get_rss_summary_by_bedrock_claude3_haiku();
Query OK, 0 rows affected (1 min 1.49 sec)
```

#### License

This library is licensed under the MIT-0 License. See the LICENSE file.


#### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.
