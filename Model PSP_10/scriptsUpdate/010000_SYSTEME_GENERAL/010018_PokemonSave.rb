#==============================================================================
# ■ Scene_Save (Version Pokémon)
# Pokemon Script Project - Krosk
# 01/08/07
#------------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#------------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Save
    def initialize
      Graphics.freeze
      @number = 0 # Nombre de cadres de sauvegarde à générer
      1.upto(MAX_SAUVEGARDES) do |i|
        @number += 1 if FileTest.exist?("Saves/Save#{i}.rxsav")
      end
      @save_game_window_list = []
      1.upto(@number) do |i|
        window = Window_Base.new(30, 30 + 83*(i-1), 580, 80)
        window.contents = Bitmap.new(548, 48)
        window.z = 1000
        @save_game_window_list.push(window)
      end
      
      # Cadre nouvelle sauvegarde
      @new_save_window = Window_Base.new(30, 30 + 83*@number, 580, 80)
      @new_save_window.contents = Bitmap.new(548, 48)
      set_window(@new_save_window)
      @new_save_window.contents.draw_text(9, 3, 548, 48, "NOUVEAU FICHIER")
      if SAVEBOUNDSLOT
        @new_save_window.y = 30
      end
      @new_save_window.z = 1000
      
      captured = $pokedex.state[1]
      $read_data = [Player.name, Player.id, captured, $map_link]
      
      @index = 0
      
      begin 
        latest_time = Time.at(0)
      rescue Exception => exception
        print "Erreur interceptée dans la sauvegarde : #{exception}"
        print "Veuillez contacter un administrateur. Ne supprimez pas la sauvegarde, cette erreur n'empêche pas son fonctionnement"
        latest_time = file.mtime
      end
      1.upto(MAX_SAUVEGARDES) do |i|
        # Vérification d'un des fichiers de sauvegarde
        filename = "Saves/Save#{i}.rxsav"
        if FileTest.exist?(filename)
          file = File.open(filename, "rb")
          if file.mtime > latest_time
            latest_time = file.mtime
            @index = i - 1
          end
          file.close
        end
      end
      
      if SAVEBOUNDSLOT
        @index = POKEMON_S::_SAVESLOT
        if @index != @number
          @new_save_window.visible = false
        end
      end
      
    end
    
    def main
      if @number > 0 and not SAVEBOUNDSLOT
        @index = @number - 1
        # Mise à jour des déplacements :
        # Déplacement tous les cadres vers le haut de manière à pouvoir bien voir
        # à l'écran la dernière sauvegarde
        position_deplacement_cadres = @index > 2 ? -80 * (@index - 2) : 0
        refresh_all(position_deplacement_cadres)
      else
        refresh_all
      end
      @background = Spriteset_Map.new
      Graphics.transition
      @text_window = create_text
      @text_window.visible = false
      loop do
        Graphics.update
        Input.update
        update
        if $scene != self
          break
        end
      end
      Graphics.freeze
      @save_game_window_list.each { |window| window.dispose }
      @text_window.dispose
      @new_save_window.dispose
      @background.dispose
    end
    
    def update
      @background.update if SAVEBOUNDSLOT
      
      if Input.trigger?(Input::DOWN) and not SAVEBOUNDSLOT
        @index += (@index < @number and @index < MAX_SAUVEGARDES - 1) ? 1 : 0
        # Mise à jour des déplacements :
        # Déplace les cadres vers le haut si le cadre en-dessous est trop bas
        deplacement_descend = @index > 2 ? -80 * (@index - 2) : 0
        refresh_all(deplacement_descend)
      end
      
      if Input.trigger?(Input::UP) and not SAVEBOUNDSLOT
        @index -= @index == 0 ? 0 : 1
        # Mise à jour des déplacements :
        # Déplace les cadres vers le haut si le cadre en-dessous est trop bas
        deplacement_monte = @index > 2 ? -80 * (@index - 2) : 0
        refresh_all(deplacement_monte)
      end
      
      if Input.trigger?(Input::C)
        if @index == @number # Nouvelle sauvegarde
          $game_system.se_play($data_system.save_se)
          filename= "Save#{@number + 1}"
          write_save_data(filename)
          # En cas d'appel d'un événement
          if $game_temp.save_calling
            # Effacer l'indicateur de sauvegarde de l'appel
            $game_temp.save_calling = false
            # Passer à l'écran de la carte
            $scene = Scene_Map.new
            return
          end
          # Passer à l'écran de menu
          $scene = POKEMON_S::Pokemon_Menu.new(6)
        else
          decision = draw_choice
          if decision
            $game_system.se_play($data_system.save_se)
            filename = "Save#{@index + 1}"
            write_save_data(filename)
            # En cas d'appel d'un événement
            if $game_temp.save_calling
              # Effacer l'indicateur de sauvegarde de l'appel
              $game_temp.save_calling = false
              # Passer à l'écran de la carte
              $scene = Scene_Map.new
              return
            end
            # Passer à l'écran de menu
            $scene = POKEMON_S::Pokemon_Menu.new(6)
          else
            return
          end
        end
        draw_text("La sauvegarde a bien été effectuée !")
        loop do
          Graphics.update
          Input.update
          @text_window.update
          break if Input.trigger?(Input::C)
        end
        draw_text("Voulez-vous revenir à l'écran titre ?")
        decision = draw_choice(1)
        if decision
          $scene = Scene_Title.new # Retour à l'écran titre
        else
          $scene = Scene_Map.new # Permet de changer de scène (skip le menu)
        end
      end
      
      if Input.trigger?(Input::B)
        if $game_temp.save_calling
          $game_temp.save_calling = false
        end
        $scene = POKEMON_S::Pokemon_Menu.new(6)
        return
      end
      
    end

    def refresh_all(deplacement = 0)
      for i in 0...@number
        if i < @index
          @save_game_window_list[i].opacity = 128
          @save_game_window_list[i].y = 30 + 83*i + deplacement
          @save_game_window_list[i].height = 80
          @save_game_window_list[i].contents = Bitmap.new(548, 48)
          set_window(@save_game_window_list[i])
          @save_game_window_list[i].contents.draw_text(9, 3, 530, 48, "SAUVEGARDER PARTIE "+(i+1).to_s)
          if SAVEBOUNDSLOT
            @save_game_window_list[i].visible = false
          end
        elsif i == @index
          @save_game_window_list[i].opacity = 255
          @save_game_window_list[i].y = 30 + 83*i + deplacement
          @save_game_window_list[i].height = 233
          @save_game_window_list[i].contents = Bitmap.new(548, 233)
          set_window(@save_game_window_list[i])
          if SAVEBOUNDSLOT
            @save_game_window_list[i].contents.draw_text(9, 3, 530, 48, "SAUVEGARDER PARTIE")
            @save_game_window_list[i].y = 30
          else
            @save_game_window_list[i].contents.draw_text(9, 3, 530, 48, "SAUVEGARDER PARTIE "+(i+1).to_s)
          end
          filename = "Save#{i + 1}"
          list = $pokemon_save.read_preview(filename)
          data = list[0]
          time_sec = list[1]
          game_var = list[2] # $game_variables
          pkmn_party = list[3] # $pokemon_party
          game_actors = list[4] # $game_actors
          pkdex = list[5] # $pokedex
          game_switche = list[6] # $game_switches
          hour = (time_sec / 3600).to_s
          minute = "00"
          minute += ((time_sec%3600)/60).to_s
          minute = minute[minute.size-2, 2]
          time =  hour + ":" + minute
          name = data[0].to_s
          id = data[1].to_i
          seen = (pkdex ? pkdex.state[0].to_s : 0.to_s)
          captured = (pkdex ? pkdex.state[1].to_s : 0.to_s)
          @save_game_window_list[i].contents.draw_text(9, 42, 252, 48, "Nom:")
          #Couleur de la police si votre heros est un garçon
          @save_game_window_list[i].contents.font.color = Color.new(64,144,208,255)															 
          # Interrupteur qui détermine si vous avez choisi un Garcon ou une Fille
          if game_switche[FILLE]
            #Couleur de la police si votre heros est une fille
            @save_game_window_list[i].contents.font.color = Color.new(255,153,204,255)
          end
          @save_game_window_list[i].contents.draw_text(9, 42, 252, 48, name, 2)
          #Retour à la couleur normale
          @save_game_window_list[i].contents.font.color = Color.new(60, 60, 60, 255)
          @save_game_window_list[i].contents.draw_text(9, 81, 252, 48, "Badges:")
          nb_badge = 0
          [BADGE_1, BADGE_2, BADGE_3, BADGE_4, BADGE_5, BADGE_6, BADGE_7, BADGE_8].each do |badge|
            nb_badge += 1 if game_switche[badge]
          end
          @save_game_window_list[i].contents.draw_text(40, 81, 252, 48, nb_badge.to_s, 2)
          @save_game_window_list[i].contents.draw_text(9, 120, 252, 48, "Pokédex:")
          @save_game_window_list[i].contents.draw_text(40, 120, 252, 48, captured+"/"+seen, 2)
          @save_game_window_list[i].contents.draw_text(9, 159, 252, 48, "Temps:")
          @save_game_window_list[i].contents.draw_text(40, 159, 252, 48, time, 2)
          
          #Icone du Poké
          src_rect = Rect.new(0, 0, 64, 64)
          if pkmn_party.size > 0
            @order = [0,1,2,3,4,5]
            for j in 0..(pkmn_party.size - 1)
              @pokemon = pkmn_party.actors[@order[j]]
              if j < 3
                bitmap = RPG::Cache.battler(@pokemon.icon, 0)
                @save_game_window_list[i].contents.blt(330+(70*j), 55, bitmap, src_rect, 255)
              else
                bitmap = RPG::Cache.battler(@pokemon.icon, 0)
                @save_game_window_list[i].contents.blt(330+(70*(j-3)), 125, bitmap, src_rect, 255)
              end
            end
          end
          
          #Character du héros
          actor = game_actors[1]
          bitmap = RPG::Cache.character(actor.character_name, actor.character_hue)
          cw = bitmap.width / 4
          ch = bitmap.height / 4
          src_rect = Rect.new(0, 0, cw, ch)
          @save_game_window_list[i].contents.blt(400, -10, bitmap, src_rect, 255)
        elsif i > @index
          @save_game_window_list[i].opacity = 128
          @save_game_window_list[i].y = 30 + 83*i + 83 + deplacement + 70
          @save_game_window_list[i].height = 80
          @save_game_window_list[i].contents = Bitmap.new(548, 48)
          set_window(@save_game_window_list[i])
          @save_game_window_list[i].contents.draw_text(9, 3, 548, 48, "SAUVEGARDER PARTIE "+(i+1).to_s)
          if SAVEBOUNDSLOT
            @save_game_window_list[i].visible = false
          end
        end
      end
      if @index == @number and @number < MAX_SAUVEGARDES
        @new_save_window.opacity = 255
        @new_save_window.y = 30 + 83*@number + deplacement
      elsif @number < MAX_SAUVEGARDES
        @new_save_window.opacity = 128
        @new_save_window.y = 30 + 83*(@number+1) + deplacement + 70
      else
        @new_save_window.visible = false
      end
    end
    
    def set_window(window)
      window.contents.font.name = $fontface
      window.contents.font.size = $fontsizebig
      window.contents.font.color = window.normal_color
    end

    def write_save_data(filename)
      characters = []
      0.upto($game_party.actors.size - 1) do |i|
        actor = $game_party.actors[i]
        characters.push([actor.character_name, actor.character_hue])
      end
      $game_system.save_count += 1
      $game_system.magic_number = $data_system.magic_number
      $pokemon_save.save(filename, characters)
    end
    
    def draw_choice(index = 0)
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsizebig)
      @command.z = @new_save_window.z + 10
      @command.x = 517
      @command.y = 359
      @command.index = index
      loop do
        Graphics.update
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          @command.dispose
          @command = nil
          Input.update
          return true
        end
        if Input.trigger?(Input::C) and @command.index == 1
          @command.dispose
          @command = nil
          Input.update
          return false
        end
      end
    end
    
    # Création d'une fenêtre de texte
    # Renvoie les détails de la fenêtre
    def create_text()
      text_window = Window_Base.new(0, 375, 632, $fontsize * 2 + 34)
      text_window.z = @new_save_window.z + 10
      text_window.contents = Bitmap.new(600, 104)
      text_window.contents.font.name = $fontface
      text_window.contents.font.size = $fontsize

      return text_window
    end
      
    # Ecriture sur la fenêtre de texte d'une taille de 2 lignes
    # line1 : La première ligne du block de texte
    # line2 : La deuxième ligne du block de texte
    def draw_text(line1 = "", line2 = "")
      @text_window.visible = true
      @text_window.contents.clear
      @text_window.draw_text(0, -8, 460, 50, line1, 0, @text_window.normal_color)
      @text_window.draw_text(0, 22, 460, 50, line2, 0, @text_window.normal_color)
    end
  end
end

class Interpreter
  # TODO modifier
  def forcer_sauvegarde(index_save = -1)
    if not SAVEBOUNDSLOT
      return if index_save == -1
    else
      index_save = POKEMON_S::_SAVESLOT + 1
    end
    captured = $pokedex.state[1]
    
    $read_data = [Player.name, Player.id, captured, $map_link]
    characters = []
    0.upto($game_party.actors.size - 1) do |i|
      actor = $game_party.actors[i]
      characters.push([actor.character_name, actor.character_hue])
    end
    $game_system.save_count += 1
    $game_system.magic_number = $data_system.magic_number
    game_system = $game_system.clone
    game_system.reset_interpreter
    $pokemon_save.save("Save#{index_save}", characters)
  end
end