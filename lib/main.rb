#!/usr/bin/env ruby 
# 
# 
 
require 'rubygems'
require 'optparse'
require "./mysql_handler.rb"
require "./image_data.rb"
require "./threading.rb"
require "./general_tools.rb"
require "./webcam_processor.rb"
require "./new_stats.rb"
require "fileutils"
require 'hornetseye'
require 'narray'
require 'mathn'
require 'matrix'
require 'rbgsl'
require 'thread'
require 'date'
require 'set'
require 'ostruct'
require 'open-uri'
require 'bleak_house' if ENV['BLEAK_HOUSE']

include Hornetseye


module Enumerable
  def each_simul
    threads = []
    each { |e| threads << Thread.new { yield e}}
    puts "waiting for threads to terminate"
    threads.each { |e| e.join }
  end
end


def usage
  print "\n --------------------------------------------------------------------------------------------------------\n"
  print "\n Usage: ./example_program.rb --task=[process,add_images,dmy_stats,remove_bad_stats,gnuplot,output_images] ........\n\n \n"
  print "for example \n"
  print "--task=process --camera=VAL --experiment=VAL --operation=VAL --area=VAL --where=VAL"
  print "\n --camera=\"Augustine\" --experiment=\"Initial Histograms\" --operation=\"channels\" --area=\"Full\" --where=\" data > 2006 \" "
  print "\n\n caries out the operation on the image, and labels it in the database with the experiment name"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=add_images --camera=VAL --path=VAL --identifier=VAL --ext=VAL"
  print "\n --camera=\"Augustine\" --path=\"/export/whale/webcam... \" --identifier=\"Classic\" --ext=\"jpeg\" \n \n adds in images from a directory structure or ?url?"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=add_all_new_images "
  print "\n goes through and adds in all the new st_helens, and kvert camera images"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=dmy_stats --camera=VAL --output_file=VAL"
  print "\n --camera=\"Augustine\" --output_file=\"/tmp/stats_out\" \n \n prints out how many images for that camera occur on what days"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=remove_bad_stats \n \n makes sure all the statistics refer to image files that exist in the database"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=gnuplot --camera=VAL --query_file=VAL --column_x=[1..9] --column_y=[1..9] --gnuplot_commands_file=[val] --output_file=VAL"
  print "\n \n"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=gnuplot_histogram --camera=VAL --channel=VAL --experiment=VAL --output_file=VAL (--statistics_id=VAL or --statistics_id_file=VAL ) --terminal=VAL --gnuplot_output=VAL --additional_gnuplot_commands=[val]  "
  print "\n where statistics_id is the src file id number, and output_file is a directory to put that file. terminal is x11, or svg etc \n"
  print "\n \n"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=find_useful_images --camera=VAL --criteria=VAL"
  print " where criteria is one of [ variance, lo_max, hi_min, all ]"
  print "\n goes through and makes a note of all images that fullfil a criteria"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=output_images --camera=VAL --src_file_id=VAL|--id_list_file=VAL --dest_path=VAL  "
  print " outputs the image into the directory specified"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=output_sub_images --camera=VAL --src_file_id=VAL|--id_list_file=VAL --experiment=VAL --channel=VAL --dest_path=VAL  "
  print " outputs the image into the directory specified"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=difference_image --camera=VAL --where=VAL (--control_exp=[] --control_exp=[] ...list of control regions..)  --crater_exp=[]  --channel=[red,green,blue,combined,all]"
  print " goes through and subtacts the mean control stats from the target stats for channel normaly use combined, but can use all if required"
  print "\n \n ++++++++++++++++++ \n "
  print "--task=mean_control_image --camera=VAL --where=VAL (--control_exp=[] --control_exp=[] ...list of control regions..)  --channel=[red,green,blue,combined,all]"
  print " goes through and makes the mean control stats.... for channel normaly use combined, but can use all if required "
  print "\n \n ++++++++++++++++++ \n "
  print "--task=thermal_stats --camera=VAL --where=VAL  "
  print " calculates the thermal stats based on images residual histograms"
  print "\n \n ++++++++++++++++++ \n "
  
  print "\n \n"
  
  
  print "\n --------------------------------------------------------------------------------------------------------\n"
  exit 1
end

def send_to_process
  cam = nil
  exp = nil
  op = nil
  ar = nil
  awhere = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--experiment=([\ 0-9A-Za-z._]+)\Z/ then exp = $1
    when /\A--operation=([\ 0-9A-Za-z._]+)\Z/ then op = $1
    when /\A--area=([\ 0-9A-Za-z._]+)\Z/ then ar = $1
    when /\A--where=((.*)+)\Z/ then awhere=$1
    end
  end
  if !( cam and exp and op and ar )
    print "error cant process this.... i think i have these #{cam}, #{exp}, #{op}, #{ar}, #{awhere}"
    usage()
  end
  wc = Webcam_processor::Webcam_Instructor.new(cam,exp, op, ar)
  wc.process_all_images(awhere)
  return true
