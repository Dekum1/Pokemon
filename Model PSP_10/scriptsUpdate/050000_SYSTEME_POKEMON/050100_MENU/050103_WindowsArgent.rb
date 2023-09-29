#===================================================  
# Window_Argent  
# Pokemon Script Project - Krosk   
# 18/07/07  
# Modifier par Slash le 15/07/09  
# Restructuré par Damien Linux
# 29/12/2019
#===================================================  
class Window_Argent < Window_Base  
        
  def initialize  
    super(0, 0, 160, 64)  
    self.contents = Bitmap.new(width - 32, height - 32)  
    self.contents.font.name = $fontface  
    self.contents.font.size = $fontsize  
    refresh  
  end  
    
  def refresh  
    self.contents.clear  
    cx = contents.text_size($data_system.words.gold).width  
    self.contents.font.color = normal_color  
    self.contents.draw_text(4, 0, 120-cx-2, 32, $pokemon_party.money.to_s + "$", 2)  
  end  
end  