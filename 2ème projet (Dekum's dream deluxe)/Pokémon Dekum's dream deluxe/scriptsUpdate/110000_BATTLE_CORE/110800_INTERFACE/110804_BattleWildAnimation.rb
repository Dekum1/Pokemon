#==============================================================================
# ■ Pokemon_Battle_Wild
# Pokemon Script Project - Krosk 
# 20/07/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
# Restructuré par Damien Linux
# 14/01/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Pokémon Sauvage
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# $battle_var.action_id
#   0 : Phase de Sélection
#   1 : Sélection Item
#   2 : Switch Pokémon
#   4 : Switch Fin de Tour
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Wild
  # - Animations pré-combat
  #------------------------------------------------------------  
  class Pokemon_Battle_Wild < Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Animations pré-combat
    #------------------------------------------------------------  
    def pre_battle_transition
      # Jingle et BGM
      Graphics.freeze
      
      # Sélection transition
      @background.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
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
      Audio.me_stop
      
      # Dessin
      Graphics.freeze
      @background.bitmap = RPG::Cache.battleback(@battleback_name)
      @message_background.bitmap = RPG::Cache.battleback(BATTLE_MSG)
      if $game_switches[SWITCH_EXTERIEUR]
        if $game_variables[TS_NIGHTDAY] == :night
          @background.color = Color.new(0,0,60,128)
          @enemy_ground.color = Color.new(0,0,60,128)
          @actor_ground.color = Color.new(0,0,60,128)
        elsif $game_variables[TS_NIGHTDAY] == :sunset
          @background.color = Color.new(50,0,0,50)
          @enemy_ground.color = Color.new(50,0,0,50)
          @actor_ground.color = Color.new(50,0,0,50)
        elsif $game_variables[TS_NIGHTDAY] == :morning
          @background.color = Color.new(0,0,60,70)
          @enemy_ground.color = Color.new(0,0,60,70)
          @actor_ground.color = Color.new(0,0,60,70)
        else
          @background.color = Color.new(255,255,255,0)
          @enemy_ground.color = Color.new(255,255,255,0)
          @actor_ground.color = Color.new(255,255,255,0)
        end
      end
      @enemy_sprite.bitmap = RPG::Cache.battler(@start_enemy_battler, 0)
      if not @enemy.is_anime
        @enemy_sprite.y = 175
      else
        @enemy_sprite.y = 135
      end
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      height = @enemy_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @enemy_sprite.oy = height - height / coef_position
      @enemy_sprite.x -= 782
      @enemy_sprite.color = Color.new(60,60,60,128)
      @enemy_ground.bitmap = RPG::Cache.battleback(@ground_name)
      @enemy_ground.ox = @enemy_ground.bitmap.width / 2
      @enemy_ground.oy = @enemy_ground.bitmap.height / 2
      @enemy_ground.zoom_x = @enemy_ground.zoom_y = 2.0/3
      @enemy_ground.x -= 782
      @actor_ground.bitmap = RPG::Cache.battleback(@ground_name)
      @actor_ground.ox = @actor_ground.bitmap.width / 2
      @actor_ground.oy = @actor_ground.bitmap.height
      @actor_ground.x += 782
      @actor_sprite.bitmap = RPG::Cache.battler(@start_actor_battler, 0)
      @actor_sprite.ox = @actor_sprite.bitmap.width / 2
      height = @actor_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @actor_sprite.oy = height - height / coef_position
      @actor_sprite.x += 782
      Graphics.transition(frame, string) if graphic != nil
    end
    
    def pre_battle_animation
      # Glissement des sprites
      loop do
        @enemy_sprite.x += 17
        @enemy_ground.x += 17
        @actor_sprite.x -= 17
        @actor_ground.x -= 17
        $scene.battler_anim ; Graphics.update
        @enemy_sprite.visible = true
        if @enemy_sprite.x == 464
          until @enemy_sprite.color.alpha <= 0
            @enemy_sprite.color.alpha -= 20
            $scene.battler_anim ; Graphics.update
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
      loop do
        @enemy_sprite.x -= 3*(-1)**(@enemy_sprite.x)
        @enemy_status.x += 20
        @enemy_sprite.update
        $scene.battler_anim ; Graphics.update
        if @enemy_status.x == 23
          until not(@enemy_sprite.effect?)
            @enemy_sprite.update
            $scene.battler_anim ; Graphics.update
          end
          @enemy_sprite.x = 464
          break
        end
      end
      
      # Attente appui de touche
      loop do
        $scene.battler_anim ; Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
      
      # Dégagement du sprite dresseur
      loop do
        @actor_sprite.x -= 20
        $scene.battler_anim ; Graphics.update
        if @actor_sprite.x <= -200
          # Récupère les détails de l'illusion
          actor_illusion = @actor.get_illusion
          if actor_illusion == nil
            @actor_sprite.bitmap = RPG::Cache.battler(@actor.battler_back, 0)
          else
            # CAS DE LA CAPACITE SPECIAL : Illusion
            @actor.illusion=(@party.actors[@party.size - 1])
            @actor_sprite.bitmap = RPG::Cache.battler(actor_illusion.battler_back, 
                                                      0)
          end
          # Envoi du pokémon (animation)
          if actor_illusion != nil
            launch_pokemon(actor_illusion)
          else
            launch_pokemon(@actor)
          end
          break
        end
      end
      @text_window.contents.clear
      $scene.battler_anim ; Graphics.update
    end
  end
end