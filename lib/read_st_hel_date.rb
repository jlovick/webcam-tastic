#!/usr/bin/env ruby 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 require "strscan"

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
##    puts " time :- #{ft.to_s}"
  end
  return ft
end

begin
  filename = "/export/stripe/St_helens_webcam/2005/Dec/2005-Fri-Dec-16-00:02:01-Classic.jpeg"
  date = read_st_hel_date( filename )
  filename = "/export/stripe/St_helens_webcam/2005/Dec/2005-Fri-Dec-16-11:54:01-Classic.jpeg"
  date = read_st_hel_date( filename )
  
end