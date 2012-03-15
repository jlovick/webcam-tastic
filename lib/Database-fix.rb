#!/usr/bin/env ruby
#
#
require "rubygems"
require "sequel"
require 'logger'


begin
  DB = Sequel.mysql(:host=>'localhost', :user=>'jlovick', :password=>'gZYNcqdh1', :database=>'webcam_processing')
  DB.loggers << Logger.new($stdout)
  all_src_files = DB.from(:src_files_table).filter(:src_camera => 2).select(:id)
  test = DB[:New_Stats].
  filter(:src_file_id => all_src_files).
  where(:Experiment_ID => 2).
  group_and_count(:src_file_id, :Channel, :Table_id).
  select_more(:max.sql_function(:Stat_ID).as(:Stat_ID),:max.sql_function(:Table_key).as(:Table_key)).
  having{count > 1}

  puts " #{test.count} items"

  #ok task now is to go through this.
  #for each stat_table now remove thoose entries... then remove the new_stat entry
  New_Stats = DB[:New_Stats]
  gnuplot_graph_table = DB[:Gnuplot_Graph_Table]
  Histogram_table = DB[:Histogram_Table]
  Image_Data_Table = DB[:Image_Data_Table]
  Max_Table = DB[:Max_Table]
  Mean_Table= DB[:Mean_Table]
  Min_Table = DB[:Min_Table]
  Thermal_Flux_Table = DB[:Thermal_Flux_Table]
  Variance_Table = DB[:Variance_Table]
  test.each do |trouble|
    p trouble
    case trouble[:Table_id]
    when 1
      Histogram_Table.filter(:ID=>trouble[:Table_key]).delete
    when 2
      Mean_Table.filter(:ID=>trouble[:Table_key]).delete
    when 3
      Max_Table.filter(:ID=>trouble[:Table_key]).delete
    when 4
      Min_Table.filter(:ID=>trouble[:Table_key]).delete
    when 5
      Variance_Table.filter(:ID=>trouble[:Table_key]).delete
    when 6
      Image_Data_Table.filter(:ID=>trouble[:Table_key]).delete
    when 7
      gnuplot_graph_table.filter(:ID=>trouble[:Table_key]).delete
    when 8
      Thermal_Flux_Table.filter(:ID=>trouble[:Table_key]).delete
    else 
      puts " table not found "
    end
    New_Stats.filter(:Stat_ID => trouble[:Stat_ID]).delete
    puts "deleted stats table entry \b"
  end


    puts "deleted all new_stats entries in group \n"


  exit(0)
  
end