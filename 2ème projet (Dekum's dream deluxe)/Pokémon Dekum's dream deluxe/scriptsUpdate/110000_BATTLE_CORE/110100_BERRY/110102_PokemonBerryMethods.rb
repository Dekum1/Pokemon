#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Berry_Methods - Damien Linux
# 24/04/2020
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
  # - Baies à utilisation classiques
  # - Baies dont l'effet varie en fonction des attaques
  # - Cas spécifiques de certaines baies
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------    
    # Baies à utilisation classiques
    # actor[0] : actor / actor[1] : actor_status / actor[2] : actor_sprite
    # enemy[0] : enemy / enemy[1] : enemy_status / enemy[2] : enemy_sprite
    #------------------------------------------------------------
    def baie_ceriz(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = guerison_status(actor[0], 2)
      if autorise
        draw_text("#{actor[0].given_name} n'est plus", "paralysé !")
        wait(40)
      end
      return autorise
    end
    
    def baie_maron(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = guerison_status(actor[0], 4)
      if autorise
        draw_text("#{actor[0].given_name} se", "réveille !")
        wait(40)
      end
      return autorise
    end
    
    def baie_pecha(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = guerison_status(actor[0], 1, 8)
      if autorise
        draw_text("#{actor[0].given_name} n'est plus", "empoisonné !")
        wait(40)
      end
      return autorise
    end
    
    def baie_fraive(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = guerison_status(actor[0], 3)
      if autorise
        draw_text("#{actor[0].given_name} n'est plus", "brûlé !")
        wait(40)
      end
      return autorise
    end
    
    def baie_willia(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = guerison_status(actor[0], 5)
      if autorise
        draw_text("#{actor[0].given_name} n'est plus", "gelé !")
        wait(40)
      end
      return autorise
    end
    
    def baie_mepo(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = false
      actor[0].skills_set.each do |skill|
        autorise = skill.pp == 0
        if autorise
          draw_text("#{actor[0].given_name} mange une", "#{target[0].item_name}")
          wait(40)
          skill.pp += 10
          skill.pp = skill.ppmax if skill.pp > skill.ppmax
          draw_text("Les PP de #{skill.name}", "ont augmenté !")
          wait(40)
          break
        end
      end
      return autorise
    end
    
    def baie_oran(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = ((actor[0].hp <= actor[0].max_hp * 0.5) or
                  (force and actor[0].hp != actor[0].max_hp))
      if autorise
        draw_text("#{actor[0].given_name} mange une", "#{target[0].item_name}")
        wait(40)
        heal(actor[0], actor[2], actor[1], 10)
        draw_text("Les PV de #{actor[0].given_name}", "ont augmenté !")
        wait(40)
      end
      return autorise
    end
    
    def baie_kika(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = guerison_status(actor[0], 6)
      if autorise
        draw_text("#{actor[0].given_name} n'est plus", "confus !")
        wait(40)
      end
      return autorise
    end
    
    def baie_prine(actor, target, coef, force)
      return false if not check_berry(actor[0])
      status = actor[0].get_status
      # Non utilisé si aucun status ou peur
      autorise = (status != 0 and status != 7)
      if autorise
        draw_text("#{actor[0].given_name} mange une", "#{target[0].item_name}")
        wait(40)
        actor[0].cure
        draw_text("#{actor[0].given_name} n'a plus", "de problème de status !")
        wait(40)
      end
      return autorise
    end
    
    def baie_sitrus(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = ((actor[0].hp <= actor[0].max_hp * 0.5) or
                  (force and actor[0].hp != actor[0].max_hp))
      if autorise
        draw_text("#{actor[0].given_name} mange une", "#{target[0].item_name}")
        wait(40)
        bonus = actor[0].max_hp / 4
        heal(actor[0], actor[2], actor[1], bonus)
        draw_text("Les PV de #{actor[0].given_name}", "ont augmenté !")
        wait(40)
      end
      return autorise
    end
    
    def baie_figuy(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return guerison_confuse(coef, actor[0], actor[2], actor[1], 
                              force, target[0], "Assuré", "Modeste", "Timide", 
                              "Calme")
    end
    
    def baie_wiki(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return guerison_confuse(coef, actor[0], actor[2], actor[1], 
                              force, target[0], "Rigide", "Jovial", "Prudent", 
                              "Malin")
    end
    
    def baie_mago(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return guerison_confuse(coef, actor[0], actor[2], actor[1], 
                              force, target[0], "Brave", "Discret", "Relax", 
                              "Malpoli")
    end
    
    def baie_gowav(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return guerison_confuse(coef, actor[0], actor[2], actor[1], 
                              force, target[0], "Mauvais", "Foufou", "Naïf", 
                              "Lâche")
    end
    
    def baie_papaya(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return guerison_confuse(coef, actor[0], actor[2], actor[1], 
                              force, target[0], "Solo", "Doux", "Gentil", "Pressé")
    end
    
    def baie_lichii(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return augmentation_stats_baie(coef, actor[0], "ATK", target[0], force)
    end
    
    def baie_lingan(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return augmentation_stats_baie(coef, actor[0], "DFE", target[0], force)
    end
    
    def baie_sailak(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return augmentation_stats_baie(coef, actor[0], "SPD", target[0], force)
    end
    
    def baie_pitaye(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return augmentation_stats_baie(coef, actor[0], "ATS", target[0], force)
    end
    
    def baie_abriko(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return augmentation_stats_baie(coef, actor[0], "DFS", target[0], force)
    end
    
    def baie_frista(actor, target, coef, force)
      return false if not check_berry(actor[0])
      autorise = ((actor[0].hp <= actor[0].max_hp * coef) or
                  (force and actor[0].hp != actor[0].max_hp))
      if autorise
        draw_text("#{actor[0].given_name} mange une", "#{target[0].item_name}")
        wait(40)
        random_raise(actor)
      end
      return autorise
    end
    
    def baie_micle(actor, target, coef, force)
      return false if not check_berry(actor[0])
      return augmentation_stats_baie(coef, actor[0], "ACC", target[0], force)
    end
    
    #------------------------------------------------------------    
    # Baies dont l'effet varie en fonction des attaques
    #------------------------------------------------------------
    def baie_jaboca(actor, skill, target)
      return false if not check_berry(actor)
      return skill.physical ? Integer(target.max_hp * 0.125) : -1
    end
    
    def baie_pommo(actor, skill, target)
      return false if not check_berry(actor)
      return skill.special ? Integer(target.max_hp * 0.125) : -1
    end
    
    def baie_rangma(actor, skill, target)
      return false if not check_berry(actor)
      recoil_damage = (skill.special and not actor.dead?) ? 0 : -1
      if recoil_damage == 0
        draw_text("#{actor.given_name} mange une #{actor.item_name}")
        wait(40)
        augmentation_stat("DFS", 1, actor)
      end
      return recoil_damage
    end
    
    def baie_eka(actor, skill, target)
      return false if not check_berry(actor)
      recoil_damage = (skill.physical and not actor.dead?) ? 0 : -1
      if recoil_damage == 0
        draw_text("#{actor.given_name} mange une", "#{actor.item_name}")
        wait(40)
        augmentation_stat("DFE", 1, actor)
      end
      return recoil_damage
    end
    
    #------------------------------------------------------------    
    # Cas spécifiques de certaines baies
    #------------------------------------------------------------
    # Définie les effets de la baie zalis : encaisse la première attaque de
    # type normal
    # actor : L'acteur, celui qui mange la baie
    # damage : Les dégâts de l'attaque
    # user : L'utilisateur de l'attaque
    # user_skill : L'attaque utilisée
    # Renvoie les dégâts à infliger
    def baie_zalis(actor, damage, user, user_skill)
      return false if not check_berry(actor)
      if actor.item_hold == id_berry(:baie_zalis) and 
         user_skill.type_normal?
        damage /= 2
        draw_text("#{actor.given_name} Mange une", "#{actor.item_name},")
        wait(40)
        draw_text("cela réduit les dégâts de", "#{user.given_name}.")
        wait(40)
        actor.item_hold = 0
      end
      return damage
    end
    
    # Définie les effets de la baie chérim : prioritaire au tour suivant
    # actor : L'acteur, celui qui mange la baie
    def baie_cherim(actor)
      return false if not check_berry(actor)
      # Si non nul c'est qu'un évènement de priorité empêche les bons effets
      # provoqués par la baie : ne fait rien
      if @prio == nil
        coef = 0.25
        coef = 0.5 if actor.ability_symbol == :gloutonnerie
        if actor.item_hold == id_berry(:baie_cherim) and 
           actor.hp <= actor.max_hp * coef
          @prio = actor == @actor # true => acteur en 1er sinon ennemie
          draw_text("#{actor.given_name} Mange une", "#{actor.item_name}")
          wait(40)
          draw_text("#{actor.given_name} attaquera en premier", 
                    "au tour suivant !")
          wait(40)
          actor.item_hold = 0
        end
      end
    end
    
    # Définie les effets de la baie enigma : récupère 25% de ces PV si est
    # touché par une attaque super efficace
    # actor : L'acteur, celui qui mange la baie
    # actor_sprite : Le sprite de l'acteur
    # actor_status : La fenêtre de status liée à l'acteur
    # efficiency : L'efficacité de l'attaque adverse
    def baie_enigma(actor, actor_sprite, actor_status, efficiency)
      return false if not check_berry(actor)
      if actor.item_hold == id_berry(:baie_enigma) and efficiency == 1 and 
         not actor.dead?
        draw_text("#{actor.given_name} mange une", "#{actor.item_name}")
        wait(40)
        bonus = actor.max_hp / 4
        heal(actor, actor_sprite, actor_status, bonus)
        draw_text("Les PV de #{actor.given_name}", "ont augmenté !")
        wait(40)
        actor.item_hold = 0
      end
    end
    
    # Définie les effets de la baie lansat : augmente le taux de coup critique
    # si l'utilisateur de l'attaque a en-dessous de 25% de ces PV
    # actor : L'acteur, celui qui mange la baie
    # Renvoie 1 s'il y a un ajout au coup critique (de 1) et 0 si aucun ajout
    def baie_lansat(actor)
      return false if not check_berry(actor)
      coef = 0.25
			coef = 0.5 if actor.ability_symbol == :gloutonnerie
      if actor.item_hold == id_berry(:baie_lansat) and 
         actor.hp <= actor.max_hp * coef
        draw_text("#{actor.given_name} mange une", "#{actor.item_name}")
        wait(40)
        draw_text("Le taux de coup critique de", 
                  "#{actor.given_name} a augmenté !")
        wait(40)
        actor.item_hold = 0
        actor.add_critical_base
        return 1
      end #else
      return 0
    end
  end
end