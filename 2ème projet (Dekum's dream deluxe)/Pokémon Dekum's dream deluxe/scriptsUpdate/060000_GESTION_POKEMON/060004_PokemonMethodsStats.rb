#==============================================================================
# ■ Pokemon
# Pokemon Script Project - Krosk 
# 20/07/07
# 26/08/08 - révision, support des oeufs
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 04/11/19
#-----------------------------------------------------------------------------
# Gestion individuelle
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon : génère l'information sur un Pokémon.
  # Méthodes sur les statistiques du Pokémon :
  # - Gestion des stats
  # - Stats basiques
  # - Actualisation des stats
  # - Getter et Setter des modifications de stats
  # - Gestion des coups critiques basiques
  # - Changement sur les stats
  # - Modificateurs de stats
  # - Modificateurs : bonus
  # - Modificateurs de DV
  #------------------------------------------------------------
  class Pokemon
    #------------------------------------------------------------
    # Gestion des stats
    #------------------------------------------------------------   
    def base_hp
      return @base_hp
    end
    def base_atk
      return @base_atk
    end
    def base_dfe
      return @base_dfe
    end
    def base_spd
      return @base_spd
    end
    def base_ats
      return @base_ats
    end
    def base_dfs
      return @base_dfs
    end
  
    #------------------------------------------------------------    
    # Stats basiques
    #------------------------------------------------------------    
    def maxhp_basis
      n = Integer((base_hp*2+@dv_hp+@hp_plus/4.0)*@level/100)+@level+10
      return n
    end
    
    alias max_hp maxhp_basis
    
    def atk_basis
      n = Integer((base_atk*2+@dv_atk+@atk_plus/4.0)*@level/100)+5
      n = Integer(n * @nature[1] / 100.0)
      return n
    end
    
    def dfe_basis
      n = Integer((base_dfe*2+@dv_dfe+@dfe_plus/4.0)*@level/100)+5
      n = Integer(n * @nature[2] / 100.0)
      return n
    end
    
    def spd_basis
      n = Integer((base_spd*2+@dv_spd+@spd_plus/4.0)*@level/100)+5
      n = Integer(n * @nature[3] / 100.0)
      return n
    end
    
    def ats_basis
      n = Integer((base_ats*2+@dv_ats+@ats_plus/4.0)*@level/100)+5
      n = Integer(n * @nature[4] / 100.0)
      return n
    end    
    
    def dfs_basis
      n = Integer((base_dfs*2+@dv_dfs+@dfs_plus/4.0)*@level/100)+5
      n = Integer(n * @nature[5] / 100.0)
      return n
    end
    
    #------------------------------------------------------------
    # Actualisation des stats
    #------------------------------------------------------------   
    def statistic_refresh
      @round ||= 0
      @bonus ||= [0, 0, 0, 0, 0]
      @battle_stage ||= [0, 0, 0, 0, 0, 0 ,0]
      @stats_manuel ||= [0, 0, 0, 0, 0]
      # Définit si on utilise les stats saisit manuellement ou les stats de base
      # pour calculer les stats du Pokémon dans un combat
      atk_initial = @stats_manuel[0] > 0 ? @stats_manuel[0] : atk_basis
      dfe_initial = @stats_manuel[1] > 0 ? @stats_manuel[1] : dfe_basis
      spd_initial = @stats_manuel[2] > 0 ? @stats_manuel[2] : spd_basis
      ats_initial = @stats_manuel[3] > 0 ? @stats_manuel[3] : ats_basis
      dfs_initial = @stats_manuel[4] > 0 ? @stats_manuel[4] : dfs_basis
      
      @atk = Integer((atk_initial + @bonus[0]) * atk_modifier)
      @dfe = Integer((dfe_initial + @bonus[1]) * dfe_modifier)
      @spd = Integer((spd_initial + @bonus[2]) * spd_modifier)
      @ats = Integer((ats_initial + @bonus[3]) * ats_modifier)
      @dfs = Integer((dfs_initial + @bonus[4]) * dfs_modifier)
    end
    
    def statistic_refresh_modif
      @round ||= 0
      @bonus ||= [0, 0, 0, 0, 0]
      @battle_stage ||= [0, 0, 0, 0, 0, 0 ,0]
      @stats_manuel ||= [0, 0, 0, 0, 0]
      # Définit si on utilise les stats saisit manuellement ou les stats de base
      # pour calculer les stats du Pokémon dans un combat
      atk_initial = @stats_manuel[0] > 0 ? @stats_manuel[0] : atk_basis
      dfe_initial = @stats_manuel[1] > 0 ? @stats_manuel[1] : dfe_basis
      spd_initial = @stats_manuel[2] > 0 ? @stats_manuel[2] : spd_basis
      ats_initial = @stats_manuel[3] > 0 ? @stats_manuel[3] : ats_basis
      dfs_initial = @stats_manuel[4] > 0 ? @stats_manuel[4] : dfs_basis
      
      if self.effect_list.include?(:astuce_force)
        @atk = Integer((dfe_initial + @bonus[1]) * dfe_modifier)
        @dfe = Integer((atk_initial + @bonus[0]) * atk_modifier)
        @spd = Integer((spd_initial + @bonus[2]) * spd_modifier)
        @ats = Integer((ats_initial + @bonus[3]) * ats_modifier)
        @dfs = Integer((dfs_initial + @bonus[4]) * dfs_modifier)
      else
        @atk = Integer((atk_initial + @bonus[0]) * atk_modifier)
        @dfe = Integer((dfe_initial + @bonus[1]) * dfe_modifier)
        @spd = Integer((spd_initial + @bonus[2]) * spd_modifier)
        @ats = Integer((ats_initial + @bonus[3]) * ats_modifier)
        @dfs = Integer((dfs_initial + @bonus[4]) * dfs_modifier)
      end
    end
    
    # Reset les modification des stats
    # stat_unique : si true, reset uniquement les stats
    def reset_stat_stage(stat_unique = false)
      @battle_stage = [0, 0, 0, 0, 0, 0, 0]
      @stats_manuel = [0, 0, 0, 0, 0]
      @critical_base = 0
      if not stat_unique
        @bonus = [0, 0, 0, 0, 0]
        if @effect != nil
          skill_effect_reset
        end
      end
      statistic_refresh
    end
    
    #------------------------------------------------------------
    # Getter et Setter des modifications de stats
    #------------------------------------------------------------ 
    # Renvoie les modifications de l'attaque
    def atk_stage
      return @battle_stage[0]
    end
    
    # Renvoie les modifications de la défense
    def dfe_stage
      return @battle_stage[1]
    end
    
    # Renvoie les modifications de la vitesse
    def spd_stage
      return @battle_stage[2]
    end
    
    # Renvoie les modifications de l'attaque spécial
    def ats_stage
      return @battle_stage[3]
    end
    
    # Renvoie les modifications de la défense spécial
    def dfs_stage
      return @battle_stage[4]
    end
    
    # Renvoie les modifications de l'esquive
    def eva_stage
      return @battle_stage[5]
    end
    
    # Renvoie les modifications de la précision
    def acc_stage
      return @battle_stage[6]
    end
    
    # Définit les modifications sur l'attaque
    # value : La valeur des modifications
    def atk_stage=(value)
      @battle_stage[0] = value
    end
    
    # Définit les modifications sur la défense
    # value : La valeur des modifications
    def dfe_stage=(value)
      @battle_stage[1] = value
    end
    
    # Définit les modifications sur la vitesse
    # value : La valeur des modifications
    def spd_stage=(value)
      @battle_stage[2] = value
    end
    
    # Définit les modifications sur l'attaque spéciale
    # value : La valeur des modifications
    def ats_stage=(value)
      @battle_stage[3] = value
    end
    
    # Définit les modifications sur la défense spéciale
    # value : La valeur des modifications
    def dfs_stage=(value)
      @battle_stage[4] = value
    end
    
    # Définit les modifications sur l'esquive
    # value : La valeur des modifications
    def eva_stage=(value)
      @battle_stage[5] = value
    end
    
    # Définit les modifications sur la précision
    # value : La valeur des modifications
    def acc_stage=(value)
      @battle_stage[6] = value
    end
    
    # Définit manuellement la nouvelle attaque
    # value : La valeur de l'attaque
    def atk=(value)
      @stats_manuel[0] = value
    end
    
    # Définit manuellement la nouvelle défense
    # value : La valeur de la défense
    def dfe=(value)
      @stats_manuel[1] = value
    end
    
    # Définit manuellement la nouvelle vitesse
    # value : La valeur de la vitesse
    def spd=(value)
      @stats_manuel[2] = value
    end
    
    # Définit manuellement la nouvelle attaque spéciale
    # value : La valeur de l'attaque spécial
    def ats=(value)
      @stats_manuel[3] = value
    end
    
    # Définit manuellement la nouvelle défense spéciale
    # value : La valeur de la défense spéciale
    def dfs=(value)
      @stats_manuel[4] = value
    end
    
    #------------------------------------------------------------
    # Gestion des coups critiques basiques
    #------------------------------------------------------------
    # Incrémente le taux de coup critique de base
    def add_critical_base
      @critical_base ||= 0
      @critical_base += 1
    end
    
    # Renvoie le taux de coup critique de base
    def get_critical_base
      @critical_base ||= 0
      return @critical_base
    end
    
    #------------------------------------------------------------
    # Changement sur les stats
    #------------------------------------------------------------  
    def change_stat(stat_id, amount = 0, actor_change = self)
      if amount > 0 and @battle_stage[stat_id] == 6
        return 0
      end
      if amount < 0 and @battle_stage[stat_id] == -6
        return 0
      end
      
      @battle_stage[stat_id] += amount
      if @battle_stage[stat_id].abs > 6
        @battle_stage[stat_id] = 6*@battle_stage[stat_id].sgn
      end
      return amount
    end
    
    def change_atk(amount = 0, actor_change = self)
      return change_stat(0, amount, actor_change)
    end
    
    def change_dfe(amount = 0, actor_change = self)
      return change_stat(1, amount, actor_change)
    end
    
    def change_spd(amount = 0, actor_change = self)
      return change_stat(2, amount, actor_change)
    end
    
    def change_ats(amount = 0, actor_change = self)
      return change_stat(3, amount, actor_change)
    end
    
    def change_dfs(amount = 0, actor_change = self)
      return change_stat(4, amount, actor_change)
    end
    
    def change_eva(amount = 0, actor_change = self)
      return change_stat(5, amount, actor_change)
    end
    
    def change_acc(amount = 0, actor_change = self)
      return change_stat(6, amount, actor_change)
    end
    
    #------------------------------------------------------------
    # Modificateurs de stats
    #------------------------------------------------------------  
    # Renvoi du multiplicateur selon le stage
    # stage : la stat à évaluer
    def modifier_stage(stage)
      if stage >= 0
        return (2+stage)/2.0
      elsif stage < 0
        return 2.0/(2-stage)
      end
    end
    
    # Détermine le multiplicateur de variation de l'attaque
    def atk_modifier
      n = 1 * modifier_stage(@battle_stage[0])
      # Etat burn
      if burn?
        n *= 0.5
      end
      return n
    end
    
    # Détermine le multiplicateur de variation de la défense
    def dfe_modifier
      n = 1 * modifier_stage(@battle_stage[1])
      return n
    end    
    
    # Détermine le multiplicateur de variation de la vitesse
    def spd_modifier
      n = 1 * modifier_stage(@battle_stage[2])
      # Etat paralyze
      if paralyzed?
        n *= 0.25
      end
      return n
    end    

    # Détermine le multiplicateur de variation de l'attaque spéciale
    def ats_modifier
      n = 1 * modifier_stage(@battle_stage[3])
      return n
    end    

    # Détermine le multiplicateur de variation de la défense spéciale
    def dfs_modifier
      n = 1 * modifier_stage(dfs_stage)
      return n
    end
    
    #------------------------------------------------------------
    # Modificateurs : bonus
    #------------------------------------------------------------  
    
    # Définit le bonus à appliquer à l'attaque
    # coef : Le coefficient de modification
    # signe : Détermine s'il s'agit d'une addition ou d'une multiplication
    # erase : true si écrase le bonus précédent sinon false
    def set_bonus_atk(coef, signe = '*', erase = false)
      atk_initial = @stats_manuel[0] > 0 ? @stats_manuel[0] : atk_basis
      if signe == '*'
        @bonus[0] = (not erase) ? @bonus[0] + Integer(atk_initial * coef) : 
                                              Integer(atk_initial * coef)
      elsif signe == '+'
        @bonus[0] = (not erase) ? @bonus[0] + Integer(atk_initial + coef) :
                                              Integer(atk_initial + coef)
      end
    end
    
    # Définit le bonus à appliquer à la défense
    # coef : Le coefficient de modification
    # signe : Détermine s'il s'agit d'une addition ou d'une multiplication
    # erase : true si écrase le bonus précédent sinon false
    def set_bonus_dfe(coef, signe = '*', erase = false)
      dfe_initial = @stats_manuel[1] > 0 ? @stats_manuel[1] : dfe_basis
      if signe == '*'
        @bonus[1] = (not erase) ? @bonus[1] + Integer(dfe_initial * coef) : 
                                              Integer(dfe_initial * coef)
      elsif signe == '+'
        @bonus[1] = (not erase) ? @bonus[1] + Integer(dfe_initial + coef) :
                                              Integer(dfe_initial + coef)
      end
    end
    
    # Définit le bonus à appliquer à la vitesse
    # coef : Le coefficient de modification
    # signe : Détermine s'il s'agit d'une addition ou d'une multiplication
    # erase : true si écrase le bonus précédent sinon false
    def set_bonus_spd(coef, signe = '*', erase = false)
      spd_initial = @stats_manuel[2] > 0 ? @stats_manuel[2] : spd_basis
      if signe == '*'
        @bonus[2] = (not erase) ? @bonus[2] + Integer(spd_initial * coef) :
                                              Integer(spd_initial * coef)
      elsif signe == '+'
        @bonus[2] = (not erase) ? @bonus[2] + Integer(spd_initial + coef) :
                                              Integer(spd_initial + coef)
      end
    end
    
    # Définit le bonus à appliquer à l'attaque spéciale
    # coef : Le coefficient de modification
    # signe : Détermine s'il s'agit d'une addition ou d'une multiplication
    # erase : true si écrase le bonus précédent sinon false
    def set_bonus_ats(coef, signe = '*', erase = false)
      ats_initial = @stats_manuel[3] > 0 ? @stats_manuel[3] : ats_basis
      if signe == '*'
        @bonus[3] = (not erase) ? @bonus[3] + Integer(ats_initial * coef) :
                                              Integer(ats_initial * coef)
      elsif signe == '+'
        @bonus[3] = (not erase) ? @bonus[3] + Integer(ats_initial + coef) :
                                              Integer(ats_initial + coef)
      end
    end
    
    # Définit le bonus à appliquer à la défense spéciale
    # coef : Le coefficient de modification
    # signe : Détermine s'il s'agit d'une addition ou d'une multiplication
    # erase : true si écrase le bonus précédent sinon false
    def set_bonus_dfs(coef, signe = '*', erase = false)
      dfs_initial = @stats_manuel[4] > 0 ? @stats_manuel[4] : dfs_basis
      if signe == '*'
        @bonus[4] = (not erase) ? @bonus[4] + Integer(dfs_initial * coef) :
                                              Integer(dfs_initial * coef)
      elsif signe == '+'
        @bonus[4] = (not erase) ? @bonus[4] + Integer(dfs_initial + coef) :
                                              Integer(dfs_initial + coef)
      end
    end
    
    #------------------------------------------------------------
    # Modificateurs de DV
    #------------------------------------------------------------  
    # Modification des DV
    def dv_modifier(list)
      @dv_hp = list[0]
      @dv_atk = list[1]
      @dv_dfe = list[2]
      @dv_spd = list[3]
      @dv_ats = list[4]
      @dv_dfs = list[5]
      statistic_refresh
      @hp = max_hp
    end
    
    # Modification manuelle des stats debase
    # list : La liste des stats sous forme de tableau [hp, atk, dfe, spd, ats, dfs]
    def stats_modifier(list)
      @base_hp = list[0]
      @base_atk = list[1]
      @base_dfe = list[2]
      @base_spd = list[3]
      @base_ats = list[4]
      @base_dfs = list[5]
      statistic_refresh
    end
    
    def ev_modifier(list)
      @hp_plus = list[0]
      @atk_plus = list[1]
      @dfe_plus = list[2]
      @spd_plus = list[3]
      @ats_plus = list[4]
      @dfs_plus = list[5]
      statistic_refresh
      @hp = max_hp
    end
  end
end