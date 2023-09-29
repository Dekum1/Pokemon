#===================================================  
# Window_Location  
# Pokemon Script Project - Krosk   
# 18/07/07  
# Modifier par Slash le 15/07/09  
# Restructuré par Damien Linux
# 29/12/2019
#===================================================        
class Window_Location < Window_Base  

  def initialize  
    super(0, 0, 160, 96)  
    self.contents = Bitmap.new(width - 32, height - 32)  
    self.contents.font.name = $fontface  
    self.contents.font.size = $fontsize  
    refresh  
  end  

  def refresh  
    self.contents.clear  
    self.contents.font.color = normal_color  
    self.contents.draw_text(4, 32, 120, 32,$data_mapzone[$game_map.map_id][1], 2)
  end  
end