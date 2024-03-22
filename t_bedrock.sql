CREATE TABLE `t_bedrock` (
  `id` int NOT NULL AUTO_INCREMENT,
  `country` varchar(52) NOT NULL DEFAULT '',
  `information` varchar(2048),
  `modify_user` varchar(255) NOT NULL DEFAULT (current_user()),
  `updated_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_update_time` (`updated_time`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;
