#==============================================================================
# ■ Pokemon_Battle_Status
# Pokemon Script Project - Krosk 
# 26/07/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 02/11/19
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#----------------------------------------------------------------------------- 
module POKEMON_S
  #------------------------------------------------------------  
  # Fenêtre de statut
  #------------------------------------------------------------  
  class Pokemon_Battle_Status < Window_Base
    def initialize(pokemon, enemy, z_level = 15, party = nil)
      @enemy = enemy # True / False
      if @enemy
        super(23,0,332,116)
      else
        super(311,203,341,140)
      end
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = $fontsmall
      self.contents.font.size = $fontsmallsize
      self.opacity = 0
      self.z = z_level
      @pokemon = pokemon
      @party = party
      refresh
    end
    
    def refresh
      self.contents.clear
      level = @pokemon.hp.to_f / @pokemon.maxhp_basis.to_f
      normal_color = Color.new(255, 255, 255, 255)
      if @enemy
        src_rect = Rect.new(0, 0, 300, 84)
        bitmap = RPG::Cache.picture(DATA_BATTLE[:fenetre_status_enemy])
        self.contents.blt(0, 0, bitmap, src_rect, 255)
        draw_hp_bar(69,45, level)
        self.contents.font.name = $fontface #"Pokémon Platine"
        draw_text(15, 6, 249, $fs, @pokemon.name, 0, normal_color)
        draw_text(15, 6, 249, $fs, "N." + @pokemon.level.to_s, 2, normal_color)
        width_text = self.contents.text_size(@pokemon.name).width + 3
        draw_gender(15 + width_text, 15, @pokemon.gender, @pokemon.id)
        if $pokedex.captured?(@pokemon.id)
          src_rect = Rect.new(0, 0, 21, 21)
          bitmap = RPG::Cache.picture(DATA_BATTLE[:ball_fenetre_status])
          self.contents.blt(27, 45, bitmap, src_rect, 255)
        end
        if @pokemon.status != 0
          string = "stat" + @pokemon.status.to_s + ".png"
          src_rect = Rect.new(0, 0, 60, 24)
          bitmap = RPG::Cache.picture(string)
          self.contents.blt(9, 42, bitmap, src_rect, 255)
        end
      else
        src_rect = Rect.new(0, 0, 309, 108)
        bitmap = RPG::Cache.picture(DATA_BATTLE[:fenetre_status])
        self.contents.blt(0, 0, bitmap, src_rect, 255)
        draw_hp_bar(93,45, level)
        self.contents.font.name = $fontface #"Pokémon Platine"
        draw_text(39, 6, 249, $fs, @pokemon.given_name, 0, normal_color)
        draw_text(39, 6, 249, $fs, "N." + @pokemon.level.to_s, 2, normal_color)
        string = @pokemon.hp < 0 ? 0 : @pokemon.hp
        draw_text(43, 60, 233, $fs, "#{string} / #{@pokemon.maxhp_basis}", 
                  2, normal_color)
        if @pokemon.level < 100
          level = @pokemon.next_exp.to_f /
            (@pokemon.exp_list[@pokemon.level+1] - 
             @pokemon.exp_list[@pokemon.level]).to_f
        else
          level = 0
        end
        draw_exp_bar(46, 99, 1.0 - level, 232)
        width_text = self.contents.text_size(@pokemon.given_name).width + 3
        draw_gender(39 + width_text, 15, @pokemon.gender, @pokemon.id)
        if @pokemon.status != 0
          string = "stat#{@pokemon.status}.png"
          src_rect = Rect.new(0, 0, 60, 24)
          bitmap = RPG::Cache.picture(string)
          self.contents.blt(42, 66, bitmap, src_rect, 255)
        end
      end
    end
    
    def exp_refresh
      level = @pokemon.next_exp.to_f / 
        (@pokemon.exp_list[@pokemon.level+1] - @pokemon.exp_list[@pokemon.level]).to_f
      draw_exp_bar(46, 99, 1.0 - level, 232)
    end
      
    def damage_refresh(info)
      damage = info[0]
      if damage == 0
        return
      end
      
      1.upto(damage) do |i|
        @pokemon.remove_hp(1)
        $scene.battler_anim ; Graphics.update
        if @pokemon.hp >= @pokemon.max_hp or @pokemon.dead?
          break
        end
      end
    end
    
    def dispose
      super
    end
    
    def draw_hp_bar(x, y, level, small = false)
      src_rect = Rect.new(0, 0, 198, 24)
      bitmap = RPG::Cache.picture(HP_BARRE)
      if small
        bitmap = RPG::Cache.picture(HP_BARRE_SMALL)
      end
      self.contents.blt(x, y, bitmap, src_rect, 255)
      rect1 = Rect.new(x + 45, y + 6, level*144.to_i, 3)
      rect2 = Rect.new(x + 45, y + 9, level*144.to_i, 6)
      if small
        rect1 = Rect.new(x + 45, y + 6, level*129.to_i, 3)
        rect2 = Rect.new(x + 45, y + 9, level*129.to_i, 6)
      end
      
      if level < 0.1
        color1 = Color.new(170, 70, 70, 255)
        color2 = Color.new(250, 90, 60, 255)
      elsif level >= 0.1 and level < 0.5
        color1 = Color.new(200, 170, 0, 255)
        color2 = Color.new(250, 225, 50, 255)
      else
        color1 = Color.new(90, 210, 125, 255)
        color2 = Color.new(110, 250, 170, 255)
      end
      self.contents.fill_rect(rect1, color1)
      self.contents.fill_rect(rect2, color2)
    end
    
    def draw_exp_bar(x, y, level, width)
      rect1 = Rect.new(x, y, level*232.to_i, 3)
      self.contents.fill_rect(rect1, Color.new(64, 144, 224, 255))
    end
    
    def draw_gender(x, y, gender, id)
      if id == 502
        rect = Rect.new(0, 0, 42, 33)
        bitmap = RPG::Cache.picture(FEMELLE)
        self.contents.blt(x, y, bitmap, rect, 255)        
      else
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
  end
end