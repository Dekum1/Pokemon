#==============================================================================
# ■ Pokemon_Battle_Trainer // IA
# Pokemon Script Project - Krosk 
# IA_Annexe - Damien Linux
# 13/01/2020
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Pokémon Dresseur et Sauvage
#-----------------------------------------------------------------------------
# Gestion de l'IA
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Core
  # - Protections
  # - Soin
  # - Météo
  # - Amélioration des statistiques de l'acteur
  # - Baisse des statistiques adverses
  # - Aide aux attaques/défense de type
  # - Pièges
  # - Echanges statistiques / statut
  # - Autres effets
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Protections
    #------------------------------------------------------------
    # Méthode de calcul concernant les attaques comme Abri qui encaissent les
    # coups
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_encaissement(rate)
      rate *= 2.5
      return rate
    end
    alias encaissement_attaque_ia_annexe ia_encaissement
    alias rune_protect_ia_annexe ia_encaissement

    def tenacite_ia_annexe(rate)
      if @user.hp <= @user.max_hp * 10 / 100
        rate *= 5
      end
      return rate
    end
    
    #------------------------------------------------------------ 
    # Soin
    #------------------------------------------------------------
    # Méthode de calcul concernant la récupération de PV
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_soin_pv(rate)
      if @user.hp <= @user.max_hp * 20 / 100 and 
         not @user.effect_list.include?(:anti_soin)
        rate *= 15
      end
      return rate
    end
    alias guerison_ia_annexe ia_soin_pv
    alias repos_ia_annexe ia_soin_pv
    alias aurore_ia_annexe ia_soin_pv
    alias synthese_ia_annexe ia_soin_pv
    alias rayon_lune_ia_annexe ia_soin_pv
    alias regagne_pv_moitie_ia_annexe ia_soin_pv
    alias atterissage_ia_annexe ia_soin_pv
    
    #------------------------------------------------------------ 
    # Météo
    #------------------------------------------------------------
    # Méthode de calcul concernant la météo
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_meteo(rate)
      if $battle_var.weather == 0
        rate *= 4
      end
      return rate
    end
    alias danse_pluie_ia_annexe ia_meteo
    alias zenith_ia_annexe ia_meteo
    alias grele_ia_annexe ia_meteo
    alias tempetesable_ia_annexe ia_meteo
    
    #------------------------------------------------------------ 
    # Amélioration des statistiques de l'acteur
    #------------------------------------------------------------
    
    
    def augmente_attaque_ia_annexe(rate)
      return ia_augmentation_stat(rate, 1.5, @user.atk_stage)
    end
    
    def danse_draco_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @user.atk_stage)
    end
    
    def augmente_defense_ia_annexe(rate)
      return ia_augmentation_stat(rate, 1.5, @user.dfe_stage)
    end
    
    def boul_armure_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @user.dfe_stage)
    end
    
    def croissance_ia_annexe(rate)
      return ia_augmentation_stat(rate, 1.5, @user.ats_stage)
    end
    
    def plenitude_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @user.ats_stage)
    end
    
    def augmente_esquive_ia_annexe(rate)
      return ia_augmentation_stat(rate, 2, @user.eva_stage)
    end
    
    #------------------------------------------------------------ 
    # Baisse des statistiques adverses
    #------------------------------------------------------------
    def baisse_attaque_ia_annexe(rate)
      return ia_augmentation_stat(rate, 1.5, @target.atk_stage)
    end
    
    def baisse_attaque_2_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @target.atk_stage)
    end
    
    def baisse_dfe_ia_annexe(rate)
      return ia_augmentation_stat(rate, 1.5, @target.dfe_stage)
    end
    
    def baisse_defense_2_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @target.dfe_stage)
    end
    
    def secretion_ia_annexe(rate)
      return ia_augmentation_stat(rate, 1.5, @target.spd_stage)
    end
    
    def baisse_vitesse_2_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @target.spd_stage)
    end
    
    def baisse_defense_spe_2_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3, @target.dfs_stage)
    end
    
    def baisse_precision_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3.5, @target.acc_stage)
    end
    
    def doux_parfum_ia_annexe(rate)
      return ia_augmentation_stat(rate, 3.5, @target.eva_stage)
    end
    alias anti_brume_ia_annexe doux_parfum_ia_annexe
    
    def seduction_ia_annexe(rate)
      if @target.gender + @user.gender != 3 or @target.ats_stage == -6
        rate = 0.5
      end
      rate *= 3.5*((6+@target.ats_stage)/6.0)
      return rate
    end
    
    def souvenir_ia_annexe(rate)
      rate /= 2
      return rate
    end
    
    #------------------------------------------------------------ 
    # Aide aux attaques/défense de type
    #------------------------------------------------------------
    # Méthode de calcul concernant les attaques entrainant une modification
    # de statistique en fonction du type
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_aide_stat_type(rate)
      rate *= 2
      return rate
    end
    alias chargeur_ia_annexe ia_aide_stat_type
    alias tourniquet_ia_annexe ia_aide_stat_type

    #------------------------------------------------------------ 
    # Pièges
    #------------------------------------------------------------
    def picots_ia_annexe(rate)
      index = @user == @actor ? 1 : 0
      if @picot != nil and @picot[index] > 3
        if @picot[index] < 1
          rate *= 3
        else
          rate *= 2
        end
      else 
        rate *= 0.5
      end
      return rate
    end
    
    def pics_toxik_ia_annexe(rate)
      index = @user == @actor ? 1 : 0
      if @pics_toxik != nil and @pics_toxik[index] > 3
        if @pics_toxik[index] < 1
          rate *= 3
        else
          rate *= 2
        end
      else 
        rate *= 0.5
      end
      return rate
    end
    
    def piege_de_roc_ia_annexe(rate)
      index = @user == @actor ? 0 : 1
      if @piege_de_roc_actif != nil and @piege_de_roc_actif[index] > 0
        rate = 0.5
      else
        rate *= 3
      end
      return rate
    end
    
    #------------------------------------------------------------ 
    # Echanges statistiques / statut
    #------------------------------------------------------------
    def permuforce_ia_annexe(rate)
      attaque_stage = @target.atk_stage + @target.ats_stage
      defense_stage = @user.atk_stage + @user.ats_stage
      rate *= (1 + attaque_stage - defense_stage)
      if rate < 0.5
        rate = 0.5
      end
      return rate
    end
    
    def permugarde_ia_annexe(rate)
      defense_stage = @target.dfe_stage + @target.dfs_stage
      attaque_stage = @user.dfe_stage + @user.dfs_stage
      rate *= (1 + defense_stage  - attaque_stage)
      if rate < 0.5
        rate = 0.5
      end
      return rate
    end
    
    def permucoeur_ia_annexe(rate)
      attaque_stage = @target.atk_stage - @user.atk_stage
      attaque_spe_stage = @target.ats_stage - @user.ats_stage
      attaque_total_stage = attaque_stage + attaque_spe_stage
      defense_stage = @target.dfe_stage - @user.dfe_stage
      defense_spe_stage = @target.dfs_stage - @user.dfs_stage
      defense_total_stage = defense_stage + defense_spe_stage
      precision_stage = @target.acc_stage - @user.acc_stage
      esquive_stage = @target.eva_stage - @user.eva_stage
      vitesse_stage = @target.spd_stage - @user.spd_stage 
      attaque_defense = attaque_total_stage + defense_total_stag
      autres_stage = precision_stage + esquive_stage + vitesse_stage
      
      rate *=  1 + attaque_defense + autres_stage
                   
      if rate < 0.5
        rate = 0.5
      end
      return rate
    end
    
    def echange_psy_ia_annexe(rate)
      if @user.status != 0
        rate *= 3.5
      else
        rate = 0.5
      end
      return rate
    end
    
    #------------------------------------------------------------ 
    # Autres effets
    #------------------------------------------------------------
    def trempette_ia_annexe(rate)
      rate = 1
      return rate
    end
    
    def gravite_ia_annexe(rate)
      if @target.type_vol? or @target.ability_name == "LEVITATION"
        rate *= 3.5
      else
        rate = 0.5
      end
      return rate
    end
    
    def oeil_miracle_ia_annexe(rate) 
      if @target.type_spectre? or @target.eva_stage > 0
        rate *= 3.5*((6+@target.eva_stage)/6.0)
      else
        rate = 0.5
      end
      return rate
    end
    
    def voeu_soin_ia_annexe(rate)
      rate = 0.5
      return rate
    end
    
    def vent_arriere_ia_annexe(rate) 
      if @user.effect_list.include?(:vent_arriere)
        rate = 0.5
      else
        rate *= 3
      end
      return rate
    end
    
    def degommage_ia_annexe(rate)
      if @user.item_hold == [0..12, 193..204, 253..329, 331..350]
        rate = 0.5
      else
        rate *= 5
      end
      return rate
    end
    
    def photocopie_ia_annexe(rate)
      if $battle_var.round == 0
        rate = 0.5
      end
      return rate
    end
    
    def dernierecour_ia_annexe(rate)
      @user.skills_set.each do |skill|
        if skill.pp == skill.ppmax and skill.name != "DERNIERECOUR"
          rate = 0.5
          break
        end
      end
      return rate
    end
    
    def vol_magnetik_ia_annexe(rate)
      if @user.effect_list.include?(:vol_magnetik)
        rate = 0.5
      else
        if @target.type_ground? 
          rate *= 10
        end
      end
      return rate
    end
  end
end