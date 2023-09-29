#==============================================================================
# ■ Pokemon_Battle_Trainer // IA
# Pokemon Script Project - Krosk 
# IA_Hit_Statut - Damien Linux
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
  # - IA Hit - Multi-hit ? - 2
  # - IA Hit - Multi-hit 3
  # - IA Hit - Auto-destruction
  # - IA Hit - 2 tours strict - Dégâts / Stats de recul 
  # - IA Hit / IA Statut - Effet de statut - de stat - de PV sur adversaire / 
  # acteur
  # - IA Hit - Coups Critiques
  # - IA Statut - Avec immunité par type de l'attaque (paralysie)
  # - IA Statut - Immunitées spéciales (type de la défense) - Poison
  # - IA Statut - Brule
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # IA Hit - Multi-hit ? - 2
    #------------------------------------------------------------
    # Méthode de calcul concernant les attaques à plusieurs frappes
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_multi_hit(rate)
      rate *= 1.8
      return rate
    end
    alias attaque_combo_ia_hit ia_multi_hit
    alias double_frappe_ia_hit ia_multi_hit
    alias double_dard_ia_hit ia_multi_hit
    
    #------------------------------------------------------------ 
    # IA Hit - Multi-hit 3
    #------------------------------------------------------------
    def triple_pied_ia_hit(rate)
      rate *= 2.6
      return rate
    end
    
    #------------------------------------------------------------ 
    # IA Hit - Auto-destruction
    #------------------------------------------------------------
    def auto_ko_ia_hit(rate)
      rate /= 4
      return rate
    end
    
    #------------------------------------------------------------ 
    # IA Hit - 2 tours strict - Dégâts / Stats de recul 
    #------------------------------------------------------------
    # Méthode de calcul concernant les attaques prennant effets sur plusieurs
    # tours ou faisant des dégâts de recul
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_multi_tour_recoil(rate)
      rate /= 1.1
      return rate
    end
    alias coupe_vent_ia_hit ia_multi_tour_recoil
    alias multi_tour_confus_ia_hit ia_multi_tour_recoil
    alias mania_ia_hit ia_multi_tour_recoil
    alias pique_ia_hit ia_multi_tour_recoil
    alias rechargement_ia_hit ia_multi_tour_recoil
    alias coud_krane_ia_hit ia_multi_tour_recoil
    alias lance_soleil_ia_hit ia_multi_tour_recoil
    alias vol_ia_hit ia_multi_tour_recoil
    alias rebond_ia_hit ia_multi_tour_recoil
    alias plongee_ia_hit ia_multi_tour_recoil
    alias tunnel_ia_hit ia_multi_tour_recoil
    alias revenant_ia_hit ia_multi_tour_recoil
    alias charge_blesse_ia_hit ia_multi_tour_recoil
    alias degats_ia_hit ia_multi_tour_recoil
    alias cognobidon_ia_hit ia_multi_tour_recoil
    alias surpuissance_ia_hit ia_multi_tour_recoil
    alias close_combat_ia_hit ia_multi_tour_recoil
    alias boutefeu_ia_hit ia_multi_tour_recoil

    #------------------------------------------------------------ 
    # IA Hit / IA Statut - Effet de statut - de stat - de PV sur adversaire / 
    # acteur
    #------------------------------------------------------------
    # Méthode de calcul concernant les attaques ayant comme effet secondaire
    # de donner un problème de statut ou une modification des statistiques
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_hit_statut_stats(rate)
      rate *= 1.1
      return rate
    end
    alias poison_ia_hit ia_hit_statut_stats
    alias brulure_ia_hit ia_hit_statut_stats
    alias gel_ia_hit ia_hit_statut_stats
    alias paralysie_ia_hit ia_hit_statut_stats
    alias apeurer_ia_hit ia_hit_statut_stats
    alias triplattaque_ia_hit ia_hit_statut_stats
    alias ronflement_ia_hit ia_hit_statut_stats
    alias degele_brule_ia_hit ia_hit_statut_stats
    alias ouragan_ia_hit ia_hit_statut_stats
    alias apeurer_attaque_ia_hit ia_hit_statut_stats
    alias fatal_foudre_ia_hit ia_hit_statut_stats
    alias bluff_ia_hit ia_hit_statut_stats
    alias pied_bruleur_ia_hit ia_hit_statut_stats
    alias crochet_venin_ia_hit ia_hit_statut_stats
    alias queue_poison_ia_hit ia_hit_statut_stats
    alias onde_boreale_ia_hit ia_hit_statut_stats
    alias ia_hit_statut_stats ia_hit_statut_stats
    alias baisse_defense_attaque_ia_hit ia_hit_statut_stats
    alias baisse_vitesse_attaque_ia_hit ia_hit_statut_stats
    alias baisse_attaque_spe_ia_hit ia_hit_statut_stats
    alias baisse_defense_spe_ia_hit ia_hit_statut_stats
    alias baisse_precision_attaque_ia_hit ia_hit_statut_stats
    alias confusion_attaque_ia_hit ia_hit_statut_stats
    alias aile_acier_ia_hit ia_hit_statut_stats
    alias augmente_attaque_attaque_ia_hit ia_hit_statut_stats
    alias augmentation_attaque_spe_ia_hit ia_hit_statut_stats
    alias recuperation_pv_ia_hit ia_hit_statut_stats
    
    # Méthode de calcul concernant les attaques ayant comme effet secondaire
    # de modifier les statistiques ou le statut de manière forte
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_hit_stats_statut_fortement(rate)
      rate *= 1.5
      return rate
    end
    alias augmente_stats_ia_hit ia_hit_stats_statut_fortement
    alias baisse_attaque_spe_attaque_ia_hit ia_hit_stats_statut_fortement
    alias sommeil_ia_statut ia_hit_stats_statut_fortement
    alias attraction_ia_statut ia_hit_stats_statut_fortement
    
    def devoreve_ia_hit(rate)
      rate *= 3
      if not @target.asleep?
        rate /= 10
      end
      return rate
    end
    
    #------------------------------------------------------------ 
    # IA Hit - Coups Critiques
    #------------------------------------------------------------
    # Méthode de calcul concernant les attaques qui donnent des coups
    # critiques
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_critique(rate)
      rate *= 1.2
      return rate
    end
    alias critique_eleve_ia_hit ia_critique
    alias pique_ia_hit ia_critique
    alias pied_bruleur_ia_hit ia_critique
    alias queue_poison_ia_hit ia_critique
    
    #------------------------------------------------------------ 
    # IA Statut - Avec immunité par type de l'attaque (paralysie)
    #------------------------------------------------------------
    def intimidation_ia_statut(rate)
      if element_rate(@ia_type1, @ia_type2, @user_skill.type, @user_skill.effect, 
                      @target.effect_list) == 0
        rate = 0.5
      else
        rate *= 1.5
      end
      return rate
    end
    
    #------------------------------------------------------------ 
    # IA Statut - Immunitées spéciales (type de la défense) - Poison
    #------------------------------------------------------------
    # Méthode de calcul concernant le statut poison
    # rate : Le taux de chance que l'attaque soit choisie
    def ia_statut_poison(rate)
      if @target.type_steel? or @target.type_poison?
        rate = 0.5
      else
        rate *= 1.5
      end
      return rate
    end
    alias gaz_toxik_ia_statut ia_statut_poison
    alias toxik_ia_statut ia_statut_poison
    
    #------------------------------------------------------------ 
    # IA Statut - Brule
    #------------------------------------------------------------
    def feu_follet_ia_statut(rate)
      if @target.type_fire?
        rate = 0.5
      else
        rate *= 1.5
      end
      return rate
    end
  end
end