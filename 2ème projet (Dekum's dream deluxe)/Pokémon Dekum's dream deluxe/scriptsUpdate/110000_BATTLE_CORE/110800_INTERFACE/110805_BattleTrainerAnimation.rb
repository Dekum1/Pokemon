#==============================================================================
# ■ Pokemon_Battle_Trainer
# Pokemon Script Project - Krosk 
# 29/09/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
# end_battle_text_audio_method : Nuri Yuri, ajout de l'audio par Damien Linux
#-----------------------------------------------------------------------------
# Restructuré par Damien Linux
# 14/01/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Pokémon Dresseur
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
#   4 : Switch Fin de Tour
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Trainer
  # - Animations pré-combat
  #------------------------------------------------------------ 
  class Pokemon_Battle_Trainer < Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Animations pré-combat
    #------------------------------------------------------------  
    def pre_battle_transition
      # Jingle et BGM
      if DEFAULT_CONFIGURATION
        index = $game_variables[CONFIGURATION_BATTLE_TRAINER]
        if DATA_TRAINERS_AUDIO_GRAPHIC[index] != nil
          graphic = DATA_TRAINERS_AUDIO_GRAPHIC[index][:graphic]
          nb_transition = DATA_TRAINERS_AUDIO_GRAPHIC[index][:nb_transition]
          frame = DATA_TRAINERS_AUDIO_GRAPHIC[index][:frame]
          audio = DATA_TRAINERS_AUDIO_GRAPHIC[index][:audio]
          volume = DATA_TRAINERS_AUDIO_GRAPHIC[index][:volume]
          pitch = DATA_TRAINERS_AUDIO_GRAPHIC[index][:pitch]
        else
          nb_transition = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:nb_transition]
          frame = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:frame]
          graphic = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:graphic]
          audio = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:audio]
          volume = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:volume]
          pitch = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:pitch]
        end
        volume = 100 unless volume
        pitch = 100 unless pitch
        Audio.bgm_play("Audio/BGM/#{audio}", volume, pitch)
        if graphic != nil
          s = nb_transition != 0 ? (rand(nb_transition)+1).to_s : ""
          string = "Graphics/Transitions/#{graphic}#{s}.png"
          Graphics.transition(frame, string)
        end
      else
        $game_system.bgm_play($game_system.battle_bgm, 80)
        s = (rand(BATTLE_TRANS)+1).to_s
        graphic = "battle"
        string = "Graphics/Transitions/#{graphic}#{s}.png"
        frame = 100
        Graphics.transition(frame, string)
      end
      Graphics.freeze
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
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      height = @enemy_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @enemy_sprite.oy = height - height / coef_position - 10
      @enemy_sprite.x -= 782
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
      $scene.battler_anim
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
          break
        end
      end
      
      # Confrontation des joueurs avec affichage des balls
      draw_text("Un combat est lancé", 
                "par #{Trainer_Info.string(@trainer_id)} !")
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:affichage_equipe]}")
      @actor_party_status.reset_position
      @enemy_party_status.reset_position
      @actor_party_status.visible = true
      @enemy_party_status.visible = true
      @actor_party_status.active = true
      @enemy_party_status.active = true
      @actor_party_status.x += 400
      @enemy_party_status.x -= 400
      $scene.battler_anim ; Graphics.update
      
      loop do
        @actor_party_status.x -= 20
        @enemy_party_status.x += 20
        $scene.battler_anim ; Graphics.update
        if @actor_party_status.x <= 309
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:affichage_equipe]}")
          @actor_party_status.reset_position
          @enemy_party_status.reset_position
          break
        end
      end
      wait_hit
      
      # Dégagement sprite dresseur
      loop do
        @enemy_sprite.x += 10
        @enemy_party_status.x -= 20
        $scene.battler_anim ; Graphics.update
        if @enemy_sprite.x >= 723
          @enemy_party_status.visible = false
          @enemy_party_status.reset_position
          break
        end
      end
      
      # Récupération des détails de l'illusion
      enemy_illusion = @enemy.get_illusion
      if enemy_illusion == nil
        @enemy_sprite.bitmap = RPG::Cache.battler(@enemy.battler_face, 0)
        # Envoi sprite
        launch_enemy_pokemon(@enemy)
      else
        # CAS DE LA CAPACITE SPECIAL : Illusion
        @enemy_sprite.bitmap = RPG::Cache.battler(enemy_illusion.battler_face, 0)
        # Envoi sprite
        launch_enemy_pokemon(enemy_illusion)
      end
      
      # Attente appui de touche
      wait(40)
      
      # Dégagement du sprite dresseur
      @actor_party_status.reset_position
      loop do
        @actor_sprite.x -= 10
        @actor_party_status.x += 20
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
          @actor_party_status.reset_position
          @actor_party_status.visible = false
          break
        end
      end
      
      actor_illusion ||= @actor.get_illusion
      # Envoi du pokémon (animation)
      if actor_illusion != nil
        launch_pokemon(actor_illusion)
      else
        launch_pokemon(@actor)
      end
      @text_window.contents.clear
      $scene.battler_anim ; Graphics.update
    end
  end
end