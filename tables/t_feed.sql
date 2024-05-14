CREATE TABLE `t_feed` (
  `id` int NOT NULL AUTO_INCREMENT,
  `title` varchar(1024) DEFAULT NULL,
  `link` varchar(2048) DEFAULT NULL,
  `product` varchar(512) DEFAULT NULL,
  `description` text,
  `summary` text,
  `modify_user` varchar(300) DEFAULT (current_user()) COMMENT 'If an import error occurs, remove this column',
  `updated_time` datetime DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_update_time` (`updated_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
