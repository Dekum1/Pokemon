#============================================================================== 
# ■ Pokemon_Box_Status 
# Pokemon Script Project - Krosk  
# 20/07/07 
# Restructuré par Damien Linux
# 11/11/19
# 24/12/2019 - Ajustement par Lizen
#============================================================================== 
# Fenêtre d'affichage info Pokémon 
#============================================================================== 
module POKEMON_S
  class Pokemon_Box_Status < Window_Base
    def initialize 
      super(0 - 16, 0 - 16, 210 + 32, 480 + 32) 
      self.contents = Bitmap.new(210, 480) 
      self.contents.font.name = $fontface 
      self.contents.font.size = $fontsizebig 
      self.opacity = 0 
      self.z = 5 
      @pokemon = nil 
      @pokemon_sprite = Sprite.new 
      @pokemon_sprite.mirror = true 
      @pokemon_sprite.x = 20 
      @pokemon_sprite.y = 72 
      @pokemon_sprite.z = 6 
    end 
     
    def dispose 
      super 
      @pokemon_sprite.dispose 
    end 
     
    def define_pokemon(pokemon) 
      @pokemon = pokemon 
    end 
     
    def pointed_pokemon 
      return @pokemon 
    end 
     
    def refresh(pokemon) 
      if pokemon != nil and @pokemon != pokemon 
        self.contents.clear 
        @pokemon = pokemon 
        @pokemon_sprite.bitmap = RPG::Cache.battler(@pokemon.battler_face(false), 0) 
        self.draw_text(9, 278, 192, 39, @pokemon.given_name) 
        self.draw_text(3, 278 + 32 + 4, 204, 39, "/" + @pokemon.name) 
        draw_gender(18, 278 + 64 + 12, @pokemon.gender) 
        draw_shiny(36, 278 + 64 + 12 + 4, @pokemon.get_shiny)
        draw_item(53, 278 + 64 + 12 + 6) if @pokemon.item_hold > 0
        self.draw_text(18 + 64, 278 + 64 + 8, 170, 39, "N. " + @pokemon.level.to_s) 
      elsif pokemon == nil and @pokemon != pokemon 
        self.contents.clear 
        @pokemon = pokemon 
        @pokemon_sprite.bitmap = RPG::Cache.battler("", 0) 
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

    def draw_shiny(x, y, shiny)
      if shiny
        rect = Rect.new(0, 0, 18, 33) 
        bitmap = RPG::Cache.picture(SHINY_INTERFACE) 
        self.contents.blt(x, y, bitmap, rect, 255) 
      end
    end

    def draw_item(x, y)
      rect = Rect.new(0, 0, 18, 33) 
      bitmap = RPG::Cache.picture(DATA_MENU[:objet]) 
      self.contents.blt(x, y, bitmap, rect, 255) 
    end
  end 
end