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
  # Calcul des damages et damages spécifiques :
  # - Calcul des dégâts
  # - Taux de résultat aux dégâts  
  # - Détermination des coups critiques
  # - Evènement provoquant une baisse des PV
  # - Evènement provoquant des dégâts
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------   
    # Calcul des dégâts
    #------------------------------------------------------------
    # Gestion des dêgats automatique en combat
    # Skill utilisé sur l'adversaire
    # Dommages Infligés - user_skill = class Skill, enemy = class Pokemon
    # Renvoie: [damage, critical (true/false), efficency (-2, -1,0,1)]
    def damage_calculation(critical_special = 0, shortcut = false, 
                           int_only = false)      
      if @user == @actor
        user_last_skill = $battle_var.actor_last_used
        user_last_taken_damage = $battle_var.actor_last_taken_damage
      elsif @user == @enemy
        user_last_skill = $battle_var.enemy_last_used
        user_last_taken_damage = $battle_var.enemy_last_taken_damage
      end
      if @target == @actor
        target_last_skill = $battle_var.actor_last_used
        target_last_taken_damage = $battle_var.actor_last_taken_damage
      elsif @target == @enemy
        target_last_skill = $battle_var.enemy_last_used
        target_last_taken_damage = $battle_var.enemy_last_taken_damage
      end
      last_skill = $battle_var.last_used
      critical_hit = (critical_special > 0)
      if critical_hit
        critical_hit = critical_decision(critical_special)
      end
      level = @user.level
      statistic_refresh_modif
      @user.statistic_refresh_modif
      if @user_skill.physical
        atk = (critical_hit and @user.atk_stage < 0) ? @user.atk_basis : 
                                                       @user.atk
        dfe = (critical_hit and @target.dfe_stage > 0) ? @target.dfe_basis : 
                                                         @target.dfe
      elsif @user_skill.special
        atk = (critical_hit and @user.ats_stage < 0) ? @user.ats_basis : 
                                                       @user.ats
        dfe = (critical_hit and @target.dfs_stage > 0) ? @target.dfs_basis : 
                                                         @target.dfs
      else
        atk = (critical_hit and @user.atk_stage < 0) ? @user.atk_basis : 
                                                       @user.atk
        dfe = (critical_hit and @target.dfe_stage > 0) ? @target.dfe_basis : 
                                                         @target.dfe
      end
      
      base_damage = @user_skill.power
       # Cas spécial : base_damage > 200 (contrainte RMXP)
      if @user_skill.name == "EXPLOSION"
        base_damage = 250
      end
      user_type1 = @user.type1
      user_type2 = @user.type2
      skill_type = @user_skill.type
      target_type1 = @target.type1
      target_type2 = @target.type2
      weather = $battle_var.weather[0]
      
      # ------------- -------------- ---------------
      #        Programmation des objets
      # ------------- -------------- ---------------
      #            Boosts de type
      # ------------- -------------- ---------------
      case @user.item_name
      when "MOUCH.SOIE"
        atk *= user_type1 == 1 ? 1.1 : 1
      when "CHARBON"
        atk *= user_type1 == 2 ? 1.1 : 1
      when "EAU MYSTIQUE"
        atk *= user_type1 == 3 ? 1.1 : 1
      when "AIMANT"
        atk *= user_type1 == 4 ? 1.1 : 1
      when "GRAIN MIRACL"
        atk *= user_type1 == 5 ? 1.1 : 1
      when "GLACETERNEL"
        atk *= user_type1 == 6 ? 1.1 : 1
      when "CEINT.NOIRE"
        atk *= user_type1 == 7 ? 1.1 : 1
      when "PIC VENIN"
        atk *= user_type1 == 8 ? 1.1 : 1
      when "SABLE DOUX"
        atk *= user_type1 == 9 ? 1.1 : 1
      when "BEC POINTU"
        atk *= user_type1 == 10 ? 1.1 : 1
      when "CUILLERTORDU"
        atk *= user_type1 == 11 ? 1.1 : 1
      when "POUDRE ARG."
        atk *= user_type1 == 12 ? 1.1 : 1
      when "PIERRE DURE"
        atk *= user_type1 == 13 ? 1.1 : 1
      when "RUNE SORT"
        atk *= user_type1 == 14 ? 1.1 : 1
      when "CROC DRAGON"
        atk *= user_type1 == 15 ? 1.1 : 1
      when "PEAU METAL"
        atk *= user_type1 == 16 ? 1.1 : 1
      when "LUNET.NOIRES"
        atk *= user_type1 == 17 ? 1.1 : 1
      end
      

      # ------------- -------------- ---------------
      #        Programmation des attaques
      # ------------- -------------- ---------------
      #      Redéfinition base_damage (puissance)
      # ------------- -------------- ---------------
      data = nil
      
      hash = {:atk => atk, :dfe => dfe, :skill_type => skill_type, 
              :base_damage => base_damage, :target_type1 => target_type1,
              :target_type2 => target_type2, :data => data,
              :user_type1 => user_type1, :user_type2 => user_type2,
              :weather => weather, 
              :user_last_taken_damages => user_last_taken_damage,
              :target_last_taken_damages => target_last_taken_damage,
              :user_last_skill => user_last_skill, 
              :target_last_skill => target_last_skill,
              :critical_hit => critical_hit}
      hash = execution_return(@user_skill.effect_symbol, "damages", hash, 
                                   hash)
      
      # Cas de Moi d'Abord
      if @me_first
        hash[:base_damage] *= 1.5
        @me_first = false
      end
      
      # --------- --------------- ----------
      #       Protections adverses
      # --------- --------------- ----------
      @target.effect_list.each do |effect|
        hash = execution_return(effect, "damages_enemy", hash, hash)
      end
      
      # --------- --------------- ----------
      #        Bonus Capacités Spéciales
      # --------- --------------- ----------
      # Suc Digestif / Soucigraine
      unless @user.effect_list.include?(:suc_digestif) or 
             @user.effect_list.include?(:soucigraine) 
        hash = execution_return(@user.ability_symbol, "damages", hash, hash)
      end
      # Suc Digestif / Soucigraine
      unless @target.effect_list.include?(:suc_digestif) or 
             @target.effect_list.include?(:soucigraine) 
        hash = execution_return(@target.ability_symbol, "damages", hash, hash)
      end
      atk = hash[:atk]
      dfe = hash[:dfe]
      skill_type = hash[:skill_type]
      base_damage = hash[:base_damage]
      target_type1 = hash[:target_type1]
      target_type2 = hash[:target_type2]
      user_type1 = hash[:user_type1]
      user_type2 = hash[:user_type2]
      data = hash[:data]
      weather = hash[:weather]
      
      # --------- --------------- ---------- ---------------
      #        Dommages infligés et calculs coefficients
      # --------- --------------- ---------- ---------------
      pre_damage = (((level*2/5.0+2)*base_damage*atk/dfe)/50)
      multiplier = 1
      
      # Effets de la météo
      # Airlock / Cloud Nine (ab)
      if not([:ciel_gris, :air_lock].include?(@user.ability_symbol) or 
             [:ciel_gris, :air_lock].include?(@target.ability_symbol) and 
          not (@user.effect_list.include?(:suc_digestif) or 
          @user.effect_list.include?(:soucigraine)) and 
          not (@target.effect_list.include?(:suc_digestif) or 
          @target.effect_list.include?(:soucigraine)))
        if ($battle_var.sunny? and skill_type == 2) or ($battle_var.rain? and 
                                                        skill_type == 3)
          # Ensoleillé + Feu ou Pluie + Eau
          multiplier *= 1.5
        end
        if ($battle_var.sunny? and skill_type == 3) or ($battle_var.rain? and 
                                                        skill_type == 2)
          # Ensoleillé + Eau ou Pluie + Feu
          multiplier *= 0.5
        end
        # Météo - Lance-Soleil / Solarbeam en cas de mauvais temps
        if @user_skill.effect_symbol == :lance_soleil and 
           [1, 3, 4].include?(weather)
          multiplier *= 0.5
        end
      end
      
      # Conversion / Adaptation
      if @user.effect_list.include?(:adaptation)
        index = @user.effect_list.index(:adaptation)
        user_type1 = @user.effect[index][2]
        user_type2 = 0
      end
      
      # Forecast / Meteo (ab) // Déguisement / Color Change (ab)
      if (@user.ability_symbol == :meteo or 
          @user.ability_symbol == :deguisement) and 
         not (@user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine))
        user_type1 = @user.ability_token
        user_type2 = 0
      end
      
      # Bonus même type (STAB)
      if skill_type == user_type1 or skill_type == user_type2
        multiplier *= 1.5
      end
      
      # Weather Ball / Ball'Meteo
      if @user_skill.effect_symbol == :ball_meteo
        case weather
        when 1 # Pluie
          skill_type = 3 # Eau
        when 2 # Sunny
          skill_type = 2 # Feu
        when 3 # Tempete Sable
          skill_type = 13 # Roche
        when 4 # Hail
          skill_type = 6 # Glace
        end
      end
        
      # Complément statut
      # Brulure // Guts / Cran (ab) // Facade
      if @user.status == 3 and @user_skill.physical and 
          not(@user.ability_symbol == :cran and 
          not (@user.effect_list.include?(:suc_digestif) or
          @user.effect_list.include?(:soucigraine))) and 
          @user_skill.effect_symbol != :facade
        multiplier *= 0.5
      end
      
      # ------------------ ----------
      #  Programmation des attaques
      # ------------------ -----------
      hash = {:skill_type => skill_type, :target_type1 => target_type1,
              :target_type2 => target_type2, :multiplier => multiplier}
      # Protections et malus adverses
      @target.effect_list.each do |effect|
        hash = execution_return(effect, "damages_malus_enemy", hash, hash)
      end
      
      skill_type = hash[:skill_type]
      target_type1 = hash[:target_type1]
      target_type2 = hash[:target_type2]
      multiplier = hash[:multiplier]
      
      # Bonus efficacité du type // Struggle / Lutte + Gravité
      rate = element_rate(target_type1, target_type2, skill_type, 
                          @user_skill.effect_symbol, @target.effect_list)
      if @user_skill.id != 165
        multiplier *= rate/100.0
      end
      
      # Attaques à double type (enlever les commentaires si utilisé)
      #case @user_skill.id 
      # Modèle :
      # when ID de l'attaque
        # Ajout type
        #rate *= element_rate(target_type1, target_type2, 
        #                     2EME TYPE DE L'ATTAQUE, user_skill.effect, 
        #                     target.effect_list)/100.0
      #end
      
      # Etude efficacité
      if rate > 100.0 # Super efficace
        efficiency = 1
      elsif rate < 100.0 and rate > 0 # Pas très efficace
        efficiency = -1
      elsif rate == 0 # Inefficace
        efficiency = -2
      elsif rate == 100.0 # Normal
        efficiency = 0
      end
      
      hash = {:skill_type => skill_type, :target_type1 => target_type1,
              :target_type2 => target_type2, :multiplier => multiplier}
      # Propriétés attaque
      hash = execution_return(@user_skill.effect_symbol, "damages_bonus", 
                              hash, hash)
      skill_type = hash[:skill_type]
      target_type1 = hash[:target_type1]
      target_type2 = hash[:target_type2]
      multiplier = hash[:multiplier]
      
      # Armurbaston / Battle Armor (ab) // Coque armure / Shell Armor (ab)
      if (@target.ability_symbol == :armurbaston or 
          @target.ability_symbol == :coque_armure) and 
          not (@target.effect_list.include?(:suc_digestif) or 
               @target.effect_list.include?(:soucigraine))
        critical_hit = false
      end
      
      # Calcul IA
      if shortcut
        return base_damage * multiplier
      end
      
      # Damage weight
      multiplier *= (100 - rand(15)) / 100.0
      if critical_hit
        multiplier *= 2
      end
      
      # Minimum dommage
      damage = pre_damage * multiplier
      if damage < 1 and damage > 0
        damage = 1
      end
      
      if int_only
        return Integer(damage)
      else
        return [Integer(damage), critical_hit, efficiency, data]
      end
    end
    
    #------------------------------------------------------------    
    # Taux de résultat aux dégâts                           
    #------------------------------------------------------------    
    def element_rate(target_type1, target_type2, skill_type, skill_effect, 
                     target_effect)
      result = 100.0
      result1 = result
      if $data_table_type[target_type1][skill_type] != nil 
        result = result * $data_table_type[target_type1][skill_type]
        result1 = result
        # Gravité, Atterissage et Oeil Miracle
        if (skill_type == 9 and target_type1 == 10 and 
           (target_effect.include?(:atterissage) or 
            target_effect.include?(:gravite))) or 
            (skill_type == 11 and target_type1 == 16 and 
            target_effect.include?(:oeil_miracle))
          result = 100.0
          result1 = result
        end
      else
        print("Erreur : vérifiez la table des types, case #{target_type1} #{skill_type}")
      end
      if $data_table_type[target_type2][skill_type] != nil
        result = result * $data_table_type[target_type2][skill_type]
        # Gravité, Atterissage et Oeil Miracle
        if (skill_type == 9 and target_type2 == 10 and 
           (target_effect.include?(:atterissage) or 
            target_effect.include?(:gravite))) or 
            (skill_type == 11 and target_type2 == 16 and 
             target_effect.include?(:oeil_miracle))
          result = result1
        end
      else
        print("Erreur : vérifiez la table des types, case #{target_type2} #{skill_type}")
      end
      if skill_effect == :fulmifer then return 100.0 end
      return result
    end
    
    #--------------------------------------------------
    # Détermination des coups critiques
    #--------------------------------------------------
    def critical_decision(critical_special = 0)
      rate = 0
      rate += critical_special
      if @target.effect_list.include?(:air_veinard) # Air Veinard
        return false
      end
      case rate
      when 0
        critical_chance = rand(15)
      when 1
        critical_chance = rand(7)
      when 2
        critical_chance = rand(3)
      when 3
        critical_chance = rand(2)
      end
      if rate >= 4
        critical_chance = rand(1)
      end
      if critical_chance == 0
        return true
      else
        return false
      end
    end
    
    #------------------------------------------------------------    
    # Evènement provoquant une baisse des PV
    #------------------------------------------------------------ 
    def heal(user, user_sprite, user_status, bonus)
      value = bonus.abs
      if user.effect_list.include?(:anti_soin) # Anti-Soin
        draw_text("ANTI-SOIN empêche","la régénération de PV!")
      else
        1.upto(value) do |i|
          if bonus >= 0
            user.add_hp(1)
          else
            user.remove_hp(1)
          end
          if user.max_hp >= 144 and i % (user.max_hp / 144 + 1) != 0
            next
          end
          user_status.refresh
          $scene.battler_anim ; Graphics.update
          #Graphics.update
          if user.hp >= user.max_hp or user.dead?
            if user.dead?
              if user == @actor and @clone != nil
                @clone[0] = 0
              elsif @clone != nil
                @clone[1] = 0
              end
            end
            break
          end
        end
      end
    end
    
    #------------------------------------------------------------    
    # Evènement provoquant des dégâts
    #------------------------------------------------------------
    def self_damage(user, user_sprite, user_status, damage)
      if damage > 0
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:degat]}", 100)
        blink(user_sprite)
      end
      1.upto(damage) do |i|
        user.remove_hp(1)
        user_status.refresh
        if user.max_hp >= 144 and i % (user.max_hp / 144 + 1) != 0
          next
        end
        $scene.battler_anim ; Graphics.update
        #Graphics.update
        if user.dead?
          if user == @actor and @clone != nil
            @clone[0] = 0
          elsif @clone != nil
            @clone[1] = 0
          end
          break
        end
      end
    end
  end
end