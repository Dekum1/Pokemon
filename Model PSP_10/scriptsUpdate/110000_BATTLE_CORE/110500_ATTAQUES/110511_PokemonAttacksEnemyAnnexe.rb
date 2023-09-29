#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attacks_Enemy_Annexe - Damien Linux
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
  # - Squelette
  # - Effets sur l'ennemi
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Squelette
    #------------------------------------------------------------
    def annexe_effects_enemy
      @target.effect_list.each do |effect|
        execution(effect, "annexe_enemy")
      end  
      faint_check(@target)
    end
    
    #------------------------------------------------------------ 
    # Effets sur l'ennemi
    #------------------------------------------------------------
    def patience_annexe_enemy
      index = @target.effect_list.index(:patience)
      @target.effect[index][2] += @damage
    end

    def frenesie_annexe_enemy
      if @damage > 0 and @multi_hit == 0 # Compte une seule fois
        index = @target.effect_list.index(:frenesie)
        @target.change_atk(+1, @user)
        @target.effect[index][2] += 1
      end
    end

    def prlvt_destin_annexe_enemy
      if @target.dead?
        damage = @user.hp
        draw_text("#{@target.given_name}", "est lié par le destin.")
        self_damage(@user, @user_sprite, @user_status, damage)
        wait(40)
        faint_check(@user)
      end
    end

    def rancune_annexe_enemy
      if @target.dead? and not(@user.dead?)
        @user_skill.pp = 0
      end
    end
  end
end