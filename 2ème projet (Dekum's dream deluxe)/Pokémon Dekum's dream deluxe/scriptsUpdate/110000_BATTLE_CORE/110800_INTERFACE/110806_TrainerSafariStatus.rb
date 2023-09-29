#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# 20/07/07
#-----------------------------------------------------------------------------
# Trainer_Safari_Status - Therand
# 28/12/2014
# Adapté pour Pokémon Brêmo par Tokeur
# Adapté pour PSPEvolved par Damien Linux
# 28/11/2020
#-----------------------------------------------------------------------------
module POKEMON_S
  class Trainer_Safari_Status < Window_Base
    def initialize(z_level = 15)
      super(311,203,341,140)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = $fontsmall
      self.contents.font.size = $fontsmallsize
      self.opacity = 0
      self.z = z_level
      refresh
    end
    
    def refresh
      self.contents.clear
      normal_color = Color.new(255, 255, 255, 255)
      src_rect = Rect.new(0, 0, 309, 108)
      bitmap = RPG::Cache.picture(DATA_BATTLE[:fenetre_status])
      self.contents.blt(0, 0, bitmap, src_rect, 255)
      draw_text(50, 11, 200, $fs, Player.name, 0, normal_color)
      if $pokemon_party.item_number(12) > 1
        draw_text(50, 58, 200, $fs, "BALLS : ", 0, normal_color)
      else
        draw_text(50, 58, 200, $fs, "BALL : ", 0, normal_color)
      end
      draw_text(160, 58, 200, $fs, $pokemon_party.item_number(12).to_s, 0, normal_color)
    end
    
    
    def dispose
      super
    end
    
  end
end