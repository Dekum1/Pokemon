#==============================================================================
# Pokemon Script Project - Krosk
# Intro_Pokedex - G!n0
# 15/08/20
#-----------------------------------------------------------------------------

module POKEMON_S
  
  class Intro_Pokedex
    
    #----------------------------------------------------
    # Les Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FONTSIZE = 24
    FONTSIZEBIG = 28
    # Afficher la Mappemende en fond
    DISPLAY_MAP = true
    
    #----------------------------------------------------
    # Initialisation
    #----------------------------------------------------
    def initialize(index = 0)
      @index = index
      @cpt_cursor = 0
      # Si l'interrupteur MODE_REGIONAL est activé, alors le pokédex régional
      # uniquement est activé
      if $game_switches[MODE_REGIONAL] 
        $pokedex.set_lv_regional
      end
    end
    
    #----------------------------------------------------
    # Initialisation du spriteset vu en fond
    #----------------------------------------------------
    def init_background1
      # Si la Mappemonde en fond n'est pas autorisée
      unless DISPLAY_MAP
        @background1 = Sprite.new
        @background1.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_1])
        return
      end
      
      # Sauvegarde des données de la map d'origine
      map_id = $game_map.map_id
      maplink = POKEMON_S._MAPLINK
      # Sauvegarde des données du player
      player_x, player_y = $game_player.x, $game_player.y
      player_transparent = $game_player.transparent
      
      # Affichage Mapppemonde
      POKEMON_S._MAPLINK = false
      $game_map.save_game_map($game_screen, $game_party.follower_pkm, 
                              $game_switches[PKM_TRANSPARENT_SWITCHES])
      $game_switches[PKM_TRANSPARENT_SWITCHES] = false
      $game_party.follower_pkm.update
      $game_screen = Game_Screen.new
      $game_map.setup(POKEMON_S::_WMAPID)
      $game_player.transparent = true
      
      # Position du chara dans la Mappemonde
      found = false
      map_zone = $data_mapzone[map_id][0]
      for element in $game_map.events.values
        name = element.event.name.split('/')
        if name.include?(map_zone.to_s) and not name.include?("*")
          found = [element.x, element.y]
        end
        if name.include?('~')
          actor_character = element
        end
      end
      
      # Si la map est répertoriée dans la Mappemonde
      if found
        # Placement du chara
        actor_character.set_map_character($game_player.character_name, 
                                          $game_player.character_hue)
        actor_character.moveto(found[0], found[1])
        actor_character.set_direction(2)
        # Déplacement de la map
        $game_map.display_x = (actor_character.x+5) * 128 - (320 - 16) * 4
        $game_map.display_y = (actor_character.y) * 128 - (240 - 16) * 4
        # Enregistrement du spriteset
        @background1 = Spriteset_Map.new
      # Sinon, background classique
      else
        @background1 = Sprite.new
        @background1.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_1])
      end
      
      # Retour à la map d'origine
      $game_map.setup(map_id, true)
      $game_player.moveto(player_x, player_y)
      $game_player.transparent = player_transparent
      POKEMON_S._MAPLINK = maplink
    end
    
    #----------------------------------------------------
    # Main
    #----------------------------------------------------
    def main
      # initialisation de @background1
      init_background1
      
      # Fond
      @background2 = Sprite.new
      @background2.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_2])
      @background2.x = 200
      @background2.z = 10
      
      # Sprite barre commandes
      @commands_sprite = Sprite.new
      @commands_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:barre_commandes])
      @commands_sprite.y = 480-35
      @commands_sprite.z = 20
      
      # Sprite Première Fenêtre
      @win1_sprite = Sprite.new
      @win1_sprite.z = 20
      @win1_sprite.x = 383
      @win1_sprite.y = $pokedex.level == 2 ? 32 : 80
      
      # Sprite deuxième Fenêtre
      @win2_sprite = Sprite.new
      @win2_sprite.z = 20
      @win2_sprite.x = 383
      @win2_sprite.y = 32+80+16
      @win2_sprite.visible = ($pokedex.level == 2)
      
      # Sprite curseur
      @cursor_sprite = Sprite.new
      @cursor_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_curseur])
      @cursor_sprite.z = 30
      @cursor_sprite.x = 362 #383 -21
      
      # fenêtre de choix
      @choice_window = Window_Base.new(383,16,240,208)
      @choice_window.contents = Bitmap.new(240-32, 208-32)
      @choice_window.contents.font.name = FONTFACE
      @choice_window.contents.font.size = FONTSIZE
      @choice_window.z = 40
      @choice_window.opacity = 0
      @choice_window.contents.font.color = @choice_window.white
      
      # Liste des pokémon proches proposés
      @pokemon_proposal = Window_Base.new(340,208,268+32,240+32)
      @pokemon_proposal.contents = Bitmap.new(268, 192)
      @pokemon_proposal.contents.font.name = FONTFACE
      @pokemon_proposal.contents.font.size = FONTSIZE
      @pokemon_proposal.contents.font.color = @choice_window.normal_color
      @pokemon_proposal.z = 40
      @pokemon_proposal.opacity = 0
      @pokemon_proposal.contents.draw_text(0,0,268,40, "Pokémon proches :", 1)
      draw_proposal(list_proposal)
      
      # Barre des commandes
      @pokedex_command = Window_Base.new(0, 480-51, 640 , 67)
      @pokedex_command.contents = Bitmap.new(640-32, 67-32)
      @pokedex_command.contents.font.name = FONTFACE
      @pokedex_command.contents.font.size = FONTSIZE
      @pokedex_command.z = 40
      @pokedex_command.opacity = 0
      @pokedex_command.contents.font.color = @pokedex_command.white
      string = "C : Selectionner    X : Retour"
      @pokedex_command.contents.draw_text(0, 0, 640-32, 35, string, 2)
      
      # Rafraichissement de la fenêtre
      $pokedex.level == 2 ? refresh_double : refresh_simple
      
      Graphics.transition
      
      while $scene == self
        Graphics.update
        Input.update
        update
      end
      
      Graphics.freeze
      
      dispose
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      @background1.dispose
      @background2.dispose
      @commands_sprite.dispose
      @cursor_sprite.dispose
      @win1_sprite.dispose
      @win2_sprite.dispose
      @choice_window.dispose
      @pokemon_proposal.dispose
      @pokedex_command.dispose
    end
    
    #----------------------------------------------------
    # Mise à jour
    #----------------------------------------------------
    def update
      cursor_animation
      # Retour
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        # On rement la liste d'affichage en mode national lorsque le pokédex est
        # au niveau 2 (quand les modes Régional et National sont tous deux disponibles)
        $pokedex.set_national if $pokedex.level == 2
        $scene = POKEMON_S::Pokemon_Menu.new(1)
        return
      end
      
      if Input.trigger?(Input::C)
        state = $pokedex.state
        state_reg = $pokedex.state_reg
        case $pokedex.level
        when 0 # Seulement Régional
          if state_reg[0] > 0
            $game_system.se_play($data_system.decision_se)
            $pokedex.set_regional
            $scene = POKEMON_S::Pokemon_Pokedex.new
          else
            $game_system.se_play($data_system.buzzer_se)
          end
        when 1 # Seulement National
          if state[0] > 0
            $game_system.se_play($data_system.decision_se)
            $pokedex.set_national
            $scene = POKEMON_S::Pokemon_Pokedex.new
          else
            $game_system.se_play($data_system.buzzer_se)
          end
        when 2 # Les deux sont disponibles
          if @index == 1 and state_reg[0] > 0
            $game_system.se_play($data_system.decision_se)
            $pokedex.set_regional
            $scene = POKEMON_S::Pokemon_Pokedex.new
          elsif @index == 0 and state[0] > 0
            $game_system.se_play($data_system.decision_se)
            $pokedex.set_national
            $scene = POKEMON_S::Pokemon_Pokedex.new
          else
            $game_system.se_play($data_system.buzzer_se)
          end
        end
        return
      end
      
      if Input.trigger?(Input::DOWN) or Input.trigger?(Input::UP)
        # Si les deux modes sont disponibles
        if $pokedex.level == 2
          @index = (@index+1)%2
          refresh_double
        end
        return
      end
    end
    
    def cursor_animation
      val = Math::PI / 30
      @cpt_cursor = (@cpt_cursor+1)%30
      @cursor_sprite.x = 362 + Integer(10*Math.sin(val*(@cpt_cursor)))
    end
    
    #----------------------------------------------------
    # Rafraichissement de la fenêtre
    # Dans le cas ou il y a deux choix de Pokédex
    #----------------------------------------------------
    def refresh_double
      @cursor_sprite.y = 60 + 96*@index
      @choice_window.contents.clear
      state = $pokedex.state
      state_reg = $pokedex.state_reg
      if @index == 0
        @win1_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_fenetre_on])
        @win2_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_fenetre_off])
      else
        @win1_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_fenetre_off])
        @win2_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_fenetre_on])
      end
      @choice_window.contents.font.color = color_win1
      @choice_window.contents.font.size = FONTSIZEBIG
      @choice_window.contents.draw_text(0,0,240-32,40,"Pokédex",1)
      @choice_window.contents.font.size = FONTSIZE
      string = sprintf("% 3s", state[1].to_s)
      @choice_window.contents.draw_text(38,40,62,36,string,1)
      string = sprintf("% 3s", state[0].to_s)
      @choice_window.contents.draw_text(134,40,62,36,string,1)
      @choice_window.contents.font.color = color_win2
      @choice_window.contents.font.size = FONTSIZEBIG
      @choice_window.contents.draw_text(0,96,240-32,40,"Pokédex Régional",1)
      @choice_window.contents.font.size = FONTSIZE
      string = sprintf("% 3s", state_reg[1].to_s)
      @choice_window.contents.draw_text(38,136,62,36,string,1)
      string = sprintf("% 3s", state_reg[0].to_s)
      @choice_window.contents.draw_text(134,136,62,36,string,1)
    end

    def color_win1
      return @index == 0 ? Color.new(255, 255, 255, 255) : Color.new(60, 60, 60, 255)
    end
    
    def color_win2
      return @index == 0 ? Color.new(60, 60, 60, 255) : Color.new(255, 255, 255, 255)
    end
    
    #----------------------------------------------------
    # Rafraichissement de la fenêtre
    # Dans le cas ou il n'y a qu'un choix de Pokédex
    #----------------------------------------------------
    def refresh_simple
      @win1_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_fenetre_on])
      @cursor_sprite.y = 108 #80+28
      case $pokedex.level
      when 0 # Régional
        @choice_window.contents.font.size = FONTSIZEBIG
        @choice_window.contents.draw_text(0,48,240-32,40,"Pokédex Régional",1)
        @choice_window.contents.font.size = FONTSIZE
        state_reg = $pokedex.state_reg
        string = sprintf("% 3s", state_reg[1].to_s)
        @choice_window.contents.draw_text(38,88,62,36,string,1)
        string = sprintf("% 3s", state_reg[0].to_s)
        @choice_window.contents.draw_text(134,88,62,36,string,1)
      when 1 # National
        @choice_window.contents.font.size = FONTSIZEBIG
        @choice_window.contents.draw_text(0,48,240-32,40,"Pokédex National",1)
        @choice_window.contents.font.size = FONTSIZE
        state = $pokedex.state
        string = sprintf("% 3s", state[1].to_s)
        @choice_window.contents.draw_text(38,88,62,36,string,1)
        string = sprintf("% 3s", state[0].to_s)
        @choice_window.contents.draw_text(134,88,62,36,string,1)
      end
    end
    
    #----------------------------------------------------
    # Affichage de la proposition de Pokémon proches
    #----------------------------------------------------
    def draw_proposal(list)
      list.size.times do |i|
        src_rect = Rect.new(0, 0, 64, 64)
        y = 40*(i+1)
        bitmap = RPG::Cache.battler("#{sprintf("Icon/%03d",list[i])}", 0) 
        dest_rect = Rect.new(0, y + 4, bitmap.width / 2, bitmap.height / 2)
        @pokemon_proposal.contents.stretch_blt(dest_rect, bitmap, src_rect, 255)
        string = Pokemon_Info.name(list[i])
        @pokemon_proposal.contents.draw_text(10+32, y, 300, 40, string)
        # attrapé/vu
        bitmap = RPG::Cache.picture(DATA_PKDX[:pokemon_capture])
        if $pokedex.captured?(list[i])
          @pokemon_proposal.contents.blt(150+32, y + 10, bitmap, Rect.new(0, 0, 20, 20))
        else
          @pokemon_proposal.contents.blt(150+32, y + 10, bitmap, Rect.new(0, 40, 20, 20))
        end
      end
    end
    
    #----------------------------------------------------
    # Création d'une proposition de Pokemon proches
    #----------------------------------------------------
    def list_proposal
      return [] if $random_encounter.empty?
        
      list_proposal = []
      
      1.upto(TAG_SYS::T_SIZE-1) do |tag|
        enemy_list = $random_encounter[tag]
        next unless enemy_list != nil and enemy_list.size > 0
        
        $random_encounter[tag].each do |group|
          if group.is_a?(POKEMON_S::Encounter) and 
              group.id_page == POKEMON_S::Encounter.index_page(group.id)
            group.info_pokemon.each do |pokemon|
              list_proposal.push(pokemon.id) if $pokedex.seen?(pokemon.id)
            end
          end
        end
      end
      
      unless list_proposal.empty?
        list_proposal.shuffle!
        return list_proposal.slice(0,4)
      end
      
      return list_proposal
    end
  end
end