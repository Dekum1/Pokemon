#===================================================  
# Window_Pokémon  
# Pokemon Script Project - Krosk   
# 18/07/07  
# Modifier par Slash le 15/07/09  
# Restructuré par Damien Linux
# 29/12/2019
#===================================================  
class Window_Pokemon < Window_Base  

  def initialize  
    super(0, 0, 470, 480)  
    self.contents = Bitmap.new(width, height)  
    self.contents.font.name = $fontface  
    self.contents.font.size = $fontsize  
    refresh  
  end  
    
  def refresh  
    if $pokemon_party.size > 0  
      @order = [0,1,2,3,4,5]  
      self.contents.clear  
      cx = contents.text_size($data_system.words.gold).width  
      self.contents.font.color = normal_color  
      src_rect = Rect.new(0, 0, 64, 64)  
      0.upto($pokemon_party.size - 1) do |i|
        @pokemon = $pokemon_party.actors[@order[i]]  
        if i < 3  
          if @pokemon.egg  
            self.contents.draw_text(67,64 + (i*106) , 120, 32,@pokemon.given_name )  
          else  
            self.contents.draw_text(67,64 + (i*106) , 120, 32,@pokemon.given_name )  
            self.contents.draw_text(73,95 + (i*106) , 120, 32,"N. "  + @pokemon.level.to_s )  
          draw_gender(160, 99 + (i*106), @pokemon.gender)  
          end  
          bitmap = RPG::Cache.battler(@pokemon.icon, 0)  
          self.contents.blt(0, 67 + (i*107), bitmap, src_rect, 255)  
        else  
          if @pokemon.egg  
            self.contents.draw_text(283,64 + ((i-3)*106) , 120, 32,@pokemon.given_name )  
          else  
            self.contents.draw_text(283,64 + ((i-3)*106) , 120, 32,@pokemon.given_name )  
            self.contents.draw_text(289,95 + ((i-3)*106) , 120, 32,"N. " + @pokemon.level.to_s )  
            draw_gender(376, 99 + ((i-3)*106), @pokemon.gender)  
          end  
          bitmap = RPG::Cache.battler(@pokemon.icon, 0)  
          self.contents.blt(219, 67 + ((i-3)*107), bitmap, src_rect, 255)         
        end  
      end  
      return  
    end      
  end  
      
  def draw_gender(x, y, gender)  
    if gender == 1  
      rect = Rect.new(0, 0, 18, 33)  
      bitmap = RPG::Cache.picture(MALE)  
      self.contents.blt(x, y, bitmap, rect, 255)  
    end  
    if gender == 2  
      rect = Rect.new(0, 0, 18, 33)  
      bitmap = RPG::Cache.picture(FEMELLE)  
      self.contents.blt(x, y, bitmap, rect, 255)          
    end  
  end  
end