end

def add_images()
  #import_webcams(msh) 
  #add_in_avo_images(msh,"Augustine Lagoon", "/export/elephant/webcam/AVO-webcams/Augustine/final_file_list_auglagoon")
  cam = nil
  pat = nil
  id = nil
  ext = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--path=((.*)+)\Z/ then pat = $1
    when /\A--identifier=((.*)+)\Z/ then id = $1
    when /\A--ext=([\ 0-9A-Za-z._]+)\Z/ then ext = $1
    end
  end
  if !(cam and pat and id and ext)
    print "add_images\n ERROR..... cant parse arguments \"#{cam}\", \"#{pat}\", \"#{id}\", \"#{ext}\" \n\n\n"
    usage()
  end
  wc = Webcam_processor::Webcam_Instructor.new(cam,"","","")
  wc.import_webcam(pat,id,ext)
  return true
end

def add_all_new_images()
  wc = Webcam_processor::Webcam_Instructor.new("","","","")
  wc.import_all_webcams()
  return true
end

def dmy_stats()
  cam = nil
  of = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--output_file=([\ 0-9A-Za-z._\/]+)\Z/ then of = $1
    end
  end
  if !(cam and of )
    print "dmy stats\n ERROR..... cant parse arguments \"#{cam}\", \"#{of}\" \n\n\n"
    usage()
  end
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.day_month_year_stats(of) 
  return true
end

def remove_bad_stats()
  wc = Webcam_processor::Webcam_Instructor.new("","", "", "")
  puts " removing bad statistics entries "
  wc.remove_bad_stats() 
  return true
end

def gnuplot_stats()
  query_file = nil
  cam = nil
  colx = nil
  coly = nil
  coms = nil
  of = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--query_file=([\ 0-9A-Za-z._\/]+)\Z/ then query_file = $1
    when /\A--column_x=([\ 0-9]+)\Z/ then colx = $1
    when /\A--column_y=([\ 0-9]+)\Z/ then coly = $1
    when /\A--gnuplot_commands_file=([\ 0-9A-Za-z._\/]+)\Z/ then coms = $1
    when /\A--output_file=([\ 0-9A-Za-z._\/]+)\Z/ then of = $1
    end
  end
  if !(cam and query_file and colx and coly and of )
    print "gnuplot\n ERROR..... cant parse arguments \"#{cam}\", \"#{query_file}\", \"#{colx}\", \"#{coly}\" , \"#{coms}\" , \"#{of}\" \n\n\n"
    usage()
  end
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.gnuplot(query_file,of, colx, coly, coms) 
  return true
end

def gnuplot_histogram()
  cam = nil
  of = nil
  st_num = nil
  st_file = nil
  coms = nil
  disp = nil
  output = nil
  channel = nil
  exp = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--output_file=([\ 0-9A-Za-z._\/]+)\Z/ then of = $1
    when /\A--statistics_id=((\d*\ *)(.*))\Z/ then st_num = $1
    when /\A--statistics_id_file=((.*)+)\Z/ then st_file = $1
    when /\A--channel=([\A-Za-z]*)\Z/ then channel = $1
    when /\A--experiment=(.*)\Z/ then exp = $1
    when /\A--additional_gnuplot_commands=([\ 0-9A-Za-z._\/]+)\Z/ then coms = $1
    when /\A--terminal=(.*)\Z/ then disp=$1
    when /\A--gnuplot_output=([\ 0-9A-Za-z._\/]+)\Z/ then output=$1
        
    end
  end
  if !(cam and of and exp and channel and (st_num or st_file) )
    print "gnuplot_histogram\n ERROR..... cant parse arguments cam=\"#{cam}\", of=\"#{of}\", exp=\"#{exp}\" , channel=\"#{channel}\" , src_file_id\"#{st_num}\", "
    print "terminal \"#{disp}\", ids-src_file\"#{st_file}\", gnuplot-comms\"#{coms}\" \n\n\n "
    usage()
  end
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.gnuplot_histogram(of,exp, channel, st_num,st_file,coms,disp,output)
  return true  
end

def output_images()
  cam = nil
  img = nil
  dest = nil
  img_list = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--src_file_id=((\d*\ *)(.*))\Z/ then img = $1
    when /\A--id_list_file=((.*)+)\Z/ then img_list = $1
    when /\A--dest_path=((.*)+)\Z/ then dest=$1
    end
  end
   
  if !( cam and (img or img_list) and dest )
    print " cant understand options.... #{cam}, #{img}, #{img_list}, #{dest}"
    usage()
  end
   
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  if ( img )
    wc.dump_img(img, dest)
  else
    wc.dump_img_list(img_list,dest)
  end
  return true
end

