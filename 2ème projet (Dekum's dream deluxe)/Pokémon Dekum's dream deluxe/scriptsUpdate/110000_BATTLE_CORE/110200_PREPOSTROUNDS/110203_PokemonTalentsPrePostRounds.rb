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
  # - Enclenchement des talents
  # - Guerison périodique
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Enclenchement des talents
    # actor[0] : actor / actor[1] : actor_status / actor[2]  actor_sprite
    # enemy[0] : enemy / enemy[1] : enemy_status / enemy[2]  enemy_sprite
    #------------------------------------------------------------ 
    # ID : 2
    def crachin_pre_post(actor, enemy)
      txt = "invoque la pluie."
      enclenchement_meteo($battle_var.rain?, $battle_var.set_rain, txt, 493)
    end 
    
    # ID : 3
    def turbo_pre_post(actor, enemy)
      if actor[0].round > 1
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "augmente la Vitesse.")
        actor[0].change_spd(+1)
        stage_animation(actor[2], $data_animations[482])
        wait(40)
      end
    end 
    
    # ID : 22
    def intimidation_pre_post(actor, enemy)
      if not(actor[0].ability_active)
        actor[0].ability_active = true
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "réduit l'Attaque de #{enemy[0].given_name}.")
        enemy[0].change_atk(-1)
        stage_animation(enemy[2], $data_animations[479])
        wait(40)
      end
    end 

    # ID : 45
    def sable_volant_pre_post(actor, enemy)
      txt = "réveille une tempête de sable."
      enclenchement_meteo($battle_var.sandstorm?, 
                          $battle_var.set_sandstorm, txt, 494)
    end 

    # ID : 59
    def meteo_pre_post(actor, enemy)
      if $battle_var.sunny? and not(actor[0].type_fire?)
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "change son type en FEU !")
        actor[0].ability_token = 2
        actor[0].form = 2
        update_sprite
        wait(40)
      elsif $battle_var.rain? and not(actor[0].type_water?)
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "change son type en EAU !")
        actor[0].ability_token = 3
        actor[0].form = 3
        update_sprite
        wait(40)
      elsif $battle_var.hail? and not(actor[0].type_ice?)
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "change son type en GLACE !")
        actor[0].ability_token = 6
        actor[0].form = 6
        update_sprite
        wait(40)
      elsif actor[0].form != 0
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "change son type en NORMAL !")
        actor[0].ability_token = 1
        actor[0].form = 0
        update_sprite
        wait(40)
      end
    end 

    # ID : 70
    def secheresse_pre_post(actor, enemy)
      txt = "intensifie le soleil."
      enclenchement_meteo($battle_var.sunny?, $battle_var.set_sunny, txt, 492)
    end 

    # ID : 118
    def alerte_neige_pre_post(actor, enemy)
      txt = "invoque la grêle."
      enclenchement_meteo($battle_var.hail?, $battle_var.set_hail, txt, 493)
    end 

    # ID : 128
    def baigne_sable_pre_post(actor, enemy)
      if $battle_var.sandstorm? and 
         actor[0].spd_basis == actor[0].spd - actor[0].spd_stage
        actor[0].spd=(actor[0].spd + actor[0].spd_basis)
      elsif not $battle_var.sandstorm? and 
            actor[0].spd_basis < actor[0].spd - actor[0].spd_stage
        actor[0].spd=(actor[0].spd - actor[0].spd_basis)
      end
    end

    # ID : 134
    def defaitiste_pre_post(actor, enemy)
      if actor[0].hp <= Integer(actor[0].max_hp / 2) and 
         not actor[0].effect_list.include?(:defaitiste)
        actor[0].set_bonus_atk(-0.5)
        actor[0].set_bonus_ats(-0.5)
        actor[0].statistic_refresh_modif
        actor[0].skill_effect(:defaitiste)
      elsif actor[0].hp > Integer(actor[0].max_hp / 2) and
            actor[0].effect_list.include?(:defaitiste)
        index = actor[0].effect_list.index(:defaitiste)
        actor[0].effect.delete_at(index)
        actor[0].set_bonus_atk(0, '*', true)
        actor[0].set_bonus_ats(0, '*', true)
        actor[0].statistic_refresh_modif
      end
    end 
    
    def calque_pre_post(actor, enemy)
      list_no_copie = [:don_floral, :illusion, :imposteur, :meteo, :mode_transe, :multi_type, :calque]
      if not list_no_copie.include?(enemy[0].ability_symbol)
        draw_text("Le talent #{enemy[0].ability_name} de #{enemy[0].given_name}", 
                          "a été copié par #{actor[0].ability_name} de #{actor[0].given_name} !")
        actor[0].save_ability = actor[0].ability
        actor[0].ability = enemy[0].ability
        wait(40)
        # Exécute le talent en "pre_post" dans le cas où il doit être exécuté ici
        execution(actor[0].ability_symbol, "pre_post", actor, enemy)
      end
    end
    
    #------------------------------------------------------------  
    # Guérison périodique
    #------------------------------------------------------------ 
    # ID : 44
    def cuvette_pre_post_guerison(actor, enemy)
      if $battle_var.rain?
        bonus = actor[0].max_hp / 16
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "restaure les PV.")
        heal(actor[0], actor[2], actor[1], bonus)
        wait(40)
      end
    end
    
    # ID : 54
    def absenteisme_pre_post_guerison(actor, enemy)
      if actor[0].ability_token == nil
        actor[0].ability_token = true
      end
      if actor[0].ability_token
        actor[0].ability_token = false
      elsif not actor[0].ability_token
        actor[0].ability_token = true
      end
    end
    
    # ID : 61
    def mue_pre_post_guerison(actor, enemy)
      if actor[0].status != 0 and rand(100) < 30
        actor[0].cure
        draw_text("#{actor[0].ability_name} de #{actor[0].given_name}", 
                  "guérit le statut.")
        wait(40)
      end
    end
  end
end