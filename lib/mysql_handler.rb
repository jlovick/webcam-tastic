# 
# This handles all the communicating with the database and very backend stuff
# i guess i will add table specific methods in time.

#this is a top level class to make yaml happy and more portable across programs
class Mysql_login_info
  attr_accessor :username, :password, :hostname, :database, :host
  def initialize()
    @hostname = "unset"
    @username = "root" # jlovick
    @password = "none" #gZYNcqdh1
    @host = "localhost"
    @database = "none"
  end
end

module Mysql_Handler
  require "mysql"
  require "./image_data.rb"
  require "./new_stats.rb"
  require "thread"
  require "socket"
  require "pp"
  require "yaml"



  class Mysql_handler



    def initialize()
      ObjectSpace.define_finalizer(self,self.class.method(:finalize).to_proc) #add an explicit disconect operation
      # connect to the MySQL server
    connection_info =  Mysql_login_info.new
  filename = "./mysql_connect.yaml"
  if ( File.exists?( filename))
    all_connection_info = YAML::load_file( filename )
    puts " found  mysql connection info"
    puts " system name is #{Socket.gethostname}"
    all_connection_info.each do |cn|
 #     pp cn
      if (cn.hostname == Socket.gethostname)
        connection_info  = cn
      end
    end

  else
    puts " writen out the default conncetion to a config file for you convience "
    exit 0;
  end

    
      @dbh = Mysql.real_connect(connection_info.host, connection_info.username, connection_info.password, connection_info.database)
      # get server version string and display it
      puts "Server version: " + @dbh.get_server_info
    rescue Mysql::Error => e
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    ensure
      puts "NOT CONNECTED to database " if !@dbh
    end
    
    def Mysql_handler.finalize()
    ensure
      puts "closed mysql connection"
      @dbh.close if @dbh   
     
    end
    
    def close()
    ensure
      puts "closed mysql connection"
      @dbh.close if @dbh   
      puts "done"
    end
    
    def generic_query(query, wanted_columns)
      ret_arr = Array.new
      res = @dbh.query(query)
      if (res.num_rows > 0)
        res.each do |row|
          i=0
          wanted_columns.each do |item|
            ret_arr[item][i]=row[item]
          end
          i=i+1
        end
      end
      return ret_arr
    rescue Mysql::Error => e
      puts "Error adding webcam image to table : #{query}"
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    end
      
    
    
    def get_webcam_id( camera_name )
      query = "SELECT `id` FROM `src_camera_table` WHERE `camera_name` LIKE \"%" + camera_name + "%\" ;"
      res = @dbh.query(query)
      if (res.num_rows > 0)
        row = res.fetch_row
        return row[0]
      else
        raise "unable to find camera ID, \n query was -: #{query}" 
      end
    end
    
    def get_webcam_data_area( camera_id, region_name )
      query = "SELECT `TL_X`,`TL_Y`,`Width`,`Height`    FROM `sub_region_table` WHERE `Camera_id` = " + camera_id+ " AND Name LIKE \"%"+(region_name.to_s)+"%\";"
      res = @dbh.query(query)
      if (res.num_rows > 0)
        row = res.fetch_row
        return Image_data::Image_data_area.new( row[0].to_i, row[1].to_i, row[2].to_i, row[3].to_i )
      else
        raise "unable to find camera subregion region , \n query was -: #{query}" 
      end
    end
    
    
    def add_webcam_image( camera_id, filename, remote_url, image_date)
      #     INSERT INTO `webcam_processing`.`src_files_table` (
      # `id` ,
      # `src_camera` ,
      # `image_date` ,
      # `filename` ,
      # remote_url,
      # `corrupt`
      #)
      #VALUES (
      #NULL , '1', '2008-03-20 11:01:52', 'test', '0'
      #);
      query = "INSERT INTO `src_files_table` ( `id` ,
       `src_camera` ,
       `image_date` ,
       `filename` ,
       `remote_url`,
       `corrupt` ) VALUES ( NULL, "
      
      query += "'"+camera_id+"','"+image_date+"','" +filename + "', '" + remote_url + "' , '');"
      res = @dbh.query(query)
    rescue Mysql::Error => e
      if (e.errno == 1062)
        puts "Error message: #{e.error}"
        puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
        puts "found entry with likely wrong path, trying to fix"
        update_webcam_image( camera_id, filename, remote_url, image_date)
      else
        puts "Error adding webcam image to table : #{query}"
        puts "Error code: #{e.errno}"
        puts "Error message: #{e.error}"
        puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
      end
    end
    
    def update_webcam_image( camera_id, filename, remote_url, image_date)
      # UPDATE `webcam_processing`.`src_files_table` SET `filename` = '/export/stripe/St_helens_webcam/2008/Mar/2008-Wed-Mar-19-18:45:02-Classic.jpeg' WHERE `src_files_table`.`id` =15517 LIMIT 1 ;
      qr = "SELECT id from `src_files_table` WHERE `image_date` ='" + image_date + "' AND `src_camera` = " + camera_id +" ;"
      resa = @dbh.query(qr)
      row = resa.fetch_row
      id = row[0]
      puts "got id of row #{id}"
      query = "UPDATE `webcam_processing`.`src_files_table` SET `filename` = '"+filename+ "' WHERE `src_files_table`.`id` = '"+id+"' LIMIT 1 ;"

      resb = @dbh.query(query)
      puts " updated record OK..................."
      
    rescue Mysql::Error => e
      puts "Error updating webcam image to table : #{query}"
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    end
    
    
    def count_images(camera, day, month, year)
      query = "SELECT COUNT(*) FROM `src_files_table` WHERE `src_camera` = " + camera.to_s + "
               AND YEAR(`image_date`)= " + year.to_s + " AND MONTH(`image_date`) = " + month.to_s + "
               AND DAY (`image_date`) = " + day.to_s + " ;"
      
      res = @dbh.query(query)
      if (res.num_rows > 0)
        row = res.fetch_row
        return row[0]
      else
        raise "unable to find or count images for that camera ID, \n query was -: #{query}" 
      end
    end
    
    def get_base_url(camera)
      query = " SELECT `camera_url`
                      FROM `src_camera_table`
                      WHERE `id` =  '" + camera.to_s+"'"
      res = @dbh.query(query)
      if (res.num_rows > 0)
        row = res.fetch_row
        return row[0]
      else
        raise "unable to find camera URL, \n query was -: #{query}" 
      end
    end
    
    def get_histogram(id, exp, channel)
      query = " SELECT `DATA` from Histogram_Table where ID = (SELECT `table_key`
                      FROM `New_Stats`
                      WHERE `src_file_id` =  #{id} AND `Experiment_id` = #{exp} AND `Channel` = #{channel} AND `Table_id` = 1 LIMIT 1)"
      res = @dbh.query(query)
      if (res.num_rows > 0)
        row = res.fetch_row
        return row[0].strip
      else
        raise "unable to find statistics id, \n query was -: #{query}" 
      end
    rescue Mysql::Error => e
      puts "unable to return histogram data \n query was -: #{query}" 
      puts "Error code: #{e.errno}"
      puts "Error message: #{e.error}"
      puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
    end
    
    def get_subimage_data(id, exp, channel)
      query = " SELECT `DATA`, `DATA_TYPE`  from IMAGE_DATA_VIEW  where `src_file_id` =  #{id} AND `Experiment_id` = #{exp} AND `Channel` = #{channel} "
      res = @dbh.query(query)
      data = Hash.new
      if (res.num_rows > 0)
        res.each_hash do |row|
          row.each do | key, value |
            data[key] =  value.clone   
          end
        end
       return data
    else
      raise "unable to find subimage entry in IMAGE_DATA_VIEW , \n query was -: #{query}" 
    end
  rescue Mysql::Error => e
    puts "unable to return histogram data \n query was -: #{query}" 
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
    
  def get_all_camera_images(camera)
    query = " SELECT `id`,`filename`,`remote_URL`
                      FROM `src_files_table`
                      WHERE `src_camera` =  '" + camera.to_s+"'"
    res = @dbh.query(query)
    if (res.num_rows > 0)
      all_files = Array.new
      res.each do |row|
        my_file = Image_data::Image_file_data.new( row[0], row[1], row[2] )
        all_files.push( my_file )
      end
      return all_files
    else
      raise "unable to return all camera images URL, \n query was -: #{query}" 
    end
  end
    
  def get_all_camera_image_files(camera)
    query = " SELECT `filename` FROM `src_files_table`
                      WHERE `src_camera` =  '" + camera.to_s+"'"
    res = @dbh.query(query)
    puts " #{res.num_rows} existing images found "
    if (res.num_rows > 0)
      all_files = Array.new
      res.each do |row|
        my_file =  row[0] 
        all_files.push( my_file )
      end
      return all_files
    else
      return nil
    end
      
  rescue Mysql::Error => e
    puts "unable to return all camera images URL, \n query was -: #{query}" 
    puts "Error adding webcam image to table : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end  
    
  def get_camera_image_file(img_file_id)
    query = " SELECT `filename` FROM `src_files_table`
                      WHERE `id` =  '" + img_file_id.to_s+"'"
    res = @dbh.query(query)
    if (res.num_rows > 0)
      all_files = Array.new
      res.each do |row|
        my_file =  row[0] 
        all_files.push( my_file )
      end
      return all_files
    else
      raise "unable to return camera image URL, \n query was -: #{query}" 
    end
  end  
    
  def get_all_unprocessed_camera_images(camera, experiment, awhere)
        
    query_1 = " SELECT `id`,`filename`,`remote_URL`,`image_date`
                      FROM `src_files_table`
                      WHERE `src_camera` =  '" + camera.to_s+"'"
      
    if ( awhere!= nil && awhere.size > 0)
      query_1 +=  "  AND " + awhere.to_s
    end

    query_2 = " SELECT Distinct `src_file_ID`
                      FROM `New_Stats` WHERE `Experiment_id` = '"+(experiment.to_s) + "'"
                      
    pp query_1
    res_a = @dbh.query(query_1)
    res_b = @dbh.query(query_2)
    puts " finding unprocessed rows "
    puts " res_a returned #{res_a.num_rows}    res_b returned #{res_b.num_rows} "
    if (res_a.num_rows > 0)
      all_files = Array.new
      done_files = Array.new
      raw_files = Array.new
      wanted_files = Array.new
      pass_out = Array.new
      res_b.each do |row|
        done_files.push( row[0].to_i )
      end
      res_a.each do |row|
        raw_files.push( row[0].to_i )
        my_file = Image_data::Image_file_data.new( row[0], row[1], row[2], row[3] )
        pass_out[row[0].to_i] = my_file
      end
      done_files.sort
      raw_files.sort
      wanted_files =  raw_files - done_files
         
      wanted_files.each do |erow|
        my_file = pass_out[erow]
        all_files.push( my_file.clone )
        # puts " found #{all_files.length} items "
      end
       
      puts " found all unprocessed items #{all_files.length}  out of a total of #{raw_files.length}  #{100-((all_files.length) / (raw_files.length))*100.0}% done"
      return all_files
    else
      raise "unable to return all camera images URL, \n query_1 was -: #{query_1} \n query_2 was :- #{query_2}" 
    end
  rescue Mysql::Error => e
    puts "Error adding webcam image to table (get_all_unprocessed_camera_images 239) : #{query_1} #{query_2}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_all_images_still_needing_stat_calculated(camera, experiment, stat_table, awhere)
    query_1 = " SELECT `id`,`filename`,`remote_URL`,`image_date`
                      FROM `src_files_table`
                      WHERE `src_camera` =  '" + camera.to_s+"'"
      
    if ( awhere!= nil && awhere.size > 0)
      query_1 +=  "  AND " + awhere.to_s
    end

    query_2 = " SELECT Distinct `src_file_ID`
                      FROM `New_Stats` WHERE (`Experiment_id` = '"+(experiment.to_s) + "' ) AND 
                      (`Table_id` = #{stat_table})"
                      
    pp query_1
    res_a = @dbh.query(query_1)
    res_b = @dbh.query(query_2)
    puts " finding unprocessed rows "
    if (res_a.num_rows > 0)
      all_files = Array.new
      done_files = Array.new
      raw_files = Array.new
      wanted_files = Array.new
      pass_out = Array.new
      res_b.each do |row|
        done_files.push( row[0].to_i )
      end
      res_a.each do |row|
        raw_files.push( row[0].to_i )
        my_file = Image_data::Image_file_data.new( row[0], row[1], row[2], row[3] )
        pass_out[row[0].to_i] = my_file
      end
      done_files.sort
      raw_files.sort
      wanted_files =  raw_files - done_files
         
      wanted_files.each do |erow|
        my_file = pass_out[erow]
        all_files.push( my_file.clone )
        # puts " found #{all_files.length} items "
      end
       
      puts " found all unprocessed items #{all_files.length}  out of a total of #{raw_files.length}  #{100-((all_files.length) / (raw_files.length))*100.0}% done"
      return all_files
    else
      raise "unable to return all camera images URL, \n query_1 was -: #{query_1} \n query_2 was :- #{query_2}" 
    end
  rescue Mysql::Error => e
    puts "Error adding webcam image to table (get_all_unprocessed_camera_images 239) : #{query_1} #{query_2}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
  def store_statistics( camera_id,experiment, region, mean, max, min, variance, channel, histogram)
    query = "INSERT INTO `statistics` ( `Stat_ID` ,
       `src_file_ID` ,
       `Experiment_ID`,
       `Region` ,
       `Mean` ,
       `Max`,
       `Min` ,
       `Variance`,
        `Channel`,
        `Histogram` ) VALUES ( NULL, "
      
    query += "'"+camera_id+"','" + (experiment.to_s) + "','"+region+"'"
    query += ",'" + (mean.to_s) + "', '" + (max.to_s) + "' , ' " + (min.to_s) +"' , ' " + (variance.to_s) +"' ,"
    esc_hist = Mysql::quote(histogram)
    query += " '" + channel +"' , ' " + esc_hist +"');"
    res = @dbh.query(query)
  rescue Mysql::Error => e
    puts "Error adding webcam image to table : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_stats(src_file_id, exp, channel, stat_table_id)
    query = "SELECT `Stat_ID`,`Table_id`,`Table_key` FROM `New_Stats` WHERE src_file_id = #{src_file_id.to_i} AND Experiment_id = #{exp.to_i} AND Channel = #{channel.to_i} AND Table_id = #{stat_table_id.to_i} " 
    res = @dbh.query(query)
    pp query
    #pp res
    stat_ids = Array.new
    if (res.num_rows > 0)
      res.each do |row|
        new_stats = ImageStats::New_Stats.new( row[0].to_i,  row[1].to_i,  row[2].to_i)
        stat_ids.push( new_stats.clone )
      end
    else 
      puts "query returned no rows :- #{query}"
    end
    puts " stat ids done"
    return stat_ids
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
    
  def update_image_record(image_id, var, value)
    query = " UPDATE `webcam_processing`.`src_files_table` SET `" + var.to_s 
    query += "` = '" + value.to_s 
    query += "' WHERE `src_files_table`.`id` = '"+ image_id.to_s 
    query += "' LIMIT 1 ;"
    res = @dbh.query(query)
  rescue Mysql::Error => e
    puts "Error adding updateing a webcam file item : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_all_stat_id()
    query = "SELECT DISTINCT `src_file_ID` FROM `statistics`"
    resa = @dbh.query(query)
    pass_out = Array.new
    resa.each do |row|
      pass_out.push( row[0].to_i )
    end
    return pass_out
  rescue Mysql::Error => e
    puts "Error gettins stats camera ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_all_camera_file_id()
    query = "SELECT DISTINCT `id` FROM `src_files_table`"
    resa = @dbh.query(query)
    pass_out = Array.new
    resa.each do |row|
      pass_out.push( row[0].to_i )
    end
    return pass_out
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
    
  def remove_stat_entry( id )
    query = "DELETE FROM `statistics` WHERE `src_file_ID` = "+ id.to_s
    resa = @dbh.query(query)
  rescue Mysql::Error => e
    puts "Error removing stat entrys : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def filter_useful_images_too_low_max(camera_id)
    #      query = "SELECT DISTINCT `src_file_id`,`Stat_ID` FROM `statistics` WHERE `Max` < 10"
    query = " select distinct src_file_id , `Stat_ID` from statistics 
  JOIN (SELECT id, src_camera FROM `src_files_table` WHERE src_camera = #{camera_id} ) AS lt 
  WHERE statistics.src_file_id = lt.id AND  statistics.Max < 30 "
    puts " #{query}"
    resa = @dbh.query(query)
    queryb = "SELECT DISTINCT `src_file_id` FROM `not_useful_images` "
    resb = @dbh.query(queryb)
      
    if (resa.num_rows < 1 ) 
      puts " no boring images found"
      return
    end
      
    puts " found #{resa.num_rows} boring images "
    throw_out = Array.new
    dont_need = Hash.new
    resb.each do |row|
      dont_need["#{row[0].to_i}"] = 1
    end
    resa.each do |row|
      if (dont_need["#{row[0].to_i}"] == nil )
        throw_out.push( [camera_id, row[0].to_i, row[1].to_i, "too low max  < 10"] )
      end
    end
    puts "marking each as boring \n"
    throw_out.each do |item|
      query =  "INSERT INTO `not_useful_images` ( `Camera_ID` , `src_file_id` , `Stat_ID`, `useful_id`, `criteria` ) VALUES ("
      query += "#{item[0]} , #{item[1]} , #{item[2]} , NULL , \"#{item[3]}\" )"
      resb = @dbh.query(query)
    end
        
    return throw_out.size
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def filter_useful_images_too_hi_min(camera_id)
    #      query = "SELECT DISTINCT `src_file_id`,`Stat_ID` FROM `statistics` WHERE `Min` > 250"
    query = " select distinct src_file_id , `Stat_ID` from statistics 
  JOIN (SELECT id, src_camera FROM `src_files_table` WHERE src_camera =  #{camera_id}) AS lt 
  WHERE statistics.src_file_id = lt.id AND  statistics.Min > 230 "
      
    resa = @dbh.query(query)
    queryb = "SELECT DISTINCT `src_file_id` FROM `not_useful_images` "
    resb = @dbh.query(queryb)
      
    if (resa.num_rows < 1 ) 
      puts " no boring images found"
      return
    end
    puts " found #{resa.num_rows} boring images "
    throw_out = Array.new
    dont_need = Hash.new
    resb.each do |row|
      dont_need["#{row[0].to_i}"] = 1
    end
    resa.each do |row|
      if (dont_need["#{row[0].to_i}"] == nil )
        throw_out.push( [camera_id, row[0].to_i, row[1].to_i, "too hi min > 250"] )
      end
    end
    puts "marking each as boring \n"
    throw_out.each do |item|
      query =  "INSERT INTO `not_useful_images` ( `Camera_ID` , `src_file_id` , `Stat_ID`, `useful_id`, `criteria` ) VALUES ("
      query += "#{item[0]} , #{item[1]} , #{item[2]} , NULL  , \"#{item[3]}\")"
      resb = @dbh.query(query)
    end
        
    return throw_out.size
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def filter_useful_images_too_low_var(camera_id)
    # query = "SELECT DISTINCT `src_file_id`,`Stat_ID` FROM `statistics` WHERE `Variance` < 15 "
    #       query = "SELECT DISTINCT `src_file_id` , `Stat_ID`
    #FROM `statistics` AS ST, `src_files_table` AS SCT
    #WHERE ((
    #ST.Variance <15
    #)
    #AND (
    #ST.src_file_id = SCT.id
    #)
    #AND (SCT.src_camera = #{camera_id})
    #)"
    query = " select distinct src_file_id , `Stat_ID` from statistics 
  JOIN (SELECT id, src_camera FROM `src_files_table` WHERE src_camera =  #{camera_id} ) AS lt 
  WHERE statistics.src_file_id = lt.id AND  statistics.variance < 15 "

    resa = @dbh.query(query)
    queryb = "SELECT DISTINCT `src_file_id` FROM `not_useful_images` "
    resb = @dbh.query(queryb)
      
    if (resa.num_rows < 1 ) 
      puts " no boring images found"
      return
    end
    puts " found #{resa.num_rows} boring images "
    throw_out = Array.new
    dont_need = Hash.new
    resb.each do |row|
      dont_need["#{row[0].to_i}"] = 1
    end
    resa.each do |row|
      if (dont_need["#{row[0].to_i}"] == nil )
        throw_out.push( [camera_id, row[0].to_i, row[1].to_i, "too low variance <15"] )
      end
    end
    puts "marking each as boring, ignoring duplicates\n"
    throw_out.each do |item|
      query =  "INSERT INTO `not_useful_images` ( `Camera_ID` , `src_file_id` , `Stat_ID`, `useful_id`, `criteria` ) VALUES ("
      query += "#{item[0]} , #{item[1]} , #{item[2]} , NULL  , \"#{item[3]}\")"
      resb = @dbh.query(query)
    end
        
    return throw_out.size
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_stats_collection(src_file_id, exp, channel)
    query = "SELECT `Stat_ID`,`Table_id`,`Table_key` FROM `New_Stats` WHERE src_file_id = #{src_file_id} AND Experiment_id = #{exp} AND Channel = #{channel}"
    res = @dbh.query(query)
    #pp query
    #pp res
    stat_ids = Array.new
    if (res.num_rows > 0)
      res.each do |row|
        new_stats = ImageStats::New_Stats.new( row[0].to_i,  row[1].to_i,  row[2].to_i)
        stat_ids.push( new_stats.clone )
      end
    else 
      puts "query returned no rows :- #{query}"
    end
    return stat_ids
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_stats_table_list()
    query = "Select * FROM `Stats_Tables`"
    puts "getting stats table list :-#{query}"
    res = @dbh.query(query)
    table_list = Hash.new
    table_ids = Hash.new
    if (res.num_rows > 0)
      res.each do |row|
        #   pp row
        table_list[row[1].to_s] = row[0].to_i #takes a tablename and gives you an id
        table_ids[row[0].to_i] = row[1].to_s #takes a tablename and gives you an id
      end
    end
    return [table_list, table_ids]
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_channel_list()
    query = "Select * FROM `channels`"
    puts "getting channels list :-#{query}"
    res = @dbh.query(query)
    channels_list = Hash.new
    channels_ids = Hash.new
    if (res.num_rows > 0)
      res.each do |row|
        #   pp row
        channels_list[row[1].to_s] = row[0].to_i #takes a tablename and gives you an id
        channels_ids[row[0].to_i] = row[1].to_s #takes a tablename and gives you an id
        #          puts " #{row[0].to_i}    #{row[1].to_s}"
      end
    end
    return [channels_list, channels_ids]
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_experiment_list()
    query = "Select * FROM `experiments`"
    puts "getting experiment list :-#{query}"
    res = @dbh.query(query)
    experiment_list = Hash.new
    experiment_ids = Hash.new
    if (res.num_rows > 0)
      res.each do |row|
        #   pp row
        experiment_list[row[1].to_s] = row[0].to_i #takes a tablename and gives you an id
        experiment_ids[row[0].to_i] = row[1].to_s #takes a tablename and gives you an id
        #         puts " #{row[0].to_i}    #{row[1].to_s}"
      end
    end
    return [experiment_list, experiment_ids]
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def get_stats_data(table, id)
    query = "SELECT * FROM #{table} WHERE ID = #{id}"
    # puts " #{query}"
    res = @dbh.query(query)
    data = Hash.new
    if (res.num_rows > 0)
      res.each_hash do |row|
        row.each do | key, value |
          if ( key != "ID" )           
            data[key] =  value.clone   
          end
        end
      end
    end
    return data
  rescue Mysql::Error => e
    puts "Error gettins file ids : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def add_stats_to_collection(src_file_id, table_id, table_key, experiment_id, channel )
    query = "INSERT INTO  `webcam_processing`.`New_Stats` ( `Stat_ID` , `timestamp`, `src_file_id` , `Table_id` , `Table_key`,  `Experiment_id`, `Channel` ) VALUES
    ( NULL , NOW(), #{src_file_id}, #{table_id}, #{table_key}, #{experiment_id}, #{channel} )"
    # need ot make sure experiment is valid also src_file_id
    res = @dbh.query(query)
  rescue Mysql::Error => e
    puts "Error adding stats in to new collection table `New_Stats` : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
    
  def add_new_stats_entry(table, results={})
    #  query = "INSERT INTO `webcam_processing`.`#{table}` ( `ID` , #{fields}) VALUES ( NULL " # #{results} ) "
    keys = ""
    values = ""
    results.each do |key,value|
      #     puts " key is #{key} value is #{value}"
      keys += ", #{key} "
      values += " , #{value} "
    end
    # take note that the commers are added in the above loop and so arent needed in the SQL query
    query = "INSERT INTO `webcam_processing`.`#{table}` ( `ID`  #{keys}) VALUES ( NULL #{values} ) "
    res = @dbh.query(query)
    return @dbh.insert_id
  rescue Mysql::Error => e
    puts "Error adding stats in to new collection in table -: `#{table}`    : #{query}"
    puts "Error code: #{e.errno}"
    puts "Error message: #{e.error}"
    puts "Error SQLSTATE: #{e.sqlstate}" if e.respond_to?("sqlstate")
  end
end # end of mysql handler class


end # end of module
