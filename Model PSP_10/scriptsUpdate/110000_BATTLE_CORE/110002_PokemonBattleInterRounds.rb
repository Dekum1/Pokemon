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
  # Phases pendant un round
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    # Recherche de priorité
    # Détermine qui doit attaquer en premier pendant le round en cours
    # Cas 1 : L'attaque de l'acteur est prioritaire sur l'ennemie
    # Cas 2 : L'attaque de l'ennemie est prioritaire sur l'acteur
    # Cas 3 : Les attaques de l'acteur et de l'ennemie ont la même priorité
    def turn_order 
      # Cas où la priorité est réglé ultérieurement
      if @prio != nil
        @strike_first = @prio
        @prio = nil # reset de la priorité manuelle
        return
      end

      # Comparaison des priorités
      if @actor_skill == nil or @enemy_skill == nil
        @strike_first = true
        return
      end
      
      if @actor_action != 1 # Attaque
        @strike_first = false
        return
      end  
      
      actor_priority = @actor_skill.priority
      enemy_priority = @enemy_skill.priority
      # Cas des CAPACITES SPECIALES : Farceur / Ailes bourrasques
      if @actor.ability_symbol == :farceur and @actor_skill.status
        actor_priority += 1
      end
      if @enemy.ability_symbol == :farceur and @enemy_skill.status
        enemy_priority += 1
      end
      
      if actor_priority > enemy_priority 
        @strike_first = true
      elsif actor_priority < enemy_priority
        @strike_first = false
      else
        # En cas d'égalité de priorité
         if @actor.item_hold == 95 && @enemy.item_hold == 95
          speed_boost_a = rand(100)
          speed_boost_b = rand(100)
          if speed_boost_a < 20 and !(speed_boost_b < 20)
            @strike_first = true
            draw_text("La Vive Griffe de #{@actor.name}", 
                      "lui permet d'agir en priorité")
            wait(40)
            return
          elsif speed_boost_b < 20 and !(speed_boost_a < 20)
            @strike_first = false
            draw_text("La Vive Griffe de #{@enemy.name}", 
                      "lui permet d'agir en priorité")
            wait(40)
            return
          end
        elsif @actor.item_hold == 95
          speed_boost = rand(100)
          if speed_boost < 20
            @strike_first = true
            draw_text("La Vive Griffe de #{@actor.name}", 
                      "lui permet d'agir en priorité")
            wait(40)
            return
          end
        elsif @enemy.item_hold == 95
          speed_boost = rand(100)
          if speed_boost < 20
            @strike_first = false
            draw_text("La Vive Griffe de #{@enemy.name}", 
                      "lui permet d'agir en priorité")
            wait(40)
            return
          end
        end
        if (@actor.item_hold == 407 or @actor.item_hold == 350) and 
            not(@enemy.item_hold == 407 || @enemy.item_hold == 350)
          @strike_first = false
          return
        elsif @enemy.item_hold == 407 or @enemy.item_hold == 350 and 
              not(@actor.item_hold == 407 || @actor.item_hold == 350) 
          @strike_first = true
          return
        end
        if @actor.effect_list.include?(:vent_arriere) and 
           not @enemy.effect_list.include?(:vent_arriere)
          if @enemy.spd > @actor.spd*2
            @strike_first = false
          elsif @enemy.spd < @actor.spd*2
            @strike_first = true
          else
            @strike_first = rand(2)>0 ? true : false
          end
        elsif @enemy.effect_list.include?(:vent_arriere) and 
              not @actor.effect_list.include?(:vent_arriere)
          if @enemy.spd*2 > @actor.spd
            @strike_first = false
          elsif @enemy.spd*2 < @actor.spd
            @strike_first = true
          else
            @strike_first = rand(2)>0 ? true : false
          end
        else
          if @enemy.spd > @actor.spd
            @strike_first = false
          elsif @enemy.spd < @actor.spd
            @strike_first = true
          else
            @strike_first = rand(2)>0 ? true : false
          end
        end
        if @actor.effect_list.include?(:distorsion) # Distorsion
          @strike_first = !@strike_first
        end
      end
    end
    
    #------------------------------------------------------------  
    # Rounds
    #------------------------------------------------------------            
    def phase2 # Pré_Rounds
      @action = false
      @choix.visible = false
      @fond.visible = false
      @curseur.visible = false
      @actor_status.visible = true
      @enemy_status.visible = true
      @actor_status.refresh
      @enemy_status.refresh
      draw_text("","")
      
      # Préround 1: Fuite
      if @actor_action == 4
        run
      end
      if @enemy_action == 4
        enemy_run
      end
      mega_evolution #méga
      
      # Préround 2: Item
      if @actor_action == 3
        actor_item_use
      end
      if @enemy_action == 3
        enemy_item_use
      end
      
      # Préround 3: Switch Pokémon
      if @actor_action == 2
        # Si Poursuite utilisé => enclenchement de la phase 3 puis switch
        if @enemy_skill and @enemy_skill.effect_symbol == :poursuite
          @phase3DejaActif = 1
          phase3
          actor_pokemon_switch
        else
          actor_pokemon_switch
        end
      end
      if @enemy_action == 2
        # Si Poursuite utilisé => enclenchement de la phase 3 puis switch
        if @actor_skill.effect_symbol == :poursuite
          @phase3DejaActif = 1
          phase3
          enemy_pokemon_switch
        else
          enemy_pokemon_switch
        end
      end
      
      @actor_status.refresh
      @enemy_status.refresh
    end
        
    # Round: Attaques
    def phase3 
      @force_switch = false
      faint_check
      if @actor.dead? or @enemy.dead? or $battle_var.battle_end?
        return
      end
      
      @suivant = nil
      @precedent = nil
      if @strike_first
        if @actor_action == 1 and not(@actor.dead?)
          @suivant = @enemy_skill
          attack_action(@actor, @actor_skill, @enemy)
        end
      else
        if not(@enemy_caught) and @enemy_action == 1 and not(@enemy.dead?) 
          @suivant = @actor_skill
          attack_action(@enemy, @enemy_skill, @actor)
        end
      end
      return if @force_switch
      
      faint_check
      # Si pokémon adversaire K.O. sans que pokémon actèel est attaqué
      # (Cas connu : auto-destruction)
      # alors le tour continue
      if (@actor.dead? or @enemy.dead? or $battle_var.battle_end?) and 
         (@actor.dead? and @enemy.dead?)
        return
      elsif (@actor.dead? or @enemy.dead? or $battle_var.battle_end?) and @user_last_skill != nil
        if @user_last_skill.effect_symbol != :auto_ko 
          return
        end
      end
      
      if not(@strike_first)
        if @actor_action == 1 and not(@actor.dead?)
          @precedent = @enemy_skill
          attack_action(@actor, @actor_skill, @enemy)
        end
      else
        if not(@enemy_caught) and @enemy_action == 1 and not(@enemy.dead?)
          @precedent = @actor_skill
          attack_action(@enemy, @enemy_skill, @actor)
        end
      end
      
      faint_check
      if @actor.dead? or @enemy.dead? or $battle_var.battle_end?
        return
      end
    end
  end
end