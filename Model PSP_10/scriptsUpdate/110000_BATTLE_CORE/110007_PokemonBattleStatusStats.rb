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
  # Gestion des status et des stats :
  # - Effets de status
  # - Calcul de la précision
  # - Impact de la précision
  # - Augmentation d'une stat
  # - Réduction d'une stat
  # - Inversion de l'effet sur une stat
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Effets de status
    #------------------------------------------------------------ 
    #------------------------------------------------------------ 
    # 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé
    # 6: Confus, 7: Flinch, 8: Toxic
    #------------------------------------------------------------ 
    # Fonction à appeler en cas d'effets sur le statut
    def status_check(target, status, forcing = false)
      return if target.dead?
      # Immunités
      # CAPACITE SPECIALE : Garde Magik
      if target.ability_symbol == :garde_magik and status != 6 and status != 7
        draw_text("Garde Magik de #{target.given_name}", 
                  "empêche l'effet de status")
        wait(40)
        return
      end
      # Poison
      if (target.type_poison? or target.type_steel?) and 
          (status == 1 or status == 8)
        draw_text(target.given_name + " est insensible", "au poison!")
        wait(40)
        return
      end
      if target.ability_symbol == :motorise and target.type_electric? and 
         status == 2 and 
         (target == @actor ? @enemy_skill : @actor_skill).type == 4
        #Motorisé
        return
      end
      # Freeze
      if status == 5 and target.type_ice?
        draw_text(target.given_name + " est insensible", "au gel !")
        wait(40)
        return
      end
      # Burn
      if status == 3 and target.type_fire?
        draw_text(target.given_name + " est insensible", "aux brûlures !")
        wait(40)
        return
      end
      # Soleil
      if status == 5 and $battle_var.sunny?
        draw_text("Le soleil empêche " + target.given_name, "de geler !")
        wait(40)
        return
      end
      unless target.effect_list.include?(:suc_digestif) or 
             target.effect_list.include?(:soucigraine)
        # Lumber / Echauffement (ab)
        if (status == 2 and target.ability_symbol == :echauffement) 
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche la paralysie.")
          wait(40)
          return
        elsif (status == 2 and target.type_electric?)
          draw_text("#{target.given_name} ne peut pas être", "paralysé :")
          wait(40)
          return
        end
        # Ignifu-voile / Water Veil (ab)
        if status == 3 and target.ability_symbol == :ignifu_voile
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche les brûlures.")
          wait(40)
          return
        end
        # Insomnia (ab) // Vital Spirit / Esprit Vital (ab) + cas de Soucigraine
        if status == 4 and (target.ability_symbol == :insomnia or 
                            target.ability_symbol == :esprit_vital or 
                            target.effect_list.include?(:soucigraine))
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche le sommeil.")
          wait(40)
          return
        end
        # Vaccin / Immunity (ab)
        if [1, 8].include?(status) and target.ability_symbol == :vaccin
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche l'empoisonnement.")
          wait(40)
          return
        end
        # Armumagma / Magma Armor (ab)
        if target.ability_symbol == :armumagma and status == 5
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche le gel.")
          wait(40)
          return
        end
        # Tempo Perso / Own Tempo (ab)
        if status == 6 and target.ability_symbol == :tempo_perso
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche la confusion.")
          wait(40)
          return
        end
        # Attention / Inner focus (ab)
        if target.ability_symbol == :attention and status == 7
          draw_text("#{target.ability_name} de #{target.given_name}", 
                    "empêche la peur.")
          wait(40)
          return
        end
        # Synchronize (ab)
        if target.ability_symbol == :synchro and [1, 2, 3, 8].include?(status)
          target.ability_token = status
          if status == 8
            target.ability_token = 1
          end
        end
      end
      
      actor = target == @enemy ? @actor : @enemy
      if [1,2,3,4,5,8].include?(target.status) and 
         not(forcing) and not([6, 7].include?(status))
        status_string(target, -target.status) # animation
      elsif status == 6 and target.confused? and not(forcing)
        status_string(target, -6)
      elsif target.effect_list.include?(:rune_protect) and 
            status != 7 and
            (actor.ability_symbol != :infiltration or target == actor) 
            # Rune Protect/Safeguard 
        draw_text("#{target.given_name} est", "protégé des altérations!")
        wait(40)
      elsif target.effect_list.include?(:brouhaha) and
        status == 4 # Uproar
        draw_text("#{target.given_name} ne peut pas dormir", 
                  "à cause du brouhaha!")
        wait(40)
      else
        case status
        when 1
          target.status_poison(forcing)
        when 2 
          target.status_paralyze(forcing)
        when 3
          target.status_burn(forcing)
        when 4
          target.status_sleep(forcing)
        when 5
          target.status_frozen(forcing)
        when 6
          target.status_confuse
        when 7
          target.status_flinch
        when 8
          target.status_toxic(forcing)
        end
        if target != @enemy
          status_animation(@actor_sprite, @actor.status)
        else
          status_animation(@enemy_sprite, @enemy.status)
        end
        status_string(target, status)
      end
    end
    
    #------------------------------------------------
    # Calcul de la précision
    #------------------------------------------------    
    def accuracy_check(user_skill, user, target) #actor: user
      n = user_skill.accuracy
      
      # ------------- ------------------ --------------------
      #             Attaques self-cible, buff
      # ------------- ------------------- ------------------- 
      if user == target
        return n = 100
      end
      
      # ------------- ------------------ --------------------
      #                Capacités spéciales
      # ------------- ------------------- -------------------
      # Suc Digestif / Soucigraine
      unless target.effect_list.include?(:suc_digestif) or 
             target.effect_list.include?(:soucigraine) 
        if target
          case target.ability_symbol
          when :voile_sable # Voile Sable / Sand Veil (ab)
            if $battle_var.sandstorm?
              n *= 0.8
            end
          end
        end
      end
      
      # Suc Digestif / Soucigraine
      unless user and (user.effect_list.include?(:suc_digestif) or 
             user.effect_list.include?(:soucigraine)) 
        case user.ability_symbol
        when :oeil_compose # Compoundeyes / Oeil Composé (ab)
          return n *= 1.3
        when :agitation # Hustle / Agitation (ab)
          if user_skill.physical
            return n *= 0.8
          end
        end
      end
      
      user.effect_list.each do |effect|
        case effect
        when :reussite_sur # Verrouillage / Lock-on
          return n = 100
        end
      end
      
      # ------------- ------------------ --------------------
      #             Attaques intouchables
      # ------------- ------------------- -------------------
      target.effect_list.each do |effect|
        case effect
        when :tunnel # Tunnel
          if not([:ampleur, :seisme, 
                  :ko_un_coup].include?(user_skill.effect_symbol) and 
             user_skill.type == 9)
            return n = 0
          end
        when :vol # Vol / Flying
          if not([:stratopercut, :ouragan, 
                  :tornade, 
                  :fatal_foudre].include?(user_skill.effect_symbol) or 
             user_skill.id == 18)
            return n = 0
          end
        when :rebond # Bounce / Rebond
          if not([:stratopercut, :ouragan, 
                  :tornade, 
                  :fatal_foudre].include?(user_skill.effect_symbol) or 
             user_skill.id == 18)
            return n = 0
          end
        when :plongee # Dive / Plongée
          if not([57, 67, 250].include?(user_skill.id))
            return n = 0
          end
        end
      end  
      
      
      case user_skill.effect
      # ------------- ------------------ --------------------
      # Attaques réussites sous certaines conditions
      # ------------- ------------------- -------------------
      when :ko_un_coup # OHKO
        if user.level > target.level
          return n += (user.level - target.level)
        else
          return n = 0
        end
      when :devoreve # Dream eater / Devorêve
        if not(target.asleep?)
          return n = 0
        end
      when :changement_force # Whirlwind, Roar
        number = rand(256)
        if number*(user.level + target.level)/256 + 1 == target.level/4
          return n = 0
        end
      when :fatal_foudre # Thunder
        if $battle_var.sunny? # Soleil
          return n = 50
        end
      end
      
      # ------------- ------------------ --------------------
      #             Attaques à précision nulle
      # ------------- ------------------- -------------------      
      if n == 0
        return n = 100
      end
      
      return n
    end
    
    #------------------------------------------------------------ 
    # Impact de la précision
    #------------------------------------------------------------ 
    def accuracy_stage(user, target)
      stage = user.acc_stage - target.eva_stage
      stage = stage < -6 ? -6 : stage > 6 ? 6 : stage
      
      # --------------- ---------------- --------------
      #           Programmation des attaques
      # --------------- ---------------- --------------
      # Clairvoyayance / Foresight
      if target.effect_list.include?(:empeche_esquive)
        stage = user.acc_stage
      end
      # --------------- ---------------- --------------
      # --------------- ---------------- --------------
      
      case stage
      when -6
        return 33.0/100
      when -5
        return 36.0/100
      when -4
        return 43.0/100
      when -3
        return 50.0/100
      when -2
        return 60.0/100
      when -1
        return 75.0/100
      when 0
        return 1
      when 1
        return 133.0/100
      when 2
        return 166.0/100
      when 3
        return 2
      when 4
        return 250.0/100
      when 5
        return 133.0/50
      when 6
        return 3
      end
    end
    
    #------------------------------------------------------------ 
    # Augmentation d'une stat
    #------------------------------------------------------------ 
    # Conséquence de l'augmentation d'une stat : texte et animation + gestion
    # des attaques / capacités spéciales
    # string : la stat visée
    # actor : le Pokémon recevant le changement de stats
    # n : L'augmentation de stat
    # self_inflicted : true s'il s'agit du Pokémon lançant l'attaque sinon false
    # premiere_execution : par défaut true, false si rappellée par une méthode
    # après avoir précèdemment été exécutée
    def raise_stat(string, actor, n = 0, self_inflicted = false, 
                   premiere_execution = true)
      return if actor.dead?
      # Mist/Brume
      if actor.effect_list.include?(:brume) and not self_inflicted
        target = actor == @actor ? @enemy : @actor
        if target.ability_symbol != :infiltration or target == actor
          draw_text("#{actor.given_name} est", "protégé par la brume !")
          wait(40)
          return
        end
      end
      
      # CAPACITE SPECIALE : Contestation
      if actor.ability_symbol == :contestation and premiere_execution and
         n != 0
        inversement_stat(string, actor, n, self_inflicted)
        return
      end
      
      if actor == @actor
        actor_sprite = @actor_sprite
      elsif actor == @enemy
        actor_sprite = @enemy_sprite
      end
      
      if n == 1
        text = "#{actor.given_name} augmente !"
      elsif n > 1
        text = "#{actor.given_name} augmente beaucoup !"
      end
      
      if n != 0
        case string
        when "ATK"
          draw_text("Ah, Attaque de", text)
          stage_animation(actor_sprite, $data_animations[478]) if $anim != 0
        when "DFE"
          draw_text("Ah, Défense de", text)
          stage_animation(actor_sprite, $data_animations[480]) if $anim != 0
        when "ATS"
          draw_text("Ah, Attaque Spéciale de", text)
          stage_animation(actor_sprite, $data_animations[484]) if $anim != 0
        when "DFS"
          draw_text("Ah, Défense Spéciale de", text)
          stage_animation(actor_sprite, $data_animations[486]) if $anim != 0
        when "SPD"
          draw_text("Ah, Vitesse de", text)
          stage_animation(actor_sprite, $data_animations[482]) if $anim != 0
        when "EVA"
          draw_text("Ah, Esquive de", text)        
          stage_animation(actor_sprite, $data_animations[488]) if $anim != 0
        when "ACC"
          draw_text("Ah, Précision de", text)
          stage_animation(actor_sprite, $data_animations[490]) if $anim != 0
        end
      elsif n == 0
        case string
        when "ATK"
          draw_text("Ah, Attaque de", 
                    "#{actor.given_name} n'ira pas plus haut !")
          wait(40)
        when "DFE"
          draw_text("Ah, Défense de", 
                    "#{actor.given_name} n'ira pas plus haut !")
          wait(40)
        when "ATS"
          draw_text("Ah, Attaque Spéciale de",
                    "#{actor.given_name} n'ira pas plus haut !")
          wait(40)
        when "DFS"
          draw_text("Ah, Défense Spéciale de",
                    "#{actor.given_name} n'ira pas plus haut !")
          wait(40)
        when "SPD"
          draw_text("Ah, Vitesse de",
                    "#{actor.given_name} n'ira pas plus haut !")
          wait(40)
        when "EVA"
          draw_text("Ah, Esquive de",
                    "#{actor.given_name} n'ira pas plus haut !")        
          wait(40)
        when "ACC"
          draw_text("Ah, Précision de ",
                    "#{actor.given_name} n'ira pas plus haut !")
          wait(40)
        when 0
          draw_text("Les effets positifs sont supprimés !")
          wait(40)
        end
      end
    end
    
    #------------------------------------------------------------ 
    # Réduction d'une stat
    #------------------------------------------------------------ 
    # Conséquence de la réduction d'une stat : texte et animation + gestion
    # des attaques / capacités spéciales
    # string : la stat visée
    # actor : le Pokémon recevant le changement de stats
    # n : La réduction de stat
    # self_inflicted : true s'il s'agit du Pokémon lançant l'attaque sinon false
    # premiere_execution : par défaut true, false si rappellée par une méthode
    # après avoir précèdemment été exécutée
    def reduce_stat(string, actor, n = 0, self_inflicted = false,
                    premiere_execution = true)
      return if actor.dead?
      # Objet : DEFENSE SPEC
      if actor.effect_list.include?(:defense_spec)
        draw_text("#{actor.given_name} est", "protégé par les changements !")
        wait(40)
        return
      end
      
      # Mist/Brume
      if actor.effect_list.include?(:brume) and not self_inflicted
        target = actor == @actor ? @enemy : @actor
        if target.ability_symbol != :infiltration or target == actor
          draw_text("#{actor.given_name} est", "protégé par la brume !")
          wait(40)
          return
        end
      end
                    
      # CAPACITE SPECIALE : Contestation
      if actor.ability_symbol == :contestation and premiere_execution
        inversement_stat(string, actor, n, self_inflicted)
        return
      end
      
      # CAPACITE SPECIALE : Coeur de Coq
      if actor.ability_symbol == :coeur_de_coq and string == "DFE"
        # Supprime le changement de stat
        actor.change_dfe(-n)
        draw_text("Coeur de Coq de #{actor.given_name}", 
                  "empêche la défense de baisser !")
        wait(40)
        return
      end
      
      unless actor.effect_list.include?(:suc_digestif) or 
             actor.effect_list.include?(:soucigraine)
        # Clear Body / Corps Sain (ab) // White Smoke / Ecran fumée (ab)
        if (actor.ability_symbol == :corps_sain or 
            actor.ability_symbol == :ecran_fumee) and not(self_inflicted)
          draw_text("#{actor.ability_name} de #{actor.given_name}", 
                    "empêche la réduction !")
          wait(40)
          return
        end
        # Keen Eye / Regard Vif (ab)
        if actor.ability_symbol == :regard_vif and string == "ACC"
          draw_text("#{actor.ability_name} de #{actor.given_name}", 
                    "conserve la Précision !")
          wait(40)
          return
        end
        # Hyper Cutter (ab)
        if actor.ability_symbol == :hyper_cutter and string == "ATK"
          draw_text("#{actor.ability_name} de #{actor.given_name}", 
                    "conserve l'Attaque !")
          wait(40)
          return
        end
      end
      
      if actor == @actor
        actor_sprite = @actor_sprite
      elsif actor == @enemy
        actor_sprite = @enemy_sprite
      end
      
      if n == -1
        text = "#{actor.given_name} baisse !"
      elsif n < -1
        text = "#{actor.given_name} baisse beaucoup !"
      end
      
      if n != 0
        case string
        when "ATK"
          draw_text("Ah, Attaque de", text)
          stage_animation(actor_sprite, $data_animations[479]) if $anim != 0
        when "DFE"
          draw_text("Ah, Défense de", text)
          stage_animation(actor_sprite, $data_animations[481]) if $anim != 0
        when "ATS"
          draw_text("Ah, Attaque Spéciale de", text)
          stage_animation(actor_sprite, $data_animations[485]) if $anim != 0
        when "DFS"
          draw_text("Ah, Défense Spéciale de", text)
          stage_animation(actor_sprite, $data_animations[487]) if $anim != 0
        when "SPD"
          draw_text("Ah, Vitesse de", text)
          stage_animation(actor_sprite, $data_animations[483]) if $anim != 0
        when "EVA"
          draw_text("Ah, Esquive de", text)        
          stage_animation(actor_sprite, $data_animations[489]) if $anim != 0
        when "ACC"
          draw_text("Ah, Précision de", text)
          stage_animation(actor_sprite, $data_animations[491]) if $anim != 0
        end
      elsif n == 0
        case string
        when "ATK"
          draw_text("Ah, Attaque de", 
                    "#{actor.given_name} n'ira pas plus bas !")
          wait(40)
        when "DFE"
          draw_text("Ah, Défense de",
                    "#{actor.given_name} n'ira pas plus bas !")
          wait(40)
        when "ATS"
          draw_text("Ah, Attaque Spéciale de",
                    "#{actor.given_name} n'ira pas plus bas !")
          wait(40)
        when "DFS"
          draw_text("Ah, Défense Spéciale de",
                    "#{actor.given_name} n'ira pas plus bas !")
          wait(40)
        when "SPD"
          draw_text("Ah, Vitesse de",
                    "#{actor.given_name} n'ira pas plus bas !")
          wait(40)
        when "EVA"
          draw_text("Ah, Esquive de",
                    "#{actor.given_name} n'ira pas plus bas !")        
          wait(40)
        when "ACC"
          draw_text("Ah, Précision de",
                    "#{actor.given_name} n'ira pas plus bas !")
          wait(40)
        when 0
          draw_text("Les effets positifs sont supprimés !")
          wait(40)
        end
      end
      
      # CAPACITE SPECIALE : Acharné
      if actor.ability_symbol == :acharne and not self_inflicted
        actor.change_atk(+2)
        draw_text("Acharné augmente l'attaque", "de #{actor.given_name}")
        stage_animation(actor_sprite, $data_animations[478]) if $anim != 0
      end
    end
    
    #------------------------------------------------------------ 
    # Inversion de l'effet sur une stat
    #------------------------------------------------------------ 
    # Inverse le changement de stat : réduit si devait augmenté et inversement
    # string : La stat visée
    # actor : Le Pokémon recevant le changement de stat
    # n : La réduction ou l'augmentation de la stat visée
    # self_inflicted : true si concerne le Pokémon lançant l'attaque sinon false
    def inversement_stat(string, actor, n, self_inflicted)
      # Réduction/Augmentation de 2 * n => Supression du changement 
      # et reduction/augmentation
      n = -n
      if n >= 0
        raise_stat(string, actor, n, self_inflicted, false)
      else
        reduce_stat(string, actor, n, self_inflicted, false)
      end
      n *= 2
      case string
      when "ATK"
        actor.change_atk(n)
      when "DFE"
        actor.change_dfe(n)
      when "SPD"
        actor.change_spd(n)
      when "ATS"
        actor.change_ats(n)
      when "DFS"
        actor.change_dfs(n)
      when "EVA"
        actor.change_eva(n)
      when "ACC"
        actor.change_acc(n)
      end
    end
  end
end