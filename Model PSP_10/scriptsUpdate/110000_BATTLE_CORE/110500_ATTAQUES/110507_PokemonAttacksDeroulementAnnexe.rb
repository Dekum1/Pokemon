#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attacks_Deroulement_Annexe - Damien Linux
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
  # - Effets sur le déroulement du combat
  #------------------------------------------------------------
  # La mention "_ko" après "_annexe" signifie que l'effet
  # a lieu même si l'adversaire est K.O.
  # pensez à rajouter "_ko" pour les attaques qui peuvent avoir
  # lieu sans la présence de l'adversaire sur le terrain
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Effets sur le déroulement du combat
    #------------------------------------------------------------
    def changement_force_annexe
      if @target.ability_symbol == :ventouse # Ventouse / Suction cups (ab)
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "l'empêche d'être expulsé.")
        wait(40)
      else
        force_switch(@target)
      end
    end

    def tempetesable_annexe_ko
      $battle_var.set_sandstorm(5)
      draw_text("Une tempête de sable", "se lève...")
      animation = $data_animations[494]
      @actor_sprite.animation(animation, true) if $anim != 0
      loop do
        @actor_sprite.update
        $scene.battler_anim ; Graphics.update
        Input.update
        if not(@actor_sprite.effect?)
          break
        end
      end
      wait(20)
    end
    
    def danse_pluie_annexe_ko
      $battle_var.set_rain(5)
      draw_text("Il commence à pleuvoir.")
      animation = $data_animations[493]
      @actor_sprite.animation(animation, true) if $anim != 0
      loop do
        @actor_sprite.update
        $scene.battler_anim ; Graphics.update
        Input.update
        if not(@actor_sprite.effect?)
          break
        end
      end
      wait(20)
    end

    def zenith_annexe_ko
      $battle_var.set_sunny(5)
      draw_text("Le soleil brille.")
      animation = $data_animations[492]
      @actor_sprite.animation(animation, true) if $anim != 0
      loop do
        @actor_sprite.update
        $scene.battler_anim ; Graphics.update
        Input.update
        if not(@actor_sprite.effect?)
          break
        end
      end
      wait(20)
    end

    def grele_annexe_ko
      $battle_var.set_hail(5)
      draw_text("Il commence à grêler.")
      animation = $data_animations[495]
      @actor_sprite.animation(animation, true) if $anim != 0
      loop do
        @actor_sprite.update
        $scene.battler_anim ; Graphics.update
        Input.update
        if not(@actor_sprite.effect?)
          break
        end
      end
      wait(20)
    end
 
    def teleport_annexe_ko
      if @user == @actor
        end_battle_flee
      else
        end_battle_flee_enemy
      end
    end

    def clonage_attaque_annexe_ko
      # @clone[0] = 0 => clonage n'est pas utilisé par l'acteur
      # @clone[0] = 1 => clonage est utilisé par l'acteur
      # @clone[1] = 0 => clonage nn'est pas utilisé par l'ennemi
      # @clone[1] = 1 => clonage est utilisé par l'ennemi
      #
      # @confused[0] = true => si acteur confus avant le clonage
      # @confused[1] = true => si ennemie confus avant le clonage
      # @paralyzed[0] = true => si acteur paralysé avant le clonage
      # @paralyzed[1] = true => si ennemie paralysé avant le clonage
      #
      # @statAvantClonage[0][] => Les stats de l'acteur
      # @statAvantClonage[1][] => Les stats de l'ennemie
      # 0 : attaque / 1 : attaque spé / 2 : défense / 3 : défense spé /
      # 4 : esquive / 5 : précision / 6 : vitesse
      #
      # @hpClone[0] => hp du clone de l'acteur
      # @hpClone[1] => hp du clone de l'ennemie
      # Initialisation de @clone et @hpClone
      @statAvantClonage ||= [[0, 0, 0, 0, 0, 0, 0], [0, 0, 0, 0, 0, 0, 0]]
      @clone ||= [0, 0]
      @hpClone ||= [0, 0]
      @confused ||= [false, false]
      @paralyzed ||= [false, false]
      index = @user == @actor ? 0 : 1
      if @clone[index] == 1
          draw_text("#{@user.given_name}", "est déjà cloné !")
          wait(40)
      else
        hpRestant = @user.hp - @user.max_hp * 0.25
        if hpRestant > 0
          draw_text("#{@user.given_name}", "a un clone !")
          wait(40)
          # enregistrement des stats
          @statAvantClonage[index][0] = @user.atk_stage
          @statAvantClonage[index][1] = @user.ats_stage
          @statAvantClonage[index][2] = @user.dfe_stage
          @statAvantClonage[index][3] = @user.dfs_stage
          @statAvantClonage[index][4] = @user.acc_stage
          @statAvantClonage[index][5] = @user.eva_stage
          @statAvantClonage[index][6] = @user.spd_stage
          @confused[index] = @user.confused?
          @paralyzed[index] = @user.paralyzed?
          @hpClone[index] = (@user.max_hp * 0.25).to_i
          heal(@user, @user_sprite, @user_status, -@hpClone[index])
          @clone[index] = 1
        else
          draw_text("#{@user.given_name}", 
                    "n'a pas assez de PV pour être cloné !")
          wait(40)
        end
      end
    end
  end
end