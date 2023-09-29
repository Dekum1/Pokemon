#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Post_Attack - Damien Linux
# 04/01/2020
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
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
  # - Dégâts de recul des baies
  # - Squelette post attaque après dégâts de recul
  # - Effets des attaques après avoir fait des dégâts
  # - Effets des attaques après échec
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Dégâts de recul des baies
    #------------------------------------------------------------
    def berry_recoil_damages(efficiency)
      # Gestion des baies pour les dégâts de recul
      if @user != @target 
        tmp_damage = use_berry_skill(@target, @user_skill, @user)
        if tmp_damage > 0
          # Dégâts de recul
          draw_text("#{@target.given_name} Mange une", "#{@target.item_name},")
          wait(40)
          draw_text("cela inflige des dégâts à", "#{@user.given_name}.")
          self_damage(@user, @user_sprite, @user_status, tmp_damage)
          wait(40)
          @target.item_hold = 0
        elsif tmp_damage == 0
          @target.item_hold = 0
        end
      end
      
      # Cas de la baie Chérim (dégâts côté cible)
      if @user != @target
        baie_cherim(@target)
      end
      
      # Gestion des baies : cas de la baie Enigma
      if @target != @user
        baie_enigma(@target, @target_sprite, @target_status, efficiency)
      end
      
      # Gestion des baies : cas de la baie Lansat (quand subit des dégâts :
      # côté cible)
      if @target != @user
        result = baie_lansat(@target)
        if  result != false
          @critical_special += result
        end
      end
    end
    
    #------------------------------------------------------------ 
    # Squelette post attaque après dégâts de recul
    #------------------------------------------------------------
    def check_post_atk(recoil_damage)
      # Cas de la baie Chérim (dégâts côté utilisateur)
      if @user != @target and recoil_damage > 0
        baie_cherim(@user)
      end
      
      # Gestion des baies : cas de la baie Lansat (quand subit des dégâts :
      # côté utilisateur)
      if @target != @user
        result = baie_lansat(@target)
        if  result != false
          @critical_special += result
        end
      end
      
      # Cas de Reflet Magik ou Miroir Magik
      if @string_magik != nil and not miss and not @user_skill.sonore?
        draw_text(@string_magik[0], @string_magik[1])
        wait(40)
        @string_magik = nil
      end
    
      faint_check
    end
    
    #------------------------------------------------------------ 
    # Effets des attaques après avoir fait des dégâts
    #------------------------------------------------------------
    def recuperation_pv_post(recoil_damage)
      bonus = @damage / 2
      if @damage > 0 and bonus == 0
        bonus = 1
      end
      heal(@user, @user_sprite, @user_status, bonus)
      draw_text("L'énergie du #{@target.given_name}", "est draînée.")
      wait(40)
      return recoil_damage
    end

    def devoreve_post(recoil_damage)
      bonus = @damage / 2
      if @damage > 0 and bonus == 0
        bonus = 1
      end
      # Liquid ooze / Suintement (ab)
      if @target.ability_symbol != :suintement and 
         not (@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))
        heal(@user, @user_sprite, @user_status, bonus)
        draw_text("L'énergie du #{@target.given_name}", "est draînée.")
        wait(40)
      else
        self_damage(@user, @user_sprite, @user_status, bonus)
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "réduit les PV.")
        wait(40)
      end
      return recoil_damage
    end

    def attaque_combo_post(recoil_damage)
      if @multi_hit == 0
        draw_text("#{@target.given_name}", 
                  "est touché #{@total_hit.to_s} fois!")
        wait(40)
      else
        draw_text("... #{(@total_hit - @multi_hit).to_s} fois...") 
        wait(40)
      end
      return recoil_damage
    end

    def guerison_post(recoil_damage)
      bonus = @user.max_hp / 2
      heal(@user, @user_sprite, @user_status, bonus)
      draw_text("#{@user.given_name}", "se soigne !")
      wait(40)
      return recoil_damage
    end
    
    def vibra_soin_post(recoil_damage)
      bonus = @target.max_hp / 2
      heal(@target, @target_sprite, @target_status, bonus)
       draw_text("#{@user.given_name}",  "soigne #{@target.given_name} !")
      wait(40)
      return recoil_damage
    end

    def jackpot_post(recoil_damage)
      draw_text("#{tagret.given_name}", "lâche de l'argent!")
      $battle_var.money_payday += 5*@user.level
      wait(40)
      return recoil_damage
    end

    def repos_post(recoil_damage)
      @user.cure
      status_check(@user, 4, true)
      @user_status.refresh
      # Dort pour 2 tours seulement sauf si Matinal => 1 tour
      @user.status_count = @user.ability_symbol != :matinal ? 3 : 2
      bonus = @user.max_hp
      heal(@user, @user_sprite, @user_status, bonus)
      draw_text("#{@user.given_name} a regagné", "son énergie.")
      wait(40)
      return recoil_damage
    end

    def ko_un_coup_post(recoil_damage)
      draw_text("K.O. en un coup!")
      wait(40)
      return recoil_damage
    end 

    def charge_blesse_post(recoil_damage)
      recoil_damage = @damage / 4
      if @damage > 0 and recoil_damage == 0
        recoil_damage = 1
      end
      # Head Rock / Tete de rock (ab) / Garde Magik // Struggle
      if (@user.ability_symbol != :tete_de_roc and 
          @user.ability_symbol != :garde_magik and
        not(@user.effect_list.include?(:suc_digestif) or 
        @user.effect_list.include?(:soucigraine))) or 
        @user_skill.id == 165 
        self_damage(@user, @user_sprite, @user_status, recoil_damage)
        draw_text("#{@user.given_name} se blesse", "en frappant.")
        wait(40)
      end 
      return recoil_damage
    end

    def rechargement_post(recoil_damage)
      @user.skill_effect(:rechargement, 2)
      return recoil_damage
    end

    def balance_post(recoil_damage)
      middle = (@user.hp + @target.hp)/2
      @user_diff = middle - @user.hp
      heal(@user, @user_sprite, @user_status, @user_diff)
      target_diff = middle - @target.hp
      heal(@target, @target_sprite, @target_status, target_diff)
      return recoil_damage
    end

    def cadeau_post(recoil_damage)
      if @gift
        bonus = @target.hp / 4
        heal(@target, @target_sprite, @target_status, bonus)
      end
      draw_text("Surprise!")
      wait(40)
      return recoil_damage
    end

    def poursuite_post(recoil_damage)
      if @precedent != nil and (@precedent.effect_symbol == :demi_tour or 
         (@precedent.effect_symbol == :change_eclair and 
          @user.ability_symbol != :absorb_volt))
        # Si actor joue, alors enemy a fait son attaque avant
        # Sinon inversement
        if $pokemon_party.number_alive > 1 and @user == @enemy
          scene_temp = Pokemon_Party_Menu.new(0, @z_level + 100, "map", nil, 
                                              true)
          # Récupération des données
          @switch_id = scene_temp.return_data
          # Switch
          actor_pokemon_switch
        elsif @user == @actor
          # Switch adverse
          force_switch(@target)
        end
      end
      return recoil_damage
    end
    
    def aurore_post(recoil_damage)
      weather = $battle_var.weather[0]
      case weather
      when 1 # Rainy
        bonus = @user.max_hp / 4
      when 2 # Sunny
        bonus = @user.max_hp * 2 / 3
      when 3 # Sandstorm
        bonus = @user.max_hp / 4
      when 4 # Hail
        bonus = @user.max_hp / 4
      when 0
        bonus = @user.max_hp / 2
      end
      heal(@user, @user_sprite, @user_status, bonus)
      return recoil_damage
    end

    def synthese_post(recoil_damage)
      weather = $battle_var.weather[0]
      case weather
      when 1 # Rainy
        bonus = @user.max_hp / 4
      when 2 # Sunny
        bonus = @user.max_hp * 2 / 3
      when 3 # Sandstorm
        bonus = @user.max_hp / 4
      when 4 # Hail
        bonus = @user.max_hp / 4
      when 0
        bonus = @user.max_hp / 2
      end
      heal(@user, @user_sprite, @user_status, bonus)
      return recoil_damage
    end

    def rayon_lune_post(recoil_damage)
      weather = $battle_var.weather[0]
      case weather
      when 1 # Rainy
        bonus = @user.max_hp / 4
      when 2 # Sunny
        bonus = @user.max_hp * 2 / 3
      when 3 # Sandstorm
        bonus = @user.max_hp / 4
      when 4 # Hail
        bonus = @user.max_hp / 4
      when 0
        bonus = @user.max_hp / 2
      end
      heal(@user, @user_sprite, @user_status, bonus)
      return recoil_damage
    end

    def cognobidon_post(recoil_damage)
      damage = @user.max_hp / 2
      self_damage(@user, @user_sprite, @user_status, damage)
      return recoil_damage
    end

    def regagne_pv_moitie_post(recoil_damage)
      bonus = @user.max_hp / 2
      heal(@user, @user_sprite, @user_status, bonus)
      @user.skill_effect(:regagne_pv_moitie, 2)
      draw_text("#{@user.given_name}", "récupère des PV !")
      wait(40)
      return recoil_damage
    end

    def degats_post(recoil_damage)
      recoil_damage = @damage / 3
      if @damage > 0 and recoil_damage == 0
        recoil_damage = 1
      end
      # Head Rock / Tete de rock (ab) / Garde Magik // Struggle
      if (@user.ability_symbol != :tete_de_roc and 
          @user.ability_symbol != :garde_magik and
          not (@user.effect_list.include?(:suc_digestif) or 
          @user.effect_list.include?(:soucigraine))) or 
          @user_skill.id == 165 
        self_damage(@user, @user_sprite, @user_status, recoil_damage)
        draw_text("#{@user.given_name} se blesse", "en frappant.")
        wait(40)
      end
      return recoil_damage
    end

    def atterissage_post(recoil_damage)
      bonus = @user.max_hp / 2
      heal(@user, @user_sprite, @user_status, bonus)
      @user.skill_effect(:atterissage, 2)
      draw_text("#{@user.given_name}", "perd son type Vol!")
      wait(40)
      return recoil_damage
    end

    def mange_baie_post(recoil_damage)
      if (@target.item_hold >= 205 and @target.item_hold <= 247) or
          (@target.item_hold >= 363 and @target.item_hold <= 386) 
        if not use_berry(@user, @target, true) # Effet de la baie (s'il y a)
          draw_text("#{@user.given_name} mange une", "#{@target.item_name}")
        end
        draw_text("#{@user.given_name} a mangé",
                  "la baie de #{@target.given_name}")
        wait(40)
        @target.item_hold = 0
      end
      return recoil_damage
    end

    def demi_tour_post(recoil_damage)
      # Si l'adversaire utilise poursuite mais tombe K.O => switch
      if @suivant == nil or @suivant.effect_symbol != :poursuite or 
         not @enemy.hp > 0
        if $pokemon_party.number_alive > 1 and @user == @actor
          scene_temp = Pokemon_Party_Menu.new(0, @z_level + 100, "map", nil, 
                                              true)
          scene_temp.main
          # Récupération des données
          @switch_id = scene_temp.return_data
          # Switch
          actor_pokemon_switch
        elsif $battle_var.enemy_party.number_alive > 1 and @user == @enemy
          # Switch adverse
          force_switch(@user)
        end
      end
      return recoil_damage
    end
    alias relais_post demi_tour_post

    def boutefeu_post(recoil_damage)
      recoil_damage = @damage / 3
      if @damage > 0 and recoil_damage == 0
        recoil_damage = 1
      end
      # Head Rock / Tete de rock (ab) / Garde Magik // Struggle
      if (@user.ability_symbol != :tete_de_roc and 
          @user.ability_symbol != :garde_magik and
          not(@user.effect_list.include?(:suc_digestif) or 
          @user.effect_list.include?(:soucigraine))) or 
          @user_skill.id == 165 
        self_damage(@user, @user_sprite, @user_status, recoil_damage)
        draw_text("#{@user.given_name} se blesse", "en frappant.")
        wait(40)
      end
      # Brûlure : 1 chance / 10
      if rand(100) < 10
        status_check(@user, 3)
      end
      return recoil_damage
    end

    def change_eclair_post(recoil_damage)
      if @suivant == nil or @suivant.effect_symbol != :poursuite or 
         not @enemy.hp > 0
        # Annule si l'adversaire a une capacité spéciale du type Absorb Volt
        if @target.ability_symbol != :absorb_volt 
          if $pokemon_party.number_alive > 1 and @user == @actor
            scene_temp = Pokemon_Party_Menu.new(0, @z_level + 100, "map", nil, 
                                                true)
            scene_temp.main
            # Récupération des données
            @switch_id = scene_temp.return_data
            # Switch
            actor_pokemon_switch
          elsif $battle_var.enemy_party.number_alive > 1 and @user == @enemy
            # Switch adverse
            force_switch(@user)
          end
        end
      end
      return recoil_damage
    end

    def ultralaser_post(recoil_damage)
      if @nonRecharge == nil
        @nonRecharge = false
      end
      if not @nonRecharge
        @user.skill_effect(:ultralaser, 2)
      else
        @nonRecharge = false
      end
      return recoil_damage
    end
    
    def ebullition_post(recoil_damage)
        @user.cure if @user.frozen?
        @target.cure if @target.frozen?
        return recoil_damage
    end
    
    #------------------------------------------------------------ 
    # Effets des attaques après échec
    #------------------------------------------------------------
    def auto_ko_miss
      rec_damage = @user.hp
      self_damage(@user, @user_sprite, @user_status, rec_damage)
      draw_text("#{@user.given_name}","se sacrifie.")
      wait(40)
      faint_check(@user)
    end

    def coup_rate_blesse_miss
      @damage = @damage_initial
      rec_damage = @damage/2
      draw_text("#{@user.given_name}","retombe au sol !")
      self_damage(@user, @user_sprite, @user_status, rec_damage)
      wait(30)
      faint_check(@user)
    end

    def triple_pied_miss
      @multi_hit = 0 # Arret si échec
    end

    def multi_tour_puissance_miss
      if @user.effect_list.include?(:multi_tour_puissance)
        index = @user.effect_list.index(:multi_tour_puissance)
        @user.effect.delete_at(index)
      end
    end

    def rebond_miss
      if @user.effect_list.include?(:rebond)
        index = @user.effect_list.index(:rebond)
        @user.effect.delete_at(index)
      end
    end
  end
end