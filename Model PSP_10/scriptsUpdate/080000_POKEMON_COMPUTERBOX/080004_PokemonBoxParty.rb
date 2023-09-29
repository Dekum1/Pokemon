#============================================================================== 
# ■ Pokemon_Box_Party 
# Pokemon Script Project - Krosk  
# 20/07/07 
# Restructuré par Damien Linux
# 11/11/19
# 24/12/2019 - Ajustement par Lizen
#============================================================================== 
# Fenêtre affichage équipe 
#============================================================================== 
module POKEMON_S
  class Pokemon_Box_Party < Window_Base 
    def initialize(index) 
      super(212 - 16, 112 - 16, 150 + 32, 336 + 16 + 32)#237 
      self.contents = Bitmap.new(650, 336 + 16)#64 
      self.opacity = 0 
      self.z = 5 
      @index = index 
      @pokemon = $pokemon_party.actors[0] 
      @selected = nil 
    end 
     
    def index=(index) 
      @index = index 
    end 
     
    def index 
      return @index 
    end 
     
    def pokemon_pointed 
      return @pokemon 
    end 
     
    def selected(data) 
      @selected = data 
    end 
    def update 
      if Input.repeat?(Input::DOWN) 
        if @index == $pokemon_party.size-1 
          return 
        end 
        $game_system.se_play($data_system.cursor_se) 
        @index += 1 
        refresh 
        return 
      end 
      if Input.repeat?(Input::UP) 
        if (@index == 0) 
          return 
        end 
        $game_system.se_play($data_system.cursor_se) 
        @index -= 1 
        refresh 
        return 
      end 
    end 
     
    def refresh 
      self.contents.clear 
      0.upto($pokemon_party.size - 1) do |i| 
        pokemon = $pokemon_party.actors[i] 
        src_rect = Rect.new(0, 0, 650, 650)#64 
        if i == @index 
          @pokemon = pokemon 
        end 
        if i == @index and self.active 
          bitmap = RPG::Cache.picture("pc/boxiconl.png") 
        else 
          bitmap = RPG::Cache.picture("pc/boxicon.png") 
        end 
        if @selected != nil 
          if @selected[0] == 0 and i == @selected[1] 
            bitmap = RPG::Cache.picture("pc/boxiconm.png") 
          end 
        end 
        self.contents.blt(20, 8 + 58*i, bitmap, src_rect, 255)#16 
         
        src_rect = Rect.new(0, 0, 64, 64) 
        bitmap = RPG::Cache.battler(pokemon.icon, 0) 
        self.contents.blt(22, 58*i - 2, bitmap, src_rect, 255) 
      end 
      if @index == $pokemon_party.size  and self.active 
        i = @index 
        src_rect = Rect.new(0, 0, 650, 650)#64 
        bitmap = RPG::Cache.picture("pc/boxiconl.png") 
        self.contents.blt(20, 8 + 58*i, bitmap, src_rect, 255) 
      end 
    end 
  end   
end