SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL,ALLOW_INVALID_DATES';


-- -----------------------------------------------------
-- Table `d015dedf`.`users`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(45) NOT NULL ,
  `email` VARCHAR(45) NOT NULL ,
  `password` VARCHAR(45) NOT NULL ,
  `api_access_key` VARCHAR(45) NULL ,
  `is_disabled` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  `is_admin` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0 ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `d015dedf`.`event_groups`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`event_groups` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `created_at` DATETIME NOT NULL ,
  `title` VARCHAR(255) NOT NULL ,
  `text` TEXT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `d015dedf`.`events`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`events` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `event_group_id` INT UNSIGNED NOT NULL ,
  `created_by_user_id` INT UNSIGNED NULL ,
  `type` VARCHAR(50) NOT NULL ,
  `utc_timestamp` DECIMAL(20,6) NOT NULL ,
  `duration` DECIMAL(11,6) NULL ,
  PRIMARY KEY (`id`) ,
  INDEX `fk_event_has_user_idx` (`created_by_user_id` ASC) ,
  INDEX `fk_event_has_event_groups_idx` (`event_group_id` ASC) ,
  CONSTRAINT `fk_event_has_user`
    FOREIGN KEY (`created_by_user_id` )
    REFERENCES `d015dedf`.`users` (`id` )
    ON DELETE SET NULL
    ON UPDATE SET NULL,
  CONSTRAINT `fk_event_has_event_groups`
    FOREIGN KEY (`event_group_id` )
    REFERENCES `d015dedf`.`event_groups` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `d015dedf`.`user_roles`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`user_roles` (
  `id` CHAR(50) NOT NULL ,
  `description` TEXT NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `d015dedf`.`user_has_event_groups`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`user_has_event_groups` (
  `user_id` INT UNSIGNED NOT NULL ,
  `event_group_id` INT UNSIGNED NOT NULL ,
  `user_role_id` CHAR(50) NULL ,
  INDEX `fk_user_has_event_groups_idx` (`event_group_id` ASC) ,
  INDEX `fk_event_group_has_users_idx` (`user_id` ASC) ,
  PRIMARY KEY (`user_id`, `event_group_id`) ,
  INDEX `fk_user_has_event_groups_user_roles1_idx` (`user_role_id` ASC) ,
  CONSTRAINT `fk_event_group_has_users`
    FOREIGN KEY (`user_id` )
    REFERENCES `d015dedf`.`users` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_user_has_event_groups`
    FOREIGN KEY (`event_group_id` )
    REFERENCES `d015dedf`.`event_groups` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE,
  CONSTRAINT `fk_user_has_event_groups_user_roles1`
    FOREIGN KEY (`user_role_id` )
    REFERENCES `d015dedf`.`user_roles` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `d015dedf`.`event_fields`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`event_fields` (
  `event_id` INT UNSIGNED NOT NULL ,
  `id` CHAR(50) NOT NULL ,
  `value` TEXT NULL ,
  INDEX `fk_event_has_event_fields_idx` (`event_id` ASC) ,
  PRIMARY KEY (`id`, `event_id`) ,
  CONSTRAINT `fk_event_has_event_fields`
    FOREIGN KEY (`event_id` )
    REFERENCES `d015dedf`.`events` (`id` )
    ON DELETE CASCADE
    ON UPDATE CASCADE)
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8
COLLATE = utf8_general_ci;


-- -----------------------------------------------------
-- Table `d015dedf`.`role_permissions`
-- -----------------------------------------------------
CREATE  TABLE IF NOT EXISTS `d015dedf`.`role_permissions` (
  `user_role_id` CHAR(50) NOT NULL ,
  `permission` CHAR(50) NOT NULL ,
  `entity` VARCHAR(50) NOT NULL ,
  PRIMARY KEY (`user_role_id`, `permission`, `entity`) ,
  INDEX `fk_acl_user_roles1_idx` (`user_role_id` ASC) ,
  CONSTRAINT `fk_acl_user_roles1`
    FOREIGN KEY (`user_role_id` )
    REFERENCES `d015dedf`.`user_roles` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
