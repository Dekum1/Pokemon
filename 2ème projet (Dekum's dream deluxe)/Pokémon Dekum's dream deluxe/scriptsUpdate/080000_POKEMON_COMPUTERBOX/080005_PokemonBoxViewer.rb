#============================================================================== 
# ■ Pokemon_Box_Viewer 
# Pokemon Script Project - Krosk  
# 20/07/07 
# Restructuré par Damien Linux
# 11/11/19
# 24/12/2019 - Ajustement par Lizen
#==============================================================================   
# Fenêtre affichage contenu boite 
#==============================================================================
module POKEMON_S
  class Pokemon_Box_Viewer < Window_Base 
    attr_accessor :box 
     
    def initialize(box, index) 
      super(328 + 22 - 16, 118 - 16 - 16, 268 + 32, 340 + 16 + 32) 
      self.contents = Bitmap.new(268, 340 + 16) 
      self.opacity = 0 
      self.z = 3 
      @box = box 
      @index = index 
      @pokemon = nil 
      @box_sprite = Sprite.new 
      @box_sprite.x = 328 
      @box_sprite.z = 1 
      @selected = nil 
    end 
     
    def dispose 
      super 
      @box_sprite.dispose 
    end 
     
    def index=(index) 
      @index = index 
    end 
     
    def index 
      return @index 
    end 
     
    def selected(data) 
      @selected = data 
    end 
     
    def update 
      if Input.repeat?(Input::DOWN) 
        if @index >= 20 
          return 
        end 
        $game_system.se_play($data_system.cursor_se) 
        @index += 4 
        refresh 
        return 
      end 
      if Input.repeat?(Input::UP) 
        $game_system.se_play($data_system.cursor_se) 
        @index -= (@index <= 3) ? 0 : 4 
        refresh 
        return 
      end 
      if Input.repeat?(Input::LEFT) 
        $game_system.se_play($data_system.cursor_se) 
        if @index%4 == 0 
          refresh 
          return 
        else 
          @index -= 1 
          refresh 
          return 
        end 
      end 
       
      if Input.repeat?(Input::RIGHT) 
        if (@index-3)%4 == 0 
          return 
        end 
        $game_system.se_play($data_system.cursor_se) 
        @index += 1 
        refresh 
        return 
      end 
    end 
     
    def pokemon_pointed 
      return @pokemon 
    end 
     
    def refresh 
      # Valeur des numéros de fonds
          num_fond = @box % 4
          if num_fond == 0
            num_fond = 4
          end
      @box_sprite.bitmap = RPG::Cache.picture("pc/box"+ num_fond.to_s + ".png")
     
      self.contents.clear 
      0.upto(23) do |i|
        if $data_storage[@box][i] != nil 
          pokemon = $data_storage[@box][i] 
          src_rect = Rect.new(0, 0, 64, 64) 
          bitmap = RPG::Cache.battler(pokemon.icon, 0) 
          draw_shiny(pokemon.shiny, i)
          draw_item(i) if pokemon.item_hold > 0
          self.contents.blt(2+68*(i%4), 8+58*(i/4), bitmap, src_rect, 255) 
        end 
        if i == @index and self.active 
          src_rect = Rect.new(0, 0, 64, 64) 
          bitmap = RPG::Cache.picture("pc/boxselector.png") 
          self.contents.blt(2+68*(i%4), 18+58*(i/4), bitmap, src_rect, 255) 
          pokemon = $data_storage[@box][i] 
          @pokemon = pokemon 
        end 
        if @selected != nil 
          if @box == @selected[0] and i == @selected[1] 
            src_rect = Rect.new(0, 0, 64, 64) 
            bitmap = RPG::Cache.picture("pc/boxselected.png") 
            self.contents.blt(2+68*(i%4), 18+58*(i/4), bitmap, src_rect, 255) 
          end 
        end 
      end 
    end 
    
    def draw_shiny(shiny, i)
      if shiny
        rect = Rect.new(0, 0, 18, 33) 
        bitmap = RPG::Cache.picture(SHINY) 
        self.contents.blt(2+68*(i%4), 8+58*(i/4), bitmap, rect, 255) 
      end
    end

    def draw_item(i)
      rect = Rect.new(-45, -40, 64, 64) 
      bitmap = RPG::Cache.picture(DATA_MENU[:objet]) 
      self.contents.blt(2+68*(i%4), 8+58*(i/4), bitmap, rect, 255) 
    end
  end 
end