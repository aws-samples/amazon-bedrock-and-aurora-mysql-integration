# Amazon Bedrock and Aurora MySQL Integration

### Prerequisites

#### Amazon Bedrock Support Regions

- Supported AWS Regions

  https://docs.aws.amazon.com/bedrock/latest/userguide/bedrock-regions.html

- Model support by AWS Region

  https://docs.aws.amazon.com/bedrock/latest/userguide/models-regions.html

#### Aurora MySQL version

- Amazon Aurora MySQL 3.06.0 or later version is required to use Amazon Bedrock integration.

```
mysql> select @@aurora_version,@@version;
+------------------+-----------+
| @@aurora_version | @@version |
+------------------+-----------+
| 3.06.0           | 8.0.34    |
+------------------+-----------+
1 row in set (0.00 sec)
```

#### Aurora MySQL cluster must allow outbound connections to Amazon Bedrock.

- Enabling network communication from Amazon Aurora MySQL to other AWS services

https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/AuroraMySQL.Integrating.Authorizing.Network.html

- Protect your data using Amazon VPC and AWS PrivateLink

https://docs.aws.amazon.com/bedrock/latest/userguide/usingVPC.html#vpc-interface-endpoints

- Aurora uses https to access Amazon Bedrock, so please allow https access from Aurora to Amazon Bedrock.

https://docs.aws.amazon.com/general/latest/gr/bedrock.html



### This is sample Scripts

- Create sample tables
- Create Functions for integrate with Amazon Bedrock
- Obtain Sample Data from RSS

