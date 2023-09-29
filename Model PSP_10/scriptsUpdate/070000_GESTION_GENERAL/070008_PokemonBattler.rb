#---------------------------------------------------
# Fonctions specifiques aux battlers des pokémon
# Remplace les modifications de RPG::Sprite utilisées 
# par les anciennes versions de PSP
#
# Par FL0RENT
#---------------------------------------------------
module POKEMON_S
  class Pokemon_Battler < PSP_Sprite
    def initialize(bmp = nil, format = 2, viewport = nil)
      @format = format
      @minsize = MINIMUM_BATTLER_SIZE
      super(viewport)
      if bmp
        change_bitmap(bmp)
      else
        
      end
    end
    
    def icon_mode
      @minsize = MINIMUM_PKMN_ICON_SIZE
      auto_rect
    end
    
    def battler_mode
      @minsize = MINIMUM_BATTLER_SIZE
      auto_rect
    end
    
    def auto_rect
      h = self.bitmap.height
      w = self.bitmap.width
      if w % h == 0
        self.src_rect = Rect.new(0, 0, h, h)
        self.src_rect.x = rand(w/h) * h
      elsif h % w == 0
        self.src_rect = Rect.new(0, 0, w, w)
        self.src_rect.y = rand(h/w) * w
      end
      if self.src_rect.height <= @minsize or self.src_rect.width <= @minsize
        @base_zoom = @format
      else
        @base_zoom = 1
      end
    end
    
    def change_bitmap(bmp)
      self.bitmap = bmp
      auto_rect
    end
  end
end