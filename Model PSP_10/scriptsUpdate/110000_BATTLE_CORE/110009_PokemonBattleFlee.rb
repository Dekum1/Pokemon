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
  # Déroulement lorsque l'action fuite est enclenchée :
  # - Fuite de la part de l'utilisateur
  # - Vérifie si la fuite est autorisée
  # - Interdictions de fuire
  # - Fuite ennemie
  # - Echec de la fuite
  #
  # La fin d'un combat par fuite est gérée dans Pokemon_Battle_End
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Fuite de la part de l'utilisateur
    #------------------------------------------------------------           
    def run
      if run_able?(@actor, @enemy) and not $game_switches[INTERDICTION_FUITE]
        $battle_var.run_count += 1
        @action = false
        end_battle_flee
      else
        $battle_var.run_count += 1
        fail_flee
        @phase = 2
        @actor_action = 0
        $battle_var.action_id = 0
      end
    end
    
    #------------------------------------------------------------  
    # Vérifie si la fuite est autorisée
    #------------------------------------------------------------   
    def run_able?(runner, opponent)
      x = (Integer(opponent.spd/4) % 255)
      if x <= 0
        x = 1
      end
      rate = Integer(runner.spd*32/x)+(30*($battle_var.run_count))
      if not(flee_able(runner, opponent))
        return false
      end
      if opponent.spd <= runner.spd
        return true
      elsif x == 0
        return true
      elsif rate > 255
        return true
      elsif rand(256) <= rate
        return true
      else
        return false
      end
    end
    
    #------------------------------------------------------------    
    # Interdictions de fuire
    #------------------------------------------------------------    
    def flee_able(actor, enemy)
      # Run away / Fuite (ab)
      if actor.ability_symbol == :fuite and 
         not (actor.effect_list.include?(:suc_digestif) or 
         actor.effect_list.include?(:soucigraine))
        return true
      end
      # Arena Trap / Piege (ab)
      if enemy.ability_symbol == :piege_sable and 
         not (enemy.effect_list.include?(:suc_digestif) or 
         enemy.effect_list.include?(:soucigraine))
        draw_text("#{enemy.ability_name} de #{enemy.given_name}", "empêche #{actor.given_name} de fuir !")
        wait(40)
        return false
      end
      list = [:empeche_fuite, :racines]
      actor.effect_list.each do |effect|
        if list.include?(effect)
          return false
        end
      end
      # Shadow Tag / Marque Ombre (ab) // Magnepiece / Magnet Pull (ab)
      if ((enemy.ability_symbol == :marque_ombre or 
           enemy.ability_symbol == :magnepiege) and not 
          (enemy.effect_list.include?(:suc_digestif) or 
           enemy.effect_list.include?(:soucigraine))) and
          enemy.type_steel?
        draw_text("#{enemy.ability_name} de #{enemy.given_name}", "empêche #{actor.given_name} de fuir !")
        wait(40)
        return false
      end
      return true
    end
    
    #------------------------------------------------------------  
    # Fuite ennemie
    #------------------------------------------------------------ 
    def run_enemy
      if run_able?(@enemy, @actor)
        end_battle_flee_enemy
      end
    end
    
    #------------------------------------------------------------  
    # Echec de la fuite
    #------------------------------------------------------------ 
    def fail_flee
      draw_text("Vous ne pouvez pas","fuire le combat !")
      wait(40)
    end
  end
end