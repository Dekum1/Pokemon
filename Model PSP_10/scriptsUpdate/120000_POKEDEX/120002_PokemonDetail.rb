#==============================================================================
# ■ Pokemon_Pokedex
# Pokemon Script Project - Krosk
# 18/07/07
# 07/09/08 - révision v0.7, Pokédex de Shaolan (PSP4G) simplifié et optimisé
#             (crédits : Shaolan, Slash)
# 03/01/09 - révision
#-----------------------------------------------------------------------------
# PSP4G+ : appel dans Pokédex et appel hors Pokédex
#-----------------------------------------------------------------------------
# Refonte - G!n0 
# 15/08/2020
# 27/01/21 - Révision
#    - Tri du pokedex (alphabétique, par taille, par poids)
#    - Prise en charge des différentes formes des pokemons
#    - ATTENTION : suppression des modes (cri, comparaison tailles)
#-----------------------------------------------------------------------------
# Scène modifiable
#-----------------------------------------------------------------------------

module POKEMON_S
  
  class Pokemon_Detail
    
    #----------------------------------------------------
    # Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FONTSIZE = 24
    FONTSIZEBIG = 28
    
    #----------------------------------------------------
    # Initialisation
    # id : id du Pokémon dont le détail est affiché
    # show : le style de tri
    # appel : :pkdx , :combat , :map
    #----------------------------------------------------
    def initialize(id, show, appel = :pkdx , z_level = 100)
      @id = id
      @show = show
      @call = appel
      @z_level = z_level
      
      # Indicateur de fin de scène
      @done = false
      
      # Pour la gestion des formes
      setup_list_form
      
      # Liste des id des Pokémons suivant le mode du Pokédex
      setup_table
      
      # Liste des pokemon triée seulement avec les pkmn vus!
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
        return
      end
      # National
      @table = Array.new($pokedex.data.size - 1) {|i| i + 1 }
      return
    end
    
    #----------------------------------------------------
    # # Mise en place de la liste des formes du Pokémon
    #----------------------------------------------------
    def setup_list_form
      @list_form = []
      @list_form = $pokedex.data[@id][1] if $pokedex.data[@id][1]
      @form_index = 0
      return
    end
    
    #----------------------------------------------------
    # Main
    #----------------------------------------------------
    def main
      # Initialisation de l'interface
      init_interface
     
      # Cri du Pokémon
      pokemon_cry
      
      # Rafraichissement données affichées
      data_refresh
       
      Graphics.transition
      until @done
        Graphics.update
        Input.update
        update
      end
      Graphics.freeze
      
      # Libération de la mémoire
      dispose
    end
    
    #----------------------------------------------------
    # Initialisation de l'interface
    #----------------------------------------------------
    def init_interface
      # Fonds
      @background1 = Sprite.new
      @background1.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_1])
      @background1.z = @z_level
      
      @background2 = Sprite.new
      @background2.bitmap = RPG::Cache.picture(DATA_PKDX[:fond_2])
      @background2.x = -176
      @background2.z = @z_level + 1
      
      # Sprite des fenêtres
      @windows_sprite = Sprite.new
      @windows_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:fenetres_detail])
      @windows_sprite.z = @z_level + 2
     
      # Sprite du Pokémon
      @pokemon_sprite = Sprite.new
      @pokemon_sprite.x = 63
      @pokemon_sprite.y = 89
      @pokemon_sprite.z = 10 + @z_level
      @pokemon_sprite.mirror = true
      @pokemon_sprite.visible = true
      
      # Sprite capturé/pris
      @ball_sprite = Sprite.new
      @ball_sprite.x = 572
      @ball_sprite.y = 27
      @ball_sprite.z = 10 + @z_level
      @ball_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:pokemon_capture])
      @ball_sprite.src_rect.set(0, 60, 20, 20)
      
      # Sprite mâle
      @gender1_sprite = Sprite.new
      @gender1_sprite.x = 520
      @gender1_sprite.y = 27
      @gender1_sprite.z = 10 + @z_level
      @gender1_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:male])
      @gender1_sprite.visible = false
      
      # Sprite femelle
      @gender2_sprite = Sprite.new
      @gender2_sprite.x = 544
      @gender2_sprite.y = 27
      @gender2_sprite.z = 10 + @z_level
      @gender2_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:femelle])
      @gender2_sprite.visible = false
      
      # sprite curseurs
      # Gauche
      @cursorL_sprite = Sprite.new
      @cursorL_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:cursors])
      @cursorL_sprite.src_rect.set(15, 0, 15, 15)
      @cursorL_sprite.x = 272
      @cursorL_sprite.y = 30
      @cursorL_sprite.z = 12 + @z_level
      @cursorL_sprite.visible = false
      # Droite
      @cursorR_sprite = Sprite.new
      @cursorR_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:cursors])
      @cursorR_sprite.src_rect.set(30, 0, 15, 15)
      @cursorR_sprite.x = 608
      @cursorR_sprite.y = 30
      @cursorR_sprite.z = 12 + @z_level
      @cursorR_sprite.visible = false
      # Haut(up)
      @cursorU_sprite = Sprite.new
      @cursorU_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:cursors])
      @cursorU_sprite.src_rect.set(45, 0, 15, 15)
      @cursorU_sprite.x = 439
      @cursorU_sprite.y = 1
      @cursorU_sprite.z = 12 + @z_level
      @cursorU_sprite.visible = true
      # Bas(down)
      @cursorD_sprite = Sprite.new
      @cursorD_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:cursors])
      @cursorD_sprite.src_rect.set(0, 0, 15, 15)
      @cursorD_sprite.x = 439
      @cursorD_sprite.y = 58
      @cursorD_sprite.z = 12 + @z_level
      @cursorD_sprite.visible = true
      
      # Fenêtre identité
      @data_window = Window_Base.new(272, 0, 354, 314)
      @data_window.contents = Bitmap.new(354-32, 314-32)
      @data_window.contents.font.name = FONTFACE
      @data_window.contents.font.size = FONTSIZE
      @data_window.contents.font.color = Color.new(60, 60, 60)
      @data_window.opacity = 0
      @data_window.z = 10 + @z_level
      @data_window.visible = true
     
      # Fenêtre description
      @text_window = Window_Base.new(0,303, 640,192)
      @text_window.contents = Bitmap.new(640-32, 192-32)
      @text_window.contents.font.name = FONTFACE
      @text_window.contents.font.size = FONTSIZE
      @text_window.contents.font.color = Color.new(60, 60, 60)
      @text_window.opacity = 0
      @text_window.z = 10 + @z_level
      @text_window.visible = true
      
      # Barre des commandes :
      @pokedex_command = Window_Base.new(0, 429, 640 , 67)
      @pokedex_command.contents = Bitmap.new(640-32, 67-32)
      @pokedex_command.contents.font.name = FONTFACE
      @pokedex_command.contents.font.size = FONTSIZE
      @pokedex_command.contents.font.color = Color.new(255, 255, 255)
      @pokedex_command.opacity = 0
      @pokedex_command.z = @z_level + 10
      string = "C : Cri    Z : Zones    X : Retour"
      @pokedex_command.contents.draw_text(0, 0, 640-32, 35, string, 2)
      @pokedex_command.visible = (@call == :pkdx )
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      @background1.dispose
      @background1 = nil
      @background2.dispose
      @background2 = nil
      @windows_sprite.dispose
      @windows_sprite = nil
      @ball_sprite.dispose
      @pokemon_sprite.dispose
      @pokemon_sprite = nil
      @gender1_sprite.dispose
      @gender1_sprite = nil
      @gender2_sprite.dispose
      @gender2_sprite = nil
      @cursorL_sprite.dispose
      @cursorL_sprite = nil
      @cursorR_sprite.dispose
      @cursorR_sprite = nil
      @cursorU_sprite.dispose
      @cursorD_sprite.dispose
      @cursorD_sprite = nil
      @data_window.dispose
      @data_window = nil
      @text_window.dispose
      @text_window = nil
      @pokedex_command.dispose
      @pokedex_command = nil
    end
    
    
    #----------------------------------------------------
    # Mise à Jour
    #----------------------------------------------------
    def update
      case @call
      # Appel :pkdx
      when :pkdx
        update_pkdx
      # Appel map
      when :map
        update_map
      # Appel en combat
      when :combat
        update_fight
      end
    end
    
    
    #----------------------------------------------------
    # MAJ en cas d'appel :pkdx
    #----------------------------------------------------
    def update_pkdx
      #Retour
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        # Détermination index suivant le style de tri : Soit numérique, soit autre
        index = (@show == 0) ? @table.index(@id) : @list.index(@id)
        # Retour à la liste des Pokémon du Pokédex
        $scene = Pokemon_Pokedex.new(index, @show)
        @done = true
        return
      end
      
      # Zones
      if Input.trigger?(Input::A)
        $game_system.se_play($data_system.decision_se)
        Graphics.freeze
        
        $game_map.save_game_map( $game_screen, $game_party.follower_pkm, 
                                 $game_switches[PKM_TRANSPARENT_SWITCHES] )
        $game_switches[PKM_TRANSPARENT_SWITCHES] = false
        $game_party.follower_pkm.update
        $game_screen = Game_Screen.new
        
        $game_temp.map_temp = [ "PKDX_DETAIL", false, 
                                $game_map.map_id, $game_player.x,
                                $game_player.y, $game_player.direction,
                                $game_player.character_name,
                                $game_player.character_hue,
                                $game_player.step_anime,
                                $game_system.menu_disabled,
                                POKEMON_S::_MAPLINK, @id, @show ]
        $game_temp.transition_processing = true
        $game_temp.transition_name = ""
        POKEMON_S::_MAPLINK = false
        $scene = Scene_Map.new
        $game_map.setup(POKEMON_S::_WMAPID)
        $game_player.moveto(9, 7)
        $game_map.autoplay
        $game_map.update
        @done = true
        return
      end
      
      # Cri du Pokémon
      if Input.trigger?(Input::C)
        pokemon_cry
      end
      
      # Bas
      if Input.trigger?(Input::DOWN)
        # Mouvement de flèche
        move_cursorD(2)
        # Changement de l'id du Pokémon
        @id = @list[ (@list.index(@id) + 1) % @list.size ]
        # Réinitialisation de la liste des formes et don son index
        setup_list_form
        # Rafraichissement des infos
        data_refresh
        # Mouvement de flèche
        move_cursorD(-2)
        # Cri du Pokémon
        pokemon_cry
      end
      
      # Haut
      if Input.trigger?(Input::UP)
        # Mouvement de flèche
        move_cursorU(-2)
        # Changement de l'id du Pokémon
        @id = @list[ (@list.index(@id) - 1) % @list.size ]
        # Réinitialisation de la liste des formes et don son index
        setup_list_form
        # Rafraichissement des infos
        data_refresh
        # Mouvement de flèche
        move_cursorU(2)
        # Cri du Pokémon
        pokemon_cry
      end
      
      # Gauche : accès aux formes du Pokémon
      if Input.trigger?(Input::LEFT)
        if @list_form.length > 1
          # Mouvement de flèche
          move_cursorL(-2)
          # Modification de l'indicateur de forme
          @form_index = (@form_index - 1) % @list_form.length
          # Rafraichissement des infos
          data_refresh
          # Mouvement de flèche
          move_cursorL(2)
        end
      end
      
      # Droite : accès aux formes du Pokémon
      if Input.trigger?(Input::RIGHT)
        if @list_form.length > 1
          # Mouvement de flèche
          move_cursorR(2)
          # Modification de l'indicateur de forme
          @form_index = (@form_index + 1) % @list_form.length
          # Rafraichissement des infos
          data_refresh
          # Mouvement de flèche
          move_cursorR(-2)
        end
      end
    end
    
    
    #----------------------------------------------------
    # MAJ en cas d'appel :map
    #----------------------------------------------------
    def update_map
      if Input.trigger?(Input::C) or Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
        @done = true
        return
      end
      
      if Input.dir4 != 0 or Input.trigger?(Input::A) or
          Input.trigger?(Input::X)
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    
    
    #----------------------------------------------------
    # MAJ en cas d'appel :combat
    #----------------------------------------------------
    def update_fight
      if Input.trigger?(Input::C) or Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @done = true
        return
      end
      
      if Input.dir4 != 0 or Input.trigger?(Input::A) or
          Input.trigger?(Input::X)
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    
    
    #----------------------------------------------------
    # Cri du Pokémon
    #----------------------------------------------------
    def pokemon_cry
      filename = "Audio/SE/Cries/#{sprintf("%03d", @id)}Cry.wav"
        Audio.se_play(filename) if FileTest.exist?(filename)
    end
    
    #----------------------------------------------------
    # Mouvement des flèches
    #----------------------------------------------------
    def move_cursorD(dy)
      @cursorD_sprite.y += dy
        Graphics.update
    end
    
    def move_cursorU(dy)
      @cursorU_sprite.y += dy
        Graphics.update
    end
    
    def move_cursorL(dx)
      @cursorL_sprite.x += dx
      Graphics.update
    end
    
    def move_cursorR(dx)
      @cursorR_sprite.x += dx
      Graphics.update
    end
    
    
    #----------------------------------------------------
    # Tri de la liste des pokemons
    #----------------------------------------------------
    def sort_list(show)
      case show
      # "numérique" avec que les pkmn vu !!
      when 0
        @list.clear
        @table.each {|id| @list.push(id) if $pokedex.seen?(id)}
      # Alphabétique : pokemon vus
      when 1 
        @list.clear
        #On ne prend que les pkmn vus
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
    # Rafraichissement de la page des données
    #----------------------------------------------------
    def data_refresh
      # id_form actuel
      id_form = @list_form[@form_index]
      id_form ||= 0
      # numéro de la forme
      form = id_form / 20
      # Indicateur shiny
      shiny = false
      female =  false
      mega = false
      value_mega = 0
      case (id_form % 20)
      when 1
        shiny = true
      when 2
        female = true
      when 3
        shiny = true
        female = true
      when 7
        value_mega = id_form % 7 + 1
      when 8
        shiny = true
        value_mega = id_form % 8 + 1
      when 9
        female = true
        value_mega = id_form % 9 + 1
      when 11
        shiny = true
        female = true
        value_mega = id_form % 11 + 1
      end
      # Rafraichissement du sprite de la ball
      refresh_ball_sprite
      # Rafraichissement des flèches
      refresh_cursors
      # Rafraichissement du sprite du Pokémon
      pokemon_face = face_conversion(id_form, value_mega)
      @pokemon_sprite.bitmap = RPG::Cache.battler(pokemon_face, 0)
      # Rafraichissement des sprites du genre
      refresh_gender_sprites(form, female)
      
      # Données du Pokémon (nom, taille, poids, types)
      draw_pokemon_data(form, value_mega)
      # Description du Pokémon
      draw_pokemon_descr(form, female, value_mega)
      # Description de la forme
      draw_form_descr(form, shiny, value_mega)
    end
   
    #----------------------------------------------------
    # Rafraichissement du sprite de la ball
    #----------------------------------------------------
    def refresh_ball_sprite
      if $pokedex.captured?(@id)
        @ball_sprite.src_rect.set(0,20,20,20)
      else
        @ball_sprite.src_rect.set(0,60,20,20)
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement des flèches
    #----------------------------------------------------
    def refresh_cursors
      @cursorU_sprite.visible = (@call == :pkdx )
      @cursorD_sprite.visible = (@call == :pkdx )
      @cursorL_sprite.visible = (@list_form.length > 1 and @call == :pkdx )
      @cursorR_sprite.visible = (@list_form.length > 1 and @call == :pkdx )
    end
    
    #----------------------------------------------------
    # Rafraichissement des sprites du genre
    #----------------------------------------------------
    def refresh_gender_sprites(form, female)
      # id pokemon
      ida = sprintf("%03d", @id)
      # Non genré
      if Pokemon_Info.female_rate(@id) == -1
        @gender1_sprite.visible = false
        @gender2_sprite.visible = false
        return
      end
      # Même apparence pour les deux sexes
      if form != 0 or !(FileTest.exist?("Graphics/Battlers/Front_Female/#{ida}.png")) 
        @gender1_sprite.visible = true
        @gender2_sprite.visible = true
        return
      end
      # Femelle sans forme
      if female
        @gender1_sprite.visible = false
        @gender2_sprite.visible = true
        return
      end
      # Mâle sans forme activée 
      @gender1_sprite.visible = true
      @gender2_sprite.visible = false
    end
    
    #----------------------------------------------------
    # Afficher les données su Pokémon :
    # Nom, taille, Poids, Types
    #----------------------------------------------------
    def draw_pokemon_data(form, value_mega)
      # Effacer le contenu
      @data_window.contents.clear
      
      # Numéro et nom du Pokémon
      id_pkdx = $pokedex.regional ? Pokemon_Info.id_bis(@id) : @id
      name = "N°" + sprintf( "%03d", id_pkdx) + "     " + Pokemon_Info.name(@id)
      @data_window.contents.font.color = @data_window.white
      @data_window.contents.draw_text(16, 0, 290, 41, name)
      @data_window.contents.font.color = @data_window.normal_color
      
      # Infos disponibles ou non
      if $pokedex.captured?(@id)
        pokemon_species = Pokemon_Info.spec(@id)
        pokemon_height = Pokemon_Info.height(@id, form, value_mega)
        pokemon_weight = Pokemon_Info.weight(@id, form, value_mega)
      else
        pokemon_species = pokemon_height = pokemon_weight = "???"
      end
      
      # Espèce du Pokémon
      @data_window.contents.draw_text(16, 50+6, 290, 41, "Pokémon " + pokemon_species, 1)
      
      # Type du Pokémon
      @data_window.contents.draw_text(0, 100+2, 120, 41, "Type", 1)
      if $pokedex.captured?(@id)
        draw_type(@id, form)
      else
        @data_window.contents.draw_text(16, 100, 290, 41, "???", 2)
      end
      
      # Taille du Pokémon
      @data_window.contents.draw_text(0, 145+2, 120, 41, "Taille", 1)
      @data_window.contents.draw_text(16, 145+2, 290, 41, pokemon_height, 2)
      
      # Poids du Pokémon
      @data_window.contents.draw_text(0, 190+2, 120, 41, "Poids",1)
      @data_window.contents.draw_text(16, 190+2, 290, 41, pokemon_weight, 2)
    end
    
    #----------------------------------------------------
    # Affichage de la description du Pokémon
    #----------------------------------------------------
    def draw_pokemon_descr(form, female, value_mega)
      @text_window.contents.clear
      return unless $pokedex.captured?(@id)
      form = "F" if form == 0 and female
      text = Pokemon_Info.descr(@id, form, value_mega)
      string = @text_window.str_builder(text,3)
      @text_window.contents.draw_text(0, 0, 640-32, 40, string[0])
      @text_window.contents.draw_text(0, 40, 640-32, 40, string[1])
      @text_window.contents.draw_text(0, 80, 640-32, 40, string[2])
    end
    
    #----------------------------------------------------
    # Affichage de la description de la forme
    #----------------------------------------------------
    def draw_form_descr(form, shiny, value_mega)
      symbol = "f#{@id}_#{form}".to_sym
      if value_mega != 0
        symbol = "#{symbol}_M#{value_mega}".to_sym
      end
      return unless $data_form[symbol] or shiny
      src_rect = Rect.new(0, 0, 321, 43)
      bitmap = RPG::Cache.picture(DATA_PKDX[:fenetre_forme])
      @data_window.contents.blt(0, 240-2, bitmap, src_rect, 255)
      descr_form = Pokemon_Info.descr_form(@id, form, shiny, value_mega)
      @data_window.contents.draw_text(16, 240-2, 290, 41, descr_form, 1)
    end
    
    #----------------------------------------------------
    # Convertir le code_appearence du Pkmn pour obtenir
    # Le chemin du fichier de son apparence
    #----------------------------------------------------
    def face_conversion(form, value_mega)
      ida = sprintf("%03d", @id)
      value_form = form/20
      battler_form = ""
      if value_form != 0
        battler_form = sprintf("_%02d", value_form)
      end
      gender = "Front_Male"
      shiny = ""
      battler_mega = ""
      form_modulo = form % 20
      
      case form_modulo
      when 1 #mâle shiny
        shiny = "Shiny_"
      when 2 #femelle non shiny
        gender = "Front_Female"
      when 3 #shiny femelle
        shiny = "Shiny_"
        gender = "Front_Female"
      end
       
      if value_mega != 0
        battler_mega = sprintf("_M%d", value_mega)
      end
      string = "#{shiny}#{gender}/#{ida}#{battler_form}#{battler_mega}.png"
      
      #Si un problème, mettre forme de base...
      if not (FileTest.exist?("Graphics/Battlers/" + string))
        string = "Front_Male/#{ida}#{battler_form}#{battler_mega}.png"
      end
      if not (FileTest.exist?("Graphics/Battlers/" + string))
        string = "Front_Male/#{ida}.png"
      end
      
      return string
    end
    
    #----------------------------------------------------
    # Tracer les genres du Pokémon affiché
    ##----------------------------------------------------
    def draw_type(id, form)
      src_rect = Rect.new(0, 0, 200, 42)
      type = Pokemon_Info.type1(id, form)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @data_window.contents.blt(122, 100+2, bitmap, src_rect, 255)
      type = Pokemon_Info.type2(id, form)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @data_window.contents.blt(222, 100+2, bitmap, src_rect, 255)
    end
   
  end
  
end