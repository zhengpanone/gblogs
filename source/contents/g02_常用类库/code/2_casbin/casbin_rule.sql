CREATE TABLE `casbin_rule` (
	`id` BIGINT ( 20 ) NOTNULL AUTO_INCREMENT,
	`ptype` VARCHAR ( 100 ) DEFAULTNULL, -- 表示策略，p (policy) g (group policy)
	`v0` VARCHAR ( 100 ) DEFAULTNULL,
	`v1` VARCHAR ( 100 ) DEFAULTNULL,
	`v2` VARCHAR ( 100 ) DEFAULTNULL,
	`v3` VARCHAR ( 100 ) DEFAULTNULL,
	`v4` VARCHAR ( 100 ) DEFAULTNULL,
	`v5` VARCHAR ( 100 ) DEFAULTNULL,
PRIMARY KEY ( `id` ) 
) ENGINE = InnoDBDEFAULT CHARSET = utf8mb4;