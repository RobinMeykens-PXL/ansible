-- phpMyAdmin SQL Dump
-- version 4.8.0.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Gegenereerd op: 29 feb 2020 om 17:22
-- Serverversie: 10.1.32-MariaDB
-- PHP-versie: 7.2.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `employees`
--
CREATE DATABASE IF NOT EXISTS `employees` DEFAULT CHARACTER SET utf8 COLLATE utf8_general_ci;
USE `employees`;

-- --------------------------------------------------------

--
-- Tabelstructuur voor tabel `employees`
--

DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees` (
  `emp_no` int(11) NOT NULL,
  `first_name` varchar(120) NOT NULL,
  `last_name` varchar(120) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Gegevens worden geëxporteerd voor tabel `employees`
--

INSERT INTO `employees` (`emp_no`, `first_name`, `last_name`) VALUES
(1001, 'Dries', 'Swinnen'),
(1002, 'Maarten', 'Sourbron'),
(1003, 'Lode', 'Van Hout'),
(1004, 'Tim', 'Dupont'),
(1005, 'David', 'Parren'),
(1006, 'Gert', 'Van Waeyenberg');

--
-- Indexen voor geëxporteerde tabellen
--

--
-- Indexen voor tabel `employees`
--
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
