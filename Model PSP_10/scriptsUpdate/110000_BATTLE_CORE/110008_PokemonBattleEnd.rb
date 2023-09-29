#==============================================================================
# ■ Pokemon_Battle_Core
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
  # Pokemon_Battle_Core
  # Déroulement de la fin d'un combat :
  # - Fin de combat - Général
  # - Fin de combat par fuite de l'acteur
  # - Fin de combat par fuite de l'ennemie
  # - Fin de combat par défaite
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Fin de combat - Général
    #------------------------------------------------------------      
    def end_battle(result = 0)
      clear_mega # méga
      $pokemon_party.actors.each do |actor|
        actor.ability = actor.save_ability if actor.save_ability != nil
        actor.save_ability = nil
        actor.item_hold = actor.save_item if actor.save_item != nil
        actor.save_item = nil
        actor.re_etablish_transform_effect if actor.save_transform != nil
        actor.save_transform = nil
      end
      $battle_var.enemy_party.actors.each do |enemy|
        enemy.item_hold = enemy.save_item if enemy.save_item != nil
        enemy.ability = enemy.save_ability if enemy.save_ability != nil
        enemy.save_ability = nil
        enemy.save_item = nil
        enemy.re_etablish_transform_effect if actor.save_transform != nil
        enemy.save_transform = nil
      end
      @user_group = nil
      @actor.round = 0
      @enemy.round = 0
      pickup if result == 0
      # Si la variable est définie, alors doit rétablir le niveau initial
      # avant le début du combat
      if $game_variables[LEVEL_TOUR_COMBAT] > 0
        refresh_level(true)
      end
      reset_illusion(@actor)
      reset_illusion(@enemy)
      # Reset des variables et effets
      $battle_var.reset
      reset_party(@party)
      @actor.cure_state
      @actor.ability_active = false
      reset_party($battle_var.enemy_party)
      @enemy.cure_state
      @enemy.ability_active = false
      
      # -----------------------------------
      Audio.me_stop
      wait(10)
      $game_system.bgm_play($game_temp.map_bgm)
      wait(10)
      Graphics.freeze
      # -----------------------------------
      if $game_temp.battle_proc != nil
        $game_temp.battle_proc.call(result)
        $game_temp.battle_proc = nil
      end
      # Défaite
      $scene = Scene_Map.new
    end
    
    #------------------------------------------------------------  
    # Fin de combat par fuite de l'acteur
    #------------------------------------------------------------  
    def end_battle_flee(expulsion = false)
      $battle_var.result_flee = true
      $game_system.se_play($data_system.escape_se)
      if expulsion
        draw_text(@actor.given_name, "est expulsé du combat !")
        loop do
          if @actor_sprite.x > -160
            @actor_sprite.x -= 20
          end
          $scene.battler_anim ; Graphics.update
          Input.update
          if @actor_sprite.x <= -160
            wait(40)
            break
          end
        end
      else
        draw_text("Vous prenez la fuite !")
        wait(40)
      end
      end_battle(1)
    end
    
    #------------------------------------------------------------  
    # Fin de combat par fuite de l'ennemie
    #------------------------------------------------------------
    def end_battle_flee_enemy(expulsion = false)
      $battle_var.result_flee = true
      $game_system.se_play($data_system.escape_se)
      if expulsion
        draw_text(@enemy.given_name, "est expulsé du combat !")
      else
        draw_text(@enemy.given_name + " s'échappe !")
      end
      loop do
        if @enemy_sprite.x < 800
          @enemy_sprite.x += 20
        end
        $scene.battler_anim ; Graphics.update
        Input.update
        if @enemy_sprite.x >= 800
          wait(40)
          break
        end
      end
      end_battle(1)
    end
    
    #------------------------------------------------------------  
    # Fin de combat par défaite
    #------------------------------------------------------------
    def end_battle_defeat
      $battle_var.result_defeat = true
      draw_text("Tous vos Pokémons", "ont été vaincus !")
      wait(40)
      $pokemon_party.money /= 2
      if not(@lose)
        if $game_variables[MAP_ID] == 0
          print("Réglez votre point de retour !")
        else
          $game_map.setup($game_variables[MAP_ID])
          $game_map.display_x = $game_variables[MAP_X]
          $game_map.display_y = $game_variables[MAP_Y]
          $game_player.moveto($game_variables[MAP_X], $game_variables[MAP_Y])
        end
        $game_temp.common_event_id = 2
      end
      $game_temp.map_bgm = $game_map.bgm
      end_battle(2)
    end
  end
end