SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

CREATE DATABASE IF NOT EXISTS `employees` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `employees`;

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
  `emp_no` int(11) NOT NULL,
  `first_name` varchar(120) NOT NULL,
  `last_name` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `employees` (`emp_no`, `first_name`, `last_name`) VALUES
(1001, 'Dries', 'Swinnen'),
(1002, 'Maarten', 'Sourbron'),
(1003, 'Lode', 'Van Hout'),
(1004, 'Tim', 'Dupont'),
(1005, 'David', 'Parren'),
(1006, 'Gert', 'Van Waeyenberg');

ALTER TABLE `employees`
  ADD PRIMARY KEY (`emp_no`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'ventieldopje24';
CREATE USER 'mysql'@'10.0.0.0/24' IDENTIFIED BY 'ventieldopje24';
GRANT SELECT, INSERT ON employees.employees TO 'mysql'@'localhost';
GRANT SELECT, INSERT ON employees.employees TO 'mysql'@'10.0.0.0/24';
