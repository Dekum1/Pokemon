#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attack_Update_Hit - Damien Linux
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
  # - Mise à jour des dégâts - Squelette
  # - Encaissement - Squelette
  # - Dégâts
  # - Dégâts des baies
  # - Mise à jour des dégâts en cas de switch - Attaques
  # - Mise à jour des dégâts - Attaques
  # - Encaissement - Attaques
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Mise à jour des dégâts - Squelette
    #------------------------------------------------------------
    def update_damage(efficiency)
      saut = false
      # Effets attaque et programmation des attaques
      execution(@user_skill.effect_symbol, "hit")
      # Capacités spéciales à effets Pré Attaque
      # Suc Digestif / Soucigraine
      unless @target.effect_list.include?(:suc_digestif) or 
             @target.effect_list.include?(:soucigraine) 
        saut = execution_return(@target.ability_symbol, "before_damage", false, efficiency)
      end
      # Dégâts des baies
      baie_hit
      return saut
    end
    
    #------------------------------------------------------------ 
    # Encaissement - Squelette
    #------------------------------------------------------------
    def encaissement
      resultat = true
      # Cas de Abri / Détection / Garde-Lame
      if @target.effect_list.include?(:encaissement_attaque)
        return false unless encaissement_attaque_encaissement
      end
      
      # Cas de Vol Magnétik
      if @target.ability_symbol != :levitation and 
         @target.effect_list.include?(:vol_magnetik) and 
         not(@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine)) 
        resultat = (not @user_skill.type_ground? or 
                    @target.effect_list.include?(:gravite))
        if not resultat
          @damage = 0
          draw_text("VOL MAGNETIK de #{@target.given_name}", "le protège !")
          wait(40)
        end
      end
      return resultat
    end
    
    def degats(efficiency)
      if @damage > 0
        case efficiency
        when 0 # Normal
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:degat]}", 100)
          blink(@target_sprite, 3, 3)
        when 1 # Super efficace
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:degat_plus]}", 100)
          blink(@target_sprite, 2, 5)
        when -1 # Peu efficace
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:degat_moins]}", 100)
          blink(@target_sprite, 4, 2)
        end
      end
    end
    
    #------------------------------------------------------------ 
    # Dégâts
    #------------------------------------------------------------
    def action_damages
      # Cas de ténacité
      string = ""
      if @target.effect_list.include?(:tenacite)
        string = tenacite_encaissement
      end
      @effective_damage = 0
      # S'assure que @damage est bien un int pour éviter les erreurs
      @damage = Integer(@damage)
      # Cas du Pokémon cloné acteur - Pokémon cloné ennemie - Dommages normaux
      if not clonage(@user, @user_skill, @damage, @target)
        # Dommages normaux
        1.upto(@damage) do |i|
          @effective_damage += 1
          @target.remove_hp(1)
          @target_status.refresh
          if @target.max_hp >= 144 and 
             @effective_damage % (@target.max_hp / 144 + 1) != 0
            next
          end
          $scene.battler_anim ; Graphics.update
          #Graphics.update
          if @target.dead?
            # Loyauté
            @target.drop_loyalty
            break
          end
        end
      end
      @damage = @effective_damage
      # Cas de ténacité
      if string.size > 0
        draw_text(string)
        wait(40)
      end
    end

    
    #------------------------------------------------------------ 
    # Dégâts des baies
    #------------------------------------------------------------
    # Dégâts provoqués par une baie
    # @damage : Les dégâts causés
    def baie_hit
      # Gestion des baies pour les dégâts
      if @user != @target
        tmp_damage = use_berry_damage(@target, @damage, @user_skill)
        if tmp_damage != nil 
          draw_text("#{@target.given_name} Mange une", "#{@target.item_name},")
          wait(40)
          draw_text("cela réduit les dégâts de", "#{@user.given_name}.")
          wait(40)
          @target.item_hold = 0
          @damage = tmp_damage
        else # Gestion du cas de la Baie Zalis
          @damage = baie_zalis(@target, @damage, @user, @user_skill)
        end
      end
    end
    
    #------------------------------------------------------------ 
    # Mise à jour des dégâts en cas de switch - Attaques
    #------------------------------------------------------------
    def poursuite_hit
      if @phase3DejaActif == 1 or 
         (@phase3DejaActif == 0 and @precedent != nil and
          (@precedent.effect_symbol == :demi_tour or
           (@precedent.effect_symbol == :change_eclair and 
            @user.ability_symbol != :absorb_volt)))
        @damage *= 2
      end
    end
    
    #------------------------------------------------------------ 
    # Mise à jour des dégâts - Attaques
    #------------------------------------------------------------
    def patience_hit
      if @damage > 0
        index = @user.effect_list.index(:patience)
        @damage = @user.effect[index][2] * 2
      end
    end

    def ko_un_coup_hit
      if @damage > 0 # Affecté par les immunités
        @damage = @target.hp
      end
    end 

    def croc_fatal_hit
      if @damage > 0 # Affecté par les immunités
        @damage = @target.hp / 2
      end
    end

    def draco_rage_hit
      if @damage > 0
        @damage = 40
      end
    end

    def degats_niveau_hit
      if @damage > 0
        @damage = @user.level
      end
    end

    def vague_psy_hit
      if @damage > 0
        @damage = Integer( @user.level * (rand(11) * 10 + 50) / 100 )
      end
    end

    def riposte_hit
      if @damage > 0
        @damage = @user_last_taken_damage * 2
      end
    end

    def faux_chage_hit
      if @target.hp - @damage <= 0
        @damage = @target.hp - 1
      end
    end

    def cadeau_hit
      number = rand(256)
      @gift = number >= 26
      if not @gift
        @damage = 120
      elsif number < 102
        @damage = 80
      elsif number < 204
        @damage = 40
      else
        @damage = 0
      end
    end
    
    def saumure_hit
      if @target.hp < (@target.max_hp/2)
        @damage *= 2
      end
    end

    def sonicboom_hit
      if @damage > 0
        @damage = 20
      end
    end

    def voile_miroir_hit
      if @damage > 0
        @damage = @user_last_taken_damage * 2
      end  
    end

    def effort_hit
      if @damage > 0
        @damage = @target.hp - @user.hp
      end
    end
    
    def puissant_si_blesse_hit
      if @user_last_taken_damage > 0 and not @strike_first
        @damage *= 2
      end
    end
    
    #------------------------------------------------------------ 
    # Encaissement - Attaques
    #------------------------------------------------------------
    def encaissement_attaque_encaissement
      if (@target == @actor and @enemy_skill.effect_symbol != :ruse) or 
         (@target == @enemy and @actor_skill.effect_symbol != :ruse) or
         (@target == @actor and @enemy_skill.effect_symbol != :revenant) or 
         (@target == @enemy and @actor_skill.effect_symbol != :revenant) # Ruse
        index = @target.effect_list.index(:encaissement_attaque)
        ind = @target.effect[index][1]
        if @damage > 0 and ind == 2
          @damage = 0
          draw_text("#{@target.given_name}", "est protégé !")
          wait(40)
          return false
        end
      else
        if @target == @user
          draw_text("#{@enemy_skill.name} de #{@enemy.given_name}", 
                    "contourne la défense ennemie !")
        else
          draw_text("#{@actor_skill.name} de #{@actor.given_name}", 
                    "contourne la défense ennemie !")
        end
        wait(40)
      end
      return true
    end

    def tenacite_encaissement
      index = @target.effect_list.index(:tenacite)
      ind = @target.effect[index][1]
      if (@target.hp - @damage) <= 0 and ind == 2
        @damage = @target.hp - 1
        return "#{@target.given_name}", "tient le coup !"
      end
      return ""
    end
    
    def auto_ko_encaissement
      rec_damage = @user.hp
      self_damage(@user, @user_sprite, @user_status, rec_damage)
      draw_text("#{@user.given_name}", "se sacrifie.")
      wait(40)
      faint_check(@user)
    end
  end
end