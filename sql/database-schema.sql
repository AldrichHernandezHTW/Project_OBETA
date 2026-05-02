-- obeta_staging.pick_data definition

CREATE TABLE `pick_data` (
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` int DEFAULT NULL,
  `order_id` bigint DEFAULT NULL,
  `position_in_order` int DEFAULT NULL,
  `pick_volume` int DEFAULT NULL,
  `quantity_unit` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `date` datetime DEFAULT NULL,
  KEY `idx_pick_data_order_date` (`order_id`,`date`),
  KEY `idx_pick_data_product` (`product_id`),
  KEY `idx_pick_data_warehouse` (`warehouse_section`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;


-- obeta_staging.pickoperations definition

CREATE TABLE `pickoperations` (
  `pick_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `order_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_group` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position_in_order` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pick_volume` int DEFAULT NULL,
  `quantity_unit` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `quarter` int DEFAULT NULL,
  `order_duration` decimal(12,6) DEFAULT NULL,
  KEY `idx_pickoperations_product` (`product_id`),
  KEY `idx_pickoperations_order` (`order_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_staging.product_data definition

CREATE TABLE `product_data` (
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_group` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_product_data_product` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_staging.warehouse_sections definition

CREATE TABLE `warehouse_sections` (
  `warehouse_abbreviation` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  KEY `idx_warehouse_abbreviation` (`warehouse_abbreviation`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_production.`order` definition

CREATE TABLE `order` (
  `order_key` int NOT NULL AUTO_INCREMENT,
  `order_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `origin` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `position_in_order` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`order_key`),
  KEY `idx_order_order_id` (`order_id`)
) ENGINE=InnoDB AUTO_INCREMENT=28835401 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_production.pick definition

CREATE TABLE `pick` (
  `pick_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_key` int DEFAULT NULL,
  `order_key` int DEFAULT NULL,
  `pick_volume` int DEFAULT NULL,
  `quantity_unit` varchar(10) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `year` int DEFAULT NULL,
  `month` int DEFAULT NULL,
  `quarter` int DEFAULT NULL,
  `order_duration` decimal(12,6) DEFAULT NULL,
  KEY `idx_pick_product_key` (`product_key`),
  KEY `idx_pick_order_key` (`order_key`),
  KEY `idx_pick_year_month` (`year`,`month`),
  KEY `idx_pick_quarter` (`quarter`),
  CONSTRAINT `fk_pick_order` FOREIGN KEY (`order_key`) REFERENCES `order` (`order_key`),
  CONSTRAINT `fk_pick_product` FOREIGN KEY (`product_key`) REFERENCES `product` (`product_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- obeta_production.product definition

CREATE TABLE `product` (
  `product_key` int NOT NULL AUTO_INCREMENT,
  `product_id` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_description` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `product_group` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `warehouse_section` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`product_key`),
  KEY `idx_product_product_id` (`product_id`)
) ENGINE=InnoDB AUTO_INCREMENT=196606 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