def output_sub_images()
  cam = nil
  img = nil
  dest = nil
  img_list = nil
  exp  = nil
  channel = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--src_file_id=((\d*\ *)(.*))\Z/ then img = $1
    when /\A--id_list_file=((.*)+)\Z/ then img_list = $1
    when /\A--dest_path=((.*)+)\Z/ then dest=$1
    when /\A--experiment=([\ 0-9A-Za-z._\/]+)\Z/ then exp=$1
    when /\A--channel=([\A-Za-z]*)\Z/ then channel = $1
    end
  end
   
  if !( cam  and exp and channel and dest and (img or img_list)  )
    print " cant understand options.... #{cam}, \"#{img}\"/ \"#{img_list}\", #{exp}, #{channel} #{dest}"
    usage()
  end
   
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  if ( img )
    wc.dump_sub_img(img, exp, channel, dest)
  else
    wc.dump_sub_img_list(img_list,exp, channel, dest)
  end
  return true
end

def useful_images()
  cam = nil
  crit = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--criteria=([\ 0-9A-Za-z._\/]+)\Z/ then crit = $1
    end
  end
   
  if !( cam and crit )
    print " cant understand options.... #{cam} #{crit}"
    usage()
  end
   
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.find_useful(crit)  
  return true
end

def difference_image()
  cam = nil
  control_exp = Array.new
  crater_exp = nil
  awhere = nil
  channel = Array.new
  img = Array.new
  id_file = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--control_exp=([\ 0-9A-Za-z._\/]+)\Z/ then control_exp.push($1)
    when /\A--crater_exp=([\ 0-9A-Za-z._\/]+)\Z/ then crater_exp=$1
    when  /\A--channel=([\ 0-9A-Za-z._\/]+)\Z/ then channel.push($1)
    when /\A--where=((.*)+)\Z/ then awhere=$1
    end
  end
   
  if !( cam and crater_exp and awhere and (control_exp.size > 0)  and (channel.size > 0))
    print " cant understand options.... #{cam}, #{crater_exp}, #{channel}, #{awhere}"
    pp control_exp
    usage()
  end
  
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.difference_image(awhere, control_exp,crater_exp, channel)  
  return true
end

def mean_control_image()
  cam = nil
  control_exp = Array.new
  awhere = nil
  channel = Array.new
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--control_exp=([\ 0-9A-Za-z._\/]+)\Z/ then control_exp.push($1)
    when  /\A--channel=([\ 0-9A-Za-z._\/]+)\Z/ then channel.push($1)
    when /\A--where=((.*)+)\Z/ then awhere=$1
    end
  end
   
  if !( cam and awhere and (control_exp.size > 0)  and (channel.size > 0))
    print " cant understand options.... #{cam},  #{channel}, #{awhere}"
    pp control_exp
    usage()
  end
  
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.mean_control_image(awhere, control_exp, channel)  
  return true
end

def thermal_stats()
  cam = nil
  where = nil
  ARGV.each do |arg|
    case arg
    when /\A--camera=([\ 0-9A-Za-z._]+)\Z/ then cam = $1
    when /\A--where=((.*)+)\Z/ then where=$1
    end
  end
   
  if !( cam and where )
    print " cant understand options.... #{cam}, #{where}"
    usage()
  end
   
  wc = Webcam_processor::Webcam_Instructor.new(cam,"", "", "")
  wc.make_thermal_stats( where )
  return true
end

begin

  #skip importing new images
  tk = nil
  tr = nil
  msg = nil
  ARGV.each do |arg|
    case arg
    when /\A--task=([\ 0-9A-Za-z._]+)\Z/ then tk = $1
    end  
  end
  
  usage() unless tk
  case tk
  when/\Aprocess\Z/ then tr=send_to_process()
  when/\Aremove_bad_stats\Z/ then tr=remove_bad_stats()
  when/\Aadd_images\Z/ then tr=add_images()
  when/\Aadd_all_new_images\Z/ then tr=add_all_new_images()
  when/\Admy_stats\Z/ then tr=dmy_stats() 
  when/\Agnuplot\Z/ then tr=gnuplot_stats()
  when/\Agnuplot_histogram\Z/ then tr=gnuplot_histogram()
  when/\Afind_useful_images\Z/ then tr=useful_images()
  when/\Aoutput_images\Z/ then tr=output_images()
  when/\Aoutput_sub_images\Z/ then tr=output_sub_images()
  when/\Adifference_image\Z/ then tr=difference_image() 
  when/\Amean_control_image\Z/ then tr =mean_control_image() 
  when/\Athermal_stats\Z/ then tr = thermal_stats() 
  end 
  
  if (tr == nil)
    print " unable to identify task..... #{tk}"
  end
  
  msg = "\n \n \n finnished at #{Time.now}"
  puts " #{msg} "
  
  # pool.join()

  # now do 
  # 
  #    load_an_image('/export/elephant/webcam/data/webcam_images/Kyluchevskoy/2008-Mon-Jan-14-06:55:17.jpeg')
  #  puts "error message #{errcond.error}"
end
