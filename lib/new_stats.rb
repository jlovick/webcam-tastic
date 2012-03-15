# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
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

module ImageStats
  class New_Stats
    attr :stat_id, true
    attr :table_id, true
    attr :table_key, true
    
    def initialize(sid,tid,tk)
       @stat_id = sid
      @table_id = tid
      @table_key = tk
    end
  end

  class Stat_Table_List
    @@msh = nil
    @@list_tables = nil
    @@list_ids = nil
  
    def initialize(msh)
      @@msh  = msh
      if (@@list_ids == nil)
        res = @@msh.get_stats_table_list()
        @@list_tables = res[0]
        @@list_ids = res[1]
      end
    end
  
    def get_table_id( table_name )
      return @@list_tables[table_name.to_s]
    end
  
    def get_table_name( table_id )
      return @@list_ids[table_id.to_i]
    end 
  
    def print()
      puts " list of tables and their id's"
      pp @@list_tables
      puts " \n \n \n list of id's and their tables"
      pp @@list_ids
    end
  end
  
  class Channel_Table_List
    @@msh = nil
    @@list_channels = nil
    @@list_ids = nil
  
    def initialize(msh)
      @@msh  = msh
      if (@@list_ids == nil)
        res = @@msh.get_channel_list()
        @@list_channels = res[0]
        @@list_ids = res[1]
      end
    end
  
    def get_channel_id( channels_name )
      return @@list_channels[channels_name.to_s]
    end
  
    def get_table_name( channels_id )
      return @@list_ids[channels_id.to_i]
    end 
    
  def get_all_channel_names()
    res = Array.new
    pp @@list_ids
    @@list_ids.each do |key, value|
      puts " found channel #{value}"
      res.push( value.clone )
    end 
    return res
  end   
    def print()
      puts " list of channels and their id's"
      pp @@list_channels
      puts " \n \n \n list of id's and their channels"
      pp @@list_ids
    end
  end

  class Experiment_Table_List
    @@msh = nil
    @@list_experiment= nil
    @@list_ids = nil
  
    def initialize(msh)
      @@msh  = msh
      if (@@list_ids == nil)
        res = @@msh.get_experiment_list()
        @@list_experiment = res[0]
        @@list_ids = res[1]
      end
    end
  
    def get_experiment_id( experiment_name )
      return @@list_experiment[experiment_name.to_s]
    end
  
    def get_table_name( experiment_id )
      return @@list_ids[experiment.to_i]
    end 
  
    def print()
      puts " list of experiment and their id's"
      pp @@list_experiment
      puts " \n \n \n list of id's and their experiments"
      pp @@list_ids
    end
  end
  
  class Stats_Collection
    attr :src_file_id, true
    attr :experiment, true
    attr_reader :stats_collection 
    @@msh = nil
    @tables = nil

    @channel = nil
  
    def initialize(msh,src_file_id,expi, channel)
      @@msh = msh
      @src_file_id = src_file_id
      @experiment = expi
      @tables = Stat_Table_List.new(@@msh)
      @stats = nil
      @stats_collection = Hash.new
      @channel = channel
      if ((src_file_id != nil) && (expi != nil) )
        load_collection(@src_file_id,@experiment, @channel)
      end
    
    end
  
    def load_collection(src_file_id, expi, channel)
      my_stats = @@msh.get_stats_collection(src_file_id, expi, channel)
      @stats_collection = Hash.new
      if (my_stats != nil && my_stats.size > 0)
        # add in sub tables from my_stats data
        my_stats.each do |stat|
          key = "ImageStats::#{@tables.get_table_name( stat.table_id )}"
   #       puts "making table #{stat.table_id} #{key}"
          @stats_collection[ key ]  = (give_me_table_object( key )).new(@@msh, stat.table_key, stat.table_id, true ) #makes a new object from the row in the table
      #    puts " made object "
      #    puts " value is #{@stats_collection[key].get_value} "
        end
      end
      end
      
      def add_table( table_name, args={} ) # accepts either a name or an index number of the stat table
       
  #     puts "add_table :- type is #{table_name.class}"
        key = arg_to_table_name( table_name )
        
        if (@stats_collection[ key ] != nil)
  #        puts " table is found allready #{key} --> #{table_name} "
        else
   #       puts "adding table #{key}  --> #{table_name} "
          @stats_collection[ key ]  = (give_me_table_object( key )).new(@@msh, nil,nil, false )
          my_key = @stats_collection[ key ].add_value( args ) 
          if (my_key != nil)
            @@msh.add_stats_to_collection( @src_file_id,  @tables.get_table_id( @stats_collection[ key ].get_name_short ), my_key ,@experiment, @channel)
  #          puts " added into stats collection "
             self.load_collection(@src_file_id,@experiment, @channel)
          end
        end
        
      end
      
      def del_table( table_name )
       key = arg_to_table_name( table_name )
       
       # code to delete the entry goes here
      end
      
      def update_value( table_name, args={})
      key = arg_to_table_name( table_name )
      #code to update the value goes here
      end
      
      private

      def arg_to_table_name( table_name )
        # makes sure we get back a string rather than a reference index to a table name
        if (table_name.class.to_s == "String" )
        key = "ImageStats::#{table_name}"
       else
        key = "ImageStats::#{@tables.get_table_name( table_name.to_i )}"
       end
       return key
      end
      
      def give_me_table_object( mytype )
        unless /\A(?:::)?([A-Z]\w*(?:::[A-Z]\w*)*)\z/ =~ mytype
 	      raise NameError, "#{mytype.inspect} is not a valid constant name!"
 	    end
        return  Object.module_eval("::#{$1}", __FILE__, __LINE__)
      end



    end #end of Stats collection class

    class Stats_Tables
      attr_reader :value 
      @table_name = nil
      @@msh = nil
      
      
      def initialize(msh,table_key, my_table_id, load_me_up)
        @table_name = (self.class).to_s
        @@msh = msh
        @table_key = table_key
        @table_id = my_table_id
        # puts " making a #{@table_name}" 
        if (load_me_up) 
          self.refresh(table_key)
        end
       # puts " finnished making a table"
      end
      
      def refresh(table_key)
        if ((self.get_name_short != nil) && (table_key != nil))
         if (!@table_id)
            tables = Stat_Table_List.new(@@msh)
            @table_id = tables.get_table_id( self.get_name_short )
          end
          @value = @@msh.get_stats_data(self.get_name_short, table_key)
        end
      end
      
      def get_name_short()
        my_name = @table_name[12..@table_name.length]  #cuts the module name from the start of the string
     #   puts " my short name is #{my_name}" 
        return my_name
      end
      def get_id()
        return @table_id
      end
      def add_value( args={})
        return nil  
      end
      
      def delete()
        return nil
      end
      def update_value( args={})
        return nil
      end
      def get_value()
        return @value
      end
    end  #end of Stats_Tables
  
    class Mean_Table < Stats_Tables
      def add_value( args={} )
        my_id = nil
        if args[:mean]
          my_id = @@msh.add_new_stats_entry(get_name_short(), :data => args[:mean])
    #      puts " added #{args[:mean]} to table, at #{my_id}"
        end
        return my_id
      end
      
    end
    
    class Max_Table < Stats_Tables
         def add_value( args={} )
        my_id = nil
        if args[:max]
          my_id = @@msh.add_new_stats_entry(get_name_short(), :data => args[:max])
   #       puts " added #{args[:max]} to table, at #{my_id}"
        end
        return my_id
      end
    end
    
    class Min_Table < Stats_Tables
            def add_value( args={} )
        my_id = nil
        if args[:min]
          my_id = @@msh.add_new_stats_entry(get_name_short(), :data => args[:min])
   #       puts " added #{args[:min]} to table, at #{my_id}"
        end
        return my_id
      end
    end
    
    class Gnuplot_Graph_Table < Stats_Tables
        def add_value( args={} )
        my_id = nil
        if (args[:gnuplot_command] && args[:gnuplot_data])
          my_id = @@msh.add_new_stats_entry(get_name_short(), :gnuplot_data => args[:gnuplot_data], :gnuplot_command => args[:gnuplot_command] )
  #        puts " added line to table, at #{my_id}"
        end
        return my_id
      end
    end
    
    class Histogram_Table < Stats_Tables
        def add_value( args={} )
        my_id = nil
        if (args[:histogram])
          esc_hist = "'#{Mysql::quote(args[:histogram])}' "
          my_id = @@msh.add_new_stats_entry(get_name_short(), :data=> esc_hist )
  #        puts " added line to table, at #{my_id}"
        end
        return my_id
      end
    end
    
    class Variance_Table < Stats_Tables
        def add_value( args={} )
        my_id = nil
        if (args[:variance])
          my_id = @@msh.add_new_stats_entry(get_name_short(), :data => args[:variance] )
 #         puts " added line to table, at #{my_id}"
        end
        return my_id
      end
    end
    
    class Thermal_Flux_Table < Stats_Tables
        def add_value( args={} )
        my_id = nil
        if (args[:flux])
          my_id = @@msh.add_new_stats_entry(get_name_short(), :data=>  args[:flux] )
  #        puts " added line to table, at #{my_id}"
        end
        return my_id
      end
    end

    class Image_Data_Table < Stats_Tables
        def add_value( args={} )
        my_id = nil
        if (args[:image_data] && args[:image_data_type])
          img_data = "'#{Mysql::quote(args[:image_data])}'"
          my_id = @@msh.add_new_stats_entry(get_name_short(),   :image_data_type => "'#{args[:image_data_type]}'" , :image_data => img_data )
  #        puts " added line to table, at #{my_id}"
        end
        return my_id
      end
    end
      

  end # of module