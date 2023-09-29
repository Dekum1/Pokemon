#==============================================================================
# ● Extension : Menu Debug Fonction Modifier par Drakhaine
# Pokemon Script Project - Krosk
# 02/02/08
#==============================================================================
module POKEMON_S
  class Skills_List < Window_Selectable
    def initialize(menu_index = 0) 
      super(170, 20, 300, 448, 32)
      @index = menu_index
      @skills_list = []
      for i in 1..$data_skills_pokemon.length-1
        if $data_skills_pokemon[i][0].is_a?(String) and $data_skills_pokemon[i][0] != ""
          @skills_list.push(i)
        end
      end
      self.opacity = 255
      value = @skills_list.size
      @item_max = value - 1
      self.contents = Bitmap.new(width - 32, value * 32)
      self.contents.font.name = $fontface
      self.contents.font.size = $fontsize
      self.contents.font.color = Color.new(0,0,0,255)
      refresh
    end
    
    def refresh
      self.contents.clear
      for i in 0..@item_max
        string = $data_skills_pokemon[@skills_list[i]][0]
        self.contents.draw_text(0, 32 * i, 480, 32, string)
      end  
    end
  end 
end