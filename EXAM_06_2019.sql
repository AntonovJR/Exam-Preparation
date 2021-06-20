CREATE SCHEMA `bank_db`;
USE `bank_db`;

CREATE TABLE `branches`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT ,
`name` VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`first_name` VARCHAR(20) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL(10,2) NOT NULL,
`started_on` DATE NOT NULL,
`branch_id` INT NOT NULL,
CONSTRAINT fk_branch_id
FOREIGN KEY(`branch_id`)
REFERENCES `branches`(`id`)
);

CREATE TABLE `clients`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`full_name` VARCHAR(50) NOT NULL,
`age` INT NOT NULL
);

CREATE TABLE `employees_clients`(
`employee_id` INT,
`client_id` INT,
CONSTRAINT fk_employee_id
FOREIGN KEY(`employee_id`)
REFERENCES `employees`(`id`),
CONSTRAINT fk_client_id
FOREIGN KEY(`client_id`)
REFERENCES `clients`(`id`)
);

CREATE TABLE `bank_accounts`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`account_number` VARCHAR(10) NOT NULL,
`balance` DECIMAL(10,2) NOT NULL,
`client_id` INT NOT NULL UNIQUE,
CONSTRAINT fk_client_account_id
FOREIGN KEY(`client_id`)
REFERENCES `clients`(`id`)
);

CREATE TABLE `cards`(
`id` INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
`card_number` VARCHAR(19) NOT NULL,
`card_status` VARCHAR(7) NOT NULL,
`bank_account_id` INT NOT NULL,
CONSTRAINT fk_bank_id
FOREIGN KEY(`bank_account_id`)
REFERENCES `bank_accounts`(`id`)
);

-- 2
INSERT INTO `cards` (`card_number`,`card_status` , `bank_account_id`)
SELECT REVERSE(`full_name`), 'Active', `id` FROM `clients`
WHERE `clients`.`id` BETWEEN 191 AND 200;

-- 3
UPDATE `employees_clients` AS ec
JOIN
(SELECT ec1.`employee_id`, COUNT(ec1.`client_id`) AS 'count'
		FROM `employees_clients` AS ec1 
		GROUP BY ec1.`employee_id`
		ORDER BY count, ec1.`employee_id`) AS s
SET ec.`employee_id` = s.`employee_id`
WHERE ec.`employee_id` = ec.`client_id`;

-- 4 
DELETE FROM `employees`
WHERE `id` NOT IN(SELECT `employee_id` FROM `employees_clients`);

-- 5
SELECT `id`, `full_name` FROM `clients`
ORDER BY `id`;

-- 6
SELECT `id`, CONCAT(`first_name`, ' ', `last_name`) AS 'full_name', 
CONCAT('$',`salary`) AS 'salary', `started_on` FROM `employees`
WHERE `salary`>100000 AND YEAR(`started_on`) >=2018
ORDER BY `salary` DESC, `id`;

-- 7
SELECT c.`id`, CONCAT(c.`card_number`,' : ', e.`full_name`) AS 'card_token' FROM `cards` AS c
JOIN `bank_accounts` AS ba ON c.`bank_account_id` = ba.`id`
JOIN `clients` AS e ON ba.`client_id` = e.`id`
ORDER BY c.`id` DESC;

-- 8
SELECT CONCAT(e.`first_name`, ' ', e.`last_name`) AS 'name', e.`started_on`, 
COUNT(ec.`client_id`) AS 'count_of_clients' FROM `employees` AS e
JOIN `employees_clients` AS ec ON e.`id` = ec.`employee_id`
GROUP BY e.`id`
ORDER BY count_of_clients DESC, e.`id` LIMIT 5;

-- 9
SELECT b.`name`, COUNT(c.`id`) AS 'count_of_cards' FROM `branches` AS b
LEFT JOIN `employees` AS e ON b.`id` = e.`branch_id`
LEFT JOIN `employees_clients` AS ec ON e.`id` = ec.`employee_id`
LEFT JOIN `clients` AS cl ON ec.`client_id` = cl.`id`
LEFT JOIN `bank_accounts` AS ba ON cl.`id` = ba.`client_id`
LEFT JOIN `cards` AS c ON ba.`id` = c.`bank_account_id`
GROUP BY b.`name`
ORDER BY count_of_cards DESC, b.`name`;












