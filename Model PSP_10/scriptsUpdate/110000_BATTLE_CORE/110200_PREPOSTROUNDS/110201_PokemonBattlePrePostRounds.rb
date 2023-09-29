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
# 02/11/19 et 04/01/2020
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
  # Phase de passage d'un round à un autre (ou début du 1er round)
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Post_round
    #------------------------------------------------------------         
    def pre_post_round_effect
      return if $battle_var.battle_end? or $battle_var.enemy_party.dead?
      # --------- -------------- --------------------
      # Fin des effets "at the end of a round"
      # --------- -------------- --------------------      
      # Suppression état apeuré (ne dure que un tour)
      @actor.flinch_check
      @enemy.flinch_check
      # Suppression état autre
      if @actor.dead?
        @actor.cure
        @actor.cure_state
      end
      if @enemy.dead?
        @enemy.cure
        @enemy.cure_state
      end
      
      # --------- -------------- --------------------
      # Programmation des attaques en Post-round
      # --------- -------------- --------------------
      #      Cycle commun 0 - Souhait et Météo
      # --------- -------------- --------------------
      post_round_cycle0
      
      # --------- -------------- --------------------
      #         Cycle individuel 1
      #      Programmation des attaques
      #           Effets du statut
      # --------- -------------- -------------------- 
      $battle_var.round ||= 0     
      if $battle_var.round > 0
        if @strike_first
          post_round_cycle_1(@actor, @enemy)
          post_round_cycle_1(@enemy, @actor)
        else
          post_round_cycle_1(@enemy, @actor)
          post_round_cycle_1(@actor, @enemy)
        end
      end
      
      # Round suivant
      $battle_var.round += 1
      end_battle_check
      return if $battle_var.battle_end?
      @actor.statistic_refresh_modif
      @enemy.statistic_refresh_modif
      @actor.round += 1
      @enemy.round += 1
      
      # --------- -------------- --------------------
      #                Cycle 2
      #         Programmation des attaques
      #            Dommages finaux
      #        Définition du round suivant
      # --------- -------------- --------------------
      if @strike_first
        post_round_cycle_2(@actor, @enemy)
        post_round_cycle_2(@enemy, @actor)
      else
        post_round_cycle_2(@enemy, @actor)
        post_round_cycle_2(@actor, @enemy)
      end
      
      @actor.skill_effect_clean  
      @enemy.skill_effect_clean
      
      faint_check
      
      # CAS DE LA CAPACITE SPECIALE : Lunatique
      users = [@actor, @enemy]
      users.each do |user|
        if $battle_var.round > 1 and user.ability_symbol == :lunatique
          # i = 1 => Augmentation : +2 / i = 2 => Réduction : -1
          1.upto(2) do |i|
            bonus = i == 1 ? 2 : -1
            random_stat = rand(7).to_i
            case random_stat
            when 0
              n = user.change_atk(bonus)
              string = "ATK"
            when 1
              n = user.change_dfe(bonus)
              string = "DFE"
            when 2
              n = user.change_spd(bonus)
              string = "SPD"
            when 3
              n = user.change_ats(bonus)
              string = "ATS"
            when 4
              n = user.change_dfs(bonus)
              string = "DFS"
            when 5
              n = user.change_acc(bonus)
              string = "ACC"
            when 6
              n = user.change_eva(bonus)
              string = "EVA"
            end
            if n > 0
              raise_stat(string, user, n)
            elsif n < 0
              reduce_stat(string, user, n)
            end
          end
        end
      end
    end
    
    
    # --------- -------------- --------------------
    #     Cycle commun 0 - Météo et Souhait
    # --------- -------------- --------------------
    def post_round_cycle0
      if @strike_first
        list = [[@actor, @actor_sprite, @actor_status], 
                [@enemy, @enemy_sprite, @enemy_status]]
      else 
        list = [[@enemy, @enemy_sprite, @enemy_status], 
                [@actor, @actor_sprite, @actor_status]]
      end
      
      # Suppression du contrôle pour un pokémon mort
      list.each do |array|
        if array[0].dead?
          list.delete(array)
        end
      end
      
      list.each do |array|
        actor = array[0]
        actor.skill_effect_end_turn
        actor.effect_list.each do |effect|
          execution(effect, "pre_post_multi", actor)
          # CAPACITE SPECIALE : Corps Maudit
          if effect == :corps_maudit
            index = actor.effect_list.index(:corps_maudit)
            if actor.effect[index][1] == 0
              skill_id = actor.effect[index][2]
              skill = actor.skills_set[skill_id]
              skill.enable
              draw_text("#{skill.name} de #{actor.given_name}", "est rétablie!")
              wait(40)
            end
          end
        end
      end
      
      0.upto(@user_group.size - 1) do |i|
        if @user_group[i][0] != @actor and @user_group[i][0] != @enemy
          @user_group[i][0].skill_effect_end_turn
        end
      end
      
      weather = $battle_var.weather[0]
      $battle_var.weather[1] -= 1
      count = $battle_var.weather[1]
      
      
      # Souhait -- Programmation des attaques
      souvenirs(list)
      # Pluie
      pluie(list, count)
      # Ensoleillé
      soleil(list, count)
      # Tempete de sable
      tempete_sable(list, count)
      # Grêle
      grele(list, count)
    end

    # --------- -------------- --------------------
    #              Cycle individuel 1
    # --------- -------------- -------------------- 
    def post_round_cycle_1(actor, enemy)
      if actor == @actor
        actor_status = @actor_status
        actor_sprite = @actor_sprite
        enemy_status = @enemy_status
        enemy_sprite = @enemy_sprite
      elsif actor == @enemy
        actor_status = @enemy_status
        actor_sprite = @enemy_sprite
        enemy_status = @actor_status
        enemy_sprite = @actor_sprite
      end
      
      # Suppression du contrôle pour un Pokémon K.O.
      faint_check
      return if actor.dead?
      
      # --------- -------------- --------------------
      #    Programmation des attaques et des capa
      # --------- -------------- --------------------
      actor_list = [actor, actor_status, actor_sprite]
      enemy_list = [enemy, enemy_status, enemy_sprite]
      actor.effect_list.each do |effect|
        execution(effect, "pre_post_soin", actor_list, enemy_list)
      end
      
      unless actor.effect_list.include?(:suc_digestif) or 
             actor.effect_list.include?(:soucigraine)
        execution(actor.ability_symbol, "pre_post_guerison", actor_list, 
                  enemy_list)
      end
      
      enemy.effect_list.each do |effect|
        execution(effect, "pre_post_enemy_piege", actor_list, enemy_list)
      end
      
      faint_check
      return if actor.dead?
      
      # --------- -------------- --------------------
      #          Inspection des statuts
      # --------- -------------- --------------------
      if actor.status == 1 # Poison
        empoisonnement(actor)
      elsif actor.status == 8 # Toxic
        empoisonnement_fort(actor)
      elsif actor.status == 3 # Brulure
        brulure(actor)
      end
      
      actor.confuse_decrement
      faint_check
      return if actor.dead?
      
      # --------- -------------- --------------------
      #         Programmation des attaques
      # --------- -------------- --------------------      
      actor.effect_list.each do |effect|
        execution(effect, "pre_post_secondaire", actor_list, enemy_list)
      end
      
      faint_check
      return if actor.dead?
      # --------- -------------- --------------------
      #                  Berry check
      # --------- -------------- --------------------  
      if POKEMON_S::Item.data(actor.item_hold)["leftovers"] and actor.hp != actor.max_hp
        draw_text("#{actor.given_name} récupère un peu", 
                  "de vie avec #{Item.name(actor.item_hold)}.")
        bonus = actor.max_hp / 16
        if bonus == 0
          bonus = 1
        end
        heal(actor, actor_sprite, actor_status, bonus)
        wait(40)
      end
    end
      
    # --------- -------------- --------------------
    #              Cycle individuel 2
    # --------- -------------- --------------------     
    def post_round_cycle_2(actor, enemy)
      # Redéfinition
      if actor == @actor
        actor_status = @actor_status
        actor_sprite = @actor_sprite
        enemy_status = @enemy_status
        enemy_sprite = @enemy_sprite
      elsif actor == @enemy
        actor_status = @enemy_status
        actor_sprite = @enemy_sprite
        enemy_status = @actor_status
        enemy_sprite = @actor_sprite
      end
      actor_list = [actor, actor_status, actor_sprite]
      enemy_list = [enemy, enemy_status, enemy_sprite]
      # Suppression du contrôle pour un pokémon mort
      return if actor.dead?
      
      # --------- -------------- --------------------
      #         Programmation des capacités
      # --------- -------------- --------------------
      unless actor.effect_list.include?(:suc_digestif) or 
             actor.effect_list.include?(:soucigraine)
        execution(actor.ability_symbol, "pre_post", actor_list, enemy_list)
      end
      
      # --------- -------------- --------------------
      #      Nettoyage des compteurs d'effets
      # --------- -------------- --------------------
      actor.effect.each do |effect|
        execution(effect[0], "pre_post_compteur", actor_list, effect[1])
      end
      
      # --------- -------------- --------------------
      #      Nettoyage des compteurs d'effets pour les groupes
      # --------- -------------- --------------------
      0.upto(@user_group.size - 1) do |i|
        if (@user_group[i][1] and enemy != @actor) or 
           (not @user_group[i][1] and enemy != @enemy)
          @user_group[i][0].effect.each do |effect|
            execution(effect[0], "group_pre_post_compteur", @user_group[i][0], enemy, effect[1])
          end
        end
      end
      
      return if actor.dead?
    end
  end
end