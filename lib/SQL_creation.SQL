-- phpMyAdmin SQL Dump
-- version 2.10.0.2
-- http://www.phpmyadmin.net
-- 
-- Host: localhost
-- Generation Time: Nov 04, 2008 at 01:54 PM
-- Server version: 5.0.51
-- PHP Version: 5.2.4-2ubuntu5.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

-- 
-- Database: `webcam_processing`
-- 

-- --------------------------------------------------------

-- 
-- Table structure for table `experiments`
-- 

CREATE TABLE `experiments` (
  `Experiment_ID` smallint(6) NOT NULL auto_increment COMMENT 'id to identify each experiment',
  `name` varchar(128) character set latin1 NOT NULL COMMENT 'Name of the Experiment',
  `notes` varchar(2048) character set latin1 default NULL COMMENT 'any notes',
  PRIMARY KEY  (`Experiment_ID`),
  KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Gnuplot_Graph_Tabls`
-- 

CREATE TABLE `Gnuplot_Graph_Tabls` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `GNUPLOT_COMMAND` text NOT NULL,
  `GNUPLOT_DATA` blob NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Histogram_Table`
-- 

CREATE TABLE `Histogram_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` blob,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COMMENT='holds histograms for an image' AUTO_INCREMENT=2 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Image_Data_Table`
-- 

CREATE TABLE `Image_Data_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `Image_Data` blob NOT NULL,
  `Image_Data_Type` varchar(3) character set ascii collate ascii_bin NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Max_Table`
-- 

CREATE TABLE `Max_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Mean_Table`
-- 

CREATE TABLE `Mean_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=6 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Min_Table`
-- 

CREATE TABLE `Min_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `New_Stats`
-- 

CREATE TABLE `New_Stats` (
  `Stat_ID` int(10) unsigned NOT NULL auto_increment,
  `src_file_id` int(11) unsigned NOT NULL,
  `Table_id` int(11) NOT NULL default '0',
  `Table_key` int(10) unsigned NOT NULL,
  `Experiment_id` smallint(6) NOT NULL,
  PRIMARY KEY  (`Stat_ID`),
  KEY `Table_id` (`Table_id`),
  KEY `src_file_id` (`src_file_id`),
  KEY `Experiment_id` (`Experiment_id`),
  KEY `Table_key` (`Table_key`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=4 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `not_useful_images`
-- 

CREATE TABLE `not_useful_images` (
  `Camera_ID` int(11) NOT NULL,
  `src_file_id` int(11) NOT NULL,
  `Stat_ID` int(11) NOT NULL,
  `useful_id` int(11) NOT NULL auto_increment,
  `criteria` varchar(256) character set latin1 default NULL,
  PRIMARY KEY  (`useful_id`),
  KEY `Camera_ID` (`Camera_ID`,`src_file_id`,`Stat_ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=286194 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `src_camera_table`
-- 

CREATE TABLE `src_camera_table` (
  `id` int(11) NOT NULL auto_increment,
  `camera_name` varchar(256) character set latin1 NOT NULL,
  `camera_url` varchar(1024) character set latin1 NOT NULL COMMENT 'url',
  `image_width` int(10) unsigned NOT NULL,
  `image_height` int(10) unsigned NOT NULL,
  `region_id` int(11) NOT NULL,
  `notes` varchar(4096) character set latin1 default NULL,
  PRIMARY KEY  (`id`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=10 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `src_files_table`
-- 

CREATE TABLE `src_files_table` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `src_camera` int(10) NOT NULL,
  `image_date` datetime NOT NULL,
  `filename` varchar(1024) character set latin1 default NULL,
  `remote_URL` varchar(1024) character set latin1 default NULL,
  `corrupt` tinyint(1) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `unique_image` (`src_camera`,`image_date`),
  KEY `image_date` (`image_date`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=1879154 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `statistics`
-- 

CREATE TABLE `statistics` (
  `Stat_ID` int(11) NOT NULL auto_increment,
  `src_file_ID` int(11) NOT NULL,
  `Experiment_ID` tinyint(4) NOT NULL,
  `Region` varchar(32) character set latin1 NOT NULL,
  `Mean` float NOT NULL,
  `Max` float NOT NULL,
  `Min` float NOT NULL,
  `Variance` float NOT NULL,
  `Channel` varchar(16) character set latin1 NOT NULL,
  `Histogram` blob NOT NULL,
  PRIMARY KEY  (`Stat_ID`),
  KEY `src_file_ID` (`src_file_ID`),
  KEY `Experiment_ID` (`Experiment_ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=8527981 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Stats_Tables`
-- 

CREATE TABLE `Stats_Tables` (
  `Table_id` int(11) NOT NULL auto_increment,
  `Table_Name` varchar(32) character set latin1 NOT NULL,
  PRIMARY KEY  (`Table_id`),
  KEY `Table_Name` (`Table_Name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `sub_region_table`
-- 

CREATE TABLE `sub_region_table` (
  `region_id` int(11) NOT NULL auto_increment,
  `Camera_id` int(11) NOT NULL,
  `Name` varchar(256) character set latin1 NOT NULL,
  `TL_X` int(11) NOT NULL,
  `TL_Y` int(11) NOT NULL,
  `Width` int(11) NOT NULL,
  `Height` int(11) NOT NULL,
  PRIMARY KEY  (`region_id`),
  KEY `Camera_id` (`Camera_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=12 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Thermal_Flux_Table`
-- 

CREATE TABLE `Thermal_Flux_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

-- 
-- Table structure for table `Variance_Table`
-- 

CREATE TABLE `Variance_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1 AUTO_INCREMENT=1 ;

-- 
-- Constraints for dumped tables
-- 

-- 
-- Constraints for table `New_Stats`
-- 
ALTER TABLE `New_Stats`
  ADD CONSTRAINT `New_Stats_ibfk_4` FOREIGN KEY (`src_file_id`) REFERENCES `src_files_table` (`id`) ON DELETE NO ACTION,
  ADD CONSTRAINT `New_Stats_ibfk_5` FOREIGN KEY (`Table_id`) REFERENCES `Stats_Tables` (`Table_id`) ON DELETE NO ACTION,
  ADD CONSTRAINT `New_Stats_ibfk_6` FOREIGN KEY (`Experiment_id`) REFERENCES `experiments` (`Experiment_ID`) ON DELETE NO ACTION;

-- 
-- Constraints for table `src_files_table`
-- 
ALTER TABLE `src_files_table`
  ADD CONSTRAINT `src_files_table_ibfk_1` FOREIGN KEY (`src_camera`) REFERENCES `src_camera_table` (`id`) ON DELETE NO ACTION ON UPDATE NO ACTION;
