-- phpMyAdmin SQL Dump
-- version 3.4.5deb1
-- http://www.phpmyadmin.net
--
-- Host: localhost
-- Generation Time: Mar 22, 2012 at 04:46 PM
-- Server version: 5.1.61
-- PHP Version: 5.3.6-13ubuntu3.6

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Database: `webcam_processing`
--

-- --------------------------------------------------------

--
-- Table structure for table `channels`
--

CREATE TABLE IF NOT EXISTS `channels` (
  `Channel_ID` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'id to identify each channel',
  `name` varchar(128) CHARACTER SET latin1 NOT NULL COMMENT 'Name of the channel',
  `notes` varchar(2048) CHARACTER SET latin1 DEFAULT NULL COMMENT 'any notes',
  PRIMARY KEY (`Channel_ID`),
  KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=14 ;

-- --------------------------------------------------------

--
-- Table structure for table `experiments`
--

CREATE TABLE IF NOT EXISTS `experiments` (
  `Experiment_ID` smallint(6) NOT NULL AUTO_INCREMENT COMMENT 'id to identify each experiment',
  `name` varchar(128) CHARACTER SET latin1 NOT NULL COMMENT 'Name of the Experiment',
  `notes` varchar(2048) CHARACTER SET latin1 DEFAULT NULL COMMENT 'any notes',
  PRIMARY KEY (`Experiment_ID`),
  KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=11 ;

-- --------------------------------------------------------

--
-- Table structure for table `Gnuplot_Graph_Table`
--

CREATE TABLE IF NOT EXISTS `Gnuplot_Graph_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `GNUPLOT_COMMAND` text CHARACTER SET latin1 NOT NULL,
  `GNUPLOT_DATA` blob NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `Histogram_Table`
--

CREATE TABLE IF NOT EXISTS `Histogram_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATA` blob,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COMMENT='holds histograms for an image' AUTO_INCREMENT=7083249 ;

-- --------------------------------------------------------

--
-- Table structure for table `Image_Data_Table`
--

CREATE TABLE IF NOT EXISTS `Image_Data_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `Image_Data` blob NOT NULL,
  `Image_Data_Type` varchar(3) CHARACTER SET ascii COLLATE ascii_bin NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=898414 ;

-- --------------------------------------------------------

--
-- Table structure for table `Max_Table`
--

CREATE TABLE IF NOT EXISTS `Max_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATA` float NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8453867 ;

-- --------------------------------------------------------

--
-- Table structure for table `Mean_Table`
--

CREATE TABLE IF NOT EXISTS `Mean_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATA` float NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8453792 ;

-- --------------------------------------------------------

--
-- Table structure for table `Min_Table`
--

CREATE TABLE IF NOT EXISTS `Min_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATA` float NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8453925 ;

-- --------------------------------------------------------

--
-- Table structure for table `New_Stats`
--

CREATE TABLE IF NOT EXISTS `New_Stats` (
  `Stat_ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `timestamp` date NOT NULL,
  `src_file_id` int(11) unsigned NOT NULL,
  `Table_id` int(11) NOT NULL DEFAULT '0',
  `Table_key` int(10) unsigned NOT NULL,
  `Experiment_id` smallint(6) NOT NULL,
  `Channel` smallint(6) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Stat_ID`),
  KEY `Table_id` (`Table_id`),
  KEY `src_file_id` (`src_file_id`),
  KEY `Experiment_id` (`Experiment_id`),
  KEY `Table_key` (`Table_key`),
  KEY `Channel` (`Channel`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=42807010 ;

-- --------------------------------------------------------

--
-- Table structure for table `not_useful_images`
--

CREATE TABLE IF NOT EXISTS `not_useful_images` (
  `Camera_ID` int(11) NOT NULL,
  `src_file_id` int(11) NOT NULL,
  `Stat_ID` int(11) NOT NULL,
  `useful_id` int(11) NOT NULL AUTO_INCREMENT,
  `criteria` varchar(256) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`useful_id`),
  KEY `Camera_ID` (`Camera_ID`,`src_file_id`,`Stat_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `src_camera_table`
--

CREATE TABLE IF NOT EXISTS `src_camera_table` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `camera_name` varchar(256) CHARACTER SET latin1 NOT NULL,
  `camera_url` varchar(1024) CHARACTER SET latin1 NOT NULL COMMENT 'url',
  `image_width` int(10) unsigned NOT NULL,
  `image_height` int(10) unsigned NOT NULL,
  `region_id` int(11) NOT NULL,
  `notes` varchar(4096) CHARACTER SET latin1 DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

--
-- Table structure for table `src_files_table`
--

CREATE TABLE IF NOT EXISTS `src_files_table` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `src_camera` int(10) NOT NULL,
  `image_date` datetime NOT NULL,
  `filename` varchar(1024) CHARACTER SET latin1 DEFAULT NULL,
  `remote_URL` varchar(1024) CHARACTER SET latin1 DEFAULT NULL,
  `corrupt` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_image` (`src_camera`,`image_date`),
  KEY `image_date` (`image_date`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=855415 ;

-- --------------------------------------------------------

--
-- Table structure for table `Stats_Tables`
--

CREATE TABLE IF NOT EXISTS `Stats_Tables` (
  `Table_id` int(11) NOT NULL AUTO_INCREMENT,
  `Table_Name` varchar(32) CHARACTER SET latin1 NOT NULL,
  PRIMARY KEY (`Table_id`),
  KEY `Table_Name` (`Table_Name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

--
-- Table structure for table `sub_region_table`
--

CREATE TABLE IF NOT EXISTS `sub_region_table` (
  `region_id` int(11) NOT NULL AUTO_INCREMENT,
  `Camera_id` int(11) NOT NULL,
  `Name` varchar(256) CHARACTER SET latin1 NOT NULL,
  `TL_X` int(11) NOT NULL,
  `TL_Y` int(11) NOT NULL,
  `Width` int(11) NOT NULL,
  `Height` int(11) NOT NULL,
  PRIMARY KEY (`region_id`),
  KEY `Camera_id` (`Camera_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Table structure for table `Thermal_Flux_Table`
--

CREATE TABLE IF NOT EXISTS `Thermal_Flux_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATA` float NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=223901 ;

-- --------------------------------------------------------

--
-- Table structure for table `Variance_Table`
--

CREATE TABLE IF NOT EXISTS `Variance_Table` (
  `ID` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `DATA` float NOT NULL,
  PRIMARY KEY (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8453963 ;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `New_Stats`
--
ALTER TABLE `New_Stats`
  ADD CONSTRAINT `new_fk_constraint` FOREIGN KEY (`Channel`) REFERENCES `channels` (`Channel_ID`) ON DELETE NO ACTION,
  ADD CONSTRAINT `New_Stats_ibfk_4` FOREIGN KEY (`src_file_id`) REFERENCES `src_files_table` (`id`) ON DELETE NO ACTION,
  ADD CONSTRAINT `New_Stats_ibfk_5` FOREIGN KEY (`Table_id`) REFERENCES `Stats_Tables` (`Table_id`) ON DELETE NO ACTION,
  ADD CONSTRAINT `New_Stats_ibfk_6` FOREIGN KEY (`Experiment_id`) REFERENCES `experiments` (`Experiment_ID`) ON DELETE NO ACTION;

--
-- Constraints for table `src_files_table`
--
ALTER TABLE `src_files_table`
  ADD CONSTRAINT `src_files_table_ibfk_1` FOREIGN KEY (`src_camera`) REFERENCES `src_camera_table` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
