#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attack_Pre_Hit - Damien Linux
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
  # - Effets des attaques sur l'action en cours
  # - Effets sur l'utilisateur
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Squelette
    #------------------------------------------------------------
    def attack_before_damages
      # Skill Effect
      execution(@user_skill.effect_symbol, "pre_hit")
      # User effect
      @user.effect.each do |effect|
        execution(effect[0], "pre_hit_user", effect)
      end
    end
    
    #------------------------------------------------------------ 
    # Effets des attaques sur l'action en cours
    #------------------------------------------------------------
    def critique_eleve_pre_hit
      @critical_special += 1
    end
    alias pique_pre_hit critique_eleve_pre_hit
    alias pied_bruleur_pre_hit critique_eleve_pre_hit
    alias queue_poison_pre_hit critique_eleve_pre_hit

    def triple_pied_pre_hit
      if not(@user.effect_list.include?(:triple_pied))
        @user.skill_effect(:triple_pied, 1, 0)
      else
        index = @user.effect_list.index(:triple_pied)
        @user.effect[index][2] += 1
        # Accuracy check à chaque coup
        n = accuracy_check(@user_skill, @user, @target)
        n = Integer(n*accuracy_stage(@user, @target))
        @hit = rand(100) <= n
      end
    end

    def tour_rapide_pre_hit
      list = [:vampigraine, :ligotement]
      @liberation = 0
      index = @target == @enemy ? 1 : 0
      # Désactivation des pièges
      @list_piege[index].each do |piege|
        suppression_effets_tour(@user, piege)
        @list_piege[index].delete(piege)
      end
      list.each do |effect|
        if @target.effect_list.include?(effect)
          index = @target.effect_list.index(effect)
          @target.effect.delete_at(index)
          @liberation += 1
        end
      end
      if @liberation > 0
        draw_text("#{@user.given_name}", "se libère !")
        wait(40)
      end
      tour_rapide_effect(@user, @target)
    end
    
    #------------------------------------------------------------ 
    # Effets sur l'utilisateur
    #------------------------------------------------------------
    def puissance_pre_hit_user(effect)
      @critical_special += 2
    end

    def tourmente_pre_hit_user(effect)
      index = @user.skills_set.index(@user_last_skill)
      @user.skills_set[index].disable
      
      skill_index = effect[2]
      @user.skills_set[skill_index].enable
      
      # new index = index du skill bloqué
      new_index = @user.skills_set.index(@user_last_skill)
      effect[2] = new_index
    end
  end
end