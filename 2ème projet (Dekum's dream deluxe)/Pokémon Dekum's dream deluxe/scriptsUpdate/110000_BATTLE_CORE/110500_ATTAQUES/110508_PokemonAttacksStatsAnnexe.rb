#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attacks_Stats_Annexe - Damien Linux
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
  # - Influence sur les statistiques
  #------------------------------------------------------------
  # La mention "_ko" après "_annexe" signifie que l'effet
  # a lieu même si l'adversaire est K.O.
  # pensez à rajouter "_ko" pour les attaques qui peuvent avoir
  # lieu sans la présence de l'adversaire sur le terrain
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Influence sur les statistiques
    #------------------------------------------------------------
    def augmente_attaque_annexe_ko
      augmentation_stat("ATK", 1, @target, @user)
    end

    def augmente_defense_annexe_ko
      augmentation_stat("DFE", 1, @target, @user)
    end

    def croissance_annexe_ko
      if $battle_var.sunny?
        augmentation_stat("ATK", 2, @target, @user)
        augmentation_stat("ATS", 2, @target, @user)
      else
        augmentation_stat("ATK", 1, @target, @user)
        augmentation_stat("ATS", 1, @target, @user)
      end
    end

    def augmente_esquive_annexe_ko
      augmentation_stat("EVA", 1, @target, @user)
    end
    
    def baisse_attaque_annexe
      reduction_stat("ATK", -1, @target, @user)
    end

    def baisse_dfe_annexe
      reduction_stat("DFE", -1, @target, @user)
    end

    def secretion_annexe
      index = @user == @actor ? 1 : 0
      if (@clone != nil and @clone[index] == 1) or 
         @target.effect_list.include?(:brume)
        reduction_stat("SPD", -2, @target, @user)
      else
        reduction_stat("SPD", -1, @target, @user)
      end
    end

    def baisse_precision_annexe
      reduction_stat("ACC", -1, @target, @user)
    end

    def doux_parfum_annexe
      reduction_stat("EVA", -1, @target, @user)
    end

    def annule_changement_stats_annexe_ko
      @user.reset_stat_stage(true)
      @target.reset_stat_stage(true)
      index = @user == @actor ? 0 : 1
      @stockage[index] = 0 if @stockage and @stockage[index]
      raise_stat(0, @target)
    end

    def danse_lames_annexe_ko
      augmentation_stat("ATK", 2, @target, @user)
    end

    def augmente_defense_2_annexe_ko
      augmentation_stat("DFE", 2, @target, @user)
    end
    
    def augmente_vitesse_annexe_ko
      augmentation_stat("SPD", 1, @user, @target)
    end

    def augmente_vitesse_2_annexe_ko
      augmentation_stat("SPD", 2, @target, @user)
    end
    
    def augmente_attaque_spe_2_annexe_ko
      augmentation_stat("ATS", 2, @target, @user)
    end

    def amnesie_annexe_ko
      augmentation_stat("DFS", 2, @target, @user)
    end

    def baisse_attaque_2_annexe
      reduction_stat("ATK", -2, @target, @user)
    end
 
    def baisse_defense_2_annexe
      reduction_stat("DFE", -2, @target, @user)
    end

    def baisse_vitesse_2_annexe
      reduction_stat("SPD", -2, @target, @user)
    end

    def baisse_vitesse_annexe
      reduction_stat("SPD", -1, @target, @user)
    end
    
    def baisse_defense_spe_2_annexe
      reduction_stat("DFS", -2, @target, @user)
    end

    def onde_boreale_annexe
      reduction_stat("ATK", -1, @target, @user)
    end

    def baisse_defense_attaque_annexe
      reduction_stat("DFE", -1, @target, @user)
    end

    def baisse_vitesse_attaque_annexe
      reduction_stat("SPD", -1, @target, @user)
    end

    def baisse_attaque_spe_annexe
      reduction_stat("ATS", -1, @target, @user)
    end

    def baisse_defense_spe_annexe
      reduction_stat("DFS", -1, @target, @user)
    end

    def baisse_precision_attaque_annexe
      reduction_stat("ACC", -1, @target, @user)
    end

    def lilliput_annexe
      @target.skill_effect(:lilliput)
      draw_text("#{@target.given_name} est tout", "petit !")
      wait(40)
      augmentation_stat("EVA", 1, @target, @user)
    end

    def malediction_annexe
      if @user.type_ghost? # Type spectre
        draw_text("#{@user.given_name} maudit", "#{@target.given_name} !")
        wait(40)
        damage = @user.max_hp / 2
        self_damage(@user, @user_sprite, @user_status, damage)
        @target.skill_effect(:malediction)
      else
        reduction_stat("SPD", -1, @target, @user)
        augmentation_stat("ATL", 1, @target, @user)
        augmentation_stat("DFE", 1, @target, @user)
      end
    end

    def vantardise_annexe
      augmentation_stat("ATK", 2, @target, @user)
      status_check(@target, 6)
      @target_status.refresh
    end

    def aile_acier_annexe_ko
      augmentation_stat("DFE", 1, @user)
    end

    def augmente_attaque_attaque_annexe_ko
      augmentation_stat("ATK", 1, @user)
    end

    def augmente_stats_annexe_ko
      augmentation_stat("ATK", 1, @user)
      augmentation_stat("DFE", 1, @user)
      augmentation_stat("SPD", 1, @user)
      augmentation_stat("ATS", 1, @user)
      augmentation_stat("DFS", 1, @user)
    end

    def cognobidon_annexe_ko
      augmentation_stat("ATK", 12, @target, @user)
    end
    
    def boost_annexe
      @user.atk_stage=(@target.atk_stage)
      @user.dfe_stage=(@target.dfe_stage)
      @user.spd_stage=(@target.spd_stage)
      @user.ats_stage=(@target.ats_stage)
      @user.dfs_stage=(@target.dfs_stage)
      @user.acc_stage=(@target.acc_stage)
      @user.eva_stage=(@target.eva_stage)
      draw_text("#{@user.given_name} copie les stats", 
                "de #{@target.given_name} !")
      wait(40)
    end

    def boul_armure_annexe_ko
      augmentation_stat("DFE", 1, @user)
      @user.skill_effect(:boul_armure)
    end

    def souvenir_annexe_ko
      reduction_stat("ATK", -2, @target, @user)
      reduction_stat("ATS", -2, @target, @user)
      damage = @user.hp
      self_damage(@user, @user_sprite, @user_status, damage)
    end

    def surpuissance_annexe_ko
      reduction_stat("ATK", -1, @user)
      reduction_stat("DFE", -1, @user)
    end

    def baisse_attaque_spe_attaque_annexe_ko
      reduction_stat("ATS", -2, @user)
    end 

    def chatouille_annexe
      reduction_stat("ATK", -1, @target, @user)
      reduction_stat("DFE", -1, @target, @user)
    end

    def augmentation_dfs_dfe_annexe_ko
      augmentation_stat("DFE", 1, @target, @user)
      augmentation_stat("DFS", 1, @target, @user)
    end

    def gonflette_annexe_ko
      augmentation_stat("ATK", 1, @target, @user)
      augmentation_stat("DFE", 1, @target, @user)
    end

    def plenitude_annexe_ko
      augmentation_stat("ATS", 1, @target, @user)
      augmentation_stat("DFS", 1, @target, @user)
    end

    def danse_draco_annexe_ko
      augmentation_stat("ATK", 1, @target, @user)
      augmentation_stat("SPD", 1, @target, @user)
    end

    def close_combat_annexe_ko
      reduction_stat("DFE", -1, @user)
      reduction_stat("DFS", -1, @user)
    end
    
    def astuce_force_annexe_ko
      @user.skill_effect(:astuce_force)
      draw_text("#{@user.given_name} échange" , "son Attaque et sa Défense !")
      wait(40)
    end

    def permuforce_annexe
      temp_atk_stage = @user.atk_stage
      temp_ats_stage = @user.ats_stage
      @user.atk_stage=(@target.atk_stage)
      @user.ats_stage=(@target.ats_stage)
      @target.atk_stage=(temp_atk_stage)
      @target.ats_stage=(temp_ats_stage)
      draw_text("Les changements d'attaque", "des Pokémon ont été échangés !")
      wait(40)
    end

    def permugarde_annexe
      temp_dfe_stage = @user.dfe_stage
      temp_dfs_stage = @user.dfs_stage
      @user.dfe_stage=(@target.dfe_stage)
      @user.dfs_stage=(@target.dfs_stage)
      @target.dfe_stage=(temp_dfe_stage)
      @target.dfs_stage=(temp_dfs_stage)
      draw_text("Les changements de défense", "des Pokémon ont été échangés !")
      wait(40)
    end

    def permucoeur_annexe
      temp_atk_stage = @user.atk_stage
      temp_ats_stage = @user.ats_stage
      temp_dfe_stage = @user.dfe_stage
      temp_dfs_stage = @user.dfs_stage
      temp_acc_stage = @user.acc_stage
      temp_eva_stage = @user.eva_stage
      temp_spd_stage = @user.spd_stage
      @user.atk_stage=(@target.atk_stage)
      @user.ats_stage=(@target.ats_stage)
      @user.dfe_stage=(@target.dfe_stage)
      @user.dfs_stage=(@target.dfs_stage)
      @user.acc_stage=(@target.acc_stage)
      @user.eva_stage=(@target.eva_stage)
      @user.spd_stage=(@target.spd_stage)
      @target.atk_stage=(temp_atk_stage)
      @target.ats_stage=(temp_ats_stage)
      @target.dfe_stage=(temp_dfe_stage)
      @target.acc_stage=(temp_acc_stage)
      @target.eva_stage=(temp_eva_stage)
      @target.spd_stage=(temp_spd_stage)
      draw_text("Les changements de stats", "des Pokémon ont été échangés !")
      wait(40)
    end

    def augmentation_attaque_spe_annexe_ko
      augmentation_stat("ATS", 1, @user)
    end

    def aiguisage_annexe_ko
      augmentation_stat("ATK", 1, @target, @user)
      augmentation_stat("ACC", 1, @target, @user)
    end

    def rengorgement_annexe_ko
      augmentation_stat("ATK", 1, @target, @user)
      augmentation_stat("ATS", 1, @target, @user)
    end

    def papillodanse_annexe_ko
      augmentation_stat("ATS", 1, @target, @user)
      augmentation_stat("DFS", 1, @target, @user)
      augmentation_stat("SPD", 1, @target, @user)
    end
    
    def seduction_annexe
      reduction_stat("ATS", -2, @target, @user)
    end
  end
end