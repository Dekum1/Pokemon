#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# 20/07/07
#-----------------------------------------------------------------------------
# Pokemon_Battle_Safari - Therand
# 28/12/2014
# Adapté pour Pokémon Brêmo par The--Elric
# Adapté pour PSPEvolved par Damien Linux
# 28/11/2020
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Battle_Safari < Pokemon_Battle_Core
    
    def initialize(pokemon)
      @enemy = pokemon
      
      @phase = 0
      # 0 Non décidé, 1 Attente, 3 Fuite
      @enemy_action = 0
      # 0 Non décidé, 1 BALL, 2 APPAT, 3 BOUE, 4 FUITE
      @actor_action = 0
      
      @nmbrRap = 0
      @nmbrApp = 0
    end
    
    def main
      # Pré-création des Sprites
      # Fond
       coord = $game_player.front_tile
      if $game_player.terrain_tag == 7 or
         ($game_map.terrain_tag(coord[0], coord[1]) == 7 and $game_switches[SUCCES_CANNE])
        @battleback_name = FOND_SURF
        @ground_name = "ground#{ FOND_SURF}"
      elsif @battleback_name != ""
        @battleback_name = "#{$game_map.battleback_name}.png"
        @ground_name = "ground#{ $game_map.battleback_name}.png"
      else
        @battleback_name = DATA_BATTLE[:back_default]
        @ground_name = DATA_BATTLE[:ground_default]
      end
      @z_level = 0
      @background = Sprite.new
      @background.z = @z_level
      
      # Fin de la scène
      @end = false
      
      # Fond du message
      @message_background = Sprite.new
      @message_background.y = 336
      @message_background.z = @z_level + 19
      
      # Sprite de flash
      @flash_sprite = Sprite.new
      @flash_sprite.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
      @flash_sprite.color = Color.new(255,255,255)
      @flash_sprite.opacity = 0
      @flash_sprite.z = @z_level + 13
      
      # Fenetre de texte
      @text_window = Window_Base.new(4, 340, 632, 136)
      @text_window.opacity = 0
      @text_window.z = @z_level + 19
      @text_window.contents = Bitmap.new(600 + 32, 104 + 32)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = $fontsizebig
      
      
      # Fenetre d'action
      s1 = "BALL"
      s2 = "APPAT"
      s3 = "BOUE"
      s4 = "FUITE"
      
      @action_window = Window_Command.new(320, [s1, s2, s3, s4], $fontsizebig, 2, 56)
      @action_window.x = 320
      @action_window.y = 336
      @action_window.z = @z_level + 21
      @action_window.height = 144
      @action_window.active = false
      @action_window.visible = false
      @action_window.index = 0
      
      # Viewport
      battle_viewport = Viewport.new(0, 0, 640, 336)
      battle_viewport.z = @z_level + 15
      
      # Sprites acteurs # Positions par défaut des centres
      @enemy_sprite = Pokemon_Battler.new
      @enemy_sprite.visible = false
      @enemy_sprite.x = 464
      if not @enemy.is_anime
        @enemy_sprite.y = 175
      else
        @enemy_sprite.y = 135
      end
      @enemy_sprite.z = @z_level + 15
      @enemy_ground = RPG::Sprite.new
      @enemy_ground.x = 464
      @enemy_ground.y = 149
      @enemy_ground.z = @z_level + 11
      @actor_ground = RPG::Sprite.new
      @actor_ground.x = 153
      @actor_ground.y = 386
      @actor_ground.z = @z_level + 11
      @actor_sprite = Pokemon_Battler.new
      @actor_sprite.bitmap = RPG::Cache.battler(Player.battler, 0)
      @actor_sprite.visible = false
      @actor_sprite.x = 153
      @actor_sprite.y = 341
      @actor_sprite.z = @z_level + 15
      
      
      #Actor et enemy
      @start_enemy_battler = ""
      
      # Création fenêtre de statut
      @enemy_status = Pokemon_Battle_Status.new(@enemy, true, @z_level + 15)
      @enemy_status.visible = false
      @enemy_caught = false
      
      @actor_status = Trainer_Safari_Status.new
      @actor_status.visible = false
      @actor_status.active = false
      
      # Lancement des animations
      pre_battle_transition
      pre_battle_animation
      
      Graphics.transition
      loop do
        Graphics.update ; $scene.battler_anim
        Input.update
        update
        if @end == true
          break
        end
      end
      
      # Fin de scene
      Graphics.freeze
      @background.dispose
      @message_background.dispose
      @flash_sprite.dispose
      @text_window.dispose
      @action_window.dispose
      @enemy_ground.dispose
      @actor_ground.dispose
      @actor_sprite.dispose
      if @skill_window != nil
        @skills_window.dispose
      end
      if @ball_sprite != nil
        @ball_sprite.dispose
      end
      @enemy_sprite.dispose
      @enemy_status.dispose
      @actor_status.dispose
      Audio.me_stop
      $game_system.bgm_play($game_temp.map_bgm)
      Graphics.freeze
      $scene = Scene_Map.new
    end
    
    def update
      case @phase
      when 0 #initialisation
        @action_window.active = true
        @action_window.visible = true
        draw_text("Que doit faire ", Player.name + " ?")
        @phase = 1
      when 1
        @action_window.update
        if Input.trigger?(Input::C) and @action_window.active
          case @action_window.index
          when 0 #BALL
            if $pokemon_party.item_number(12) > 0
              @action_window.active = false
              @action_window.visible = false
              @item_id = 12
              @actor_action = 1
              $game_system.se_play($data_system.decision_se)
              $pokemon_party.drop_item(12)
              @actor_status.refresh
              if POKEMON_S::Item.data(@item_id)["ball"] and HASH_BALL[@item_id]
                if catch_pokemon
                  @enemy.given_name = @enemy.name
                  @enemy.id_ball = @item_id
                  @end = true
                  # Changement de surnom
                  string1 = "Voulez-vous changer le"
                  string2 = "surnom de " + @enemy.given_name + "?"
                  draw_text(string1, string2)
                  if draw_choice
                    draw_text("")
                    scene = POKEMON_S::Pokemon_Name.new(@enemy, @z_level + 50)
                    scene.main
                  end
                  # Intégration au PC
                  if $pokemon_party.size < 6
                    $pokemon_party.add(@enemy)
                  else
                    $pokemon_party.store_captured(@enemy)
                    string1 = @enemy.given_name
                    string2 = "est envoyé au PC."
                    draw_text(string1, string2)
                    wait(40)
                  end
                  @phase = 0
                else
                  wait_hit
                  @phase = 2
                end
              end
            else
              @action_window.active = false
              @action_window.visible = false
              draw_text("Vous n'avez plus", "de balls !")
              wait_hit
              @phase = 0
            end
          when 1 #APPAT
            @nmbrApp += 1
            @choix_action = 1
            @phase = 2
          when 2 ##BOUE
            @nmbrRap += 1
            @choix_action = 2
            @phase = 2
          when 3 #FUITE
            $game_system.se_play($data_system.escape_se)
            draw_text("Vous prenez la", "fuite!")
            wait_hit
            @end = true
          end
        end
      when 2
        @action_window.active = false
        @action_window.visible = false
        escapeChance = rand(100)
        escapeChance += (5 * @nmbrApp)
        escapeChance -= (@nmbrRap * 3)
        if escapeChance < 0
          escapeChance = 0
        end
        if escapeChance > 100
          escapeChance = 100
        end
        case @choix_action
        when 1
          draw_text("#{Player.name} utilise", "un appat !")
          wait(40)
          launch_appat
        when 2
          draw_text("#{Player.name} lance", "de la boue !")
          wait(40)
          launch_boue
        end
        if escapeChance <= 30
          iaChoice = 0 # S'enfuir
          draw_text(@enemy.name, "prend la fuite !")
          $game_system.se_play($data_system.escape_se)
          wait_hit
          @end = true
        else
          iaChoice = 1 # Rester
          draw_text(@enemy.name + " regarde", "attentivement")
          wait(40)
        end
        @choix_action = 0
        @phase = 0
      end
    end
  
    def pre_battle_transition
      # Jingle et BGM
      if DEFAULT_CONFIGURATION
        index = $game_variables[CONFIGURATION_BATTLE_WILD]
        if DATA_WILD[index] != nil
          graphic = DATA_WILD[index][:graphic]
          nb_transition = DATA_WILD[index][:nb_transition]
          frame = DATA_WILD[index][:frame]
          audio = DATA_WILD[index][:audio]
          volume = DATA_WILD[index][:volume]
          pitch = DATA_WILD[index][:pitch]
        else
          nb_transition = DATA_WILD[-1][:nb_transition]
          frame = DATA_WILD[-1][:frame]
          graphic = DATA_WILD[-1][:graphic]
          audio = DATA_WILD[-1][:audio]
          volume = DATA_WILD[-1][:volume]
          pitch = DATA_WILD[-1][:pitch]
        end
        volume = 100 unless $volume
        pitch = 100 unless $pitch
        Audio.bgm_play("Audio/BGM/#{audio}", volume, pitch)
        if graphic != nil
          s = nb_transition != 0 ? (rand(nb_transition)+1).to_s : ""
          string = "Graphics/Transitions/#{graphic}#{s}.png"
          Graphics.transition(frame, string)
        end
      else
        $game_system.bgm_play($game_system.battle_bgm, 100)
        s = (rand(BATTLE_TRANS)+1).to_s
        graphic = "battle"
        string = "Graphics/Transitions/#{graphic}#{s}.png"
        frame = 80
        Graphics.transition(frame, string)
      end
      Graphics.freeze
      
      # Dessin
      Graphics.freeze
      @background.bitmap = RPG::Cache.battleback(@battleback_name)
      @message_background.bitmap = RPG::Cache.battleback(INFO_MSG)
      @enemy_sprite.bitmap = RPG::Cache.battler(@enemy.battler_face, 0)
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      height = @enemy_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @enemy_sprite.oy = height - height / coef_position
      @enemy_sprite.x -= 782
      @enemy_sprite.color = Color.new(60,60,60,128)
      @enemy_ground.bitmap = RPG::Cache.battleback(@ground_name)
      @enemy_ground.ox = @enemy_ground.bitmap.width / 2
      @enemy_ground.zoom_x = @enemy_ground.zoom_y = 2.0/3
      @enemy_ground.x -= 782
      @actor_ground.bitmap = RPG::Cache.battleback(@ground_name)
      @actor_ground.ox = @actor_ground.bitmap.width / 2
      @actor_ground.oy = @actor_ground.bitmap.height
      @actor_ground.x += 782
      @actor_sprite.visible = true
      @actor_sprite.bitmap = RPG::Cache.battler(Player.battler, 0)
      @actor_sprite.ox = @actor_sprite.bitmap.width / 2
      @actor_sprite.oy = @actor_sprite.bitmap.height
      @actor_sprite.x += 782
      Graphics.transition(frame, string) if graphic != nil
    end
    
    def launch_appat
      @appat_sprite = Sprite.new
      @appat_sprite.bitmap = RPG::Cache.picture(DATA_BATTLE_SAFARI[:appat])
      @appat_sprite.x = -25
      @appat_sprite.y = 270
      @appat_sprite.z = @z_level + 16
      t = 153
      pi = Math::PI
      loop do
        t += 16
        @appat_sprite.y = (270.0 - 130.0 * Math.sin(2 * pi / 3.0 * t / 445.0)).to_i
        @appat_sprite.x = -15 + t
        Graphics.update ; $scene.battler_anim
        if @appat_sprite.x >= 445
          break
        end
      end
      @appat_sprite.dispose
    end

    def launch_boue
      @boue_sprite = Sprite.new
      @boue_sprite.bitmap = RPG::Cache.picture(DATA_BATTLE_SAFARI[:boue])
      @boue_sprite.x = -25
      @boue_sprite.y = 270
      @boue_sprite.z = @z_level + 16
      t = 153
      pi = Math::PI
      loop do
        t += 16
        @boue_sprite.y = (270.0 - 130.0 * Math.sin(2 * pi / 3.0 * t / 445.0)).to_i
        @boue_sprite.x = -15 + t
        Graphics.update ; $scene.battler_anim
        if @boue_sprite.x >= 445
          break
        end
      end
      @boue_sprite.dispose
    end
      
    def actor_item_use # items à utiliser
      # Item déjà utilisé ie remplacé par 0
      if @item_id == 0
        return
      end
      if POKEMON_S::Item.data(@item_id)["flee"] != nil
        end_battle_flee
        return
      end
      if POKEMON_S::Item.data(@item_id)["ball"] and HASH_BALL[@item_id]
        if catch_pokemon
          @enemy.given_name = @enemy.name
          @enemy.id_ball = @item_id
          # Changement de surnom
          draw_text("Voulez-vous donner un", "surnom à #{@enemy.given_name} ?")
          if draw_choice
            draw_text("")
            scene = POKEMON_S::Pokemon_Name.new(@enemy, @z_level + 50)
            scene.main
          end
          # Intégration au PC
          if $pokemon_party.size < 6
            $pokemon_party.add(@enemy)
          else
            $pokemon_party.store_captured(@enemy)
            string1 = @enemy.given_name
            string2 = "est envoyé au PC."
            draw_text(string1, string2)
            wait(40)
          end
          $battle_var.result_win = true
          end_battle
        end
      end
    end

    #------------------------------------------------------------  
    # Lancer de pokéball
    #------------------------------------------------------------         
    def catch_pokemon
      # Initialisation des données
      ball = Pokemon_Object_Ball.new
      ball_name = Pokemon_Object_Ball.name(@item_id)
      ball_sprite = Pokemon_Object_Ball.sprite_name(@item_id)
      ball_open_sprite = Pokemon_Object_Ball.open_sprite_name(@item_id)
      ball_color = Pokemon_Object_Ball.color(@item_id)      
      
      oscillation_number = ball.catch_pokemon(@item_id, @actor, @enemy, [@nmbrRap, @nmbrApp])
      
      # Procédure / Animation
      # Lancer
      draw_text(Player.name + " utilise une", ball_name + " !")
      @ball_sprite = Sprite.new
      @ball_sprite.bitmap = RPG::Cache.picture(ball_sprite)
      @ball_sprite.x = -25
      @ball_sprite.y = 270
      @ball_sprite.z = @z_level + 16
      @ball_sprite.mirror = true
      t = 0.0
      pi = Math::PI
      loop do
        t += 16
        calcul = Math.sin(2 * pi / 3.0 * t / 445.0)
        @ball_sprite.y = (270.0 - 230.0 * calcul).to_i
        @ball_sprite.x = -15 + t
        $scene.battler_anim ; Graphics.update
        if @ball_sprite.x >= 445
          @ball_sprite.bitmap = RPG::Cache.picture(ball_open_sprite)
          break
        end
      end
      
      count = oscillation_number
      $scene.battler_anim ; Graphics.update
      # Rejet
      if $game_switches[INTERDICTION_CAPTURE]
        draw_text("Capture impossible !")
        Audio.se_stop
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:open_break]}")
        
        t = 0
        loop do
          t += 1
          @ball_sprite.x -= -20
          @ball_sprite.y += t
          $scene.battler_anim ; Graphics.update
          if t == 10
            @ball_sprite.dispose
            break
          end
        end
        
        wait(40)
        
        return false
      end      
      
      # "Aspiration"
      @enemy_sprite.color = ball_color
      @enemy_sprite.color.alpha = 0
      @ball_sprite.z -= 2
      until @enemy_sprite.color.alpha >= 255
        @flash_sprite.opacity += 50
        @enemy_sprite.color.alpha += 50
        $scene.battler_anim ; Graphics.update
      end
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:recall_pokemon]}")
      loop do
        @enemy_sprite.zoom_x -= 0.1
        @enemy_sprite.zoom_y -= 0.1
        @enemy_sprite.opacity -= 25
        @flash_sprite.opacity -= 25
        $scene.battler_anim ; Graphics.update
        if @enemy_sprite.zoom_x <= 0.1
          @flash_sprite.opacity = 0
          @enemy_sprite.opacity = 0
          break
        end
      end
      @ball_sprite.bitmap = RPG::Cache.picture(ball_sprite)
      
      # Descente de la ball + rebond
      t = 0
      r = 0
      loop do
        t += 1
        calcul = 1-Math.exp(-t/20.0)*(Math.cos(t*2*pi/30.0)).abs
        @ball_sprite.y = 81 + 75*calcul
        if @ball_sprite.y >= 81+45 and r < 6
          r += 1
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:pokeball_capture]}")
        end
        $scene.battler_anim ; Graphics.update
        if t >= 60
          break
        end
      end

      # Oscillement
      width = @ball_sprite.bitmap.width
      height = @ball_sprite.bitmap.height
      @ball_sprite.x += width / 2
      @ball_sprite.y += height / 2
      @ball_sprite.ox = width / 2
      @ball_sprite.oy = height / 2
      while count > 0
        count -= 1
        t = 0
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:pokeball_move]}")
        loop do
          t += 4
          @ball_sprite.angle = 30*Math.sin(2*pi*t/100.0)          
          $scene.battler_anim ; Graphics.update          
          if t == 100
            wait(15)
            @ball_sprite.angle = 0
            break
          end
        end
      end
      
      if oscillation_number != 4
        # Echappé
        @ball_sprite.bitmap = RPG::Cache.picture(ball_open_sprite)
        @ball_sprite.y -= 16
        @ball_sprite.z -= 1
        Audio.se_stop
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:open_break]}")
        @enemy_sprite.oy = @enemy_sprite.bitmap.height
        @enemy_sprite.y += @enemy_sprite.bitmap.height / 2
        loop do
          @enemy_sprite.opacity += 25
          @enemy_sprite.zoom_x += 1
          @enemy_sprite.zoom_y += 1
          @ball_sprite.opacity -= 25
          @flash_sprite.opacity += 25
          $scene.battler_anim ; Graphics.update
          if @enemy_sprite.zoom_x >= 0
            height = @enemy_sprite.bitmap.height
            coef_position = height / (height * 0.16 + 14)
            @enemy_sprite.oy = height - height / coef_position
            @enemy_sprite.y -= @enemy_sprite.bitmap.height / 2
            $scene.battler_anim ; Graphics.update
            @ball_sprite.dispose
            break
          end
        end
        until @enemy_sprite.color.alpha <= 0
          @enemy_sprite.color.alpha -= 25
          @flash_sprite.opacity -= 25
          $scene.battler_anim ; Graphics.update
        end
        @enemy_sprite.color.alpha = 0
        @enemy_sprite.opacity = 255
        @flash_sprite.opacity = 0
        $scene.battler_anim ; Graphics.update
        
        string1 = oscillation_number == 3 ? "Mince !" : oscillation_number == 2 ? "Aaaah !" : 
          oscillation_number == 1 ? "Raah !" : "Oh non !"
        string2 = oscillation_number == 3 ? "Ca y était presque !" : 
          oscillation_number == 2 ? "Presque !" : oscillation_number == 1 ? "Ca y était presque !" : "Le Pokémon s'est libéré !"
        draw_text(string1, string2)
        wait(40)
      else
        # Attrapé
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:capturer_pokemon]}")
        @enemy = ball.effect_ball(@item_id, @enemy)
        @enemy_caught = true
        draw_text("Et hop ! " + @enemy.given_name , "est attrapé !")
        wait(90)
        wait_hit
        unless $pokedex.captured?(@enemy.id)
          draw_text("#{@enemy.name} est ajouté", "au Pokédex.")
          wait(20)
          wait_hit
          $pokedex.add(@enemy)
          scene = POKEMON_S::Pokemon_Detail.new(@enemy.id, 0, :combat , 9999)
          scene.main          
          wait(40) 
          wait_hit
          Graphics.transition 
          wait(10)          
        end
        until @ball_sprite.opacity <= 0
          @ball_sprite.opacity -= 25
          $scene.battler_anim ; Graphics.update
        end
      end
      if oscillation_number != 4
        return false
      elsif oscillation_number == 4
        return true
      end
    end

    
    def wait_hit
      loop do
        Graphics.update ; $scene.battler_anim
        Input.update
        if input
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
    end
    
    def wait(frame)
      i = 0
      loop do
        i += 1
        Graphics.update ; $scene.battler_anim
        if i >= frame
          break
        end
      end
    end
    
    def input
      if Input.trigger?(Input::C) or Input.trigger?(Input::B) or
        Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN) or
        Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
        return true
      end
      return false
    end
    
    def draw_choice
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsizebig)
      @command.x = 517
      @command.y = 215
      loop do
        Graphics.update ; $scene.battler_anim
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          $game_system.se_play($data_system.decision_se)
          @command.dispose
          @command = nil
          Input.update
          return true
        end
        if Input.trigger?(Input::C) and @command.index == 1
          $game_system.se_play($data_system.decision_se)
          @command.dispose
          @command = nil
          Input.update
          return false
        end
      end
    end
    
    def pre_battle_animation
      # Glissement des sprites
      loop do
        @enemy_sprite.x += 17
        @enemy_ground.x += 17
        @actor_sprite.x -= 17
        @actor_ground.x -= 17
        Graphics.update ; $scene.battler_anim
        @enemy_sprite.visible = true
        if @enemy_sprite.x == 464
          until @enemy_sprite.color.alpha <= 0
            @enemy_sprite.color.alpha -= 20
            Graphics.update ; $scene.battler_anim
          end
          break
        end
      end
      
      # Texte
      draw_text("Un " + @enemy.given_name, "apparait!")
      if FileTest.exist?(@enemy.cry)
        Audio.se_play(@enemy.cry)
      end
      
      # Arrivé du panel de l'adversaire
      @enemy_status.x -= 300
      @enemy_status.visible = true
      if @enemy.shiny
        animation = $data_animations[496]
        @enemy_sprite.animation(animation, true)
      end
      
      @actor_status.x = 730
      @actor_status.visible = true
      
      loop do
        if @enemy_status.x != 23
          @enemy_sprite.x -= 3*(-1)**(@enemy_sprite.x)
          @enemy_status.x += 20
          @enemy_sprite.update
        end
        Graphics.update ; $scene.battler_anim
        if @actor_status.x != 370
          @actor_status.x -= 20
        end
        if @enemy_status.x == 23 and @actor_status.x == 370
          until not(@enemy_sprite.effect?)
            @enemy_sprite.update
            Graphics.update ; $scene.battler_anim
          end
          @enemy_sprite.x = 464
          break
        end
      end
      
      # Attente appui de touche
      loop do
        Graphics.update ; $scene.battler_anim
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
      
      @text_window.contents.clear
      Graphics.update ; $scene.battler_anim
    end
    
    def draw_text(line1 = "", line2 = "")
      if line1.type == Array
        if line1[1] != nil
          draw_text(line1[0], line1[1])
        else
          draw_text(line1[0])
        end
      else
        Graphics.freeze
        @text_window.contents.clear
        @text_window.draw_text(12, 0, 460, 50, line1)
        @text_window.draw_text(12, 55, 460, 50, line2)
        Graphics.transition(5)
      end
    end
  end
end