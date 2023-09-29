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
  # Méthodes sur les types du Pokemon
  #------------------------------------------------------------
  class Pokemon
    def type_normal?
      if [@type1, @type2].include?(1)
        return true
      end
      return false
    end
    
    def type_fire?
      if [@type1, @type2].include?(2)
        return true
      end
      return false
    end
    alias type_feu? type_fire?
    
    def type_water?
      if [@type1, @type2].include?(3)
        return true
      end
      return false
    end
    alias type_eau? type_water?
    
    def type_electric?
      if [@type1, @type2].include?(4)
        return true
      end
      return false
    end
    
    def type_grass?
      if [@type1, @type2].include?(5)
        return true
      end
      return false
    end
    alias type_plante? type_grass?
    
    def type_ice?
      if [@type1, @type2].include?(6)
        return true
      end
      return false
    end
    alias type_glace? type_ice?
    
    def type_fighting?
      if [@type1, @type2].include?(7)
        return true
      end
      return false
    end
    alias type_combat? type_fighting?
    
    def type_poison?
      if [@type1, @type2].include?(8)
        return true
      end
      return false
    end
    
    def type_ground?
      if [@type1, @type2].include?(9)
        return true
      end
      return false
    end
    alias type_sol? type_ground?
    
    def type_fly?
      if [@type1, @type2].include?(10)
        return true
      end
      return false
    end
    alias type_vol? type_fly?
    
    def type_psy?
      if [@type1, @type2].include?(11)
        return true
      end
      return false
    end
    
    def type_insect?
      if [@type1, @type2].include?(12)
        return true
      end
      return false
    end
    
    def type_rock?
      if [@type1, @type2].include?(13)
        return true
      end
      return false
    end
    alias type_roche? type_rock?
    
    def type_ghost?
      if [@type1, @type2].include?(14)
        return true
      end
      return false
    end
    alias type_spectre? type_ghost?
    
    def type_dragon?
      if [@type1, @type2].include?(15)
        return true
      end
      return false
    end
    
    def type_steel?
      if [@type1, @type2].include?(16)
        return true
      end
      return false
    end
    alias type_acier? type_steel?
    
    def type_dark?
      if [@type1, @type2].include?(17)
        return true
      end
      return false
    end
    alias type_tenebres? type_dark?
    
    # Renvoie true si le Pokémon est de type Fée sinon false
    def type_fee?
      if [@type1, @type2].include?(18)
        return true
      end #else
      return false
    end
    
    def type_custom?(number)
      if [@type1, @type2].include?(number)
        return true
      end
      return false
    end
  end
end