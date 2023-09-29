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
  # Méthodes de calcul en combat :
  # - Enclenchement d'un évènement météo
  # - Suppression des effets d'un piège
  # - Calcul des dégâts : spécifique à clonage
  # - Supprime les effets d'illusion
  # - Saut de phase (pour les attaques à répition ou à charger / recharger)
  # - Conséquences de Tour Rapide
  # - Retourne une attaque non-offensive contre sa cible
  # - Copie du pokémon adverse : Morphing
  # - Chargement du pokémon : multi-tour
  # - Augmentation/Réduction du stat : bonne redirection
  # - Augmentation de 2 niveaux aléatoires
  # - Contrôleurs
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Enclenchement d'un évènement météo
    #------------------------------------------------------------
    # Enclenchement d'un évènement météo pendant un combat (pluie / soleil /
    # grêle / tempête de sable)
    # condition_meteo : Vérifie que la météo n'est pas déjà présente
    # var_tempete : permet de provoquer l'évènement météo
    # txt_tempete : le texte adapté en fonction de l'évènement météo
    # index_anim : l'index de l'animation à faire en fonction de l'évènement
    # météo
    def enclenchement_meteo(condition_tempete, var_tempete, txt_tempete, 
                            index_anim)
      if not(condition_tempete)
        draw_text("#{actor.ability_name} de #{actor.given_name}", txt_tempete)
        wait(40)
        animation = $data_animations[index_anim]
        @actor_sprite.animation(animation, true) if $anim != 0
        loop do
          @actor_sprite.update
          $scene.battler_anim ; Graphics.update
          Input.update
          if not(@actor_sprite.effect?)
            break
          end
        end
      end
      var_tempete
    end
    
    
    #------------------------------------------------------------  
    # Suppression des effets d'un piège
    #------------------------------------------------------------
    # Supprime les effets des attaques de type picots
    # user : pokémon utilisateur de l'attaque supprimant les effets
    # var_stock : la variable à modifier pour supprimer les effets
    # var_stock[0] => piège positionné par l'acteur sur l'ennemie
    # var_stock[1] => piège positionné par l'ennemie sur l'acteur
    def suppression_effets_tour(user, var_stock)
      if var_stock != nil
        index = user == @actor ? 1 : 0
        if var_stock[index] > 0
          var_stock[index] = 0
          if @liberation != nil
            # Pour Tour Rapide : si liberation > 1, prévient que l'acteur 
            # est libéré
            @liberation += 1
          end
        end
      end
    end
    
    #------------------------------------------------------------  
    # Calcul des dégâts : spécifique à clonage
    #------------------------------------------------------------
    # Vérifie si un pokémon est cloné, si oui donne des dégâts au clone
    # user : pokémon subissant clonage
    # user_skill : Attaque utilisé par le pokémon lanceur
    # damage : les dommages subit par le clone
    # target : la cible de l'attaque (possédant le clone)
    # Renvoie true si le pokémon adverse est cloné, false sinon (par défaut)
    def clonage(user, user_skill, damage, target)
      index = user == @actor ? 1 : 0
      if @clone != nil and @clone[index] == 1 and not user_skill.sonore?
        # Vérifie si l'attaque subit est différente d'une attaque sans dommage
        # ou avec amélioration des points de vies
        # Vérifie si l'attaque utilisé n'est pas clonage
        if damage > 0 and user_skill.effect_symbol != :clonage_attaque
          tmpDamage = @hpClone[index]
          @hpClone[index] -= damage
          draw_text("le clone de #{target.given_name}", "prend des dégâts !")
          wait(40)
        else
          return false
        end
        if  @hpClone[index] <= 0
          damage = tmpDamage
          @clone[index] = 0
          draw_text("#{target.given_name}", "perd son clone")
          # Rétablissement des stats avant le clonage
          target.atk_stage=(@statAvantClonage[index][0])
          target.ats_stage=(@statAvantClonage[index][1])
          target.dfe_stage=(@statAvantClonage[index][2])
          target.dfs_stage=(@statAvantClonage[index][3])
          target.acc_stage=(@statAvantClonage[index][4])
          target.eva_stage=(@statAvantClonage[index][5])
          target.spd_stage=(@statAvantClonage[index][6])
          # Reset du status confus
          if target.confused? and not @confused[index]
            target.cure_state
          end
          # Reset du status paralysé
          if target.paralyzed? and not @paralyzed[index]
            target.cure
          end
          if user_skill.effect_symbol == :ultralaser
            # Pas besoin de se reharger pour ultralaser
            @nonRecharge = true
          end
          wait(40)
        end
        @effective_damage = damage
        return true
      end #else
      return false
    end
    
    #------------------------------------------------------------  
    # Supprime les effets d'illusion
    #------------------------------------------------------------
    # Reset les effets d'illusion lors d'un switch ou en fin de combat
    # actor : l'acteur visé
    def reset_illusion(actor, update = false)
      if actor.ability_symbol == :illusion
        if actor == @actor and @actor.get_illusion != nil
          # Modifie le nom du pokémon pour la fonction recall_pokemon
          # Dans Pokemon_Battle_Core_1
          actor.gender=(actor.get_gender)
          last_name = actor.given_name
          actor.change_name(actor.get_name)
          actor.last_name=(last_name)
          @actor.illusion=(nil)
          # Mise à jour du sprite rétablit
          update_sprite if update
        elsif @enemy.get_illusion != nil
          actor.gender=(actor.get_gender)
          last_name = actor.name
          # Suppression du nom spécial
          actor.name_enemy=(nil)
          type_name = @enemy.male? ? "ennemi" : "ennemie"
          name = @enemy.name + " " + type_name
          actor.change_name(name)
          actor.last_name=(last_name)
          @enemy.illusion=(nil)
          # Mise à jour du sprite rétablit
          update_sprite if update
        end
      end
    end
    
    #------------------------------------------------------------  
    # Saut de phase (pour les attaques à répition ou à charger / recharger)
    #------------------------------------------------------------
    # Vérification saut de phase
    # Force l'utilisateur à continuer à attaquer         
    def phase_jump(enemy = false)
      @last_skill = $battle_var.last_used
      list = [:coupe_vent, :pique, :rechargement, :mania,
              :multi_tour_puissance, :brouhaha, :patience, :multi_tour_confus,
              :coud_krane, :lance_soleil, :ultralaser, :tunnel, :vol, 
              :rebond, :plongee, :mitra_poing, :revenant]
      if not(enemy) # Actor
        @actor.effect_list.each do |effect|
          if list.include?(effect)
            @actor_skill = $battle_var.actor_last_used
            @phase = 2
            return true
          end
        end
        return false
      elsif enemy
        @enemy.effect_list.each do |effect|
          if list.include?(effect)
            @enemy_skill = $battle_var.enemy_last_used
            return false
          end
        end
        return true
      end
    end
       
    # Vérification saut de phase de sélection d'attaque
    #     Force l'utilisateur à utiliser la même attaque     
    def attack_selection_jump
      @actor.effect_list.each do |effect|
        case effect
        when :encore # Encore
          return true
        when :patience # Patience / Bide
          return true
        when :multi_tour_confus # Mania / Thrash
          return true
        end
      end
      return false
    end
    
    #------------------------------------------------------------    
    # Conséquences de Tour Rapide
    #------------------------------------------------------------ 
    def tour_rapide_effect(actor, enemy)
      enemy.effect_list.each do |effect|
        if effect == :vampigraine  or effect == :ligotement
          enemy.effect.delete(effect)
        end
      end
    end
    
    #------------------------------------------------------------    
    # Retourne une attaque non-offensive contre sa cible
    #------------------------------------------------------------
    # Retourne l'attaque de l'utilisateur contre la cible s'il s'agit d'une
    # attaque non offensive plus gestion de certaines exceptions dans
    # effect_list
    # user : L'utilisateur de l'attaque*
    # user_skill : L'attaque effectuée
    # target : Cible de l'attaque
    # Renvoie la cible si le retournement de l'attaque ne peut pas se faire
    # sinon renvoie l'utilisateur (qui devient la cible)
    def retour_magik(user, user_skill, target)
      effect_list = [[:malediction, (not user.type_ghost?)]]
      if user != target and user_skill.status
        autorise = true
        effect_list.each do |effect|
          autorise = user_skill.effect_symbol != effect[0] or 
                     effect[1] != nil and not effect[1]
          if not autorise
            break
          end
        end
        if not autorise
          @string_magik = nil
          return target
        end #else
        return user
      end #else
      @string_magik = nil
      return target
    end
    
    #------------------------------------------------------------    
    # Copie du pokémon adverse : Morphing
    #------------------------------------------------------------ 
    # Transforme le pokémon acteur en pokémon cible (capacité Morphing
    # et talent Imposteur)
    # user : L'acteur
    # target : L'ennemie copié
    def morphing(user, target)
      if user.effect_list.include?(:entrave) # Cure Disable / Entrave
        index = user.effect_list.index(:entrave)
        skill_index = user.effect[index][2]
        user.skills_set[skill_index].enable
      end
      
      set = []
      target.skills_set.each do |skill|
        adskill = skill.clone
        adskill.define_ppmax(5)
        adskill.refill
        adskill.enable
        set.push(adskill)
      end
      
      data = user.clone
      user.skill_effect(:morphing, -1, data)
      if user == @actor
        @actor.skills_set = set
        @actor.transform_effect(target)
        @actor_sprite.bitmap = RPG::Cache.battler(@enemy.battler_back, 0)
        @actor_sprite.ox = @actor_sprite.bitmap.width / 2
        height = @actor_sprite.bitmap.height
        coef_position = height / (height * 0.16 + 14)
        @actor_sprite.oy = height - height / coef_position
        $scene.battler_anim ; Graphics.update
      else
        @enemy.skills_set = set
        @enemy.transform_effect(target)
        @enemy_sprite.bitmap = RPG::Cache.battler(@actor.battler_face, 0)
        @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
        height = @enemy_sprite.bitmap.height
        coef_position = height / (height * 0.16 + 14)
        @enemy_sprite.oy = height - height / coef_position
        $scene.battler_anim ; Graphics.update
      end
    end
    
    #------------------------------------------------------------    
    # Chargement du pokémon : multi-tour
    #------------------------------------------------------------ 
    # Tour de chargement du pokémon
    # user : L'utilisateur de l'attaque
    # effect : L'ID de l'effet de l'attaque
    # nb_tour : La durée en rounds de l'effet
    # string : Le texte à afficher pour mentionner que le pokémon se charge
    def chargement(user, effect, nb_tour, string)
      if not(user.effect_list.include?(effect)) # not(Déjà préparé)
        user.skill_effect(effect, nb_tour)
        draw_text("#{user.given_name} #{string}")
        @jumper_end = true
        wait(40)
      elsif user.effect_list.include?(effect)
        @pp_use = false
        index = user.effect_list.index(effect)
        user.effect.delete_at(index)
      end
    end
    
    #------------------------------------------------------------    
    # Augmentation/Réduction du stat : bonne redirection
    #------------------------------------------------------------
    # Augmentation d'une statistique
    # string : la stat à augmenter
    # bonus : le niveau d'augmentation
    # target : La cible subissant l'augmentation
    # user : L'utilisateur provoquant l'augmentation
    def augmentation_stat(string, bonus, target, user = nil)
      n = 0
      case string
      when "ATK"
        n = user == nil ? target.change_atk(bonus) : 
                          target.change_atk(bonus, user)
      when "DFE"
        n = user == nil ? target.change_dfe(bonus) : 
                          target.change_dfe(bonus, user)
      when "SPD"
        n = user == nil ? target.change_spd(bonus) : 
                          target.change_spd(bonus, user)
      when "ATS"
        n = user == nil ? target.change_ats(bonus) : 
                          target.change_ats(bonus, user)
      when "DFS"
        n = user == nil ? target.change_dfs(bonus) : 
                          target.change_dfs(bonus, user)
      when "EVA"
        n = user == nil ? n = target.change_eva(bonus) : 
                              target.change_eva(bonus, user)
      when "ACC"
        n = user == nil ? n = target.change_acc(bonus) : 
                              target.change_acc(bonus, user)
      end
      self_inflicted = user == nil or user == target
      raise_stat(string, target, n, self_inflicted)
    end
    
    # Réduction d'une statistique
    # string : la stat à réduire
    # malus : le niveau de réduction
    # target : La cible subissant la réduction
    # user : L'utilisateur provoquant la réduction
    def reduction_stat(string, malus, target, user = nil)
      n = 0
      case string
      when "ATK"
        n = user == nil ? target.change_atk(malus) : 
                          target.change_atk(malus, user)
      when "DFE"
        n = user == nil ? target.change_dfe(malus) : 
                          target.change_dfe(malus, user)
      when "SPD"
        n = user == nil ? target.change_spd(malus) : 
                          target.change_spd(malus, user)
      when "ATS"
        n = user == nil ? target.change_ats(malus) : 
                          target.change_ats(malus, user)
      when "DFS"
        n = user == nil ? target.change_dfs(malus) : 
                          target.change_dfs(malus, user)
      when "EVA"
        n = user == nil ? target.change_eva(malus) : 
                          target.change_eva(malus, user)
      when "ACC"
        n = user == nil ? target.change_acc(malus) : 
                          target.change_acc(malus, user)
      end
      self_inflicted = user == nil or user == target
      reduce_stat(string, target, n, self_inflicted)
    end
    
    #------------------------------------------------------------  
    # Augmentation de 2 niveaux aléatoires
    #------------------------------------------------------------
    # Augmente au hsard une stat de 2 niveaux
    # user : Le receveur de l'augmentation
    def random_raise(user)
      random_stat = rand(7).to_i
      case random_stat
      when 0
        augmentation_stat("ATK", 2, user)
      when 1
        augmentation_stat("DFE", 2, user)
      when 2
        augmentation_stat("SPD", 2, user)
      when 3
        augmentation_stat("ATS", 2, user)
      when 4
        augmentation_stat("DFS", 2, user)
      when 5
          augmentation_stat("ACC", 2, user)
      when 6
        augmentation_stat("EVA", 2, user)
      end
    end
    
    # Détermine les faiblesses de l'acteur à partir des efficacités de
    # l'ennemi
    # efficiency : l'efficacité de l'ennemi
    # Renvoie le taux de faiblesse de l'acteur
    def calcul_faiblesse(efficiency)
      faiblesse = 3.0 # Type inneficace
      case efficiency
      when 25.0 # double type pas très efficace
        faiblesse = 2.0
      when 50.0 # un type pas très efficace
        faiblesse = 1.5
      when 100.0 # normal
        faiblesse = 1.0
      when 200.0 # un type très efficace
        faiblesse = 0.5
      when 400.0 # double type très efficace
        faiblesse = 0.25
      end
      
      return faiblesse
    end
    
    #------------------------------------------------------------  
    # Contrôleurs
    #------------------------------------------------------------
    # Contrôleur redirigeant sur la bonne méthode pour les attaques /
    # talents et objets...
    # effect : L'effet à exécuter sous forme de méthode
    # suffixe : suffixe de la fonction (exemple : post)
    # param1 : Un paramètre de la méthode à appeller
    # param2 : 2eme paramètre de la méthode à appeller
    # param3 : 3eme paramètre de la méthode à appeller
    # param4 : 4eme paramètre de la méthode à appeller
    def execution(effect, suffixe = "", param1 = nil, param2 = nil, 
                  param3 = nil, param4 = nil)
      method_to_call = suffixe.size > 0 ? "#{effect}_#{suffixe}" : effect.to_s
      if methods.include?(method_to_call)
        if param1 != nil and param2 != nil and param3 != nil and param4 != nil
          send(method_to_call, param1, param2, param3, param4)
        elsif param1 != nil and param2 != nil and param3 != nil
          send(method_to_call, param1, param2, param3)
        elsif param1 != nil and param2 != nil
          send(method_to_call, param1, param2)
        elsif param1 != nil
          send(method_to_call, param1)
        else
          send(method_to_call)
        end
      end
    end
    
    # Contrôleur redirigeant sur la bonne méthode pour les attaques /
    # talents et objets... Avec valeur de retour
    # effect : L'effet à exécuter sous forme de méthode
    # suffixe : suffixe de la fonction (exemple : post)
    # default : retour par défaut si la fonction ne s'exécute pas
    # param1 : Un paramètre de la méthode à appeller
    # param2 : 2eme paramètre de la méthode à appeller
    # param3 : 3eme paramètre de la méthode à appeller
    # param4 : 4eme paramètre de la méthode à appeller
    # Retourne la valeur de la fonction
    def execution_return(effect, suffixe = "", default = true, param1 = nil, 
                         param2 = nil, param3 = nil, param4 = nil)
      method_to_call = suffixe.size > 0  ? "#{effect}_#{suffixe}" : effect.to_s
      if methods.include?(method_to_call)
        if param1 != nil and param2 != nil and param3 != nil and param4 != nil
          resultat = send(method_to_call, param1, param2, param3, param4)
        elsif param1 != nil and param2 != nil and param3 != nil
          resultat = send(method_to_call, param1, param2, param3)
        elsif param1 != nil and param2 != nil
          resultat = send(method_to_call, param1, param2)
        elsif param1 != nil 
          resultat = send(method_to_call, param1)
        else
          resultat = send(method_to_call)
        end
      else
        resultat = default
      end
      return resultat
    end
  end
end