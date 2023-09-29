#==============================================================================
# ■ Pokemon_Battle_Trainer // IA
# Pokemon Script Project - Krosk 
# 30/10/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 13/01/2020
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Pokémon Dresseur et Sauvage
#-----------------------------------------------------------------------------
# Gestion de l'IA
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Core
  # - Squelette de l'IA
  # - Méthodes de calcul des taux des attaques - IA
  # - IA des switch
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Squelette de l'IA
    #------------------------------------------------------------
    def ia_rate_calculation(skill, user, target)
      @user_skill = skill
      @user = user
      @target = target
      rate = 0.5
      @ia_type1 = target.type1
      @ia_type2 = target.type2
      # Rate damage
      if skill.power > 0
        # Efficacité
        rate = damage_calculation(0, true) + 0.5

        # Détermine le taux en fonction des attaques
        return execution_return(skill.effect_symbol, "ia_hit", rate, rate)
      else
        # Détermine le taux en fonction des attaques de type statut
        rate = execution_return(skill.effect_symbol, "ia_statut", 30, 30)
        
        # Annulation si le statut n'est pas "normal", et que le 
        #    pokémon va etre soumis à un autre effet de statut
        #    => variation de rate
        if target.status != 0 and rate != 30
          rate = 0.5
        end
        
        # Détermine le taux en fonction des attaques restantes (annexe)
        rate = execution_return(skill.effect_symbol, "ia_annexe", rate, rate)
        
        # Effet général d'accumulation d'effets
        if target.effect_list.include?(skill.effect)
          rate = 0.5
        end
        if user.effect_list.include?(skill.effect)
          rate = 0.5
        end
        return rate
      end
    end
    
    #------------------------------------------------------------ 
    # Méthodes de calcul des taux des attaques - IA
    #------------------------------------------------------------
    # Méthode de calcul concernant les augmentations de stats globales
    # rate : Le taux de chance que l'attaque soit choisie
    # importance : Un nombre réel désignant l'importance des effets
    #              de l'attaque
    # type_stat : Niveau d'une statistique évaluée
    def ia_augmentation_stat(rate, importance, type_stat)
      if type_stat == 6
        rate = 0.5
      end
      rate *= importance*((6-@user.dfe_stage)/6.0)
      return rate
    end

    #------------------------------------------------------------ 
    # IA des switch
    #------------------------------------------------------------
    # Choisis le meilleur switch à faire en fonction du pokémon en face,
    # du type de chaque pokémon de l'équipe concerné par le switch et leurs
    # capacités.
    # party : L'équipe pokémon
    # Renvoie l'ID dans la party du pokémon qui doit remplacé celui qui est
    # switch
    def ia_choice_switch(party)
      rates = Array.new(party.size) # Initialisation : calcul du taux
                                    # chaque pokemon
      # Détermine le rate de chaque pokemon à partir du pokemon n°2
      # comme le pokémon n°1 doit être switch
      enemy = party.actors[0] == @enemy ? @actor : @enemy
      vitesse_enemy = enemy.spd
      0.upto(rates.size - 1) do |j|
        actor = party.actors[j]
        if actor.dead?
          rates[j] = -1.0
          next
        end #else
        # Etude des damages des capacités du pokemon possible sur l'ennemi
        damage_rate = Array.new(actor.skills.size)
        0.upto(actor.skills_set.size - 1) do |i|
          skill = actor.skills_set[i]
          if actor.skills_set[i].pp == 0
            damage_rate[i] = 0
            next
          end
          info = Array.new(2)
          loop do
            info = damage_calculation
            # Quitte la boucle seulement si dans la calculation des dégâts
            # il n'y a pas de coup critique
            break if not info[1]
          end
          # Récupère les damages et multiplie par la précision de l'attaque
          # pour évaluer les chances de réussite si le pokémon envoyé utilise
          # cette attaque
          damage_rate[i] = info[0] * skill.accuracy
          
          next if damage_rate[i] <= 0
          
          # Détermine combien de tour l'attaque en question permettra de mettre
          # K.O. le pokémon adverse
          hp_enemy = enemy.hp
          tour = 0
          while hp_enemy > 0
            # Attaques sur plusieurs tours / Ultralaser
            if skill.effect_symbol != :rechargement and 
               skill.effect_symbol != :ultralaser or tour % 2 == 0
              hp_enemy -= info[0]
            end
            tour += 1
          end
          # Si la vitesse de l'acteur est inférieur et qu'il ne s'agit pas
          # d'une attaque proritaire : incrémente
          tour += 1 if actor.spd < enemy.spd and skill.priority <= 6
          tauxTour = 1.0 - (1.0 / (tour + 1))
          damage_rate[i] -= damage_rate[i] * tauxTour
          
          # Comparaison du nombre de tour nécessaire avec les pp de l'attaque
          if skill.pp > tour
            next
          end #else
          # Si besoin de 3 tours et 2 PP restant => 1 tour ne pourra pas
          # être effectué. Il faut incrémenté de 1 car sinon 1 / 1 = 1
          tour -= skill.pp
          tauxTour = 1.0 - (1.0 / (tour + 1.0))
          damage_rate[i] -= damage_rate[i] * tauxTour
        end
        
        # Etude de la faiblesse du type du pokemon en question sur l'ennemi :
        # Regarde le type du pokémon en face et l'efficacité si le pokémon en
        # face utilise une attaque du même type qu'un de ces 2 types  
        efficiency = element_rate(actor.type1, actor.type2, enemy.type1, 0, 
                                  actor.effect_list)
        tauxFaiblesse = calcul_faiblesse(efficiency)
        if enemy.type2 != 0
          efficiency = element_rate(actor.type1, actor.type2, enemy.type2, 0, 
                                    actor.effect_list)
          tauxFaiblesse *= calcul_faiblesse(efficiency)
        end
        
        # Détermine si le pokémon a un problème de status
        tauxStatus = status_rate(actor) ? 1 : 0.5
        
        # Récupère les damage maximum
        maxDamage = damage_rate[0]
        1.upto(actor.skills_set.size - 1) do |i|
          maxDamage = damage_rate[i] if maxDamage < damage_rate[i]
        end
        rates[j] = tauxFaiblesse * maxDamage * tauxStatus
      end
      
      # Décision => récupère l'index maximum au niveau du taux d'intérressement
      # de switch avec le pokémon en question
      maxRate = rates[0]
      index = 0
      1.upto(rates.size - 1) do |i|
        if maxRate < rates[i]
          maxRate = rates[i]
          index = i
        end
      end
      
      return index
    end
    
    # Détermine si le status est préocuppant pour le pokémon pouvant être
    # switch
    # actor : Le pokémon qui peut être switch
    # Renvoie true si le ratio doit être de 1 sinon false
    def status_rate(actor)
      @objects ||= []
      resultat = true
      list_soin = ["TOTAL SOIN", "POUDRE SOIN", "LAVA COOKIE", "BONBON RAGE",
                   "GUERISON"]
      list_soin_pv = ["POTION", "SUPER POTION", "HYPER POTION", "POTION MAX", 
                      "GUERISON", "RACINERGIE", "SODA COOL", "EAU FRAICHE",
                      "LIMONADE", "LAIT MEUMEU", "JUS DE BAIE", "POUDRENERGIE"]
      objet = @objects.find { |obj| list_soin_pv.include?(obj) }
      need_pv = list_soin_pv.include?(objet) ? 0 : actor.max_hp * 0.25
      objet = @objects.find { |obj| list_soin.include?(obj) }
      return resultat if list_soin.include?(objet) and need_pv <= actor.hp
      resultat = ((actor.status == 0 or 
                  (actor.poisoned? or actor.toxic?) and 
                   @objects.include?("ANTIDOTE")) or
                  (actor.paralyzed? and @objects.include?("ANTI-PARA")) or
                  (actor.frozen? and @objects.include?("ANTIGEL")) or
                  (actor.burn? and @objects.include?("ANTI-BRULE")) or
                  (actor.asleep? and @objects.include?("REVEIL")) and
                  need_pv <= actor.hp)
      return resultat
    end
  end
end