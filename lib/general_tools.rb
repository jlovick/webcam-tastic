# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

module General_tools
require 'rubygems'
require 'optparse'
require "./mysql_handler.rb"
require "./image_data.rb"
require "./threading.rb"
require "./general_tools.rb"
require "./webcam_processor.rb"
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

  class GT
    
  
  def make_dir_if_doesnt_exist(dir)
  # looks to see if the directory exists, if not it makes it
  if not (File.exists?(dir) &&  File.directory?(dir))
        Dir.mkdir(dir)
    end
  end
  
  end
end

