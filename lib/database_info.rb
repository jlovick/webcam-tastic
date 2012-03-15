#!/usr/bin/env ruby
#
#
require "rubygems"
require "sequel"
require 'logger'
require "socket"
require "pp"

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

begin
  puts " system is :"
  pp Socket.gethostname
  puts "\n going through and working out what experiments have been done to what \n "

  connection_info =  Mysql_login_info.new
  filename = "./mysql_connect.yaml"
  if ( File.exists?( filename))
    all_connection_info = YAML::load_file( filename )
    puts " found  mysql connection info"
    #         pp all_connection_info
    all_connection_info.each do |cn|
      pp cn
      if (cn.hostname == Socket.gethostname)
        connection_info  = cn
      end
    end
        
  else
    puts " writen out the default conncetion to a config file for you convience "
    exit 0;
  end

  DB = Sequel.mysql(:host=>connection_info.host, :user=>connection_info.username, :password=>connection_info.password, :database=>connection_info.database)
  #  DB.loggers << Logger.new($stdout)
  src_cameras = DB[:src_camera_table]
  channels = DB[:channels]
  experiments = DB[:experiments]
  New_Stats = DB[:New_Stats]
  gnuplot_graph_table = DB[:Gnuplot_Graph_Table]
  Histogram_table = DB[:Histogram_Table]
  Image_Data_Table = DB[:Image_Data_Table]
  Max_Table = DB[:Max_Table]
  Mean_Table= DB[:Mean_Table]
  Min_Table = DB[:Min_Table]
  Thermal_Flux_Table = DB[:Thermal_Flux_Table]
  Variance_Table = DB[:Variance_Table]
  indent = " "

  src_cameras.each do |each_cam|
    all_src_files = DB.from(:src_files_table).filter(:src_camera => each_cam[:id]).select(:id)
    puts "#{indent * 0} Camera --> #{each_cam[:id]} :- [#{each_cam[:camera_name]}] ---> found #{all_src_files.count} images in total"
    if (all_src_files.count > 0)
      experiments.each  do |each_exp|
        images = New_Stats.filter(:src_file_id => all_src_files).filter(:Experiment_id => each_exp[:Experiment_ID]).count
        puts "#{indent * 2} Experiment --> #{each_exp[:Experiment_ID]} :- [#{each_exp[:name]}]     ---> found #{images} images"
        if (images > 0)
          channels.each do |each_channel|
            ch_images = New_Stats.filter(:src_file_id => all_src_files).filter(:Experiment_id => each_exp[:Experiment_ID]).filter(:Channel => each_channel[:Channel_ID]).count
            puts "#{indent * 4} channel --> #{each_channel[:Channel_ID]} :- [#{each_channel[:name]}]     ---> found #{ch_images} images"
          end
          puts ""
        end
      end
    end
  
  end


  exit(0)
  
end