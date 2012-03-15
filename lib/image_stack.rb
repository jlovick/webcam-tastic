#!/usr/bin/env ruby
#
#

# To change this template, choose Tools | Templates and open the template in the
# editor.
require 'hornetseye'
require 'narray'
require("gsl")
require 'pp'

include GC
include Hornetseye

class Sequence_
  def average
    sum / size
  end
  def equalise( n = 4096, c_max = 255 )
    if typecode < RGB_
      result = contiguous.class.new
      max_average = [ r, g, b ].collect { |c| c.average }.max
      result.r, result.g, result.b = *[ r, g, b ].collect do |c|
        c.equalise n, c_max * c.average / max_average
      end
      result
    else
      quantised = normalise 0 .. n - 1
      if (quantised.max > 0)
        quantised.map quantised.hist( n ).integral.normalise( 0 .. c_max )
      end
    end
  end
end

def tri_mean(ax,ay,az)
  return ((ax.to_f + ay.to_f + az.to_f) / 3.0)
end

def do_fft(inarr)

  fft_pix_in_time = inarr.fft
  fft_view = fft_pix_in_time.subvector(0 ,  fft_zero_window )
  fft_view.set_all(0)
  myres = masterfft * fft_pix_in_time
  ifft_pix_in_time = myres.ifft
  return ifft_pix_in_time
end

def penta_mean(au,av,ax,ay,az)
  return ((au.to_f + av.to_f + ax.to_f + ay.to_f + az.to_f) / 5.0)
end

def running_mean(inarr)
  outr = Array.new
  inarr.size.times do |pos|
    aa = pos -2
    ab = pos -1
    ac = pos 
    ad = pos +1
    ae = pos +2
    
    if (aa < 0) 
      aa = nil
    else
      aa = inarr[aa]
    end
    if (ab < 0) 
      ab = nil
    else
      ab = inarr[ab]
    end
    
    ac = inarr[ac]
    
    if (ad >= inarr.size) 
      ad = nil
    else
      ad = inarr[ad]
    end
    if (ae >= inarr.size) 
      ae = nil
    else
      ae = inarr[ae]
    end
    
    outr.push( penta_mean(aa,ab,ac,ad,ae) )
  end
  return outr
end

begin

  files = Dir.glob '*.jpeg'
  files.sort!
  sum = nil
  sum_after = nil
  img = Array.new  # a number of multiarray
  allgreyimg = Array.new # a number of narray
  @greyimg = Array.new
  @outgreyimg = Array.new
  greymeans = Array.new
  grey_total = Array.new
  pix_in_time = Array.new
  puts "loading files"
  for f in files
    # puts "#{f}"
    if (File.size?(f) && (@greyimg.size < 50))
    eimg = (MultiArray.load_ubytergb f).to_sfloatrgb
    greyna = (((eimg.r.to_narray() * eimg.b.to_narray() * eimg.g.to_narray())**(0.5))**(0.5))
    mn = greyna.mean
     if ( (mn < 10 ) )
      @greyimg.push(greyna)
      @outgreyimg.push(greyna)
      greymeans.push(mn)
      puts "#{greymeans.size}   mean value #{mn} #{f} "
     end
    end
  end

  puts " finished loading in files "
  puts " calculating means "
 
  garbage_collect

 
  countimgs = @greyimg.size
  if greymeans.size > 0
  gm = greymeans.to_gv
  gm.graph
  end

  if (@greyimg.size < 1 )
    puts " no images past criteria "
    exit 1
  end
  allgreyimg = nil
  sum = nil
  @greyimg.each do |di|
    mn = di.mean
    dx = di / mn
    sum = sum ? sum + dx : dx
    puts " #{di.min} -> #{di.max}  divided by mean #{mn} and add in "
  end
  smin = sum.min
  smax = sum.max
  puts " now doing initial sum image stats values are #{smin} -> #{smax}"
  sum = ((sum - smin) / (smax - smin) ) * 255
  sum = sum.to_multiarray
  resultb = sum.to_sfloatrgb
  puts " saving file resulta.png"
  resultb.save_ubytergb 'resulta.png'
  resultb.show

  # masterfft = sum.r.to_narray.to_gv.fft

  countimgs = @greyimg.size
  puts " countimgs #{countimgs}"

  puts " loaded and converted #{countimgs} files "
  shape = @greyimg.first.shape
  puts " shape is #{shape.first} by #{shape.last} "
  extracycles = 0
  fft_zero_window = 20
  pix_in_time = GSL::Vector.calloc(countimgs*((extracycles*2) + 1))
  resid = Array.new
                                 
  puts " fft details.... vector size is #{countimgs*((extracycles*2) + 1)}   extra-cycles #{extracycles}  and fft_window #{fft_zero_window} "
  puts "made pix_in_time"
  ifft_pix_in_time =  GSL::Vector.calloc(countimgs)
  puts "made ifft_pix_in_time"
  fft_pix_in_time  =  GSL::Vector.calloc(countimgs)

  puts " mafe fft_pix_in_time"
