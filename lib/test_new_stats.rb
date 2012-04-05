#!/usr/bin/env ruby 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 
require 'rubygems'
require 'optparse'
require "./mysql_handler.rb"
require "./image_data.rb"
require "./threading.rb"
require "./general_tools.rb"
require "./webcam_processor.rb"
require "./new_stats.rb"
require "fileutils"
require 'hornetseye_rmagick'
require 'narray'
require 'mathn'
require 'matrix'
require 'rbgsl'
require 'thread'
require 'date'
require 'set'
require 'ostruct'
require 'open-uri'

begin
  @@msh = Mysql_Handler::Mysql_handler.new()

  tbl_list = ImageStats::Stat_Table_List.new(@@msh)
  channel_list = ImageStats::Channel_Table_List(@@msh)
#  tbl_list.print
  
  puts "\n table 3 is #{tbl_list.get_table_name(3)} should be (Max_Table)"
  puts " table Mean_Table is #{tbl_list.get_table_id("Mean_Table")} Should be 2"
  puts "if these are right then stats table list is working \n \n \n"
  
  sc = ImageStats::Stats_Collection.new(@@msh, nil, nil)
  scb = ImageStats::Stats_Collection.new(@@msh, 2345, 2 )
  scb.add_table(tbl_list.get_table_id("Mean_Table"), :mean => 12.556)
  @@msh.close()
end
