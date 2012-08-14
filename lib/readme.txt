==

  to run 
    > ruby main.rb 

  it should give you lots of command line options

  useful sql is  bellow that will help pull things out of the database

  this was writen primarily in ruby 1.8.7 which only has softthreads, that did not work well with hornetseye

  the shell scripts provide a way of subdiving a problem and distributing it to various different machines.

  it is often easier to write a small program to grab just what you need for analysis of your data 
  rather than use the main, ingestion analysis program, database_dump_bright.rb is inteded to be example
  of how to do this.

   
==



SELECT DISTINCT src_file_id, `Stat_ID` , lt.image_date, statistics.max
FROM statistics
JOIN (

SELECT id, src_camera, image_date
FROM `src_files_table`
WHERE src_camera =2
) AS lt
WHERE (
(
statistics.src_file_id = lt.id
)
AND (
(
statistics.experiment = "luminesence_enhance"
)
AND (
statistics.max <300
)
)
) 


this involes the time of day so we jsut get the night images

SELECT DISTINCT src_file_id, `Stat_ID` , lt.image_date, statistics.max,  statistics.max, statistics.mean, statistics.Variance
FROM statistics
JOIN (

SELECT id, src_camera, image_date
FROM `src_files_table`
WHERE src_camera =2
) AS lt
WHERE (
(
statistics.src_file_id = lt.id
) AND (
( statistics.experiment = "luminesence_enhance" )
        AND ( statistics.max <300 )
        AND (( (TIME(lt.image_date) > TIME('20:00') ) 
            OR 
            ( TIME(lt.image_date) < TIME('06:00') ) 
            )
        )
)
)


-------------------------
SELECT sft.id, sft.image_date, tfv.DATA
FROM `THERMAL_FLUX_VIEW` AS tfv, `MAX_VIEW` AS mx, `MEAN_VIEW` AS mn, src_files_table AS sft
WHERE (
mx.`src_file_id` = mn.`src_file_id`
AND tfv.`src_file_id` = mn.`src_file_id`
AND sft.`id` = mn.`src_file_id`
)
AND (
mn.`Experiment_id` =7
)
AND (
mx.`Experiment_id` =1
)
AND (
mn.`Channel` =13
)
AND (
mn.DATA <20
)
AND (
mx.DATA >60
)
ORDER BY sft.image_date ASC 
--------------------------------------------------
count the number of images each week

SELECT * , MAX(
DATA ) , count( YEARWEEK( image_date ) )
FROM `INCANDESCENT_VIEW`
GROUP BY (
YEARWEEK( image_date )
)
LIMIT 0 , 30
------------------------------------------------

number of images each week


SELECT image_date , count( YEARWEEK( image_date ) )
FROM `src_files_table` WHERE src_camera=2 GROUP BY YEARWEEK( image_date )


-------------------------------------------------

from the avo observation database

gives the number of passes each week since mid 2005, that have a hotspot at st_helens

SELECT ah.auto_hot_id, si.acquisition_datetime, COUNT(si.acquisition_datetime) FROM AUTO_HOTSPOT as ah, SWATH_INFO as si 
WHERE 
(ah.avo_subregion_id = 92) 
AND (si.swath_id = ah.swath_id) 
AND (ah.evaluation = 'acceptable') 
and (ah.sun_zenith_degrees > 92 ) 
AND (YEARWEEK(si.acquisition_datetime) > 200525) 
AND (YEARWEEK(si.acquisition_datetime) < 200850) 
GROUP BY YEARWEEK(si.acquisition_datetime) ORDER BY si.acquisition_datetime ASC 


---------------------------------------------
this one olny chooses band 3 avhrr passes with more the 20C difference in temps


SELECT ah.auto_hot_id, si.acquisition_datetime, COUNT(si.acquisition_datetime),ahss.max/100  FROM AUTO_HOTSPOT as ah, SWATH_INFO as si, AUTO_HOTSPOT_SUBSEC_STATS AS ahss WHERE
 (ah.avo_subregion_id = 92) AND (si.swath_id = ah.swath_id) AND
 (ah.evaluation = 'acceptable') and (ah.sun_zenith_degrees > 92 ) AND
 (ahss.auto_hot_id = ah.auto_hot_id) AND ((ahss.max - ahss.min) > 2000) AND (ahss.sensor_band_id = 3) AND
 (YEARWEEK(si.acquisition_datetime) > 200525) AND 
(YEARWEEK(si.acquisition_datetime) < 200850) GROUP BY YEARWEEK(si.acquisition_datetime) ORDER BY si.acquisition_datetime ASC 

-------------------------------------------


SELECT ah.auto_hot_id, si.acquisition_datetime, COUNT(si.acquisition_datetime),ahss.max/100  FROM AUTO_HOTSPOT as ah, SWATH_INFO as si, AUTO_HOTSPOT_SUBSEC_STATS AS ahss WHERE
  (si.swath_id = ah.swath_id) AND
 (ah.evaluation = 'acceptable') and (ah.sun_zenith_degrees > 92 ) AND
 (ahss.auto_hot_id = ah.auto_hot_id) AND (ahss.sensor_band_id = 3) AND
 (YEARWEEK(si.acquisition_datetime) > 200525) AND 
(YEARWEEK(si.acquisition_datetime) < 200850) GROUP BY YEARWEEK(si.acquisition_datetime) ORDER BY si.acquisition_datetime ASC 


----------------------------------------------
this is the search for manual observations

SELECT obsas.`acquisition_datetime`, count(YEARWEEK(obsas.`acquisition_datetime`)) FROM
OBS_SATELLITE AS obsas, OBS_THERMAL AS obther WHERE ( obther.obs_sat_id = obsas.obs_sat_id ) AND ( obther.sensor_band_id < 7) AND
(YEARWEEK(obsas.acquisition_datetime) > 200525) AND
(YEARWEEK(.acquisition_datetime) < 200850)  GROUP BY YEARWEEK(obsas.`acquisition_datetime`)




--------------------------------------------
 manual observations of st-helens

SELECT obsas.`acquisition_datetime`, count(YEARWEEK(obsas.`acquisition_datetime`)) FROM
OBS_SATELLITE AS obsas, OBS_THERMAL AS obther WHERE ( obther.obs_sat_id = obsas.obs_sat_id ) AND ( obther.sensor_band_id < 7)  AND (obsas.`volcano_id` = 1310)
AND
(YEARWEEK(obsas.acquisition_datetime) > 200525) AND
(YEARWEEK(obsas.acquisition_datetime) < 200850)  GROUP BY YEARWEEK(obsas.`acquisition_datetime`)