rangedx = shape.first

rangedx_a = (rangedx * 1/4)
rangedx_b = (rangedx * 3/4)

rangedy = shape.last
rangedy_a = (rangedy * 1/4)
rangedy_b = (rangedy * 3/4)


  (rangedx_a...rangedx_b).each do |dx|
    (rangedy_a...rangedy_b).each  do |dy|
      cur_pos = dx+(shape.first * dy)
      #    puts " point is #{dx},#{dy} --> #{cur_pos}"
      # #stack in time so fft works in time
      countimgs.times do |i|
        # just set the middle agents to the data, padd with zeros on either side
        pix_in_time[(countimgs*(extracycles))+i] =  @greyimg[i][dx   ,  dy]
      end
    # if wanting fft
    #  ifft_pix_in_time = do_fft(pix_in_time)
      pix_mean = GSL::Stats::mean(pix_in_time)
      pix_stdev = GSL::Stats::sd(pix_in_time)
      indexs = pix_in_time.where{ |ind| (ind < (pix_mean))}
     indexs = indexs.to_a
#      p indexs
      indexs.each do |p|
        if (!p.nil?)
        pix_in_time[p] = 0  
        end
      end if (!indexs.nil? )
      
#    left = fft_pix_in_time - ifft_pix_in_time
#
      if ((dx == (shape.first/2)) && (dy == (shape.last / 2) ))
      	pix_in_time.graph
	puts " mean #{pix_mean}    stdev = #{pix_stdev} "
      end
#
   #   resid.push(left)
     
      countimgs.times do |i|
        #for fft
        #   @outgreyimg[i][dx , dy] = ifft_pix_in_time[(countimgs*(extracycles))+i]
        # sttdev exclusion
          @outgreyimg[i][dx , dy] = pix_in_time.max
      end
    end
    if ((dx % 50) == 0)
      puts "done row #{dx} of #{shape.first}"
    end
  end
  pix_in_time = nil
  ifft_pix_in_time = nil
  fft_pix_in_time = nil

  puts " doing means"

  # #countimgs.times do |img_index| fft_mean = outgreyimg[img_index].mean puts
  # "img #{img_index} #{fft_mean}" outgreyimg[img_index].to_multiarray.show end

  puts " doing visible img"
  greyna = nil
  grey_total = Array.new
  sum_after = nil
  @outgreyimg.each do |di|
    dx = di.to_multiarray
    sum_after = sum_after ? sum_after + dx : dx.to_sfloatrgb
    grey_total.push( di.mean )
  end
  smin = sum_after.min
  smax = sum_after.max
  puts " now doing initial sum image stats values are #{smin} -> #{smax}"
  sum_after = ((sum_after -smin) / (smax - smin) ) * 255
  gv = grey_total.to_gv
  gv.graph

  puts " now doing initial sum image stats values are #{sum_after.r.min} -> #{sum_after.r.max}  #{gv.mean}"
  result = sum_after
  result.save_ubytergb 'resultb.png'
  result.show
  resulte = sum_after.equalise
  resulte.show
  resultc = (resultb - result)
  resultc.show
  resultc.save_ubytergb 'resultc.png'

  # resid.each do |sp|
  #   sp.print
  # end
  puts " all done!"
  #

end
