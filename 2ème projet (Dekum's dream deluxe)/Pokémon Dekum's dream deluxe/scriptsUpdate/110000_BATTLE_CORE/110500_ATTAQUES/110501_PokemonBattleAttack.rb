#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Battle_Attack - Damien Linux
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
  # Déroulement d'une attaque
  # Définition
  # Effectue une action
  # Dégâts
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Déroulement d'une attaque
    #------------------------------------------------------------    
    # Traite l'attaque de l'acteur ou de l'ennemi sur un round
    # Squelette du déroulement
    # user_atk :Ccelui qui utilise l'attaque
    # user_skill_atk : L'attaque utilisé
    # enemy : L'autre acteur
    def attack_action(user_atk, user_skill_atk, enemy)
      #------------------------------------------------------------ 
      # Définition des variables de combat
      #------------------------------------------------------------
      assignation(user_atk, user_skill_atk, enemy)
      #------------------------------------------------------------ 
      # Check de la possibilité d'attaquer : problème de status /
      # effets de talents ou attaques
      #------------------------------------------------------------
      return if not check_possibility_attack
      #------------------------------------------------------------ 
      # Check des attaques à concentration ou à effet sur
      # plusieurs tours + utilisation
      #------------------------------------------------------------  
      return if not pre_accuracy_check
      return if @jumper_end
      draw_text("#{@user.given_name} utilise", "#{@user_skill.name}!")
      wait(10)
      # Redéfinition des derniers skills utilisés
      @user_last_skill = @user_skill
      #------------------------------------------------------------ 
      # Décision frappe manquée
      #------------------------------------------------------------       
      n = accuracy_check(@user_skill, @user, @target) #weather, status...
      # Si la cible n'est pas soi meme (10), ou K.O., pas de vérif
      if @user_skill.target != 10 or @user.effect == :ko_un_coup
        n = Integer(n*accuracy_stage(@user, @target))
      end
      number = rand(100)
      @hit = number < n
      @multi_hit = 1 # Nombre de coups
      @total_hit = 1
      #------------------------------------------------------------ 
      # Check du bon fonctionnement d'une attaque : échoue
      # ou rate
      # Effets pré-attaque en cas de non échec
      #------------------------------------------------------------
      miss = pre_miss_attack
      return if @jumper_end
      #------------------------------------------------------------ 
      # Déroulement des attaques : 
      # Attaque plusieurs fois de suite => @multi_hit > 1
      # Attaque une seule fois (une itération) => @multi_hit = 1
      #------------------------------------------------------------
      action_atk(miss, n) while @multi_hit > 0
    end
    
    #------------------------------------------------------------  
    # Définition
    #------------------------------------------------------------
    # Définition des instances, détermine l'acteur, la cible 
    # + initialisation
    # user_atk : Celui qui utilise l'attaque
    # user_skill_atk : L'attaque utilisé
    # enemy : L'autre acteur
    def assignation(user_atk, user_skill_atk, enemy)
      # Initialisation de la liste des pièges
      # Utile pour : Tour rapide et Anti-brume
      @list_piege ||= [[], []]
      @user = user_atk
      @user_skill = user_skill_atk
      @adversaire = enemy
      # target
      @target_id = @user_skill.target
      if @target_id == 0 or @target_id == 4 or @target_id == 8 or 
         @target_id == 20 #Opposants
        @target = enemy
      elsif @target_id == 10
        @target = @user # Défini la cible comme l'acteur
      end
      # Assignation sprite et informations
      if @user == @actor
        @user_sprite = @actor_sprite
        @user_status = @actor_status
        @user_last_skill = $battle_var.actor_last_used
        @user_last_taken_damage = $battle_var.actor_last_taken_damage
      elsif @user == @enemy
        @user_sprite = @enemy_sprite
        @user_status = @enemy_status
        @user_last_skill = $battle_var.enemy_last_used
        @user_last_taken_damage = $battle_var.enemy_last_taken_damage
      end
      if @target == @actor
        @target_sprite = @actor_sprite
        @target_status = @actor_status
        @target_last_skill = $battle_var.actor_last_used
        @target_last_taken_damage = $battle_var.actor_last_taken_damage
      elsif @target == @enemy
        @target_sprite = @enemy_sprite
        @target_status = @enemy_status
        @target_last_skill = $battle_var.enemy_last_used
        @target_last_taken_damage = $battle_var.enemy_last_taken_damage
      end
      @critical_special = @user.get_critical_base
      @last_skill = $battle_var.last_used
    end
    
    # Redétermine l'attaque précédente utilisé par l'attaque qui vient
    # d'être utilisé
    # @damage : les dégâts qui provoqué par l'attaque
    def redefinition
      # Redéfinition des derniers points de dommage infligés
      if @user == @actor
        $battle_var.enemy_last_taken_damage = @damage
      else
        $battle_var.actor_last_taken_damage = @damage
      end
      # @multi_hit
      if @target.dead?
        @total_hit -= @multi_hit
        @multi_hit = 0
      end
    end
    
    # Détermine le taux applicable pour activer l'effet secondaire
    # d'une attaque
    # Renvoie le taux d'activation
    def effets_taux_activation
      ec_rate = rand(101)
      effect_applied = ec_rate <= @user_skill.effect_chance
      # Serene Grace / Sérenité (ab)
      if @user.ability_symbol == :serenite and 
         not (@user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine))
        effect_applied = ec_rate <= (@user_skill.effect_chance * 2)
      end
      return effect_applied
    end
    
    #------------------------------------------------------------  
    # Effectue une action
    #------------------------------------------------------------  
    # Déroulement de l'action d'une attaque
    # Si une attaque comme Combo-griffe est exécuté plusieurs fois,
    # Une utilisation de Combo-griffe = une action
    # miss : Si true, échec de l'attaque
    # precision : La précision de l'attaque. Si 0, l'attaque doit
    # forcément échouer ! (donc passer @hit à false)
    def action_atk(miss, precision)
      @multi_hit -= 1
      #------------------------------------------------------------ 
      # Effets des attaques avant dégâts
      #------------------------------------------------------------ 
      attack_before_damages
      #------------------------------------------------------------ 
      # Détermination des dommages
      #------------------------------------------------------------
      unless miss
        info = damage_calculation(@critical_special)
        @damage_initial = info[0] 
      end
      # Invincibilité
      @hit = false if $game_temp.god_mode or precision == 0
      
      #------------------------------------------------------------ 
      # Traitement des dégâts en fonction des attaques
      #------------------------------------------------------------  
      if @hit and not(miss)
        traitement_degats(info, miss)
        @critical_special = -1
      else
        #-------------------------------------------------------
        # Effets en cas d'échec
        #--------------------------------------------------------
        attack_animation(info, @hit, miss, @user, @user_skill, @user_sprite, 
                         @target_sprite)
        execution(@user_skill.effect_symbol, "miss")
      end
      @user_status.refresh
      @target_status.refresh
    end
    
    #------------------------------------------------------------  
    # Dégâts
    #------------------------------------------------------------  
    # Traitement des dégâts d'une attaque :
    # Vérifie si le pokémon adverse a un effet lui permettant d'encaisser
    # partiellement ou totalement une attaque
    # Afflige les dégâts - Exécution de l'attaque
    # Détermine les effets après l'attaque (dégâts de recul, vol de PV...)
    # Détermine les effets après l'attaque de certains talents
    # info : les informations concernant les dégâts provoqués par l'attaque
    # miss : true si l'attaque a échoué sinon false
    def traitement_degats(info, miss)
      #-------------------------------------------------
      # Mise à jour des dégâts
      #-------------------------------------------------
      efficiency  = info[2]
      # Informations supplémentaires sur l'action de l'attaque
      @action_atk = info[3]
      @damage = info[0]
      return if update_damage(efficiency)
      # ------------------------------------------------
      # Check de l'encaissement des dégâts de type Abri
      # ------------------------------------------------          
      return if not encaissement
      # Animation d'attaque
      attack_animation(info, @hit, miss, @user, @user_skill, @user_sprite, 
                       @target_sprite)
      # Cas des auto-destruction
      if @user_skill.effect_symbol == :auto_ko 
        auto_ko_encaissement
      end
      # Encaissement des dégâts
      degats(efficiency)
      #-------------------------------------------------
      # Application des dégâts
      #-------------------------------------------------
      action_damages
      berry_recoil_damages(efficiency)
      redefinition
      #------------------------------------------------------------ 
      # Effets post-attaque et programmation des attaques
      #------------------------------------------------------------ 
      post_attack(info, @damage, @user_skill.power) if @multi_hit == 0
      # -------------------------------------------------------------
      # Effets influant le taux qu'un effect s'active
      # -------------------------------------------------------------
      effect_applied = effets_taux_activation
      # -------------------------------------------------------------
      # Prise en compte du pourcentage de chance que l'effet s'active
      #                Si l'ennemi est K.O. ou non
      # -------------------------------------------------------------
      recoil_damage = 0
      if ((@user_skill.effect_chance != 0 and effect_applied) or 
          @user_skill.effect_chance == 0)
        # --------------------------------------------------
        #  Effets post attaques
        # ------------------------------------------------- 
        recoil_damage = execution_return(@user_skill.effect_symbol, "post", 
                                          recoil_damage, 0)
      end
      check_post_atk(recoil_damage)
      # -------------------------------------------------------------
      # Prise en compte du pourcentage de chance que l'effet s'active
      #                     Si l'ennemi n'est pas K.O.
      # -------------------------------------------------------------
      if ((@user_skill.effect_chance != 0 and effect_applied) or 
          @user_skill.effect_chance == 0) and not(@target.dead?) and
          (@user_skill.power == 0 or (@user_skill.power > 0 and 
           efficiency != -2)) and # Cas d'une attaque dégat sans être efficace
          not (@target.ability_symbol == :ecran_poudre and 
          @user_skill.effect_chance > 0 and 
          not (@target.effect_list.include?(:suc_digestif) or 
          @target.effect_list.include?(:soucigraine))) 
          # Ecran Poudre / Shield Dust (ab)
        # ------------------------------------------------
        #  Effets annexes des attaques :
        #  - Sur utilisateur
        #  - Changement de stats
        #  - Effets à venir sur de futur tour
        #  - Effets de status
        # La mention "_ko" veut dire que les attaques
        # peuvent être utilisés sans la présence de l'ennemi
        # sur le terrain
        # ------------------------------------------------ 
        execution(@user_skill.effect_symbol, "annexe")
        execution(@user_skill.effect_symbol, "annexe_ko")
      end
      # ---------------------------------------------------
      #     Contrôle des effets adverses / Adversaire
      # ---------------------------------------------------
      annexe_effects_enemy 
      # -------------------------------------------
      # Capacités spéciales à effets Post Attaque
      # -------------------------------------------
      # Suc Digestif / Soucigraine
      unless @target.effect_list.include?(:suc_digestif) or 
             @target.effect_list.include?(:soucigraine) 
        execution(@target.ability_symbol, "after_damage")
      end
      faint_check(@target) # Vérifie si la cible est K.O.
    end
  end
end