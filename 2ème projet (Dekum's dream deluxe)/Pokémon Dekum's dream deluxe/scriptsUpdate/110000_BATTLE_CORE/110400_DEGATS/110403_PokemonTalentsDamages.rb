#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Talent_Damages - Damien Linux
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
  # Calcul des damages et damages spécifiques :
  # - Calcul des dégâts en fonction du talent de l'acteur
  # - Calcul des dégâts en fonction du talent de l'ennemi
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Calcul des dégâts en fonction du talent de l'acteur
    #------------------------------------------------------------
    def torche_damages(hash)
      if @user.ability_active and @user_skill.type_fire?
        hash[:base_damage] *= 1.5
      end
      return hash
    end

    def coloforce_damages(hash)
      if @user_skill.physical
        hash[:atk] *= 2
      end
      return hash
    end 
 
    def agitation_damages(hash)
      if @user_skill.physical
        hash[:atk] *= 1.5
      end
      return hash
    end

    def plus_damages(hash)
      if @target.ability_symbol == :minus and @user_skill.special # Minus 
        hash[:atk] *= 1.5
      end
      return hash
    end 
 
    def minus_damages(hash)
      if @target.ability_symbol == :plus and @user_skill.special # Plus 
        hash[:atk] *= 1.5
      end
      return hash
    end 

    def cran_damages(hash)
      if @user.status != 0 and @user_skill.physical
        hash[:atk] *= 1.5
      end
      return hash
    end 

    def engrais_damages(hash)
      if @user.hp < (@user.max_hp/3) and @user_skill.type_grass?
        hash[:base_damage] *= 1.5
      end
      return hash
    end 

    def brasier_damages(hash)
      if @user.hp < (@user.max_hp/3) and @user_skill.type_fire?
        hash[:base_damage] *= 1.5
      end
      return hash
    end 

    def torrent_damages(hash)
      if @user.hp < (@user.max_hp/3) and @user_skill.type_water?
        hash[:base_damage] *= 1.5
      end
      return hash
    end 

    def essaim_damages(hash)
      if @user.hp < (@user.max_hp/3) and @user_skill.type_insect?
        hash[:base_damage] *= 1.5
      end
      return hash
    end 

    def force_pure_damages(hash)
      if @user_skill.physical
        hash[:atk] *= 2
      end
      return hash
    end

    def force_sable_damages(hash)
      if $battle_var.sandstorm? and (@user_skill.type_rock? or 
         @user_skill.type_steel? or @user_skill.type_ground?)
        hash[:base_damage] *= 1.3
      end
      return hash
    end 
    
    #------------------------------------------------------------  
    # Calcul des dégâts en fonction du talent de l'ennemi
    #------------------------------------------------------------
    def isograisse_damages_enemy(hash)
      if @user_skill.type_fire? or @user_skill.type_ice?
        hash[:atk] /= 2
      end
      return hash
    end

    def deguisement_damages_enemy(hash)
      if @target.ability_token == nil
        @target.ability_token = 1 # Normal
      end
      hash[:target_type1] = @target.ability_token
      hash[:target_type2] = 0
      return hash
    end

    def meteo_damages_enemy(hash)
      if @target.ability_token == nil
        @target.ability_token = 1
      end
      hash[:target_type1] = @target.ability_token
      hash[:target_type2] = 0
      return hash
    end 

    def ecaille_spe_damages_enemy(hash)
      if @target.status != 0 and @user_skill.physical
        hash[:dfe] *= 1.5
      end
      return hash
    end
  end
end