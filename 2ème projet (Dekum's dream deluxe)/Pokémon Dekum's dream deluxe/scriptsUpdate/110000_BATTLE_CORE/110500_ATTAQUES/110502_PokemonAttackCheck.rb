#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attack_Check - Damien Linux
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
  # - Squelette des effets de certaines capacités et talents spécifiques
  # - Méthodes de Check
  # - Vérification / Exécution de la présence d'un saut
  # - ATTAQUES : Saut
  # - ATTAQUES : Saut last skill
  # - ATTAQUES : Saut user effect
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #--------------------------------------------------------------------
    # Squelette des effets de certaines capacités et talents spécifiques
    #--------------------------------------------------------------------
    # Check des status et vérifie si le pokémon peut attaquer
    # Renvoie false si la suite de la procédure ne doit pas avoir lieu
    def check_possibility_attack
      tab_check = [:check_sommeil, :check_gel, :check_paresse,
                   :check_flinch, :check_confuse, :check_paralysie,
                   :check_miroir_magik, :check_anti_bruit, :check_saisie,
                   :check_garde_magik]
      suite_action = true
      tab_check.each do |check|
        suite_action = send(check)
        break if not suite_action
      end
      return suite_action
    end
    
    #------------------------------------------------------------ 
    # Méthodes de Check
    #------------------------------------------------------------
    # Vérifie si le sommeil fait effet
    # Renvoie false si la suite des actions est impossible
    def check_sommeil
      if @user.asleep?
        if @user.sleep_check and 
           not(@user.effect_list.include?(:brouhaha)) # Uproar
          draw_text("#{@user.given_name}", "dort!")
          status_animation(@user_sprite, @user.status)
          wait(40)
          # Attaques actives au sommeil
          # Sleep Talk - Blabla Dodo / Snore - Baillement non affecté par 
          # le sommeil
          if not(@user_skill.effect_symbol == :blabla_dodo or 
                 @user_skill.effect_symbol == :ronflement)
            return false
          end
        else
          @user_status.refresh
          draw_text("#{@user.given_name}", "se réveille !")
          wait(40)
        end
      end
      return true
    end
    
    # Vérifie si le gel fait effet
    # Renvoie false si la suite des actions est impossible
    def check_gel
      if @user.frozen?
        if @user.froze_check
          if @user_skill.effect_symbol == :degele_brule # Defrost move
            @user.cure
            @user_status.refresh
            draw_text("#{@user.given_name}", "dégèle !")
            wait(40)
          else
            draw_text("#{@user.given_name}", "est gelé !")
            status_animation(@user_sprite, @user.status)
            wait(40)
            return false
          end
        else
          @user_status.refresh
          draw_text("#{@user.given_name}", "dégèle !")
          wait(40)
        end
      end
      return true
    end
    
    # Vérifie si un talent empêchant le pokémon d'attaquer agit
    # Renvoie false si la suite des actions est impossible
    def check_paresse
      if @user.ability_symbol == :absenteisme and 
         not (@user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine))
        if @user.ability_token == nil
          @user.ability_token = false
        end
        if @user.ability_token
          draw_text("#{@user.given_name}", "paresse !")
          wait(40)
          return false
        end
      end
      return true
    end
    
    # Vérifie si le pokémon est apeuré
    # Renvoie false si la suite des actions est impossible
    def check_flinch
      if @user.flinch?
        draw_text("#{@user.given_name}", "est apeuré !")
        status_animation(@user_sprite, 7)
        @user.flinch_check
        wait(40)
        return false
      end
      return true
    end
    
    # Vérifie si le pokémon est confus et que cela l'empêche d'attaquer
    # Renvoie false si la suite des actions est impossible
    def check_confuse
      if @user.confused?
        if @user.state_count > 0
          draw_text("#{@user.given_name}", "est confus !")
          status_animation(@user_sprite, 6)
          condition = @user.confuse_check
          if condition
            draw_text("#{@user.given_name} se blesse", "dans sa confusion.")
            damage = @user.confuse_damage
            self_damage(@user, @user_sprite, @user_status, damage)
            wait(40)
            return false
          end
        elsif @user.state_count == 0
          draw_text("#{@user.given_name}", "n'est plus confus !")
          @user.cure_state
          wait(40)
        end
      end
      return true
    end
    
    # Vérifie si la paralysie fait effet
    # Renvoie false si la suite des actions est impossible
    def check_paralysie
      if @user.paralyzed?
        if @user.paralysis_check
          draw_text("#{@user.given_name} est paralysé !", 
                    "Il ne peut pas attaquer !")
          status_animation(@user_sprite, @user.status)
          wait(40)
          return false
        end
      end
      return true
    end
    
    # Modification de la cible : cas des attaques de type Reflet Magik
    # ou des talents de type Miroir Magik
    def check_miroir_magik
      if @target != @user and @target.ability_symbol == :miroir_magik and 
         not @user_skill.sonore?
        @string_magik = Array.new(2)
        @string_magik[0] = "Miroir Magik de #{@target.name} retourne"
        @string_magik[1] = "la capacité #{@user_skill.name} !"
        @target = retour_magik(@user, @user_skill, @target)
      elsif @target != @user and @precedent != nil and 
            @precedent.effect_symbol == :reflet_magik
        @string_magik = Array.new(2)
        @string_magik[0] = "Reflet Magik de #{@target.name} retourne" 
        @string_magik[1] = "la capacité #{@user_skill.name} !"
        @target = retour_magik(@user, @user_skill, @target)
      end
      return true
    end
    
    # CAPACITE SPECIALE : Anti-Bruit
    def check_anti_bruit
      if @user_skill.sonore? and @target.ability_symbol == :anti_bruit
        draw_text("Anti-Bruit de #{@target.given_name}", "empêche l'attaque !")
        wait(40)
        return false
      end
      return true
    end
    
    # Capacite Saisie :
    def check_saisie
      if @user.effect_list.include?(:saisie)
        if @user_skill.status and @user == @target and 
          @user_skill.effect_symbol != :coup_main # Coup d'Main
          @target = @adversaire
        end
      end
      return true
    end
      
    # CAPACITE SPECIALE : Garde Magik
    def check_garde_magik
      if @target.ability_symbol == :garde_magik and not @user_skill.direct?
        draw_text("Garde Magik de #{@target.given_name}", "empêche l'attaque !")
        wait(40)
        return false
      end
      return true
    end
    
    #------------------------------------------------------------ 
    # Vérification / Exécution de la présence d'un saut
    #------------------------------------------------------------  
    def pre_accuracy_check
      @pp_use = true
      @jumper_end = false
      suite_action = execution_return(@user_skill.effect_symbol, "saut")
      return false if suite_action == nil or not suite_action 
      
      # Spécial dernier skill utilisé
      if @user_last_skill != nil
        execution(@user_last_skill.effect_symbol, "saut_last_skill")
      end
      
      suite_action = true
      @user.effect.each do |effect|
        suite_action = execution_return(effect[0], "saut_user_effect", true, effect)
        break if not suite_action
      end
      return false if suite_action == nil or not suite_action 
      
      # Utilisation des PP
      pp_use_action
      return true
    end
    
    # Utilisation de l'attaque et donc diminution des PP
    # Prise en compte du talent pression qui baisse les PP de double
    def pp_use_action
      # PP spent
      if @pp_use
        @user_skill.use
        if @user == @actor
          $battle_var.actor_last_used = @user_skill
          @user_last_skill = $battle_var.actor_last_used
        elsif @user == @enemy
          $battle_var.enemy_last_used = @user_skill
          @user_last_skill = $battle_var.enemy_last_used
        end
        $battle_var.last_used = @user_skill
        @last_skill = $battle_var.last_used
      end
      
      # Pressure / Pression
      if @target and @pp_use and @target.ability_symbol == :pression and 
          not (@target.effect_list.include?(:suc_digestif) or 
          @target.effect_list.include?(:soucigraine)) and 
          @target == @adversaire and @user_skill.pp > 0
        @user_skill.use
      end
    end
    
    #------------------------------------------------------------ 
    # ATTAQUES : Saut
    #------------------------------------------------------------  
    def patience_saut
      index = @user.effect_list.index(:patience)
      if @user.effect_list.include?(:patience) and 
         [4,5].include?(@user.status)
        @user.effect.delete_at(index) # Supprime si endormi ou gelé
      end
      if not(@user.effect_list.include?(:patience))
        draw_text("#{@user.given_name}", "patiente...")
        wait(40)
        turn = rand(2) + 3
        @user.skill_effect(:patience, turn, 0)
        @jumper_end = true
      elsif @user.effect[index][1] >= 2 # Encore en charge
        draw_text("#{@user.given_name} patiente...")
        wait(40)
        @pp_use = false
        @jumper_end = true
      else
        @pp_use = false
        # Changement de cible!
        if @user == @actor
          @target = @enemy
          @target_sprite = @enemy_sprite
          @target_status = @enemy_status
        elsif @user == @enemy
          @target = @actor
          @target_sprite = @actor_sprite
          @target_status = @actor_status
        end
      end
      return true
    end
    
    def multi_tour_confus_saut
      index = @user.effect_list.index(:multi_tour_confus)
      if not(@user.effect_list.include?(:multi_tour_confus))
        turn = rand(2) + 2
        @user.skill_effect(:multi_tour_confus, turn)
        @pp_use = true
      else
        @pp_use = false
      end
      return true
    end 
    
    def mania_saut
      index = @user.effect_list.index(:mania)
      if @user.effect_list.include?(:mania) and 
         [4,5].include?(@user.status)
        @user.effect.delete_at(index) # Supprime si endormi ou gelé
      end
      if not(@user.effect_list.include?(:mania))
        turn = rand(2) + 2
        @user.skill_effect(:mania, turn)
        @pp_use = true
      else
        @pp_use = false
      end
      return true
    end

    def coupe_vent_saut
      string = "se prépare !"
      chargement(@user, :coupe_vent, 2, string)
      return true
    end
    
    def pique_saut
      string = "se concentre !"
      chargement(@user, :pique, 2, string)
      return true
    end

    def rechargement_saut
      if @user.effect_list.include?(:rechargement) # Déjà attaqué
        draw_text("#{@user.given_name}", "doit se recharger !")
        wait(40)
        return false
      end
      return true
    end

    def coud_krane_saut
      string = "se prépare !"
      chargement(@user, :coud_krane, 2, string)
      if not(@user.effect_list.include?(:coud_krane))
        augmentation_stat("DFE", 1, @user)
      end
      return true
    end

    def lance_soleil_saut
      if $battle_var.sunny? and 
         not(@user.effect_list.include?(:lance_soleil)) # Sunny
        # Continue et lance l'attaque
      else
        string = "se charge !"
        chargement(@user, :lance_soleil, 2, string)
      end
      return true
    end

    def revenant_saut
      string = "disparaît !"
      chargement(@user, :revenant, 2, string)
      return true
    end

    def ultralaser_saut
      if @user.effect_list.include?(:ultralaser) # Déjà attaqué
          draw_text("#{@user.given_name}", "doit se recharger !")
          wait(40)
        return false
      end
      return true
    end

    def tunnel_saut
      string = "creuse !"
      chargement(@user, :tunnel, 2, string)
      return true
    end
    
    def vol_saut
      string = "s'envole !"
      chargement(@user, :vol, 2, string)
      return true
    end

    def rebond_saut
      string = "saute !"
      chargement(@user, :rebond, 2, string)
      return true
    end

    def plongee_saut
      string = "plonge !"
      chargement(@user, :plongee, 2, string)
      return true
    end
    
    def prescience_saut
      if not @user.effect_list.include?(:prescience) and not @user.effect_list.include?(:carnareket)
        draw_text("#{@user.given_name} prévoit une", "attaque !")
        @user_group.push([@user, (@user == @actor)])
        @user_group[@user_group.size - 1][0].skill_effect(:prescience, 3, [@user, @user_skill])
        wait(40)
        @jumper_end = true
      end
      return true
    end
    
    def carnareket_saut
      if not @user.effect_list.include?(:prescience) and not @user.effect_list.include?(:carnareket)
        draw_text("#{@user.given_name} souhaite le", "déclenchement de #{@user_skill.name} !")
        @user_group.push([@user, (@user == @actor)])
        @user_group[@user_group.size - 1][0].skill_effect(:carnareket, 3, [@user, @user_skill])
        wait(40)
        @jumper_end = true
      end
      return true
    end
    
    #------------------------------------------------------------ 
    # ATTAQUES : Saut last skill
    #------------------------------------------------------------  
    def voeu_saut_last_skill
      @user.skill_effect(:voeu, 1)
    end
    
    #------------------------------------------------------------ 
    # ATTAQUES : Saut user effect
    #------------------------------------------------------------  
    def frenesie_saut_user_effect(effect)
      if @user_skill.effect_symbol != :frenesie
        @user.change_atk(-effect[2])
        @user.effect.delete(effect)
      end
      return true
    end

    def encore_saut_user_effect(effect)
      @user_skill = @user.skills_set[effect[2]]
      return true
    end

    def prlvt_destin_saut_user_effect(effect)
      index = @user.effect.index(effect)
      @user.effect.delete_at(index)
      return true
    end

    def multi_tour_puissance_saut_user_effect(effect)
      @pp_use = false
      return true
    end
    
    def attraction_saut_user_effect(effect)
      draw_text("#{@user.given_name} est amoureux !")
      wait(40)
      if rand(2) == 1
        draw_text("#{@user.given_name} est amoureux", "il ne peut pas attaquer !")
        wait(40)
        return false
      end
      return true
    end

    def brouhaha_saut_user_effect(effect)
      @pp_use = false
      return true
    end

    def rancune_saut_user_effect(effect)
      index = @user.effect.index(effect)
      @user.effect.delete_at(index)
      return true
    end
  end
end