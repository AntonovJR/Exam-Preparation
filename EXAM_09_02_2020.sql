
CREATE TABLE `coaches`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`salary` DECIMAL(10,2) NOT NULL DEFAULT 0,
`coach_level` INT NOT NULL DEFAULT 0
);

CREATE TABLE `skills_data`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`dribbling` INT DEFAULT 0,
`pace` INT DEFAULT 0,
`passing` INT DEFAULT 0,
`shooting` INT DEFAULT 0,
`speed` INT DEFAULT 0,
`strength` INT DEFAULT 0
);

CREATE TABLE `countries`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(45) NOT NULL
);

CREATE TABLE `towns`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(45) NOT NULL,
`country_id` INT NOT NULL,
CONSTRAINT fk_country_id
FOREIGN KEY(`country_id`)
REFERENCES `countries`(`id`)
);

CREATE TABLE `stadiums`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(45) NOT NULL,
`capacity` INT NOT NULL,
`town_id` INT NOT NULL,
CONSTRAINT fk_town_id
FOREIGN KEY(`town_id`)
REFERENCES `towns`(`id`)
);

CREATE TABLE `teams`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`name` VARCHAR(45) NOT NULL,
`established` DATE NOT NULL,
`fan_base` BIGINT NOT NULL DEFAULT 0,
`stadium_id` INT NOT NULL,
CONSTRAINT fk_stadium_id
FOREIGN KEY(`stadium_id`)
REFERENCES `stadiums`(`id`)
);

CREATE TABLE `players`(
`id` INT PRIMARY KEY AUTO_INCREMENT NOT NULL UNIQUE,
`first_name` VARCHAR(10) NOT NULL,
`last_name` VARCHAR(20) NOT NULL,
`age` INT NOT NULL DEFAULT 0,
`position` CHAR NOT NULL,
`salary` DECIMAL(10,2) NOT NULL DEFAULT 0,
`hire_date` DATETIME,
`skills_data_id` INT NOT NULL,
`team_id` INT,
CONSTRAINT fk_skills_id
FOREIGN KEY(`skills_data_id`)
REFERENCES `skills_data`(`id`),
CONSTRAINT fk_team_id
FOREIGN KEY(`team_id`)
REFERENCES `teams`(`id`)
);

CREATE TABLE `players_coaches`(
`player_id` INT,
`coach_id` INT,
CONSTRAINT fk_player_id
FOREIGN KEY(`player_id`)
REFERENCES `players`(`id`),
CONSTRAINT fk_coach_id
FOREIGN KEY(`coach_id`)
REFERENCES `coaches`(`id`)
);

-- 2
INSERT INTO `coaches` (`first_name`,`last_name`, `salary`, `coach_level`)
SELECT `first_name`, `last_name`, `salary`, CHAR_LENGTH(`first_name`) FROM `players`
WHERE `age` >= 45;

-- 3

UPDATE `coaches` 
SET `coach_level` = `coach_level` + 1
WHERE `first_name` LIKE 'A%' 
AND `id` = (SELECT `coach_id` FROM `players_coaches` WHERE `coach_id` =  `id` LIMIT 1);

-- 4
DELETE FROM `players`
WHERE `age`>=45;

-- 5
SELECT `first_name`, `age`, `salary` FROM `players`
ORDER BY `salary` DESC;

-- 6
SELECT p.`id`, CONCAT(p.`first_name`,' ', p.`last_name`) AS 'full_name', 
p.`age`, p.`position`, p.`hire_date` FROM `players` AS p
JOIN `skills_data` AS s ON p.`skills_data_id` = s.`id`
WHERE `age`<23 AND `position` = 'A' AND `hire_date` IS NULL AND s.`strength` >50
ORDER BY p.`salary` ASC, p.`age`;

-- 7
SELECT `name` AS 'team_name', `established`, `fan_base`, COUNT(p.`id`) AS 'players_count' FROM `teams` AS t
LEFT JOIN `players` AS p ON p.`team_id` = t.`id`
GROUP BY t.`id`
ORDER BY COUNT(p.`id`) DESC, `fan_base` DESC;

-- 8
SELECT MAX(sd.`speed`) AS 'max_speed', tw.`name` AS `town_name`
FROM players AS p 
RIGHT JOIN `skills_data` AS sd ON p.`skills_data_id` = sd.`id`
RIGHT JOIN `teams` AS t ON p.`team_id` = t.`id`
RIGHT JOIN `stadiums` AS s ON t.`stadium_id`= s.`id`
RIGHT JOIN `towns` AS tw ON s.`town_id` = tw.`id`
WHERE t.`name` != 'Devify'
GROUP BY tw.`name`
ORDER BY max_speed DESC, tw.`name`;

-- 9
SELECT c.`name`, COUNT(p.`id`) AS 'total_count_of_players', 
SUM(p.`salary`) AS 'total_sum_of_salaries'
FROM `countries` AS c
LEFT JOIN `towns` AS t ON c.`id` = t.`country_id`
LEFT JOIN `stadiums` AS s ON t.`id` = s.`town_id`
LEFT JOIN `teams` AS ts ON s.`id` = ts.`stadium_id`
LEFT JOIN `players` AS p  ON ts.`id` = p.`team_id`
GROUP BY c.`id`
ORDER BY total_count_of_players DESC, c.`name`;

-- 10
DELIMITER //
CREATE FUNCTION udf_stadium_players_count(stadium_name VARCHAR(30))
RETURNS INT DETERMINISTIC
BEGIN
DECLARE `player_count` INT;
SET `player_count` := 
(SELECT COUNT(p.`id`) FROM `players` AS p
JOIN `teams` AS t ON p.`team_id` = t.`id`
JOIN `stadiums` AS s ON t.`stadium_id` = s.`id`
WHERE s.`name` = stadium_name);
RETURN `player_count`;
END //
DELIMITER ; 

SELECT udf_stadium_players_count('Jaxworks');

-- 11
DELIMITER //
CREATE PROCEDURE udp_find_playmaker(min_dribble_points INT,team_name VARCHAR(45))
BEGIN
SELECT CONCAT(`first_name`,' ',`last_name`) AS 'full_name', `age`, `salary`, sd.`dribbling`, sd.`speed`, t.`name` FROM `players` AS e
JOIN `skills_data` AS sd ON e.`skills_data_id` = sd.`id`
JOIN `teams` AS t ON e.`team_id` = t.`id`
WHERE t.`name` = team_name AND sd.`dribbling`> min_dribble_points
ORDER BY sd.`speed` DESC LIMIT 1;
END //
DELIMITER ; 

CALL udp_find_playmaker(20, 'Skyble');