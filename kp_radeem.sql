-- KP-Radeem schema (import once)

CREATE TABLE IF NOT EXISTS `kp_redeem_codes` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code` VARCHAR(20) NOT NULL,
  `creator` VARCHAR(50) NOT NULL,
  `description` TEXT,
  `usage_limit` INT NOT NULL DEFAULT 1,
  `usage_count` INT NOT NULL DEFAULT 0,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_deleted` TINYINT(1) NOT NULL DEFAULT 0,
  `deleted_by` VARCHAR(50),
  `delete_reason` TEXT,
  `deleted_at` TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `kp_redeem_rewards` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code_id` INT NOT NULL,
  `type` ENUM('money', 'item', 'vehicle') NOT NULL,
  `subtype` VARCHAR(50),
  `name` VARCHAR(100) NOT NULL,
  `amount` INT,
  `plate` VARCHAR(12),
  FOREIGN KEY (`code_id`) REFERENCES `kp_redeem_codes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE IF NOT EXISTS `kp_redeem_history` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `code_id` INT NOT NULL,
  `user_identifier` VARCHAR(60) NOT NULL,
  `redeemed_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`code_id`) REFERENCES `kp_redeem_codes`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


