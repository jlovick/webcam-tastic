#!/usr/bin/env ruby
#
# aims to make it easier to get data out of the database and into csv format
#
require "rubygems"
require "sequel"
require 'logger'
require "socket"
require "pp"
require "faster_csv"

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
def usage()
  puts " ./database_dump.rb [required options]"
  puts "options... \n --exp=\"blah\" "
  puts "--channel=\"red\" "
  puts "--camera_name=\"Kluichevskoy\" "
  puts "--table_name=\"Mean_Table\" "
  puts "--output_file=\"./myfile.csv\" "
exit 0
end

begin
  camname = nil
  expname = nil
  channelname = nil
  tablename = nil
  outfile = nil
  
  ARGV.each do |arg|
    case arg
    when /\A--camera_name=([\ 0-9A-Za-z._\/]+)\Z/ then camname = $1.to_s
    when /\A--exp=([\ 0-9A-Za-z._\/]+)\Z/ then expname = $1.to_s
    when /\A--channel=([\ 0-9A-Za-z._\/]+)\Z/ then channelname = $1.to_s
    when /\A--table_name=([\ 0-9A-Za-z._\/]+)\Z/ then tablename = $1.to_s
    when /\A--output_file=([\ 0-9A-Za-z._\/]+)\Z/ then outfile = $1.to_s

    end
  end
 usage() unless ( outfile and camname and expname and channelname and tablename)
  puts " using these options \n outfile=\"#{outfile}\",  camname=\"#{camname}\", expname=\"#{expname}\", channelname=\"#{channelname}\",  tablename=\"#{tablename}\" "
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
  Stats_table= DB[:Stats_Tables]
  indent = " "

cam = src_cameras.filter(:camera_name => camname ).select(:id).single_value
all_src_files = DB.from(:src_files_table).filter(:src_camera => cam).select(:id)
expr = experiments.filter(:name => expname).select(:Experiment_ID).single_value
chan = channels.filter(:name => channelname).select(:Channel_ID).single_value
tbl = Stats_table.filter(:Table_name => tablename).select(:Table_id).single_value

if (cam == nil)
  puts "ERROR :- camera not found [#{camname}]"
end
if (expr == nil)
  puts "ERROR :- experiment not found [#{expname}]"
end
if (chan == nil)
  puts "ERROR :- channel not found [#{chaannelname}"
end
if (tbl == nil)
  puts "ERROR :- stats table not found [#{tablename}]"
end
exit 1 unless (cam and expr and chan and tbl)

stat_entries = New_Stats.filter(:table_id => tbl).filter(:src_file_id => all_src_files ).filter(:Experiment_id => expr).filter(:Channel => chan).select(:src_file_id, :Table_key)
FasterCSV.open(outfile, "w") do |csv|
stat_entries.each do |entry|
  res = Mean_Table.filter(:id=>entry[:Table_key]).filter(:DATA < 60).select(:DATA).single_value
  imgdate = DB.from(:src_files_table).filter(:src_camera => cam).filter(:id=>entry[:src_file_id]).select(:image_date).single_value
  tt = Time.parse(imgdate.to_s)
  outt = tt.hour*60 + tt.min
    csv << [entry[:src_file_id],outt,res]
    end
end
  exit(0)

end