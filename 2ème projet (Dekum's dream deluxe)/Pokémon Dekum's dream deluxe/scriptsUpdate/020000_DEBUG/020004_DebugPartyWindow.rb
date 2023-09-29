module POKEMON_S
  class Debug_Party_Window < Window_Selectable
    def initialize
      super(192, 0, 448, 382, 58)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = $fontface
      self.contents.font.size = $fontsize
      self.contents.font.color = self.normal_color
      self.index = -1
      self.active = false
      @item_max = 6
      #@mode = 0
      #@top_id = 1
      refresh
    end
    
    def refresh
      self.contents.clear
      for i in 0..5
        pokemon = $pokemon_party.actors[i]
        if pokemon != nil
          ida = sprintf("%03d", pokemon.id.to_s)
          gender = pokemon.gender == 1 ? "Male" : pokemon.gender == 2 ? "Femelle" : "Inconnu"
          self.contents.draw_text(4 + 60, i * 58, 400, 32, "ID" + ida + " " + pokemon.given_name + "/" + pokemon.name + " " + gender)
          
          case pokemon.status
          when 0
            status = "Normal"
          when 1
            status = "Poison"
          when 2
            status = "Paralyse"
          when 3
            status = "Brule"
          when 4
            status = "Sommeil"
          when 5
            status = "Gel"
          when 6
            status = "Confus"
          when 7
            status = "Peur"
          when 8
            status = "Toxik"
          end
          self.contents.draw_text(12 + 60, i * 58 + 24, 400, 32, "Nv. " + pokemon.level.to_s + "  PV " + pokemon.hp.to_s + "/" + pokemon.max_hp.to_s + "  " + status)
          
          src_rect = Rect.new(0, 0, 64, 64)
          bitmap = RPG::Cache.battler(pokemon.icon, 0)
          self.contents.blt(0, -10 + i*58, bitmap, src_rect, 255)
        else
          self.contents.draw_text(4 + 60, i * 58, 400, 32, "Aucun")
        end
      end
    end
  end
end