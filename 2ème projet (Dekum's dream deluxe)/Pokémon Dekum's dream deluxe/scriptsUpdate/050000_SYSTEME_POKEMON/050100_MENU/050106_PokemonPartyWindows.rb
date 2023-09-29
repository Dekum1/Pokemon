#-----------------------------------------------------------------------------
# Pokemon_Party_Window
# Pokemon Script Project - Krosk   
# 18/07/07  
# Modifier par Slash le 15/07/09  
# Restructuré par Damien Linux
# 29/12/2019
#-----------------------------------------------------------------------------
# Window_Base
#-----------------------------------------------------------------------------
# Fenetre individuelle de statut dans la gestion d'équipe
#-----------------------------------------------------------------------------
class Pokemon_Party_Window < Window_Base
  def initialize(pokemon, index, z_level = 100, mode = nil, data = nil, menu = -1)
    if index == 0 #Pokémon en tête de rang
      super(14, 68, 254, 167)
    else
      super(275, 17 + (index-1) * 72, 372, 92)
    end
    self.contents = Bitmap.new(width - 32, height - 32)
    self.contents.font.name = $fontsmall
    self.contents.font.size = $fontsmallsize
    self.opacity = 0
    self.z = z_level + 8
    @pokemon = pokemon
    @index = index #position de la fenêtre
    @menu_index = menu
    @on_switch = -1
    @mode = mode
    @data = data
    sprite_team = Yuki::AnimatedSurface.new
    if $game_switches[ANIMATION_MENU]
      sprite_team.bitmap = RPG::Cache.battler(@pokemon.icon_2, 0)
      no_animation = (not @pokemon.icon_2.include?("Anime"))
    else
      sprite_team.bitmap = RPG::Cache.battler(@pokemon.icon, 0)
      no_animation = true
    end
    if @pokemon.dead? and not @pokemon.egg
      sprite_team.define_animation(2, 99999, :horizontal, no_animation)
    elsif @pokemon.hp <= @pokemon.max_hp / 4 and not @pokemon.egg
      sprite_team.define_animation(2, 20, :horizontal, no_animation)
    elsif @pokemon.hp <= @pokemon.max_hp / 2 and not @pokemon.egg
      sprite_team.define_animation(2, 10, :horizontal, no_animation)
    else
      sprite_team.define_animation(2, 5, :horizontal, no_animation)
    end
    if index == 0
      sprite_team.x = self.x + 16
      sprite_team.y = self.y + 16
      sprite_team.z = z_level + 10
      @sprite_team = sprite_team
    else
      sprite_team.x = self.x + 16
      sprite_team.y = self.y + 6
      sprite_team.z = z_level + 10
      @sprite_team = sprite_team
    end
    update
  end
  
  def update 
    @sprite_team.update
    super
  end
  
  #fonction qui sert à importer l'information de la position du curseur
  def refresh_index(index) 
    @sprite_team.update
    @menu_index = index
  end
  
  def switch(value)
    @on_switch = value
  end
  
  def hp_refresh
    if @pokemon.egg
      return
    end
    if @index == 0
      level = @pokemon.hp / @pokemon.maxhp_basis.to_f
      draw_hp_bar(21, 84, level)
      src_rect = Rect.new(93, 105, 129, 30)
      if @index == @on_switch or (@on_switch != -1 and @menu_index == @index)
        # Cadre bleu sélectionné
        bitmap = RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_selection])
      elsif @menu_index == @index
        # Cadre rouge hover / vert hover
        bitmap = @pokemon.dead? ? RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_hover]) : 
                                  RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_ko_hover])
      else
        # Cadre rouge
        bitmap = @pokemon.dead? ? RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon]) : 
                                  RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_ko])
      end
      self.contents.font.name = $fontface
      self.contents.blt(93, 105, bitmap, src_rect, 255)
      draw_text(0, 99, 215, $fs, @pokemon.hp.to_s + " / " + @pokemon.maxhp_basis.to_s, 2)
    else
      level = @pokemon.hp / @pokemon.maxhp_basis.to_f
      draw_hp_bar(160, 9, level, true)
      src_rect = Rect.new(211, 30, 129, 30)
      if @on_switch == @index or (@on_switch != -1 and @menu_index == @index)
        # Cadre bleu sélectionné
        bitmap = RPG::Cache.picture(DATA_MENU[:cadre_pokemon_selection])
      elsif @menu_index == @index
        # Cadre rouge si ko sinon vert hover
        bitmap = @pokemon.dead? ? RPG::Cache.picture(DATA_MENU[:cadre_pokemon_hover]) : 
                                  RPG::Cache.picture(DATA_MENU[:cadre_pokemon_ko_hover])
      else
        # Cadre rouge si ko sinon vert
        bitmap = @pokemon.dead? ? RPG::Cache.picture(DATA_MENU[:cadre_pokemon]) : 
                                  RPG::Cache.picture(DATA_MENU[:cadre_pokemon_ko])
      end
      self.contents.font.name = $fontface
      self.contents.blt(211, 30, bitmap, src_rect, 255)
      draw_text(0, 24, 330, $fs, @pokemon.hp.to_s + " / " + @pokemon.maxhp_basis.to_s, 2)
    end
  end
  
  def refresh
    self.contents.clear
    if @index == 0
      # fond
      src_rect = Rect.new(0, 0, 222, 135)
      if @index == @on_switch or (@on_switch != -1 and @menu_index == @index)
        # Cadre bleu sélectionné
        bitmap = RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_selection])
      elsif @menu_index == @index
        # Cadre rouge si ko sinon vert hover
        bitmap = (@pokemon.dead? and not @pokemon.egg) ? RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_hover]) : 
                                                         RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_ko_hover])
      else
        # Cadre rouge si ko sinon vert
        bitmap = (@pokemon.dead? and not @pokemon.egg) ? RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon]) : 
                                                         RPG::Cache.picture(DATA_MENU[:cadre_premier_pokemon_ko])
      end
      self.contents.blt(0, 0, bitmap, src_rect, 255)
      # Objet
      if @pokemon.item_hold != 0
        src_rect = Rect.new(0, 0, 21, 21)
        bitmap = RPG::Cache.picture(DATA_MENU[:objet])
        self.contents.blt(60, 50, bitmap, src_rect, 255)
      end
      
      # Nom, niveau, genre
      self.contents.font.name = $fontface
      draw_text(69, 18, 150, $fs, @pokemon.given_name)
      if @pokemon.egg
        return
      end
      draw_text(100, 48, 100, $fs, "N." + @pokemon.level.to_s)
      draw_gender(180, 57, @pokemon.gender)
      if (@pokemon.status > 0 and @pokemon.status < 6) or @pokemon.status == 8 or @pokemon.dead?
        string = "stat" + @pokemon.status.to_s + ".png"
        src_rect = Rect.new(0, 0, 60, 24)
        bitmap = RPG::Cache.picture(string)
        self.contents.blt(15, 108, bitmap, src_rect, 255)
      end
      # HP
      if @mode == "item_able" or ( @mode == "selection" and @data != nil )
        self.contents.font.name = $fontface
        if POKEMON_S::Item.able?(@data, @pokemon)
          string = "APTE"
        else
          string = "PAS APTE"
        end
        draw_text(0, 98, 215, $fs, string, 2)
      else
        level = @pokemon.hp / @pokemon.maxhp_basis.to_f
        self.contents.font.name = $fontface
        draw_hp_bar(21, 84, level)
        draw_text(0, 99, 215, $fs, @pokemon.hp.to_s + " / " + @pokemon.maxhp_basis.to_s, 2)
      end
    else
      src_rect = Rect.new(0, 0, 340, 60)
      if @on_switch == @index or (@on_switch != -1 and @menu_index == @index)
        # Cadre bleu sélectionné
        bitmap = RPG::Cache.picture(DATA_MENU[:cadre_pokemon_selection])
      elsif @menu_index == @index
        # Cadre rouge si ko sinon vert hover
        bitmap = (@pokemon.dead? and not @pokemon.egg) ? RPG::Cache.picture(DATA_MENU[:cadre_pokemon_hover]) : 
                                                         RPG::Cache.picture(DATA_MENU[:cadre_pokemon_ko_hover])
      else
        # Cadre rouge si ko sinon vert
        bitmap = (@pokemon.dead? and not @pokemon.egg) ? RPG::Cache.picture(DATA_MENU[:cadre_pokemon]) : 
                                                         RPG::Cache.picture(DATA_MENU[:cadre_pokemon_ko])
      end
      self.contents.blt(0, 0, bitmap, src_rect, 255)
      
      if @pokemon.item_hold != 0
        src_rect = Rect.new(0, 0, 21, 21)
        bitmap = RPG::Cache.picture(DATA_MENU[:objet])
        self.contents.blt(55, 36, bitmap, src_rect, 255)
      end
      
      self.contents.font.name = $fontface
      draw_text(66, -3, 92, $fs, @pokemon.given_name)
      if @pokemon.egg
        return
      end
      draw_text(72, 24, 100, $fs, "N." + @pokemon.level.to_s)
      
      draw_gender(138, 35, @pokemon.gender)
      if (@pokemon.status > 0 and @pokemon.status < 6) or @pokemon.status == 8 or @pokemon.dead?
        string = "stat" + @pokemon.status.to_s + ".png"
        src_rect = Rect.new(0, 0, 60, 24)
        bitmap = RPG::Cache.picture(string)
        self.contents.blt(151, 33, bitmap, src_rect, 255)
      end
      
      if @mode == "item_able" or ( @mode == "selection" and @data != nil )
        self.contents.font.name = $fontface
        if POKEMON_S::Item.able?(@data, @pokemon)
          string = "APTE"
        else
          string = "PAS APTE"
        end
        draw_text(160, 4, 170, 30, string, 1)
      else
        level = @pokemon.hp / @pokemon.maxhp_basis.to_f
        draw_hp_bar(160, 9, level, true)
        draw_text(0, 24, 330, $fs, @pokemon.hp.to_s + " / " + @pokemon.maxhp_basis.to_s, 2)      
      end
    end
  end
  
  def dispose
    @sprite_team.dispose
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