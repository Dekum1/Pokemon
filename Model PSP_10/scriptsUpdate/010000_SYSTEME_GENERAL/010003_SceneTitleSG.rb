#==============================================================================
# ■ Scene_Title (Version Pokémon)
# Pokemon Script Project - Krosk
# 01/08/07
#------------------------------------------------------------------------------
# Scène modifiable
#------------------------------------------------------------------------------
# Intègre le menu de chargement
#------------------------------------------------------------------------------
class Scene_Title
  include POKEMON_S

  def main
    if $BTEST
      battle_test
      return
    end
    $mega_on = nil
    
    $pokemon_save = SaveFile.allocate
    if $game_system == nil
      filenames = %w[Actors Classes Skills Items Weapons Armors Enemies Troops
                     States Animations Tilesets CommonEvents System Library]
      loaded = []
      threads = filenames.map do |filename|
        next Thread.new do
          loaded[filenames.index(filename)] = load_data("Data/#{filename}.rxdata")
        end
      end
      threads.each { |thread| thread.join }
      $data_actors = loaded[0]
      $data_classes = loaded[1]
      $data_skills = loaded[2]
      $data_items = loaded[3]
      $data_weapons = loaded[4]
      $data_armors = loaded[5]
      $data_enemies = loaded[6]
      $data_troops = loaded[7]
      $data_states = loaded[8]
      $data_animations = loaded[9]
      $data_tilesets = loaded[10]
      TAG_SYS::system_tags_check #ajout des system_tags manquant dans $data_tilesets
      $data_common_events = loaded[11]
      $data_system = loaded[12]
      $picture_data = loaded[13]
      $game_system = Game_System.new
    end
    
    $splash.dispose
    Graphics.transition(5)
    Graphics.freeze
    # Chargement des données
    $battle_var = POKEMON_S::Pokemon_Battle_Variable.new
    if File.exist?("Options.rxdata")
      $data_system.windowskin_name =$save[3] #chargement du Windowskin
      $message_dummy =$save[4] #Chargement de la boîte des dialogues
    end
    
    if not @auto_load and not MAPINTRO
      if FileTest.exist?("Saves/SaveAuto.rxsav")
        print("Sauvegarde de secours détectée.\n\nAppuyez sur Entrée, puis sur Echap pour charger, ou Entrée pour continuer.")
        loop do
          Input.update
          if Input.trigger?(Input::C)
            File.delete("Saves/SaveAuto.rxsav")
            break
          end
          if Input.trigger?(Input::B)
            @auto_load = true
            break
          end
        end
      end
    
      # -----------------------------------------------------------------
      #     La scène d'intro commence ici (non MAPINTRO)
      # -----------------------------------------------------------------
      # Elle est bien sûr modifiable à votre goût.
      # -----------------------------------------------------------------
      if not $DEBUG
        view = Viewport.new(0,0,640,480)
        view.z = -5
        background = Plane.new(view)
        background.bitmap = RPG::Cache.title(DATA_TITLE[:opening1])
        background.z = 0
        background.tone = Tone.new(0,0,0,255)

        band_top = Sprite.new
        band_top.bitmap = RPG::Cache.title(DATA_TITLE[:opening2])
        band_top.z = 5
        band_bottom = Sprite.new
        band_bottom.bitmap = RPG::Cache.title(DATA_TITLE[:opening2])
        band_bottom.z = 5
        band_bottom.y = 450
        
        band_mid = Plane.new(Viewport.new(0,0,640,480))
        band_mid.bitmap = RPG::Cache.title(DATA_TITLE[:opening3])
        band_mid.z = 5
        
        middle = Sprite.new
        middle.bitmap = RPG::Cache.title(DATA_TITLE[:opening4])
        middle.z = 2
        
        title1 = Sprite.new
        title1.bitmap = RPG::Cache.title(DATA_TITLE[:opening5])
        title1.z = 3
        title1.opacity = 0
        title1.color = Color.new(255,255,255,255)
        
        title2 = Sprite.new
        title2.bitmap = RPG::Cache.title(DATA_TITLE[:opening6])
        title2.z = 4
        title2.opacity = 0
        title2.color = Color.new(255,255,255,255)
        
        flash = Sprite.new
        flash.bitmap = RPG::Cache.title(DATA_TITLE[:opening7])
        flash.z = 10
        flash.opacity = 0
        
        mid = Sprite.new
        mid.bitmap = RPG::Cache.title(DATA_TITLE[:opening8])
        mid.z = 5
        mid.visible = false
        
        screen = Sprite.new
        screen.bitmap = RPG::Cache.title(DATA_TITLE[:opening9])
        screen.z = 2
        screen.visible = false
        
        start = Sprite.new
        start.bitmap = RPG::Cache.title(DATA_TITLE[:opening10])
        start.z = 5
        start.visible = false
        
        Graphics.transition(5)
        
        $game_system.bgm_play($data_system.title_bgm)
        Audio.me_stop
        Audio.bgs_stop
        
        timer = 0
        loop do
          Graphics.update
          Input.update
          
          timer += 1
          background.ox -= 12
          
          if timer == 210
            background.tone.gray = 0
          end
          
          if timer > 210 and background.tone.red > 0
            background.tone.red -= 25
            background.tone.green -= 25
          end
            
          if timer > 210 and timer % (150 + rand(50)) == 0
            background.tone.red = background.tone.green = 250
          end
          
          if flash.opacity > 0
            flash.opacity -= 15
          end
          
          if timer > 5 and not band_top.disposed?
            band_top.x += 13
            if band_top.x > 640
              band_top.dispose
            end
          end
          
          if timer > 73 and not band_bottom.disposed?
            band_bottom.x -= 13
            if band_bottom.x < -640
              band_bottom.dispose
            end
          end
          
          if timer > 150 and not band_mid.disposed?
            band_mid.ox -= 20
            if timer > 210
              band_mid.dispose
              mid.visible = true
            end
          end
          
          if timer > 210 and not title1.disposed? and title1.opacity < 255
            title1.opacity += 15
            title1.color.alpha -= 15
          end
          
          if timer > 240 and not title1.disposed? and title1.opacity == 255
            title1.color.alpha += 15
          end
          
          if timer == 270
            flash.opacity = 255
            title1.dispose
            mid.dispose
            middle.dispose
            screen.visible = true
          end
          
          if timer > 270 and not title2.disposed? and title2.opacity < 255
            title2.opacity += 15
            title2.color.alpha -= 15
            if title2.opacity >= 255
              title2.dispose
            end
          end
          
          if timer > 290 and timer%20 == 0
            start.visible = !start.visible
          end
          
          if Input.trigger?(Input::C)
            $game_system.se_play($data_system.decision_se)
            break
          end
          
          if timer > 3750
            Audio.bgm_fade(1000*5)
          end
          
        end
        
        Graphics.freeze
        background.dispose if not background.disposed?
        band_top.dispose if not band_top.disposed?
        band_bottom.dispose if not band_bottom.disposed?
        band_mid.dispose if not band_mid.disposed?
        mid.dispose if not mid.disposed?
        middle.dispose if not middle.disposed?
        title1.dispose if not title1.disposed?
        title2.dispose if not title2.disposed?
        flash.dispose if not flash.disposed?
        start.dispose if not start.disposed?
        screen.dispose if not screen.disposed?
        Graphics.transition
        Graphics.freeze
        
        Audio.bgm_stop
      end
      
      # -----------------------------------------------------------------
      #     Fin de la scène d'intro
      # -----------------------------------------------------------------
    
    elsif MAPINTRO.is_a?(Array) and $_temp_map_intro == nil
      $_temp_map_intro = true
      $map_link = {}
      Audio.bgm_stop
      Graphics.frame_count = 0
      $game_temp          = Game_Temp.new
      $game_system        = Game_System.new
      $game_switches      = Game_Switches.new
      $game_variables     = Game_Variables.new
      $game_self_switches = Game_SelfSwitches.new
      $game_screen        = Game_Screen.new
      $game_actors        = Game_Actors.new
      $game_party         = Game_Party.new
      $game_troop         = Game_Troop.new
      $game_map           = Game_Map.new
      $game_player        = Game_Player.new
      # ---- Pas forcément nécessaire
      $pokemon_party = POKEMON_S::Pokemon_Party.new
      $data_storage = [[0]]
      $pokemon_party.create_box
      Player.set_trainer_code(rand(2**32))
      $random_encounter = POKEMON_S::Random_Encounter.new
      $random_encounter.update
      $existing_pokemon = []
      $string = []
      POKEMON_S::set_SAVESLOT = @index
      Player.trainer_trade_code
      # ---- Pas forcément nécessaire
      $game_party.setup_starting_members
      $game_map.setup(MAPINTRO[0])
      $game_player.moveto(MAPINTRO[1], MAPINTRO[2])
      $game_player.refresh
      $game_map.autoplay
      $game_map.update
      $scene = Scene_Map.new
      $thread_data.join
      return
    end
    
    Audio.bgm_stop
    $_temp_map_intro = nil
    
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    $thread_data.join
    
    @number = 0 # Nombre de cadres de sauvegarde à générer
    1.upto(MAX_SAUVEGARDES) do |i|
      # Rend compatible les sauvegardes d'avant PSP 1.0 avec ce dernier
      @number += 1 if $pokemon_save.save_exist("Save#{i}")
    end
    
    @new_game_window = Window_Base.new(30, 30 + 83*@number, 580, 80)
    @new_game_window.contents = Bitmap.new(548, 48)
    set_window(@new_game_window)
    @new_game_window.contents.draw_text(9,3,548,48,"NOUVELLE PARTIE")
    
    @save_game_window_list = []
    for i in 1..@number
      window = Window_Base.new(30, 30 + 83*(i-1), 580, 80)
      window.contents = Bitmap.new(548, 48)
      @save_game_window_list.push(window)
    end
    
    @index = 0
    
    @background = Plane.new(Viewport.new(0,0,640,480))
    @background.bitmap = RPG::Cache.picture(DATA_TITLE[:fond_menu])
    @background.z -= 10
    
    refresh_all
    Graphics.transition
    
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    
    Graphics.freeze
    
    @new_game_window.dispose
    @background.dispose
    @save_game_window_list.each { |window| window.dispose }
  end
  
  def update
    if Input.trigger?(Input::DOWN)
      @index += (@index >= @number) ? 0 : 1
      # Mise à jour des déplacements :
      # Déplace les cadres vers le haut si le cadre en-dessous est trop bas
      deplacement_descend = @index > 3 ? -80 * (@index - 3) : 0
      refresh_all(deplacement_descend)
    end
    if Input.trigger?(Input::UP)
      @index -= @index == 0 ? 0 : 1
      # Mise à jour des déplacements :
      # Déplace les cadres vers le bas si le cadre au-dessus est trop haut
      deplacement_monte = @index > 3 ? -80 * (@index - 3) : 0
      refresh_all(deplacement_monte)
    end
    if Input.trigger?(Input::C)
      case @index
      when @number # Nouveau jeu
        if @number == MAX_SAUVEGARDES
          $game_system.se_play($data_system.decision_se)
          @erase = true
          @index = @number
          @new_game_window.contents.clear
          @new_game_window.contents.draw_text(9,3,548,48,"RECOMMENCER QUELLE PARTIE?")
          # Mise à jour des déplacements :
          # Déplace les cadres vers le haut pour afficher de manière visible
          # à l'écran la dernière sauvegarde
          deplacement_end = @index > 3 ? -80 * (@index - 3) : 0
          refresh_all(deplacement_end)
        else
          command_new_game
        end
      else # Chargement
        if @erase
          command_new_game
        else
          $game_temp = Game_Temp.new
          on_decision("Save#{@index + 1}")
        end
      end
    end
    if Input.trigger?(Input::B) and @erase
      $game_system.se_play($data_system.cancel_se)
      @erase = false
      @index = 3
      @new_game_window.contents.clear
      @new_game_window.contents.draw_text(9,3,548,48,"NOUVELLE PARTIE")
      refresh_all
    end
    if @auto_load != nil
      $game_temp = Game_Temp.new
      on_decision("SaveAuto")
      File.delete("Saves/SaveAuto.rxsav")
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
        @save_game_window_list[i].contents.draw_text(9, 3, 530, 48, "CONTINUER PARTIE "+(i+1).to_s)
      elsif i == @index
        @save_game_window_list[i].opacity = 255
        @save_game_window_list[i].y = 30 + 83*i + deplacement
        @save_game_window_list[i].height = 233
        @save_game_window_list[i].contents = Bitmap.new(548, 233)
        set_window(@save_game_window_list[i])
        @save_game_window_list[i].contents.draw_text(9, 3, 530, 48, "CONTINUER PARTIE "+(i+1).to_s)
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
        @save_game_window_list[i].contents.draw_text(9, 3, 548, 48, "CONTINUER PARTIE "+(i+1).to_s)
      end
    end
    if @index == @number
      @new_game_window.opacity = 255
      @new_game_window.y = 30 + 83*@number + deplacement
    else
      @new_game_window.opacity = 128
      @new_game_window.y = 30 + 70 + 83*(@number+1) + deplacement
    end
  end
  
  def set_window(window)
    window.contents.font.name = $fontface
    window.contents.font.size = $fontsizebig
    window.contents.font.color = window.normal_color
  end
  
  # --------------------------------------------------------
  # Chargement
  # --------------------------------------------------------
  # Chargement d'une partie
  # filename : Nom de la sauvegarde
  def load(filename)
    load_save = File.open("Saves/#{filename}.rxsav", 'rb') do |f|
      $pokemon_save = Marshal.load(f)
    end
    # Initialise les variables globales
    $pokemon_save.assignation_var
  end
  
  def read_save_data(filename)
    load(filename)
    $map_link = ($read_data != nil and $read_data[3] != nil) ? $read_data[3] : {}
    if $game_system.magic_number != $data_system.magic_number
      $game_map.setup($game_map.map_id)
      $game_player.center($game_player.x, $game_player.y)
    end
    $game_party.refresh
    POKEMON_S::set_SAVESLOT = @index
    Player.trainer_trade_code
  end
  
  def on_decision(filename)
    unless FileTest.exist?("Saves/#{filename}.rxsav")
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    $game_system.se_play($data_system.load_se)
    read_save_data(filename)
    $game_system.bgm_play($game_system.playing_bgm)
    $game_system.bgs_play($game_system.playing_bgs)
    $game_map.update
    $scene = Scene_Map.new
    $random_encounter.update
    $pokedex.update
  end
  
  alias alias_command_new_game command_new_game
  def command_new_game
    $map_link = {}
    alias_command_new_game
    #-----------------------------------------------------
    # Variables créées automatiquement au début du jeu
    #   Elles sont absolument nécessaires
    #-----------------------------------------------------
    $pokemon_party = POKEMON_S::Pokemon_Party.new
    $data_storage = [[0]]
    $pokemon_party.create_box
    Player.set_trainer_code(rand(2**32))
    $random_encounter = POKEMON_S::Random_Encounter.new
    $random_encounter.update
    $existing_pokemon = []
    $string = []
    POKEMON_S::set_SAVESLOT = @index
    Player.trainer_trade_code
    $pokedex = POKEMON_S::Pokedex.new($data_pokemon.length-1)
  end
end