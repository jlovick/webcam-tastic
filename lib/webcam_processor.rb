#
# To change this template, choose Tools | Templates and open the template in the
# editor.
 

module Webcam_processor
  require 'rubygems'
  require "./mysql_handler.rb"
  require "./image_data.rb"
  require "./threading.rb"
  require "./general_tools.rb"
  require "./webcam_processor.rb"
  require "./new_stats.rb"
  require "fileutils"
#  require 'hornetseye_xorg'
  require 'hornetseye_narray'
  require 'malloc'
  require 'multiarray'
  require 'narray'
  require 'mathn'
  require 'matrix'
  require 'rbgsl'
  require 'thread'
  require 'date'
  require 'set'
  require 'ostruct'
  require 'open-uri'
  require 'pp'
  require "gnuplot"
  require 'strscan'
  include Hornetseye

  class Webcam_Instructor
    attr_reader :current_webcam, :experiment , :operation, :area
    attr_writer  :current_webcam, :experiment , :operation, :area
 
    @@msh = nil
    

    def initialize( current_webcam, experiment, operation, area)
  
      @@msh = Mysql_Handler::Mysql_handler.new()
      @pw = Process_webcam.new(@@msh)
      @webcam_names = Array.new
    
      @webcam_names. push( "St_Helens_Hi_res" )
      @webcam_names. push("St_Helens_Low_res")
      @webcam_names. push("Shiveluch")
      @webcam_names. push("Bezymianny")
      @webcam_names. push("Klyuchevskoy")
      @webcam_names. push("Augustine")
      @webcam_names. push("Augustine Mound")
      @webcam_names. push("Augustine Lagoon")
      @webcam_names. push("Veniaminof")
  
      @current_webcam = current_webcam
      @experiment = experiment
      @operation = operation
      @area = area
    end
    
    def close()
      @@msh.close()
    end
    
    def import_all_webcams()
            @pw.add_in_images("St_Helens_Hi_res", "/export/whale/webcam-data/St_Helens_Hi_Res/","",".jpeg")
            @pw.add_in_images("St_Helens_Low_res", "/export/whale/webcam-data/St_Helens_Lo_Res/","",".jpeg")
      #      @pw.add_in_images("Shiveluch", "/raid/webcam-archive/Shiveluch/","",".jpeg")
      #      @pw.add_in_images("Bezymianny", "/raid/webcam-archive/Bezymianny/","",".jpeg")
      #  @pw.add_in_images("Klyuchevskoy", "/mnt/worlddrive/webcam_images/Klyuchevskoy/","",".jpeg")
    puts " not set up at the moment due to svn / machine difference issues"
    end
    
    def import_webcam(path,id,ext)
      @pw.add_in_images(@current_webcam, path,id,ext)
    end
    

    def day_month_year_stats(filename)
      File.open(filename, "w") do |wfl|
        @current_webcam.each do  |wm|
          puts " doing ymd stats for #{wm}"
          wid =  @@msh.get_webcam_id(wm)
          for year in (2003..2009)
            for month in (1..12)
              for day in (1..31)
                res = @@msh.count_images(wid, day, month, year)
                if (res.to_i > 0)
                  wfl.puts " for #{wm} #{year.to_s}/#{month.to_s}/#{day.to_s}  #{res.to_s} images found"
                end
              end  
            end
            puts " done #{year} \n"
          end
        end
      end
      puts " finished outputing dmy stats \n"
    end

    def process_all_images( awhere )
      camera_id =  @@msh.get_webcam_id( @current_webcam )
      tesr = @@msh.get_webcam_data_area( camera_id, @area )
      exp_list = ImageStats::Experiment_Table_List.new(@@msh)
      exp = exp_list.get_experiment_id(@experiment)
      puts " experiment #{@experiment} is #{exp} "
      if (exp != nil)
        images = @@msh.get_all_unprocessed_camera_images(camera_id, exp, awhere)
        images_count = images.length
        puts " #{images_count}"
        @it = 0
        sttime = Time.new
        images.each do |thisimage| 
          thisimage = @pw.if_required_get_missing_image_from_url(thisimage, @current_webcam)
          @pw.send_image_to_process(sttime, images_count, thisimage, tesr, @operation ,exp) 
         
          #   }
        end
      end
    end
    
    def remove_bad_stats()
      all_stats = @@msh.get_all_stat_id()
      all_file_ids = @@msh.get_all_camera_file_id()
      all_stats.sort
      all_file_ids.sort
      unfound = Array.new
      unfound = all_stats - all_file_ids
      puts " found #{all_stats.length} statistics entries, and #{all_file_ids.length} files entries"
      puts " #{unfound.length} file entries do not exist in table"
      unfound.each do |id|
        #        @@msh.remove_stat_entry(id)
        puts " remove statistics entrys for camera id #{id}"
      end
    end
    
    def gnuplot(query_file,output_file, colx, coly, coms_file) 
      # #not finnished
      query = nil
      File.open(query_file, "r").each  do |line|
        line = line.strip
        query = query.to_s + line.to_s + " "
      end
      puts "#{query}"
       
      IO.popen("gnuplot -persist", "w") do |io| 
        File.open(coms_file, "r").each  do |line|
          line = line.strip
          io.puts "#{line}"
        end
        columns = Array.new
        columns.push(colx)
        columns.push(coly)
       
        outdata = @@msh.generic_query(query,columns ) 
        File.open( fn,"w") do |outfile|
        
        end 
        
        
      end
    end
    
    def gnuplot_histogram(of,exp, channel, st_num,st_file, coms, disp, output) 
      ids = Hash.new
      comms = Hash.new
      hbrr = nil
      pio = nil
      title = nil
      chlist = ImageStats::Channel_Table_List.new(@@msh)
      exp_table = ImageStats::Experiment_Table_List.new(@@msh)
      exp_id=exp_table.get_experiment_id(exp)
      channel_id = chlist.get_channel_id(channel)
      puts "experiment #{exp} is #{exp_id} \n channel #{channel} is #{channel_id}"
      if (st_file.to_s.length > 0)
        puts "loading in file #{st_file} "
        File.open(st_file, "r").each  do |line|
          line = line.strip
          #      puts " line is #{line} #{line.to_s.slice(0,1)}"
          if (line.to_s.slice(0,1) != "#")
            #   puts " ahhh"
            if (line.to_s.slice(0,1) == "!")
              puts " got a gnuplot command "
              line.slice(1...line.length).scan(/(\w*) (.*)/) { |file, res| 
                puts " setting #{file}  to #{res} "
                comms[file] = res
              }
            else
              puts " got an id "
              line.scan(/(\d*\ *)(.*)/) { |file, res| 
                if (file.length > 0)
                  if (res.length == 0)
                    puts " file is #{file}"
                    res = file
                  end
                  puts " adding in  id=#{file} as #{res} "
                  ids[res] = file
                end
              }
            end
          else
            puts " skipped commented line #{line}"
          end
        end
      else
         
        st_num.scan(/(\d*\ *)(.*)/) { |file, res| 
          if (file.length > 0)
            if (res.length == 0)
              res = file
            end
            puts " adding in  id=#{file} as #{res} "
            ids[res] = file
          end
        }
      end
      puts " finnished loading in id's to process "
      puts " set output base to #{output}"
      if (disp.to_s.length == 0)
        disp = "x11"
        puts " set display to default (x11)"
      end
      puts " gnuplot terminal set to #{disp}"
       
      #  GSL::Vector.graph([hbrr], "-T svg -C -g 1 -S 1 > "+of+"_"+id.to_s+".svg")
      ids.keys.each do |id|
        hbrr = nil
        pio = nil
        file_path = @@msh.get_camera_image_file(id)
       
        end_name =  File.basename(file_path[0].to_str,".jpeg")
        puts " processing      #{id} #{end_name}"
        IO.popen("gnuplot -persist", "w") do |io|
          io.print("set terminal #{disp} \n")
    
       
          if ( coms != nil )
            io.print("#{coms} \n")
            puts "#{coms}"
          end
          comms.keys.each do |idc|
            io.print("set #{idc}  #{comms[idc]}\n")
            puts  "set #{idc}  \'#{comms[idc]}\'\n"
          end
        
          io.print("set xrange  [0:255] \n")
       
     

          title = id
          io.print(" set title 'Histogram of DN occurance  #{title}   #{exp}  #{channel}' \n")
        
          if (output.to_s.length > 0)
            io.print("set output \"#{output}/#{end_name}-hist-#{id}-exp-#{exp}-channel-#{channel}.#{disp}\" \n")
            puts "set output \"#{output}/#{end_name}-hist-#{id}-exp-#{exp}-channel-#{channel}.#{disp}\" \n"
          end
        
          fn= "#{of}/#{end_name}_#{ids[id]}_exp-#{exp}-channel-#{channel}.txt"
          puts " Processing \"#{id}\" as src_file_id  #{ids[id]} with datafile #{fn} \n"
          File.open( fn,"w") do |outfile|
            if ((ids[id].length)> 0)
              my_hist = @@msh.get_histogram(ids[id],exp_id, channel_id)
              # puts "#{my_hist.length}\n #{my_hist}"
              hbrr = (Marshal.load(my_hist.strip)).to_gv
              y = 0
              hbrr.each do |it|
                outfile.puts " #{y}, #{it} "
                y=y+1
              end
            end
          end
          #
          if pio.to_s.length > 0 
            pio = pio + " , "
          end
          # pio = pio.to_s + "'"+fn.to_s + "' using 1:2 with lines title
          # \'"+id+"\' "
          pio = "#{pio} '#{fn}' using 1:2 with lines title '#{end_name}-#{id}' "
          # puts " #{pio}"
          io.print("plot #{pio} \n")
          io.flush
          puts " flushed gnuplot"
        end

        
      end
    end
    
    def find_useful( criteria )
      # #goes through a  camera's images/stats and marks out the ones that look
      # promising.
      camera_id =  @@msh.get_webcam_id( @current_webcam )
      affected = nil
      case (criteria)
      when "variance"
        affected = @@msh.filter_useful_images_too_low_var(camera_id)
      when  "low_max"
        affected = @@msh.filter_useful_images_too_low_max(camera_id)
      when  "hi_min"
        affected = @@msh.filter_useful_images_too_hi_min(camera_id)
      when "all"
        affected = @@msh.filter_useful_images_too_low_var(camera_id)
        affected = @@msh.filter_useful_images_too_low_max(camera_id)
        affected = @@msh.filter_useful_images_too_hi_min(camera_id)
      end #end of case
      puts " #{affected} images were marked 'boring'"
    end #end of find_useful
    
    def dump_img(img, dest)
      # #puts a copy of the image in the dest directory
      camera_id =  @@msh.get_webcam_id( @current_webcam )
      file_path = @@msh.get_camera_image_file(img)
       
      end_name = dest.to_str + File.basename(file_path[0].to_str)
      puts " #{img} #{camera_id} #{file_path[0]} --> #{end_name} "
      File.symlink(file_path[0].to_str, end_name)
    end
    
    def dump_sub_img(img, exp, channel,  dest )
      # #puts a copy of the image in the dest directory
      camera_id =  @@msh.get_webcam_id( @current_webcam )
      chlist = ImageStats::Channel_Table_List.new(@@msh)
      exp_table = ImageStats::Experiment_Table_List.new(@@msh)
      exp_id=exp_table.get_experiment_id(exp)
      ch_id = chlist.get_channel_id(channel)
      file_data = @@msh.get_subimage_data(img, exp_id, ch_id)
      #   pp file_data
      file_path = @@msh.get_camera_image_file(img)
      sub_img =  File.basename(file_path[0].to_str, ".jpeg")
      end_name = "#{dest.to_str}/#{sub_img}-ch-#{ch_id}-exp-#{exp_id}.#{file_data["DATA_TYPE"]}"
      puts " writting file name #{end_name} for camera  #{camera_id}"
      f = open(end_name,'w')
      f.write(file_data["DATA"])
      f.close
     
      
    end
    
    def dump_sub_img_list(img_list, exp, channel, dest)
      # #loads up the img list file and calls dump_img for each line
      File.open(img_list, "r").each  do |line|
        line = line.strip
        dump_sub_img(line,exp,channel,dest)
      end
    end
    
    def dump_img_list(img_list,dest)
      # #loads up the img list file and calls dump_img for each line
      File.open(img_list, "r").each  do |line|
        line = line.strip
        dump_img(line,dest)
      end
    end
    
    def mean_control_image( img_where, control_exp, channel)
      # allot of this is cut and paste from the difference image code
      chlist = ImageStats::Channel_Table_List.new(@@msh)
      pp channel
      if ( channel.include?("all") )
        
        channel = chlist.get_all_channel_names()
      end
      data_tables = ImageStats::Stat_Table_List.new(@@msh)
      exp_table = ImageStats::Experiment_Table_List.new(@@msh)
      exp_id=exp_table.get_experiment_id("Mean_Control")
      control_exp.each do |cont_exp|
        puts " experiment #{cont_exp} has id #{exp_table.get_experiment_id(cont_exp)} "
      end
      img = @@msh.get_all_unprocessed_camera_images( @@msh.get_webcam_id( @current_webcam ), exp_id, img_where)
      img.each do |img_a|
        #       pp img_a
        img_id = img_a.id
        puts " img id #{img_id} "
        channel.each do |ch_name|
          ch_id = chlist.get_channel_id(ch_name)
          puts " doing #{img_id} #{ch_id} #{exp_id} "
          scb = ImageStats::Stats_Collection.new(@@msh, img_id, exp_id, ch_id)
          raw_control_stats = Array.new 
          control_exp.each do |cont_exp|
            raw_control_stats.push( @@msh.get_stats_collection(img_id, exp_table.get_experiment_id(cont_exp), ch_id) )
          end
          cont_max = nil
          cont_min = nil
          cont_mean_a = Array.new
          cont_var_a = Array.new
          hsarr = Array.new
          
          raw_control_stats.each do |cd|
            cd.each do |cc|
              #   pp cc
              this_tables_name = data_tables.get_table_name( cc.table_id )
              control_result=@@msh.get_stats_data(this_tables_name, cc.table_key)
              #         puts " table name #{this_tables_name}"
              case (this_tables_name)
              when "Mean_Table"
                cont_mean_a.push( control_result["DATA"].to_f )
              when "Max_Table"
                if (cont_max != nil)
                  cont_max = [control_result["DATA"].to_f , cont_max].max
                else  
                  cont_max = control_result["DATA"].to_f;
                end
              when "Min_Table"
                if (cont_min != nil)
                  cont_min = [control_result["DATA"].to_f, cont_min].min
                else
                  cont_min = control_result["DATA"].to_f
                end
              when "Variance_Table"
                cont_var_a.push( control_result["DATA"].to_f )
              when "Histogram_Table"
                if ( chlist.get_channel_id("combined") == ch_id)
                  puts " got a histogram (a)"
                  hsarr.push( NArray.to_na((Marshal.load(control_result["DATA"].strip))) )
                end              
              end
              
            end
          end
          puts " done with getting control stats from DB"
          if (cont_mean_a.size > 0)
            cont_mean = NArray.to_na(cont_mean_a).mean
          else
            cont_mean = nil
          end
          if (cont_var_a.size > 0)
            cont_var = NArray.to_na(cont_var_a).mean
          else
            cont_var_a = nil
          end
          hbrr = nil
          count = 0
          itsum = 0
          if ( chlist.get_channel_id("combined") == ch_id)
           
            hsarr.each do |it|
              if (!hbrr)
                hbrr = it
              else
                hbrr += it
              end
              count += 1
              itsum += it.sum
            end
            if ((hbrr != nil) && (hbrr.size > 0) )
              hbrr = hbrr / ( itsum)
            else
              hbrr = nil
            end
         
            puts " doing histogram  "
            # crat_hist = NArray.to_na( Marshal.load(crater_stat[9].strip) )
           
            res_hist = hbrr
            dp = Marshal.dump( res_hist.to_a)
            scb.add_table("Histogram_Table", :histogram => dp)
          end
          scb.add_table("Mean_Table", :mean => ( cont_mean.to_f) )
          scb.add_table("Max_Table", :max => ( cont_max.to_f) )
          scb.add_table("Min_Table", :min => ( cont_min.to_f) )
          scb.add_table("Variance_Table", :variance => ( cont_var.to_f) )
          puts " done with avarging (etc) the control-stats stats"
        end
      end
      puts " finnished making mean control stats"
    
    end
    
    def difference_image(img_where, control_exp, crater_exp, channel)
      chlist = ImageStats::Channel_Table_List.new(@@msh)
      pp channel
      if ( channel.include?("all") )
        
        channel = chlist.get_all_channel_names()
      end
      data_tables = ImageStats::Stat_Table_List.new(@@msh)
      exp_table = ImageStats::Experiment_Table_List.new(@@msh)
      exp_id=exp_table.get_experiment_id("crater - control")
      
      # pp channel
      #  --------------------------remove images from list that have allready been processed
      img = @@msh.get_all_unprocessed_camera_images( @@msh.get_webcam_id( @current_webcam ), exp_id, img_where)
      #  -----------------------------------------------------------------------------------
      #      pp img

      img.each do |img_a|
        #       pp img_a
        img_id = img_a.id
        puts " img id #{img_id} "
        channel.each do |ch_name|
          ch_id = chlist.get_channel_id(ch_name)
          puts " doing #{img_id} #{ch_id} #{exp_id} "
          # #go through each image and work out difference stats
          scb = ImageStats::Stats_Collection.new(@@msh, img_id, exp_id, ch_id)
          #    puts " got collection#{scb}"
          #    puts " crater_exp #{crater_exp}   id #{exp_table.get_experiment_id(crater_exp)} "
          raw_crater_stats = @@msh.get_stats_collection(img_id, exp_table.get_experiment_id(crater_exp), ch_id) 
          raw_control_stats = Array.new 
          control_exp.each do |cont_exp|
            raw_control_stats.push( @@msh.get_stats_collection(img_id, exp_table.get_experiment_id(cont_exp), ch_id) )
          end
          #    puts " crater stats:"
          #    pp raw_crater_stats
          #    puts " control stats:"
          #    pp raw_control_stats
          # pp crater_stat ok so raw_crater_stats has a list of tables and ids
          # of relevant stats as does raw_control_stats pp control_stats ok now
          # work out the combined control stats
          cont_max = nil
          cont_min = nil
          cont_mean_a = Array.new
          cont_var_a = Array.new
          hsarr = Array.new
          
          raw_control_stats.each do |cd|
            cd.each do |cc|
              #   pp cc
              this_tables_name = data_tables.get_table_name( cc.table_id )
              control_result=@@msh.get_stats_data(this_tables_name, cc.table_key)
              puts " table name #{this_tables_name}"
              case (this_tables_name)
              when "Mean_Table"
                cont_mean_a.push( control_result["DATA"].to_f )
              when "Max_Table"
                if (cont_max != nil)
                  cont_max = [control_result["DATA"].to_f , cont_max].max
                else  
                  cont_max = control_result["DATA"].to_f;
                end
              when "Min_Table"
                if (cont_min != nil)
                  cont_min = [control_result["DATA"].to_f, cont_min].min
                else
                  cont_min = control_result["DATA"].to_f
                end
              when "Variance_Table"
                cont_var_a.push( control_result["DATA"].to_f )
              when "Histogram_Table"
                if ( chlist.get_channel_id("combined") == ch_id)
                  puts " got a histogram (a)"
                  hsarr.push( NArray.to_na((Marshal.load(control_result["DATA"].strip))) )
                end              
              end
              
            end
          end
          puts " done with control stats"
          if (cont_mean_a.size > 0)
            cont_mean = NArray.to_na(cont_mean_a).mean
          else
            cont_mean = nil
          end
          if (cont_var_a.size > 0)
            cont_var = NArray.to_na(cont_var_a).mean
          else
            cont_var_a = nil
          end
          hbrr = nil
          count = 0
          itsum = 0
          if ( chlist.get_channel_id("combined") == ch_id)
           
            hsarr.each do |it|
              if (!hbrr)
                hbrr = it
              else
                hbrr += it
              end
              count += 1
              itsum += it.sum
            end
            if ((hbrr != nil) && (hbrr.size > 0) )
              hbrr = hbrr / ( itsum)
            else
              hbrr = nil
            end
          end
          # #puts " #{cont_mean} #{cont_max} #{cont_min} #{cont_var}" #hbrr.each
          # do |it| print "#{it}  " end
          crat_mean = nil
          crat_max = nil
          crat_min = nil
          crat_var = nil
          crat_hist = nil
          raw_crater_stats.each do |cc|
            this_tables_name = data_tables.get_table_name(cc.table_id)
            crat_result=@@msh.get_stats_data(this_tables_name, cc.table_key)
            puts " crater....  got #{this_tables_name} "
            case (this_tables_name)
            when "Mean_Table"
              crat_mean = crat_result["DATA"].to_f
            when "Max_Table"
              crat_max = crat_result["DATA"].to_f 
            when "Min_Table"
              crat_min = crat_result["DATA"].to_f
            when "Variance_Table"
              crat_var = crat_result["DATA"].to_f
            when "Histogram_Table"
              
              if ( chlist.get_channel_id("combined") == ch_id)
                puts " got  histogram (b)"
                crat_hist =  NArray.to_na((Marshal.load(crat_result["DATA"].strip))) 
              end
            end
           
          end
          puts " ch_id = #{ch_id}  Combined = #{ chlist.get_channel_id("combined") }"
          
          if ( (chlist.get_channel_id("combined") == ch_id) && ( crat_hist != nil))
            puts " doing histogram  "
            # crat_hist = NArray.to_na( Marshal.load(crater_stat[9].strip) )
            crat_hist = crat_hist / (crat_hist.sum)
            res_hist = crat_hist - hbrr
            dp = Marshal.dump( res_hist.to_a)
            scb.add_table("Histogram_Table", :histogram => dp)
          end
          puts " done with crater stats"
          scb.add_table("Mean_Table", :mean => (crat_mean.to_f - cont_mean.to_f) )
          scb.add_table("Max_Table", :max => (crat_max.to_f - cont_max.to_f) )
          scb.add_table("Min_Table", :min => (crat_min.to_f - cont_min.to_f) )
          scb.add_table("Variance_Table", :variance => (crat_var.to_f - cont_var.to_f) )
          # #@@msh.store_statistics( crater_stat[1], "crater - control", "0x0
          # +0,0", crater_.to_f - cont_mean.to_f, crater_stat[5].to_f -
          # cont_max.to_f, crater_stat[6].to_f - cont_min.to_f,
          # crater_stat[7].to_f - cont_var.to_f, "combined",  dp)
     
        end
        
      end
      # #end of diff_img
    end
    
    def make_thermal_stats( sql_where )
      camera_id =  @@msh.get_webcam_id( @current_webcam )
      data_tables = ImageStats::Stat_Table_List.new(@@msh)
      exp_table = ImageStats::Experiment_Table_List.new(@@msh)
      chlist = ImageStats::Channel_Table_List.new(@@msh)
      exp_id=exp_table.get_experiment_id("crater - control")
      exp_source = exp_table.get_experiment_id("luminesence_enhance")
      tf_stat_table_id = data_tables.get_table_id("Thermal_Flux_Table")
      ch_id = chlist.get_channel_id("combined")
      img = @@msh.get_all_images_still_needing_stat_calculated(camera_id, exp_id, tf_stat_table_id, sql_where)
      hist_stat_table_id = data_tables.get_table_id("Histogram_Table")
      mean_stat_table_id = data_tables.get_table_id("Mean_Table")
      variance_stat_table_id = data_tables.get_table_id("Variance_Table")
      img.each do |img_a|
        # pp img_a
        img_id = img_a.id
        sca = ImageStats::Stats_Collection.new(@@msh, img_id, exp_source, ch_id)
        scb = ImageStats::Stats_Collection.new(@@msh, img_id, exp_id, ch_id)
          
        # pp scb
        if (scb.stats_collection["ImageStats::Histogram_Table"] )
          crater_hist_stat = scb.stats_collection["ImageStats::Histogram_Table"].value["DATA"].strip
          
          #    pp crater_hist_stat
          crater_hist =  NArray.to_na((Marshal.load(crater_hist_stat))) 
          #       j=0
          
          # #puts " histogram #{ crater_hist.to_string } "
          crater_mean_s = sca.stats_collection["ImageStats::Mean_Table"].value["DATA"].strip.to_f
          #       puts " crater_mean is #{crater_mean} "
          crater_var_s = sca.stats_collection["ImageStats::Variance_Table"].value["DATA"].strip.to_f
          crater_mean_t = scb.stats_collection["ImageStats::Mean_Table"].value["DATA"].strip.to_f
          #       puts " crater_mean is #{crater_mean} "
          crater_var_t = scb.stats_collection["ImageStats::Variance_Table"].value["DATA"].strip.to_f
          crater_mean = crater_mean_s.to_f - crater_mean_t.to_f #find out the mean of the control group
          crater_var = crater_var_s.to_f - crater_var_t.to_f # find out the control group var
          #       puts "crater_var is #{crater_var}"
          hist_start = (crater_mean.to_f + (crater_var.to_f / 2.0)).to_i  #work out where to start counting up on the histogram from,
          #      hist_sum = 0
          if (hist_start < 0 )
            hist_start = 0
          end
          if (hist_start > 255)
            hist_sum = 0
          else
            hist_sum = crater_hist[hist_start..255].sum
          end
          #        hist_suma = 0
          
          #      crater_hist.each do |i|
          #        puts " #{j} #{i}"
          #        j+= 1
          #        if (j > hist_start)
          #          hist_suma += i
          #        end
          #      end
          scb.add_table("Thermal_Flux_Table", :flux => hist_sum ) 
          puts " added flux entry #{img_id} from histogram range ( #{hist_start} to 255 ) with value sum of : #{hist_sum} "
        else
          puts " entry #{img_id} appears not to have a histogram?"
           
        end
      end
      puts " finnished adding flux table entries"
    end
    # #end of module
  end
  
  module Enumerable
    def each_simul
      threads = []
      each { |e| threads << Thread.new { yield e}}
      puts "waiting for threads to terminate"
      threads.each { |e| e.join }
    end
  end

  class Channel_list
    include Enumerable
    include Comparable
    attr_reader :channel
    attr_writer :channel  
    def <=>(other)
      self.channel <=> other.channel
    end
  end

  class Image_stats
    include Enumerable
    
    attr_reader :image_proto
    attr_writer :image_proto
    @@msh = nil
    @nimg = nil
    @@gc_count = 0
    @@tbl_list = nil
    @@chl_list = nil
    
    def initialize(mh, image_proto)
      @@msh = mh
      @@tbl_list = ImageStats::Stat_Table_List.new(@@msh)
      @@chl_list = ImageStats::Channel_Table_List.new(@@msh)
      @image_proto = image_proto

    end

    def image_to_pixel_matrix( channel  )
      dx = @image_proto.tlx.to_i
      dy = @image_proto.tly.to_i
      nx = @image_proto.width.to_i
      ny = @image_proto.height.to_i
      img = @nimg
      case (channel)
      when "red"
        #        img = (@nimg).to_multiarray()
        res = img.r.to_narray();
      when "blue"
        #        img = (@nimg).to_multiarray()
        res = img.b.to_narray();
      when "green"
        #        img = (@nimg).to_multiarray()
        res = img.g.to_narray();
      when "grey"  
        #        img = (@nimg.to_greyf).to_multiarray()
        res = ((img.r + img.b + img.g)/3).to_narray();
      end
      ipful = res.to_gm();
      if ((dx+dy+nx+ny) != 0)
        ipres = ipful.view(dy,dx,ny,nx) 
        return ipres
      else
        return ipful
      end
    end
    
    
    def st_helens_lumninesce_enhance(image_id,exp)
      dx = @image_proto.tlx.to_i
      dy = @image_proto.tly.to_i
      nx = @image_proto.width.to_i
      ny = @image_proto.height.to_i
       
       
      img = @nimg
      res_r = img.r.to_narray();
      res_g = img.g.to_narray();
      res_b = img.b.to_narray();
      dims = res_r.dim
      shape = res_r.shape
      result = NArray.new(Float, shape[0], shape[1])
      result = ((res_r.to_f * res_g.to_f * res_b.to_f) / (255.0*255.0*255.0)) * 255.0
      #     puts " #{res_r.mean} #{res_g.mean} #{res_b.mean} #{result.mean}"
      ipful = result.to_gm()
    
      
      if ((dx+dy+nx+ny) != 0)
        ipres = ipful.view(dy,dx,ny,nx) 
    
        return ipres
      else
        #     outimg = (result).to_hornetseye()
        #  outimg.save("/tmp/test-#{image_id}.tif")
        #    outimg.to_grey8.save("~/tmp/images/#{exp}-#{image_id}.jpeg" );
        #   outimg = nil
        return ipful
      end
    end
    
    def load_an_image(image_id, my_img,  operation, channel, experiment )
      @nimg = my_img
    	@@gc_count = @@gc_count+1
      pixels = nil
      scb = ImageStats::Stats_Collection.new(@@msh, image_id, (experiment), @@chl_list.get_channel_id(channel) )
      
      case (operation)
      when "channels"
        pixels = image_to_pixel_matrix( channel  )
      when "st_helens_luminesce_enhance"
        pixels = st_helens_lumninesce_enhance(image_id,experiment)
        outimg = (pixels.to_na).to_multiarray()
        fname = "/tmp/images/#{experiment}-#{image_id}.jpeg"
        outimg.save_ubyte ( fname );
        outimg = nil
        puts " written #{fname}"
        f = open(fname,'r')
        tbl_img = f.read
        f.close
        # #dp = Marshal.dump( tbl_img.to_a )
        scb.add_table(@@tbl_list.get_table_id("Image_Data_Table"), :image_data => tbl_img, :image_data_type => "jpg" )
        puts " stored #{fname} as a binary blob in the \"Image_Data_Table\" table in the DB"
      end
      @nimg = nil
    
      #    pna = nil
      #    gma = nil
      #    hni = nil
    
      #    pna = pixels.to_narray
      #    gma = pna.to_multiarray
      #    hni = gma.to_hornetseye
    
      #  output = OpenGLOutput.new
      #  display = X11Display.new
      #  window = X11Window.new( display, output, image_proto.width  ,image_proto.height  )
      #  window.title = "XVideo display"
      #  window.show
      #  output.write( hni )
      #  display.eventLoop

      mean = GSL::Stats::mean(pixels,1)
      max = GSL::Stats::max(pixels,1)
      min = GSL::Stats::min(pixels,1)
      variance =  Math::sqrt( GSL::Stats::variance(pixels,1) )
      #  puts " mean is #{mean}, max #{max}, min #{min}, #{variance}"
      h = GSL::Histogram.alloc(256,0,255)
      (pixels.to_v).each do |x|
        h.increment(x)
      end
      #  h.graph("-T X -C ") # we dont need to see the raw histogram here
      harr = GSL::Vector.alloc(256)
      hpos = GSL::Vector.alloc(256)
      for day in (0..255)
        harr[day] = h.get(day)
        hpos[day] = day;
      end
      # need to find right fitting solution
      #   coef, err, chisq = GSL::Fit::mul(hpos, harr)
      #
      # puts "coef #{coef} err #{err} chisq #{chisq}" dump coef coef, cov,
      # chisq, status = GSL::Poly::fit(hpos, harr, 32) coef, cov, chisq, status
      # = Poly.fit(hpos, harr, 3)
      #  puts "coef #{coef} err #{cov} chisq #{chisq}"
 
      # none of these fittings worked very well
      #
      #  x2 = GSL::Vector.linspace(1, 256, 255)
      #  GSL::Vector.graph([hpos, harr], "-C -g 1 -S 1")

      dp = Marshal.dump( harr.to_a )
      #  puts " dt = #{dp}"
      #  hbrr = (Marshal.load(dp)).to_gv
      region = @image_proto.tlx.to_s + 'x' + @image_proto.tly.to_s + '+'+@image_proto.height.to_s + ','+ @image_proto.width.to_s
     
      # this was the old style store stats
      #   @@msh.store_statistics( image_id, experiment, region, mean, max, min, variance, channel, dp)
      #    exp_list = ImageStats::Experiment_Table_List.new(@@msh)

         
      #    scb = ImageStats::Stats_Collection.new(@@msh, image_id, (experiment), @@chl_list.get_channel_id(channel) )
      scb.add_table(@@tbl_list.get_table_id("Mean_Table"), :mean => mean)
      scb.add_table(@@tbl_list.get_table_id("Max_Table"), :max => max)
      scb.add_table(@@tbl_list.get_table_id("Min_Table"), :min => min)
      scb.add_table(@@tbl_list.get_table_id("Variance_Table"), :variance => variance)
      scb.add_table(@@tbl_list.get_table_id("Histogram_Table"), :histogram => dp)
      scb = nil
      #  hbrr.print
      # #output = OpenGLOutput.new #display = X11Display.new #window =
      # X11Window.new( display, output, nimg.display ) #window.title = "XVideo
      # display" #window.show #output.write( nimg ) #display.eventLoop
      puts "#{@@gc_count},  #{image_id}, channel #{channel} done"
    end
    if (@@gc_count >= 200)
      GC.start
      @@gc_count = 1
    end

  end

  
  
  class Process_webcam
    @@msh = nil
    
    def initialize( mh)
      @@msh = mh
      @it = 0
      @tm = 0
      @ch = ["grey","red","green","blue"]
      @odtime = "some time in the future"
    end
    
    def process_path( src,  grep, ext)
      if (!@all_files_list) 
        @all_files_list = Array.new
      end
      processed = 0
      puts "in dir #{src}"
      image_dir = Dir.new(src)
      image_dir.each do |fn|
        if ( File.directory?(src+fn) )
          puts " done... #{fn}"
          if ( (fn == ".") )
            if (processed == 0)
              items = process_directory(src,grep,ext)
              items.each do |it|
                @all_files_list.push(it)
              end
              processed = 1
            end
          else
            if (! (fn == "..") )
              process_path(src+fn+"/",grep,ext)
            end
          end
        end
      end
      return @all_files_list
    end
  
    def process_directory(directory,grep, ext)
      @files_list = Array.new
      puts " Processing Directory : #{ directory } "
      image_dir = Dir.new(directory)
      image_dir.each do |fn|
        if (File.extname(fn) == ext)  then
          parse_fn = File.basename(fn, ext)
          # #see if we should be further greping the filename
          if (grep.length > 0 )
            # ok see if filename contains string
            if (parse_fn.match(grep) != nil)
              # puts "#{parse_fn} matches #{grep}"
              @files_list.push( directory+fn.to_s)
            end
          else #Classic
            # #no grepping needed
            @files_list.push( directory+fn.to_s)
          end
        end #see if file has png extension
      end  # getting directory list
      puts "found this number of files : #{@files_list.count}" 
      return @files_list
    end
    
    def read_st_hel_date( filename )
      
      ft = nil
      open(filename, 'rb') do  |f|
        f.seek(24,File::SEEK_SET)
        astr = f.read(8)
        #  puts "astr:-#{astr}"
        if (  astr != "Webcam32")
          return nil
        end
        f.seek(30,File::SEEK_SET)
        dstr  = f.read(35)
        mdstr =  StringScanner.new(dstr.to_s)
        rb = mdstr.exist?(/(\d+)\/(\d+)\/(\d+) (\d+):(\d+):(\d+)/)
        ms = dstr[rb-17..rb-1]
        # puts "|#{ms}| |#{rb}|"
        #  puts "#{filename} image time is supposedly :- \"#{dstr}\"   :- 20#{ms[6..7]}/#{ms[0..1]}/#{ms[3..4]}   #{ms[9..10]}:#{ms[12..13]}:#{ms[15..16]} "
        ft = Time.utc("20#{ms[6..7]}",ms[0..1],ms[3..4],ms[9..10],ms[12..13],ms[15..16] )
        # ##    puts " time :- #{ft.to_s}"
      end
      return ft
    end

    def get_image_date( fn,ext )
      id = read_st_hel_date( fn )
      if ( id )
        @image_date = id
        return id
      end
      @months = [ "Jan", "Feb" , "Mar" , "Apr" , "May" , "Jun" , "Jul" , "Aug", "Sep", "Oct" , "Nov", "Dec" ]
      @days = ["Mon","Tue","Wed","Thu","Fri","Sat","Sun"]
      parse_fn = File.basename(fn, ext)
      fn_parts = parse_fn.split(/-/)
      tn_parts = fn_parts[4].split(/:/)
      mon = @months.index( fn_parts[2] ) + 1
      @image_date = Time.utc( fn_parts[0].to_i , mon.to_i, fn_parts[3].to_i, tn_parts[0].to_i, tn_parts[1].to_i, tn_parts[2].to_i)
      return @image_date
    end

    def add_in_images( name, path, grep,  ext)
      wid =  @@msh.get_webcam_id(name)
      puts " webcam id is #{wid}"
      filenames = process_path(path,grep, ext)
      puts "got all files to process #{filenames.length}"
      allready_present = @@msh.get_all_camera_image_files(wid)
      if (allready_present != nil)
        puts "got list of files present.. #{allready_present.length}"
        filenames.sort
        allready_present.sort 
        less_filenames = filenames - allready_present
        puts " removed all duplicate images.... #{less_filenames.length} files left \n now adding these images to db "
      else
        less_filenames = filenames 
      end
      less_filenames.each do |fn|
        image_date = get_image_date(fn,ext)
        # date format is :2008-03-20 11:01:52
        @@msh.add_webcam_image(wid,fn,"NULL",image_date.strftime("%Y-%m-%d %H:%M:%S"))
        puts " added file #{fn} OK"
      end
      less_filenames.clear
      filenames.clear
      if (allready_present) then
        allready_present.clear
      end
      puts " done adding images to the DB "
    end

    def add_in_avo_images(name, filelist)
      wid =  @@msh.get_webcam_id(name)
      base_url = @@msh.get_base_url(wid)
    
      File.open(filelist, "r") do |wfl|
        wfl.each_line do |line|
          # puts "Got #{line.dump}"
          filename = "NULL"
          # parse the line to what we need
          dt = line.dump.slice(-20,13)
          puts dt
          year = dt[0,4].to_i
          month =  dt[4,2]
          day = dt[6,2]
          hr =  dt[9,2].to_i
          mn =  dt[11,2].to_i
        
          im_date = Time.utc(year ,month.to_i,day.to_i ,hr,mn)
          puts im_date
          brurl = base_url + year.to_s+"/"+month+ "/"+day+"/"+line
          @@msh.add_webcam_image( wid, filename,brurl, im_date.strftime("%Y-%m-%d %H:%M:%S"))
        end

      end
      puts " Done adding  #{name}"
    end

    def get_image_from_url(thisimage, myuser, mypassword)
      # #need to this 4 step program to properly flush out the buffer before
      # reading it in the convert command
      f =  open(thisimage.filename,"w")
    
      puts "getting #{thisimage.url} as  #{thisimage.filename} \n using authentication"
      f.write(open(thisimage.url.to_s ,
          :http_basic_authentication=>[myuser, mypassword]  ).read)
      f.flush
      f.close
    end

    def if_required_get_missing_image_from_url(thisimage, current_webcam)
      if (thisimage.url.to_s.length > 6)
        # dont do anything if their is no valid URL
        if not ((thisimage.filename == "NULL") ^ (thisimage.filename == nil )) # see if it exists (XOR)
          if ((not File.exists?(thisimage.filename )) ^ File.directory?(thisimage.filename )) #is it a valid file
            thisimage.filename = "NULL" # ok file is gone, so delete it from DB
          end
        end
  
        if ((thisimage.filename == "NULL") ^ (thisimage.filename == nil )) #XOR
          # #work out where we are going to put it
          base_fn = Time.parse(thisimage.image_date)
          year_str = base_fn.year
          month_str = base_fn.strftime("%b")
          # of tyhis style date_filename = 2008-Thu-Mar-20-05:55:02-HD.jpeg
          date_filename = base_fn.strftime("%Y-%a-%b-%d-%H:%M:%S")+".jpeg"
          # #create the filename
          gt = General_tools::GT.new()
          thisimage.filename = '/raid/webcam-archive/'+ current_webcam.to_s
          gt.make_dir_if_doesnt_exist(thisimage.filename)
          thisimage.filename += '/'+ year_str.to_s 
          gt.make_dir_if_doesnt_exist(thisimage.filename)
          thisimage.filename +=  '/' + month_str.to_s 
          gt.make_dir_if_doesnt_exist(thisimage.filename)
    
          thisimage.filename += '/'+ date_filename.to_s
          # get the image
          myuser = "internalavo"
          mypassword = "volcsrus"
          get_image_from_url(thisimage, myuser,mypassword)
          # #then update the image record
          @@msh.update_image_record(thisimage.id, "filename", thisimage.filename)
        end
        # #then return the updated thisimage record
  
      end
      return thisimage
    end

    def send_image_to_process(sttime, images_count, thisimage, tesr,  operation, experiment)
      if (thisimage.filename != "NULL" || thisimage.filename != nil )
        puts " working on image #{thisimage.id} #{thisimage.filename}"
        im = Image_stats.new(@@msh, tesr)
        
        case ( operation)
        when "channels"
          # slight change here, now we load the image once, and then pass it in
          # to the processing each time, this cuts back on file IO, with only a
          # small overhead in processing memory.
          @nimg = nil
          if (File.size(thisimage.filename) > 500 ) #make sure file exists.
            my_fileimg = MultiArray.load_ubytergb( thisimage.filename );
            my_fileimg = (my_fileimg).to_sfloat;
            @ch.each do |col| # do it for all the basic channels
              im.load_an_image( thisimage.id, my_fileimg,  "channels"  ,col ,experiment)
            end
          
          end
          @nimg = nil
        when "st_helens_luminesce_enhance"
          im = Image_stats.new(@@msh, tesr)
          @nimg = nil
          if (File.size(thisimage.filename) > 500 ) #make sure file exists.
            my_fileimg = MultiArray.load_ubytergb( thisimage.filename );
            my_fileimg = (my_fileimg).to_sfloat;
            im.load_an_image( thisimage.id, my_fileimg , "st_helens_luminesce_enhance","combined",experiment)
          end
        end
        @it = @it + 1
        @tm = @tm + 1
        cttime = Time.new 
        inctime = (cttime - sttime ) / @tm
        ftime = sttime + (inctime * images_count)
        fracti = (@id.to_f  * 100.000)/ images_count.to_f
        if ( @tm > 500)
          puts " stored #{thisimage.id}  #{@it} of #{images_count} (#{fracti}%) Ok, finishing at #{ftime.to_s}"
          @odtime = ftime.to_s
        else
          puts " stored #{thisimage.id}  #{@it} of #{images_count} (#{fracti}%) Ok, finishing at #{@odtime} "
        end

        if ( @tm > 10000)
          @tm = 1
          sttime = Time.new
        end
      end
    rescue  Exception => errcond 
      @it = @it + 1 
      @tm = @tm + 1
      msg = "#{Time.now} an error occured inprocessing \n Error Was : #{errcond} \n #{errcond.message} \n #{errcond.backtrace.inspect}"
      puts " #{thisimage.id} #{msg} had a processing problem "
      # # exit
      return nil
    end

 
  

  end
end
