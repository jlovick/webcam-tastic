# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

module Image_data
     class Image_data_area
    attr_reader :tlx, :tly, :width, :height
    
    def initialize( tlx, tly, width, height)
      self.tlx= tlx
      self.tly = tly
      self.width = width
      self.height = height
    end
    def tlx=(tlx)
      @tlx = tlx
    end
    def tly=(tly)
      @tly = tly
    end
    def width=(width)
      @width = width
    end
    def height=(height)
      @height = height
    end
    
  end
  
  class Image_file_data
    attr_reader :id, :filename, :url, :image_date    
    def initialize( id, filename, url, image_date)
      self.id= id
      self.filename = filename
      self.url = url
      self.image_date = image_date
      
    end
    def id=(id)
      @id = id
    end
    def filename=(filename)
      @filename = filename
    end
    def url=(url)
      @url= url
    end
    def image_date=(image_date)
      @image_date = image_date
    end
    
  end
end
