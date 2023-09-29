#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attack_Talents - Damien Linux
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
  # - Talents avant les dégâts
  # - Talents après les dégâts
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Talents avant les dégâts
    #------------------------------------------------------------
    def static_after_damage
      # Contact + dommages + 30% chance # force?
      if @user_skill.direct? and @damage > 0 and rand(100) < 30
        draw_text("#{@target.ability_name} de #{@target.given_name}",   
                  "paralyse #{@user.given_name} !")
        wait(40)
        status_check(@user, 2, true)
        @user_status.refresh
        wait(40)
      end
    end 

    def absorb_volt_before_damage(efficiency)
      if @user_skill.type_electric? and @damage > 0
        @damage = 0
        bonus = @target.max_hp / 4
        heal(@target, @target_sprite, @target_status, bonus)
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "restaure ses PV.")
        wait(40)
        return true # SAUT
      end
    end 

    def absorb_eau_before_damage(efficiency)
      if @user_skill.type_water? and @damage > 0
        @damage = 0
        bonus = @target.max_hp / 4
        heal(@target, @target_sprite, @target_status, bonus)
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "restaure ses PV.")
        wait(40)
        return true # SAUT
      end
    end 

    def torche_before_damage(efficiency)
      if @user_skill.type_fire? and not(@target.ability_active)
        @damage = 0
        @target.ability_active = true
        draw_text("#{@target.ability_name} de #{@target.given_name}", "s'active!")
        wait(40)
        return true # SAUT
      elsif @user_skill.type_fire?
        @damage = 0
      end
    end 
    
    def garde_mystik_before_damage(efficiency)
      if efficiency != 1 and @damage > 0 and @target != @user
        @damage = 0
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "le protège !")
        wait(40)
        return true # SAUT
      end
    end 
    
    def levitation_before_damage(efficiency)
      if @user_skill.type_ground? 
         not @target.effect_list.include?(:gravite)
        @damage = 0
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "le protège !")
        wait(40)
        return true # SAUT
      end
    end 

    def analyste_before_damage(efficiency)
      if @precedent != nil
        @damage += @damage * 0.3
      end
    end 
    
    def motorise_before_damage(efficiency)
      if @user_skill.type == 4 and @user != @target
        @damage = 0
        draw_text("#{@target.ability_name} de #{@target.given_name} l'immunise", "aux dégats de type Electric")
        wait(40)
        n = @target.change_spd(+1)
        raise_stat("SPD", @target, n)
        return true # SAUT
      end
    end
    
    def lavabo_before_damage(efficiency)
      if @user_skill.type_water? and @user != @target
        @damage = 0
        draw_text("#{@target.ability_name} de #{@target.given_name} l'immunise", "aux dégats de type Eau")
        wait(40)
        n = @target.change_ats(+1)
        raise_stat("ATS", @target, n)
        return true # SAUT
      end
    end
    
    def fermete_before_damage(efficiency)
      @fermete = (@target.max_hp == @target.hp and (@target.hp - @damage) <= 0)
      if @fermete
        @damage = @target.hp - 1
      end
      return false
    end
    
    #------------------------------------------------------------ 
    # Talents après les dégâts
    #------------------------------------------------------------
    def statik_after_damage
      if @user_skill.direct? and rand(100) < 30 and not @user.paralyzed?
        draw_text("#{@target.ability_name} de #{@target.given_name}", "paralyse #{@user.given_name} !")
        status_check(@user, 2)
        @user_status.refresh
        wait(40)
      end
    end
    
    def deguisement_after_damage
      type = @user_skill.type
      if [@user.type1, @user.type2].include?(type) and type != 0 and 
        type != @user.ability_token and @damage > 0
        @user.ability_token = type
        string = type_string(type)
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "change le type en " + string + " !")
        wait(40)
      end
    end 

    def peau_dure_after_damage
      if @user_skill.direct? and @damage > 0
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "blesse #{@user.given_name} !")
        rec_damage = @user.max_hp / 8
        self_damage(@user, @user_sprite, @user_status, rec_damage)
        wait(40)
      end
    end 

    def pose_spore_after_damage
      # Contact + dommages + 10% chance # force?
      if @user_skill.direct? and @damage > 0 and rand(100) < 10  and 
         @user.ability_symbol != :envelocape
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "laisse des spores !")
        wait(40)
        status_check(@user, [1, 2, 4][rand(3)], true)
        @user_status.refresh
        wait(40)
      end
    end 

    def synchro_after_damage
      if @target.ability_token != nil
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "inflige le même statut !")
        wait(40)
        status_check(@user, @target.ability_token, true)
        @user_status.refresh
        @target.ability_token = nil
      end
    end 

    def point_poison_after_damage
      # Contact + dommages + 30% chance # force?
      if @user_skill.direct? and @damage > 0 and rand(100) < 30 
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empoisonne #{@user.given_name} !")
        wait(40)
        status_check(@user, 1, true)
        @user_status.refresh
        wait(40)
      end
    end 

    def joli_sourire_after_damage
      # N'est pas affecté si a Bénêt
      if @user.ability_symbol != :benet
        # Contact + dommages + 30% chance # force?
        if @user_skill.direct? and @damage > 0 and rand(100) < 30 and
           not(@target.effect_list.include?(:attraction) or 
           (@target.gender + @user.gender) != 3)
          @user.skill_effect(:attraction)
          draw_text("#{@target.ability_name} de #{@target.given_name}", 
                    "séduit #{@user.given_name} !")
          wait(40)
        end
      else
        draw_text("Ça n'affecte pas #{@user.given_name} !")
        wait(40)
      end
    end

    def corps_ardent_after_damage
      # Contact + dommages + 30% chance # force?
      if @user_skill.direct? and @damage > 0 and rand(100) < 30 
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "brûle #{@user.given_name} !")
        wait(40)
        status_check(@user, 3, true)
        @user_status.refresh
        wait(40)
      end
    end 
    
    def boom_final_after_damage
      if @target.dead? and @user_skill.direct?
        draw_text("Boom Final de #{@target.given_name}", 
                  "blesse #{@user.given_name} !")
        damage = Integer(@user.max_hp / 4)
        self_damage(@user, @user_sprite, @user_status, damage)
        wait(40)
      end
    end 

    def armurouillee_after_damage
      if @user_skill.physical and @damage > 0
        n = actor.change_dfe(-1)
        if n != 0
          draw_text("Armurouillée baisse la défense", 
                    "de #{actor.given_name} !")
          stage_animation(@target_sprite, $data_animations[481]) if $anim != 0
        end
        n = actor.change_spd(+2)
        if n != 0
          draw_text("Armurouillée augmente la vitesse", 
                    "de #{actor.given_name} !")
          stage_animation(@target_sprite, $data_animations[482]) if $anim != 0
        end
      end
    end 

    def coeur_noble_after_damage
      if @user_skill.type_dark?
        n = actor.change_atk(+1)
        if n != 0
          draw_text("Coeur Noble augmente l'attaque", "de #{actor.given_name} !")
          stage_animation(@target_sprite, $data_animations[478]) if $anim != 0
        end
      end
    end 

    def corps_maudit_after_damage
      if rand <= 1.0 and @user != @target
        index = @user.skills_set.index(@user_skill)
        # Une seule capacité peut être entravée par corps maudit
        if index != nil and 
           not @user.effect_list.include?(:corps_maudit)
          @user.skill_effect(:corps_maudit, 4, index)
          @user.skills_set[index].disable
          draw_text("#{@user.skills_set[index].name} est bloqué par", 
                    "Corps Maudit de #{@target.given_name} !")
          wait(40)
        end
      end
    end 

    def herbivore_after_damage
      if @user_skill.type_grass? and @user_skill.effect_symbol != :soin_status
        n = actor.change_atk(+1)
        if n != 0
          draw_text("Herbivore augmente l'attaque", "de #{actor.given_name} !")
          stage_animation(@target_sprite, $data_animations[478]) if $anim != 0
        end
      end
    end 

    def illusion_after_damage
      if @user_skill.physical and @damage > 0
        if @target == @actor and @actor.get_illusion != nil
          @target_sprite.bitmap = RPG::Cache.battler(@target.battler_back, 0)
          reset_illusion(@target, true)
          if not @target.dead? and @party.size > 1
            stage_animation(@target_sprite, $data_animations[144]) if $anim != 0
            draw_text("L'illusion de #{@target.given_name} se brise !")
            wait(40)
          end
          @target.last_name=(nil)
        elsif @target == @enemy and @enemy.get_illusion != nil
          @target_sprite.bitmap = RPG::Cache.battler(@target.battler_face, 0)
          reset_illusion(@target, true)
          if not @target.dead? and $battle_var.enemy_party.size > 1
            stage_animation(@target_sprite, $data_animations[144]) if $anim != 0
            draw_text("L'illusion de #{@target.given_name} se brise !")
            wait(40)
          end
          @target.last_name=(nil)
        end
      end
    end 
    
    def fermete_after_damage
      if @fermete
        draw_text("#{@target.ability_name} de #{@target.given_name} lui", "permet d'encaisser les coups !")
        wait(40)
      end
    end
  end
end