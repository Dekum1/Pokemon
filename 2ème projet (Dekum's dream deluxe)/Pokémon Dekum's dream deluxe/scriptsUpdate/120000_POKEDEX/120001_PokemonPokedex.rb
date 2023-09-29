#==============================================================================
# ■ Pokemon_Pokedex
# Pokemon Script Project - Krosk
# 18/07/07
# 07/09/08 - révision v0.7, Pokédex de Shaolan (PSP4G) simplifié et optimisé
#             (crédits : Shaolan, Slash)
# 03/01/09 - révision
#-----------------------------------------------------------------------------
# Refonte - G!n0 
# 15/08/2020
# 27/01/21 - Révision
#    - Optimisation (réduction du temps d'attente lors du lancement du pokedex)
#    - Tri du pokedex (alphabétique, par taille, par poids)
#-----------------------------------------------------------------------------
# Scène modifiable
#-----------------------------------------------------------------------------

module POKEMON_S
  
  class Pokemon_Pokedex #(Numérique)
    #----------------------------------------------------
    # Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FONTSIZE = 24
    FONTSIZEBIG = 28
    
    #----------------------------------------------------
    # Initialisation
    # Show désigne le style de tri :
    # 0 : Numérique ; 1 : Alpha ; 2 : Par Taille ; 3 : Par Poids
    #----------------------------------------------------
    def initialize(index = 0, show = 0 )
      @index = index
      @show = show
      
      # liste des Pokémon disponibles suivant le mode (Régional/National)
      setup_table
      
      # Liste triée des Pokémon
      @list = []
      sort_list(@show)
    end
   
    #----------------------------------------------------
    # Mise en place de la liste des Pokémon
    # disponibles suivant le mode (Régional/National)
    #----------------------------------------------------
    def setup_table
      # Regional
      if $pokedex.regional
        @table = $pokedex.list_reg
      else # National
        @table = Array.new($pokedex.data.size - 1) {|i| i + 1 }
      end
    end
    
    #----------------------------------------------------
    # Main
    #----------------------------------------------------
    def main
      # Initialisation de l'interface
      init_interface

      Graphics.transition
      while $scene == self
        Graphics.update
        Input.update
        update
      end
      Graphics.freeze
      
      #Libération de la mémoire
      dispose
    end
   
    #----------------------------------------------------
    # Initialisation de l'interface
    #----------------------------------------------------
    def init_interface
      # Fonds
      @background1 = Sprite.new
      @background1.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_1])
      @background1.z = 0
      
      @background2 = Sprite.new
      @background2.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_2])
      @background2.x = 160
      @background2.z = 1
      
      # Sprite de la barre de titre
      @title_sprite = Sprite.new
      @title_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:barre_titre])
      @title_sprite.y = 12
      @title_sprite.z = 5
      
      # Sprite de la barre des commandes
      @commands_sprite = Sprite.new
      @commands_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:barre_commandes])
      @commands_sprite.y = 480-35
      @commands_sprite.z = 5
      
      # Création de la fenetre de la liste des pokemon
      @pokemon_list = POKEMON_S::Pokemon_List.new( @list, @index)
      @pokemon_list.active = true
      
      # Titre
      @title = Window_Base.new(0, -16, 640+32, 50+32)
      @title.contents = Bitmap.new(640, 50)
      @title.contents.font.name = FONTFACE
      @title.contents.font.color = @title.normal_color
      @title.opacity = 0
      title_refresh
      
      # Barre des commandes
      @pokedex_command = Window_Base.new(0, 480-51, 640 , 67)
      @pokedex_command.contents = Bitmap.new(640-32, 67-32)
      @pokedex_command.contents.font.name = FONTFACE
      @pokedex_command.contents.font.size = FONTSIZE
      @pokedex_command.contents.font.color = @pokedex_command.white
      @pokedex_command.opacity = 0
      string = "C : Infos    Z : Zones    A : Trier    X : Retour"
      @pokedex_command.contents.draw_text(0, 0, 640-32, 35, string,2)
      
      # Fenêtre de tri
      s1 = "Numérique"
      s2 = "Alphabétique"
      s3 = "Taille croissante"
      s4 = "Poids Croissant"
      @sort_window = Window_Command.new(216, [s1, s2, s3, s4], FONTSIZE, 1)
      @sort_window.contents.font.name = FONTFACE
      @sort_window.x = 16
      @sort_window.y = 305-32
      4.times do |i|
        @sort_window.draw_item(i, Color.new(255, 255, 255))
      end
      @sort_window.windowskin = RPG::Cache.windowskin(DATA_PKDX[:windowskin])
      @sort_window.opacity = 125
      @sort_window.visible = false
      @sort_window.active = false
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      @background1.dispose
      @background1 = nil
      @background2.dispose
      @background2 = nil
      @title_sprite.dispose
      @title_sprite = nil
      @commands_sprite.dispose
      @commands_sprite = nil
      @title.dispose
      @title = nil
      @pokemon_list.dispose
      @pokemon_list = nil
      @pokedex_command.dispose
      @pokedex_command = nil
      @sort_window.dispose
      @sort_window = nil
    end
    
    #----------------------------------------------------
    # Mise à jour
    #----------------------------------------------------
    def update
      # Si la fenêtre de la liste est active
      if @pokemon_list.active
        update_pokemon_list
        return
      end
      # Si la fenêtre de tri est active
      if @sort_window.active
        update_sort_window
      end
    end
    
    #----------------------------------------------------
    # MAJ lorsque la liste des Pokémon est active
    #----------------------------------------------------
    def update_pokemon_list
      @pokemon_list.update
      @index = @pokemon_list.index
      
      # Retour
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        ind = $pokedex.regional ? 1 : 0
        $scene = Intro_Pokedex.new(ind)
        return
      end
      
      # Infos. Seulement pour les pkmn vus
      if Input.trigger?(Input::C)
        pokemon_id = @list[@index]
        unless $pokedex.seen?(pokemon_id)
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $scene = Pokemon_Detail.new(pokemon_id, @show)
        return
      end
      
      # Zone. Seulement pour les pkmn vus
      if Input.trigger?(Input::A)
        pokemon_id = @list[@index]
        unless $pokedex.seen?(pokemon_id)
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        
        Graphics.freeze
        
        $game_map.save_game_map( $game_screen, $game_party.follower_pkm, 
                                 $game_switches[PKM_TRANSPARENT_SWITCHES] )
        $game_switches[PKM_TRANSPARENT_SWITCHES] = false
        $game_party.follower_pkm.update
        $game_screen = Game_Screen.new
        
        $game_temp.map_temp = ["PKDX", false, $game_map.map_id, $game_player.x,
          $game_player.y, $game_player.direction, $game_player.character_name,
          $game_player.character_hue, $game_player.step_anime,
          $game_system.menu_disabled, POKEMON_S::_MAPLINK, pokemon_id, @index, @show]
        $game_temp.transition_processing = true
        $game_temp.transition_name = ""
        POKEMON_S::_MAPLINK = false
        
        $scene = Scene_Map.new
        $game_map.setup(POKEMON_S::_WMAPID)
        $game_player.moveto(9, 7)
        $game_map.autoplay
        $game_map.update
        return
      end
      
      # Tri
      if Input.trigger?(Input::X)
        @pokemon_list.active = false
        @sort_window.visible = true
        @sort_window.active = true
        return
      end
    end
    
    #----------------------------------------------------
    # MAJ Lorsque la fenêtre de tri est active
    #----------------------------------------------------
    def update_sort_window
      @sort_window.update
      
      # Choix du tri
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        @index = 0 if @show != @sort_window.index
        @show = @sort_window.index
        @sort_window.visible = false
        @sort_window.active = false
        sort_list(@show)
        @pokemon_list.dispose
        @pokemon_list = POKEMON_S::Pokemon_List.new(@list, @index)
        @pokemon_list.active = true
        title_refresh
        return
      end
      
      # Retour
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @sort_window.visible = false
        @sort_window.active = false
        @pokemon_list.active = true
        return
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement du titre
    ##----------------------------------------------------
    def title_refresh
      @title.contents.clear
      @title.contents.font.size = FONTSIZEBIG
      @title.contents.font.color = @title.normal_color
      # Etat du pokédex : [vus, capturés]
      state = $pokedex.regional ? $pokedex.state_reg : $pokedex.state
      string = $pokedex.regional ? "Rég." : ""
      @title.contents.draw_text(0, 12 , 640-32, 50, "Pokédex " + string)
      @title.contents.font.size = FONTSIZE
      @title.contents.font.color = @title.white
      string = sprintf("% 3s", state[1].to_s)
      @title.contents.draw_text(196, 12, 52, 50, string, 1)
      string = sprintf("% 3s", state[0].to_s)
      @title.contents.draw_text(282, 12, 52, 50, string, 1)
      @title.contents.draw_text(334, 12, 289, 50, sort_title, 1)
    end
    
    def sort_title
      case @show
      when 0
        return "Numéro"
      when 1
        return "Ordre Alphabétique"
      when 2
        return "Taille Croissante"
      when 3
        return "Poids Croissant"
      end
    end
    
    
    #----------------------------------------------------
    # Méthode de tri
    #----------------------------------------------------
    def sort_list(show)
      case show
      # Liste de tous les id jusqu'au dernier vu
      when 0
        index_last = @table.index(id_last_list)
        @list = Array.new(index_last + 1) {|i| @table[i]}
      # Alphabétique
      when 1
        @list.clear
        # On ne prend que les pkmn vus
        @table.each {|id| @list.push(id) if $pokedex.seen?(id)}
        @list.sort!{|a,b| Pokemon_Info.name(a) <=> Pokemon_Info.name(b) }
      # Taille pour les pkmn capturés
      when 2
        @list.clear
        # On ne prend que les Pokémon Capturés
        @table.each {|id| @list.push(id) if $pokedex.captured?(id)}
        @list.mergeSort! do |a,b| 
          elementA = $data_pokemon[a][9][2].gsub(' m', '').to_f
          elementB = $data_pokemon[b][9][2].gsub(' m', '').to_f
          elementA <=> elementB
        end
      # Poids pour les pkmn capturés
      when 3
        @list.clear
        @table.each {|id| @list.push(id) if $pokedex.captured?(id)}
        @list.mergeSort! do |a,b| 
          elementA = $data_pokemon[a][9][3].gsub(' kg', '').to_f
          elementB = $data_pokemon[b][9][3].gsub(' kg', '').to_f
          elementA <=> elementB
        end
      end
    end
    
    #----------------------------------------------------
    # obtenir l'id du dernier des Pokémon vus
    #----------------------------------------------------
    def id_last_list
      @table.reverse.each {|id| return id if $pokedex.seen?(id)}
      return @table
    end
    
  end
  
end