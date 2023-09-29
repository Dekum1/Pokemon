#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Battle_Berry - Damien Linux
# 03/11/19
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
  # - Check de baie
  # - Utilisation de baie
  # - Guérison status
  # - Guérison + confus
  # - Augmentation stats
  # - Divers méthodes sur les baies
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------    
    # Check de baie
    #------------------------------------------------------------
    def check_berry(actor)
      return (not actor.effect_list.include?(:embargo))
    end
    
    #------------------------------------------------------------    
    # Utilisation de baie
    #------------------------------------------------------------
    # Utilisation d'une baie en combat
    # Définie l'ensemble des utilisation de baie lorsque celle-ci est appellée
    # actor : acteur, celui qui mange la baie
    # target : celui dont la baie provient (par défaut l'acteur)
    # force : si true force l'action
    # réduisant les dégâts
    # Renvoie true si la baie est mangée et que les effets ont eu lieu
    # sinon false
    def use_berry(actor, target = nil, force = false)
      target ||= actor
      if actor == @actor
        actor_list = [actor, @actor_status, @actor_sprite]
        target_list = target == actor ? actor_list : 
                                        [target, @enemy_status, @enemy_sprite]
      else
        actor_list = [target, @enemy_status, @enemy_sprite]
        target_list = target == actor ? actor_list : 
                                        [actor, @actor_status, @actor_sprite]
      end
      
      coef = actor.ability_symbol != :gloutonnerie ? 0.25 : 0.5
      return execution_return(symbol_berry(target.item_hold), "", false, 
                              actor_list, target_list, coef, force)
    end
    
    # Utilisation d'une baie réduisant les dégâts en combat
    # actor : acteur, celui qui mange la baie
    # damage : Les dégâts infligé par une capacité : utilisé pour les baies
    # skill : L'attaque adverse utilisé
    # Renvoie des dégâts si la baie est utilisée
    # Sinon renvoie nil
    def use_berry_damage(actor, damage, skill)
      method_to_call = "skill.type_#{symbol_berry_type(actor.item_hold)}?"
      if methods.include?(method_to_call)
        return damage / 2 if send(method_to_call)
      end # else
      return nil
    end
    
    # Utilisation d'une baie dont les effets se sont en fonction du type
    # d'attaque reçu
    # actor : acteur, celui qui mange la baie
    # damage : Les dégâts infligés par une capacité
    # skill : L'attaque adverse utilisée
    # target : la cible des dégâts de recul
    # Renvoie les dégâts de recul s'il y en a, 0 si la baie est juste mangée,
    # sinon -1
    def use_berry_skill(actor, skill, target)
      return execution_return(symbol_berry_skill(target.item_hold), "", -1, 
                              actor, skill, target)
    end
    
    #------------------------------------------------------------    
    # Guérison status
    #------------------------------------------------------------
    # Guéris un status en fonction du status requis
    # actor : acteur à guérir
    # type_status : les type de status que le pokémon doit avoir pour être
    # guérit
    # Renvoie true si la baie est mangée sinon false
    def guerison_status(actor, *type_status)
      status = actor.get_status
      autorise = false
      type_status.each do |type|
        autorise = (status == type)
        if autorise
          draw_text("#{actor.given_name} mange une", "#{actor.item_name}")
          wait(40)
          actor.cure
          break
        end
      end
      return autorise
    end
 
    #------------------------------------------------------------    
    # Guérison + confus
    #------------------------------------------------------------
    # Guéris un pokémon mais le rend confus
    # coef : Le coefficient autorisée sur ls HP Max pour que les effets prennent
    # actor : l'acteur à guérir
    # actor_sprite : le sprite de l'acteur
    # actor_status : le status de l'acteur
    # force : si true force l'action
    # target : celui dont la baie provient (par défaut l'acteur)
    # natures : les nature qui ne sont pas victimes de la confusion
    # Renvoie true si la baie est mangée sinon false
    def guerison_confuse(coef, actor, actor_sprite, actor_status, force, target, 
                         *natures)
      if ((actor.hp <= actor.max_hp * coef) or 
         (force and actor.hp != actor.max_hp))
        draw_text("#{actor.given_name} mange une", "#{target.item_name}")
        wait(40)
        bonus = actor.max_hp / 2
        heal(actor, actor_sprite, actor_status, bonus)
        draw_text("Les PV de #{actor.given_name}", "ont augmenté !")
        wait(40)
        actor_nature = actor.get_nature
        natures.each do |nature|
          confus = nature == actor_nature
          if confus
            break
          end
        end
        if confus
          status_check(actor, 6, true)
        end
        return true
      end #else
      return false
    end
    
    #------------------------------------------------------------    
    # Augmentation stats
    #------------------------------------------------------------
    # Augmente la stat en fonction de la baie mangée
    # coef : Le coefficient autorisée sur ls HP Max pour que les effets prennent
    # actor : L'acteur mangeant la baie
    # target : celui dont la baie provient (par défaut l'acteur)
    # force : si true force l'action
    # stat : La stat augmentée
    def augmentation_stats_baie(coef, actor, stat, target, force)
      if ((actor.hp <= actor.max_hp * coef) or 
         (force and actor.hp != actor.max_hp))
          draw_text("#{actor.given_name} mange une", "#{target.item_name}")
          wait(40)
          raise_stat(stat, actor, 1, true)
      end
    end
    
    #------------------------------------------------------------    
    # Divers méthodes sur les baies
    #------------------------------------------------------------
    # Récupère l'ID de la baie dans Objets en BDD en fonction du symbole
    # symbol : le symbole désignant la baie
    # Renvoie l'ID de la baie dans le fichier de configuration
    def id_berry(symbol)
      return HASH_BERRY_ANNEXE[symbol]
    end
    
    # Récupère le symbole de la baie dans le fichier de configuration concernant
    # les baies classiques
    # id : L'identifiant de la baie dans Objets en BDD
    # Renvoie le symbole correspond à l'ID de la baie
    def symbol_berry(id)
      return HASH_BERRY[id]
    end
    
    # Récupère le symbole de la baie dans le fichier de configuration concernant
    # les baies dont l'effet varie en fonction de l'attaque
    # id : L'identifiant de la baie dans Objets en BDD
    # Renvoie le symbole correspond à l'ID de la baie
    def symbol_berry_skill(id)
      return HASH_BERRY_SKILL[id]
    end
    
    # Récupère le symbole de la baie dans le fichier de configuration concernant
    # les baies qui baisse les dégâts d'une attaque super efficace
    # id : L'identifiant de la baie dans Objets en BDD
    # Renvoie le symbole correspond à l'ID de la baie
    def symbol_berry_type(id)
      return HASH_BERRY_TYPE[id]
    end
  end
end