Note: In this script use CURRENT_USER() as default value of modify_user column.
It is work after [MySQL 8.0.34](https://dev.mysql.com/doc/relnotes/mysql/8.0/en/news-8-0-34.html#mysqld-8-0-34-sql-syntax ).


### Create Amazon Bedrock functions by using account with AWS_BEDROCK_ACCESS role.


- Please grant AWS_BEDROCK_ACCESS role to the user that create and execute functions

```
GRANT AWS_BEDROCK_ACCESS TO `<user name>`@`%`;
```
refer: [Using Amazon Aurora machine learning with Aurora MySQL](https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/mysql-ml.html#aurora-ml-sql-privileges.br)


- Make sure your user set role before executing command

```
mysql> SET ROLE AWS_BEDROCK_ACCESS;
Query OK, 0 rows affected (0.00 sec)

mysql> SELECT CURRENT_ROLE();
+--------------------------+
| CURRENT_ROLE()           |
+--------------------------+
| `AWS_BEDROCK_ACCESS`@`%` |
+--------------------------+
1 row in set (0.00 sec)

```



- Function for Titan Text G1 - Express

```
CREATE FUNCTION invoke_titan (request_body TEXT)
RETURNS TEXT
ALIAS AWS_BEDROCK_INVOKE_MODEL
MODEL ID 'amazon.titan-text-express-v1' /*** model ID ***/
CONTENT_TYPE 'application/json'
ACCEPT 'application/json';

```

- Function for Anthropic Claude 3 Haiku

```
CREATE FUNCTION claude3_haiku (request_body TEXT)
RETURNS TEXT
ALIAS AWS_BEDROCK_INVOKE_MODEL
MODEL ID 'anthropic.claude-3-haiku-20240307-v1:0' 
CONTENT_TYPE 'application/json'
ACCEPT 'application/json';

```



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

- invoke Anthropic Claude 3 (run claude3_haiku.sql for cloude3_haiku function)

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

##### 1: Add information to exsisting column information.

- 1: t_bedrock.sql for creating t_bedrock table. (sample table)
- 2: sample_data_for_t_bedrock.sql for add sample data to t_bedrock.
- 3: get_bedrock_claude3_haiku.sql for create procedure to obtain popular food in each country.

```
call get_bedrock_claude3_haiku();
```


##### 2: Import data from RSS feed. Then pickup service name and summarize it.

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


##### Summarize ten rss descriptions.  

- Request Amazon Bedrock to summarize twenty rss contents.

```
set session group_concat_max_len = 1048576; 
set session aurora_ml_inference_timeout = 30000;

set @all = (select group_concat(description) from t_feed);
-- set @all = (select group_concat(top20.description) from (select description from t_feed limit 20) top20);

set @question = concat('\"messages\": [{\"role\": \"user\",\"content\": [{\"type\": \"text\", \"text\": \"Please categorize and tell me what kind of services improvement being talked about based on the following content.  ', @all,' ?\"}]}]}\'),\"$.content[0].text\")) as response_from_bedrock');
set @parameter = '(\'{\"anthropic_version\": \"bedrock-2023-05-31\",\"max_tokens\": 1024,\"temperature\": 0,\"top_p\": 0, \"top_k\":1, \"stop_sequences\": [],';
set @request = concat("select json_unquote(json_extract(claude3_haiku",@parameter,@question);

PREPARE select_stmt FROM @request;
EXECUTE select_stmt\G
DEALLOCATE PREPARE select_stmt;

```

- Output: Summarized batch contents.

```
mysql> EXECUTE select_stmt\G

*************************** 1. row ***************************
response_from_bedrock: Based on the content provided, the key service improvements being discussed are:

1. Expansion of service availability to new AWS Regions:
   - IAM Identity Center is now available in 30 AWS Regions globally, including the new Asia Pacific (Melbourne) Region.
   - Amazon Athena and its latest features are now available in the AWS Canada West (Calgary) Region.
   - Amazon Cognito is now available in the Europe (Zurich), Middle East (UAE), and Canada West (Calgary) Regions.
   - Amazon FSx for OpenZFS file systems can now be created in the Europe (Spain), Europe (Zurich), and AWS GovCloud (US) Regions.
   - Amazon GuardDuty is now available in the Canada West (Calgary) Region.

2. Enhancements to existing services:
   - Amazon Managed Service for Apache Flink now supports Apache Flink 1.18 with improvements to connectors and performance.
   - AWS Secrets Manager can now create and rotate user credentials for Amazon Redshift Serverless.
   - Amazon CloudWatch Synthetics is extending historical data for canary runs from 7 days to 30 days.
   - AWS Backup now supports restore testing for Amazon EBS Snapshots Archive and Amazon Aurora continuous backups.
   - Amazon EC2 now enables tagging of Amazon Machine Images (AMIs) during creation or copying.
   - AWS CloudFormation has improved stack creation speed by up to 40% and introduced a new stack creation event.
   - Amazon SageMaker Canvas has a revamped home page to help customers get started faster with ML and Generative AI.

3. New capabilities and features added to services:
   - Amazon Managed Service for Apache Flink now supports in-place Apache Flink version upgrades.
   - AWS CloudFormation StackSets now provides an API to list existing target Organizational Units (OUs) and AWS Regions.
   - Amazon SageMaker now integrates with NVIDIA NIM inference microservices for improved price-performance of large language models.
   - Amazon Timestream for InfluxDB, a new time-series database engine, is now generally available.
   - AWS Signer container image signing and verification is now available in the AWS GovCloud (US) Regions.
   - AWS Batch now supports a Batch Job Queue Blocked CloudWatch Event for jobs stuck in RUNNABLE state.
   - Application Load Balancer (ALB) now provides flexibility to configure HTTP client keepalive duration.
   - Amazon MSK Replicator now supports replicating existing data on your topics across Amazon MSK clusters.
   - AWS Fault Injection Service (FIS) now allows you to preview target resources before starting an experiment.
   - Amazon S3 on Outposts now caches AWS IAM permissions locally, improving application performance.

The overall theme is the expansion of service availability to new regions, enhancements to existing services, and the addition of new capabilities across various AWS services.
1 row in set (7.96 sec)
```


#### License

This library is licensed under the MIT-0 License. See the LICENSE file.


#### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.
