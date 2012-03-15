-- phpMyAdmin SQL Dump
-- version 3.1.0
-- http://www.phpmyadmin.net
--
-- Host: 127.0.0.1:3307
-- Generation Time: Feb 24, 2009 at 09:53 AM
-- Server version: 5.0.67
-- PHP Version: 5.2.4-2ubuntu5.4

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";

--
-- Database: `webcam_processing`
--

-- --------------------------------------------------------

--
-- Table structure for table `channels`
--

DROP TABLE IF EXISTS `channels`;
CREATE TABLE IF NOT EXISTS `channels` (
  `Channel_ID` smallint(6) NOT NULL auto_increment COMMENT 'id to identify each channel',
  `name` varchar(128) character set latin1 NOT NULL COMMENT 'Name of the channel',
  `notes` varchar(2048) character set latin1 default NULL COMMENT 'any notes',
  PRIMARY KEY  (`Channel_ID`),
  KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=14 ;

-- --------------------------------------------------------

--
-- Table structure for table `experiments`
--

DROP TABLE IF EXISTS `experiments`;
CREATE TABLE IF NOT EXISTS `experiments` (
  `Experiment_ID` smallint(6) NOT NULL auto_increment COMMENT 'id to identify each experiment',
  `name` varchar(128) character set latin1 NOT NULL COMMENT 'Name of the Experiment',
  `notes` varchar(2048) character set latin1 default NULL COMMENT 'any notes',
  PRIMARY KEY  (`Experiment_ID`),
  KEY `name` (`name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=11 ;

-- --------------------------------------------------------

--
-- Table structure for table `Gnuplot_Graph_Table`
--

DROP TABLE IF EXISTS `Gnuplot_Graph_Table`;
CREATE TABLE IF NOT EXISTS `Gnuplot_Graph_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `GNUPLOT_COMMAND` text character set latin1 NOT NULL,
  `GNUPLOT_DATA` blob NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii COLLATE=ascii_bin AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `Histogram_Table`
--

DROP TABLE IF EXISTS `Histogram_Table`;
CREATE TABLE IF NOT EXISTS `Histogram_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` blob,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii COMMENT='holds histograms for an image' AUTO_INCREMENT=7078095 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `HISTOGRAM_VIEW`
--
DROP VIEW IF EXISTS `HISTOGRAM_VIEW`;
CREATE TABLE IF NOT EXISTS `HISTOGRAM_VIEW` (
`ID` int(10) unsigned
,`DATA` blob
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Table structure for table `Image_Data_Table`
--

DROP TABLE IF EXISTS `Image_Data_Table`;
CREATE TABLE IF NOT EXISTS `Image_Data_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `Image_Data` blob NOT NULL,
  `Image_Data_Type` varchar(3) character set ascii collate ascii_bin NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=898414 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `IMAGE_DATA_VIEW`
--
DROP VIEW IF EXISTS `IMAGE_DATA_VIEW`;
CREATE TABLE IF NOT EXISTS `IMAGE_DATA_VIEW` (
`ID` int(10) unsigned
,`DATA` blob
,`DATA_TYPE` varchar(3)
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Stand-in structure for view `INCANDESCENT_VIEW`
--
DROP VIEW IF EXISTS `INCANDESCENT_VIEW`;
CREATE TABLE IF NOT EXISTS `INCANDESCENT_VIEW` (
`id` int(10) unsigned
,`image_date` datetime
,`DATA` float
);
-- --------------------------------------------------------

--
-- Table structure for table `Max_Table`
--

DROP TABLE IF EXISTS `Max_Table`;
CREATE TABLE IF NOT EXISTS `Max_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8448709 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `MAX_VIEW`
--
DROP VIEW IF EXISTS `MAX_VIEW`;
CREATE TABLE IF NOT EXISTS `MAX_VIEW` (
`ID` int(10) unsigned
,`DATA` float
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Table structure for table `Mean_Table`
--

DROP TABLE IF EXISTS `Mean_Table`;
CREATE TABLE IF NOT EXISTS `Mean_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8448634 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `MEAN_VIEW`
--
DROP VIEW IF EXISTS `MEAN_VIEW`;
CREATE TABLE IF NOT EXISTS `MEAN_VIEW` (
`ID` int(10) unsigned
,`DATA` float
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Table structure for table `Min_Table`
--

DROP TABLE IF EXISTS `Min_Table`;
CREATE TABLE IF NOT EXISTS `Min_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8448767 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `MIN_VIEW`
--
DROP VIEW IF EXISTS `MIN_VIEW`;
CREATE TABLE IF NOT EXISTS `MIN_VIEW` (
`ID` int(10) unsigned
,`DATA` float
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Table structure for table `New_Stats`
--

DROP TABLE IF EXISTS `New_Stats`;
CREATE TABLE IF NOT EXISTS `New_Stats` (
  `Stat_ID` int(10) unsigned NOT NULL auto_increment,
  `src_file_id` int(11) unsigned NOT NULL,
  `Table_id` int(11) NOT NULL default '0',
  `Table_key` int(10) unsigned NOT NULL,
  `Experiment_id` smallint(6) NOT NULL,
  `Channel` smallint(6) NOT NULL default '0',
  PRIMARY KEY  (`Stat_ID`),
  KEY `Table_id` (`Table_id`),
  KEY `src_file_id` (`src_file_id`),
  KEY `Experiment_id` (`Experiment_id`),
  KEY `Table_key` (`Table_key`),
  KEY `Channel` (`Channel`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=42781292 ;

-- --------------------------------------------------------

--
-- Table structure for table `not_useful_images`
--

DROP TABLE IF EXISTS `not_useful_images`;
CREATE TABLE IF NOT EXISTS `not_useful_images` (
  `Camera_ID` int(11) NOT NULL,
  `src_file_id` int(11) NOT NULL,
  `Stat_ID` int(11) NOT NULL,
  `useful_id` int(11) NOT NULL auto_increment,
  `criteria` varchar(256) character set latin1 default NULL,
  PRIMARY KEY  (`useful_id`),
  KEY `Camera_ID` (`Camera_ID`,`src_file_id`,`Stat_ID`)
) ENGINE=InnoDB DEFAULT CHARSET=ascii AUTO_INCREMENT=1 ;

-- --------------------------------------------------------

--
-- Table structure for table `src_camera_table`
--

DROP TABLE IF EXISTS `src_camera_table`;
CREATE TABLE IF NOT EXISTS `src_camera_table` (
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

DROP TABLE IF EXISTS `src_files_table`;
CREATE TABLE IF NOT EXISTS `src_files_table` (
  `id` int(10) unsigned NOT NULL auto_increment,
  `src_camera` int(10) NOT NULL,
  `image_date` datetime NOT NULL,
  `filename` varchar(1024) character set latin1 default NULL,
  `remote_URL` varchar(1024) character set latin1 default NULL,
  `corrupt` tinyint(1) NOT NULL,
  PRIMARY KEY  (`id`),
  UNIQUE KEY `unique_image` (`src_camera`,`image_date`),
  KEY `image_date` (`image_date`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=583482 ;

-- --------------------------------------------------------

--
-- Table structure for table `Stats_Tables`
--

DROP TABLE IF EXISTS `Stats_Tables`;
CREATE TABLE IF NOT EXISTS `Stats_Tables` (
  `Table_id` int(11) NOT NULL auto_increment,
  `Table_Name` varchar(32) character set latin1 NOT NULL,
  PRIMARY KEY  (`Table_id`),
  KEY `Table_Name` (`Table_Name`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=9 ;

-- --------------------------------------------------------

--
-- Table structure for table `sub_region_table`
--

DROP TABLE IF EXISTS `sub_region_table`;
CREATE TABLE IF NOT EXISTS `sub_region_table` (
  `region_id` int(11) NOT NULL auto_increment,
  `Camera_id` int(11) NOT NULL,
  `Name` varchar(256) character set latin1 NOT NULL,
  `TL_X` int(11) NOT NULL,
  `TL_Y` int(11) NOT NULL,
  `Width` int(11) NOT NULL,
  `Height` int(11) NOT NULL,
  PRIMARY KEY  (`region_id`),
  KEY `Camera_id` (`Camera_id`)
) ENGINE=InnoDB  DEFAULT CHARSET=ascii AUTO_INCREMENT=16 ;

-- --------------------------------------------------------

--
-- Table structure for table `Thermal_Flux_Table`
--

DROP TABLE IF EXISTS `Thermal_Flux_Table`;
CREATE TABLE IF NOT EXISTS `Thermal_Flux_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=223901 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `THERMAL_FLUX_VIEW`
--
DROP VIEW IF EXISTS `THERMAL_FLUX_VIEW`;
CREATE TABLE IF NOT EXISTS `THERMAL_FLUX_VIEW` (
`ID` int(10) unsigned
,`DATA` float
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Table structure for table `Variance_Table`
--

DROP TABLE IF EXISTS `Variance_Table`;
CREATE TABLE IF NOT EXISTS `Variance_Table` (
  `ID` int(10) unsigned NOT NULL auto_increment,
  `DATA` float NOT NULL,
  PRIMARY KEY  (`ID`)
) ENGINE=InnoDB  DEFAULT CHARSET=latin1 AUTO_INCREMENT=8448806 ;

-- --------------------------------------------------------

--
-- Stand-in structure for view `VARIANCE_VIEW`
--
DROP VIEW IF EXISTS `VARIANCE_VIEW`;
CREATE TABLE IF NOT EXISTS `VARIANCE_VIEW` (
`ID` int(10) unsigned
,`DATA` float
,`Stat_ID` int(10) unsigned
,`src_file_id` int(11) unsigned
,`Table_id` int(11)
,`Table_key` int(10) unsigned
,`Experiment_id` smallint(6)
,`Channel` smallint(6)
);
-- --------------------------------------------------------

--
-- Structure for view `HISTOGRAM_VIEW`
--
DROP TABLE IF EXISTS `HISTOGRAM_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'HISTOGRAM_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `IMAGE_DATA_VIEW`
--
DROP TABLE IF EXISTS `IMAGE_DATA_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'IMAGE_DATA_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `INCANDESCENT_VIEW`
--
DROP TABLE IF EXISTS `INCANDESCENT_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'INCANDESCENT_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `MAX_VIEW`
--
DROP TABLE IF EXISTS `MAX_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'MAX_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `MEAN_VIEW`
--
DROP TABLE IF EXISTS `MEAN_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'MEAN_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `MIN_VIEW`
--
DROP TABLE IF EXISTS `MIN_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'MIN_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `THERMAL_FLUX_VIEW`
--
DROP TABLE IF EXISTS `THERMAL_FLUX_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'THERMAL_FLUX_VIEW')

-- --------------------------------------------------------

--
-- Structure for view `VARIANCE_VIEW`
--
DROP TABLE IF EXISTS `VARIANCE_VIEW`;
-- in use(#1142 - SHOW VIEW command denied to user 'jlovick'@'localhost' for table 'VARIANCE_VIEW')

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


INSERT INTO `channels` (`Channel_ID`, `name`, `notes`) VALUES
(9, 'grey', 'combined r,g,b'),
(10, 'red', NULL),
(11, 'blue', NULL),
(12, 'green', NULL),
(13, 'combined', 'like grey but sqrt(r^2 + g^2 + b^2)');


INSERT INTO `experiments` (`Experiment_ID`, `name`, `notes`) VALUES
(1, 'crater - control', NULL),
(2, 'Initial Histograms', NULL),
(3, 'luminesence_enhance', NULL),
(4, 'luminesence_enhance_control1', NULL),
(5, 'luminesence_enhance_control2', NULL),
(6, 'luminesence_enhance_control3', NULL),
(7, 'Mean_Control', 'an average of all the control regions'),
(8, 'make_basic_stats', 'go through and do stats without the luminance enhance'),
(9, 'make_basic_stats_b', NULL),
(10, 'make_basic_stats_c', NULL);

INSERT INTO `src_camera_table` (`id`, `camera_name`, `camera_url`, `image_width`, `image_height`, `region_id`, `notes`) VALUES
(1, 'St_Helens_Hi_res', 'http://www.fs.fed.us/gpnf/volcanocams/msh/hdimages/volcanocamhd.jpg', 1024, 768, 2, NULL),
(2, 'St_Helens_Low_res', 'http://www.fs.fed.us/gpnf/volcanocams/msh/images/mshvolcanocam.jpg', 640, 480, 3, NULL),
(3, 'Shiveluch', 'http://data.emsd.iks.ru/videosvl/latest.jpg', 720, 576, 4, NULL),
(4, 'Bezymianny', 'http://data.emsd.iks.ru/videokzy/latest.jpg', 720, 576, 5, NULL),
(5, 'Klyuchevskoy', 'http://data.emsd.iks.ru/video/latest.jpg', 720, 576, 6, NULL),
(6, 'Augustine', 'http://avosouth.wr.usgs.gov/cam/augustine/', 1113, 835, 7, NULL),
(7, 'Augustine Lagoon', 'http://avosouth.wr.usgs.gov/cam/aug_lagoon/', 320, 240, 0, NULL),
(8, 'Augustine Mound', 'http://avosouth.wr.usgs.gov/cam/aug_mound/', 640, 480, 0, NULL),
(9, 'Veniaminof', 'http://avosouth.wr.usgs.gov/cam/veni/', 640, 480, 8, NULL);


INSERT INTO `Stats_Tables` (`Table_id`, `Table_Name`) VALUES
(7, 'Gnuplot_Graph_Table'),
(1, 'Histogram_Table'),
(6, 'Image_Data_Table'),
(3, 'Max_Table'),
(2, 'Mean_Table'),
(4, 'Min_Table'),
(8, 'Thermal_Flux_Table'),
(5, 'Variance_Table');



INSERT INTO `sub_region_table` (`region_id`, `Camera_id`, `Name`, `TL_X`, `TL_Y`, `Width`, `Height`) VALUES
(1, 2, 'Around the new dome', 185, 62, 362, 164),
(2, 1, 'Full', 0, 60, 1024, 708),
(3, 2, 'Full', 0, 25, 640, 430),
(4, 3, 'Full', 0, 0, 720, 572),
(5, 4, 'Full', 0, 0, 720, 572),
(6, 5, 'Full', 0, 0, 720, 562),
(7, 6, 'Full', 61, 54, 1166, 875),
(8, 9, 'Full', 13, 28, 615, 321),
(9, 2, 'St_Helens_Control_Area_1', 185, 136, 32, 32),
(10, 2, 'St_Helens_Control_Area_2', 422, 137, 32, 32),
(11, 2, 'St_Helens_lumi_small_1', 359, 139, 71, 36),
(12, 2, 'St_Helens_Control_Area_3', 106, 46, 366, 54),
(13, 5, 'klui_control_sky', 42, 23, 640, 117),
(14, 5, 'klui_control_volc_base', 318, 394, 186, 49),
(15, 5, 'klui_summit', 352, 206, 305, 172);


