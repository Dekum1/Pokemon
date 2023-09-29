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
  # - Effets prennant effet sur de multiples tours
  # - Soin périodique
  # - Pièges de l'ennemi s'activant sur l'acteur
  # - Effets secondaires
  # - Nettoyage des effets
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Effets prennant effet sur de multiples tours
    #------------------------------------------------------------ 
    def entrave_pre_post_multi(actor)
      index = actor.effect_list.index(:entrave)
      if actor.effect[index][1] == 0
        skill_id = actor.effect[index][2]
        skill = actor.skills_set[skill_id]
        skill.enable
        draw_text(skill.name + " de "+ actor.given_name, "est rétablie!")
        wait(40)
      end
    end

    def encore_pre_post_multi(actor)
      index = actor.effect_list.index(:encore)
      if actor.skills_set[index].pp == 0 
        actor.effect[index][1] = 0 # Fin de l'effet
      end
    end

    def multi_tour_puissance_pre_post_multi(actor)
      index = actor.effect_list.index(:multi_tour_puissance)
      if actor.asleep? or actor.frozen?
        actor.effect.delete_at(index)
      end
    end

    def effets_augmentes_tour_pre_post_multi(actor)
      index = actor.effect_list.index(:effets_augmentes_tour)
      # N'a pas fait de dégât ce tour ci => Suppression
      if actor.effect[index][2] != actor.effect[index][1]
        actor.effect.delete_at(index)
      end
    end
    
    #------------------------------------------------------------  
    # Soin périodique
    # actor[0] : actor / actor[1] : actor_status / actor[2]  actor_sprite
    # enemy[0] : enemy / enemy[1] : enemy_status / enemy[2]  enemy_sprite
    #------------------------------------------------------------
    def vampigraine_pre_post_soin(actor, enemy)
      malus = actor[0].max_hp / 8
      malus = actor[0].max_hp
      draw_text("L'énergie de #{actor[0].given_name}","est drainée !")
      heal(actor[0], actor[2], actor[1], -malus)
      heal(enemy[0], enemy[2], enemy[1], malus)
      wait(40)
    end

    def racines_pre_post_soin(actor, enemy)
      bonus = actor[0].max_hp / 16
      draw_text(actor[0].given_name + " puise", "de l'énergie dans la terre.")
      heal(actor[0], actor[2], actor[1], bonus)
      wait(40)
    end

    def anneau_hydro_pre_post_soin(actor, enemy)
      bonus = actor[0].max_hp / 16
      draw_text(actor[0].given_name + " se soigne", "grâce à ANNEAU HYDRO!")
      heal(actor[0], actor[2], actor[1], bonus)
      wait(40)
    end
    
    #------------------------------------------------------------  
    # Pièges de l'ennemi s'activant sur l'acteur
    # actor[0] : actor / actor[1] : actor_status / actor[2]  actor_sprite
    # enemy[0] : enemy / enemy[1] : enemy_status / enemy[2]  enemy_sprite
    #------------------------------------------------------------ 
    def ligotement_pre_post_enemy_piege(actor, enemy)
      damage = enemy[0].max_hp / 16
      draw_text(enemy[0].given_name, "est piégé !")
      self_damage(enemy[0], enemy[2], enemy[1], damage)
      wait(40)
    end
    
    #------------------------------------------------------------  
    # Effets secondaires
    # actor[0] : actor / actor[1] : actor_status / actor[2]  actor_sprite
    # enemy[0] : enemy / enemy[1] : enemy_status / enemy[2]  enemy_sprite 
    #------------------------------------------------------------ 
    def cauchemard_pre_post_secondaire(actor, enemy)
      if actor[0].asleep?
        damage = actor[0].max_hp / 4
        draw_text(actor[0].given_name + " fait", "un chauchemar !")
        heal(actor[0], actor[2], actor[1], -damage)
        wait(20)
      else
        index = actor[0].effect_list.index(:cauchemard)
        actor[0].effect.delete_at(index)
      end
    end

    def malediction_pre_post_secondaire(actor, enemy)
      damage = actor[0].max_hp / 4
      draw_text(actor[0].given_name + " est", "maudit!")
      heal(actor[0], actor[2], actor[1], -damage)
      wait(20)
    end

    def brouhaha_pre_post_secondaire(actor, enemy)
      if actor[0].asleep?
        actor[0].cure
        draw_text(actor[0].given_name + " se réveille", "à cause du brouhaha !")
        wait(40)
      end
      if actor[0].frozen? # Fin de l'effet
        index = actor[0].effect_list.index(:brouhaha)
        actor[0].effect.delete_at(index)
      end
    end

    def provoc_pre_post_secondaire(actor, enemy)
      index = actor[0].effect_list.index(:provoc)
      actor[0].skills_set.each do |skill|
        if skill.status and actor[0].effect[index][1] > 0 and skill.enabled?
          draw_text("#{skill.name} est bloqué !")
          wait(40)
        elsif actor[0].effect[index][1] == 0 and skill.status 
          draw_text("#{skill.name} est rétablit.")
          skill.enable
          wait(40)
        end
      end
    end

    def baillement_pre_post_secondaire(actor, enemy)
      index = actor[0].effect_list.index(:baillement)
      if actor[0].status == 0 and actor[0].effect[index][1] == 0
        status_check(actor[0], 4)
        actor[1].refresh
      end
    end
    
    #------------------------------------------------------------  
    # Nettoyage des effets
    # actor[0] : actor / actor[1] : actor_status / actor[2]  actor_sprite
    #------------------------------------------------------------ 
    def mur_lumiere_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("L'effet de MUR LUMIERE", "prend fin.")
        wait(40)
      end
    end

    def brume_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("La brume se dissipe.")
        wait(40)
      end
    end

    def protection_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("L'effet de PROTECTION", "prend fin.")
        wait(40)
      end
    end

    def requiem_pre_post_compteur(actor, compteur)
      index = actor[0].effect_list.index(:requiem)
      number = actor[0].effect[index][1]
      if number > 0
        if number > 1
          string = "#{number.to_s} tours"
        elsif number == 1
          string = "#{number.to_s} tour"
        end
        draw_text("Plus que #{string}", "pour #{actor[0].given_name}...")
        wait(40)
      else
        draw_text("#{actor[0].given_name} est", "K.O. par REQUIEM !")
        damage = actor[0].hp
        heal(actor[0], actor[2], actor[1], -damage)
        wait(40)
      end
    end

    def rune_protect_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("L'effet de RUNE PROTECT", "prend fin.")
        wait(40)
      end
    end

    def embargo_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("L'effet d'EMBARGO","prend fin.") 
        wait(40)
      end
    end

    def anti_soin_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("L'effet d'ANTI-SOIN","prend fin.") 
        wait(40)
      end
    end

    def air_veinard_pre_post_compteur(actor, compteur)
      if compteur == 0
        draw_text("L'effet d'AIR VEINARD","prend fin.") 
        wait(40)
      end
    end
    
    #------------------------------------------------------------  
    # Nettoyage des effets stockés dans des groupes d'acteurs
    #------------------------------------------------------------ 
    def prescience_group_pre_post_compteur(actor, enemy, compteur)
      if compteur == 0
        index = actor.effect_list.index(:prescience)
        # data[0] => acteur
        # data[1] => attaque
        # data[2] => ennemi
        data = actor.effect[index][2]
        draw_text("#{enemy.given_name} reçoit l'attaque", "#{data[1].name} !")
        assignation(data[0], data[1], enemy)
        info = damage_calculation(@user.get_critical_base)
        @action_atk = info[3]
        @damage = info[0]
        attack_animation(info, 0, false, @user, @user_skill, @user_sprite, @target_sprite)
        degats(info[2])
        action_damages
        post_attack(info, @damage, @user_skill.power)
        actor.effect.delete_at(index)
      end
    end
    
    def carnareket_group_pre_post_compteur(actor, enemy, compteur)
      if compteur == 0
        index = actor.effect_list.index(:carnareket)
        # data[0] => acteur
        # data[1] => attaque
        # data[2] => ennemi
        data = actor.effect[index][2]
        draw_text("#{enemy.given_name} reçoit l'attaque", "#{data[1].name} !")
        assignation(data[0], data[1], enemy)
        @damage = (((data[0].level * 2 / 5.0 + 2) * data[1].power * data[0].ats / enemy.dfs) / 50)
        info = [@damage, false, 0, 0]
        attack_animation(info, 0, false, @user, @user_skill, @user_sprite, @target_sprite)
        degats(0)
        action_damages
        post_attack(info, @damage, @damage)
        actor.effect.delete_at(index)
      end
    end
  end
end