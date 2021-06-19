
CREATE TABLE `pictures`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`url` VARCHAR(100) NOT NULL,
`added_on` DATE NOT NULL
);

CREATE TABLE `categories`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE `products`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(40) NOT NULL UNIQUE,
`best_before` DATETIME,
`price` DECIMAL(10,2) NOT NULL,
`description` TEXT,
`category_id` INT NOT NULL,
`picture_id` INT NOT NULL,
CONSTRAINT fk_category_id
FOREIGN KEY(`category_id`)
REFERENCES `categories`(`id`),
CONSTRAINT fk_picture_id
FOREIGN KEY(`picture_id`)
REFERENCES `pictures`(`id`)
);

CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE `addresses`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(50) NOT NULL UNIQUE,
`town_id` INT NOT NULL,
CONSTRAINT fk_town_id
FOREIGN KEY(`town_id`)
REFERENCES `towns`(`id`)
);

CREATE TABLE `stores` (
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(20) NOT NULL UNIQUE,
`rating` FLOAT NOT NULL,
`has_parking` BOOLEAN DEFAULT FALSE,
`address_id` INT NOT NULL,
CONSTRAINT fk_address_id
FOREIGN KEY(`address_id`)
REFERENCES `addresses`(`id`)
);

CREATE TABLE `products_stores`(
`product_id` INT NOT NULL ,
`store_id` INT NOT NULL ,
PRIMARY KEY (`product_id`, `store_id`)
);

CREATE TABLE `employees`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`first_name` VARCHAR(15) NOT NULL,
`middle_name` CHAR(1),
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL (19,2) DEFAULT 0,
`hire_date` DATE NOT NULL,
`manager_id` INT, 
`store_id` INT NOT NULL,
CONSTRAINT fk_manager_id
FOREIGN KEY(`manager_id`)
REFERENCES `employees`(`id`),
CONSTRAINT fk_store_id
FOREIGN KEY(`store_id`)
REFERENCES `stores`(`id`)
);

-- 2
INSERT INTO `products_stores` (`product_id`, `store_id`) 
VALUES
(9, 1),
(10, 1),
(13, 1),
(16, 1),
(18, 1);

-- 3
UPDATE `employees`
SET 
`salary` = `salary`-500,
`manager_id` = 3
WHERE YEAR(`hire_date`)>2003 AND `store_id` NOT IN(5,14);

-- 4
DELETE FROM `employees`
WHERE `salary`>6000 AND `manager_id` IS NOT NULL;

-- 5
SELECT `first_name`, `middle_name`, `last_name`, `salary`, `hire_date` FROM `employees`
ORDER BY `hire_date` DESC;

-- 6
SELECT a.`name`AS 'product_name', a.`price`, a.`best_before`, CONCAT(LEFT(a.`description`,10),'...')AS 'short_description', p. `url` FROM `products` AS a
JOIN `pictures` AS p ON a.`picture_id` = p.`id`
WHERE CHAR_LENGTH(a.`description`) > 100 AND a.`price`>20 AND YEAR(p.`added_on`)<2019
ORDER BY a.`price` DESC;

-- 7 
SELECT s.`name`, COUNT(sp.`product_id`) AS 'product_count', ROUND(AVG(p.`price`),2) AS 'avg' FROM `stores` AS s
LEFT JOIN `products_stores` AS sp ON s.`id` = sp.`store_id`
LEFT JOIN `products` AS p ON p.`id` = sp.`product_id`
GROUP BY s.`name`
ORDER BY COUNT(sp.`product_id`) DESC, AVG(p.`price`) DESC, s.`id`;

-- 8
SELECT CONCAT(e.`first_name`,' ', `last_name`) AS 'Full_name', s.`name` AS 'Store_name', a.`name` AS 'address', e.`salary` FROM `employees` AS e
JOIN `addresses` AS a ON e.`store_id` = a.`id`
JOIN `stores` AS s ON e.`store_id` = s.`id`
WHERE e.`salary`<4000 AND CHAR_LENGTH(s.`name`)>8 AND a.`name` LIKE('%5%') AND e.`last_name` LIKE('%n');

-- 9
SELECT REVERSE(s.`name`) AS 'reversed_name', CONCAT(UPPER(t.`name`),'-',a.`name`) AS 'full_address', COUNT(e.`id`) AS 'employees_count' FROM `stores` AS s
JOIN `addresses` AS a ON s.`address_id` = a.`id`
JOIN `towns` AS t ON a.`town_id` = t.`id`
JOIN `employees` AS e ON e.`store_id` = s.`id`
GROUP BY s.`name`
ORDER BY CONCAT(UPPER(t.`name`),'-',a.`name`);

-- 10
DELIMITER //
CREATE FUNCTION `udf_top_paid_employee_by_store`(store_name VARCHAR(50))
RETURNS VARCHAR(100)
DETERMINISTIC
BEGIN
	
	RETURN (SELECT CONCAT(e.`first_name`, ' ', e.`middle_name`, '. ', e.`last_name`, ' works in store for ', '2020' - YEAR(e.`hire_date`), ' years') AS `full_info` 
	FROM `employees` AS e
	JOIN `stores` AS s
	ON e.`store_id` = s.`id`
	WHERE s.`name` = store_name
	ORDER BY e.`salary` DESC
	LIMIT 1);
	
END//
DELIMITER ;


-- 11
DELIMITER //
CREATE PROCEDURE udp_update_product_price(address_name VARCHAR (50))
BEGIN
	UPDATE `products` AS p
    JOIN `products_stores` AS ps
    ON p.`id` = ps.`product_id`
    JOIN `stores` AS s
    ON ps.`store_id` = s.`id`
    JOIN `addresses` AS a
    ON s. `address_id` = a.`id`
    SET p.`price` = (
    CASE 
    WHEN LEFT(a.`name`,1) = 0 THEN
    p.`price` +100
    ELSE p.`price` +200
    END
    )
    WHERE a.`name` = address_name;
END//
DELIMITER ; 


CALL udp_update_product_price('1 Cody Pass');
SELECT name, price FROM products WHERE id = 17;

