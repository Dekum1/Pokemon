#==============================================================================
# ■ DAYCARE
# Pokemon Script Project - Krosk 
# 27/08/08
#-----------------------------------------------------------------------------
# Fonctions supplémentaires dans la classe Interpreter
#   qui assure les fonctions de Pension
#-----------------------------------------------------------------------------
# $game_variables[PENSION]
#   0 : male
#   1 : femelle
#   2 : taux de compatibilité
#   3 : oeuf résultant
#   4 : nombres de pas avant ponte
#-----------------------------------------------------------------------------

module POKEMON_S
  
  class Daycare
    def self.breed_male
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if not $game_variables[PENSION][0].is_a?(Pokemon)
        return nil
      end
      return $game_variables[PENSION][0]
    end
  
    def self.breed_female
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if not $game_variables[PENSION][1].is_a?(Pokemon)
        return nil
      end
      return $game_variables[PENSION][1]
    end
    
    def self.breed_egg
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if not $game_variables[PENSION][3].is_a?(Pokemon)
        return nil
      end
      return $game_variables[PENSION][3]
    end
    
    # ------------------------------------------------------
    # set_male
    #   enregistrement du Pokémon dans la pension
    # ------------------------------------------------------
    def self.set_breed_male(value)
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if not value.is_a?(Pokemon) and value != nil
        return $game_variables[PENSION][0] = nil
      end
      $game_variables[PENSION][0] = value
      $game_variables[PENSION][2] = set_affinity
    end
    
    def self.set_breed_female(value)
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if not value.is_a?(Pokemon) and value != nil
        return $game_variables[PENSION][1] = nil
      end
      $game_variables[PENSION][1] = value
      $game_variables[PENSION][2] = set_affinity
    end
    
    def self.set_breed_egg(value)
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if not value.is_a?(Pokemon) and value != nil
        return $game_variables[PENSION][3] = nil
      end
      $game_variables[PENSION][3] = value
    end
    
    # ------------------------------------------------------
    # daycare_sequence
    #   ce qui se passe à chaque pas supplémentaire à la pension
    # ------------------------------------------------------
    def self.sequence
      # Reproduction
      if breed_affinity > 0 and breed_egg == nil
        if $game_variables[PENSION][4] == nil
          $game_variables[PENSION][4] = 0
        end
        $game_variables[PENSION][4] += 1
        # Nombre de pas avant l'apparition d'un oeuf
        if $game_variables[PENSION][4] == 128
          if rand(100) < breed_affinity
            if   breed_female.female? or breed_male.male?
              set_breed_egg(Pokemon.new.new_egg(breed_female, breed_male))
            elsif breed_male.female? or breed_female.male?
              set_breed_egg(Pokemon.new.new_egg(breed_male, breed_female))
            end
          end
          $game_variables[PENSION][4] = 0
        end
      end
      # Augmentation d'exp
      if breed_male.is_a?(Pokemon)
        breed_male.exp += 1
        while breed_male.level_check
          breed_male.silent_level_up
        end
      end
      if breed_female.is_a?(Pokemon)
        breed_female.exp += 1
        while breed_female.level_check
          breed_female.silent_level_up
        end
      end
    end
    
    # ------------------------------------------------------
    # breed_affinity / set_affinity
    #   lecture / calcul de la compatibilité entre les pokémons
    # ------------------------------------------------------
    def self.breed_affinity
      if not $game_variables[PENSION].is_a?(Array)
        $game_variables[PENSION] = []
      end
      if $game_variables[PENSION][2] == nil
        return -1
      end
      return $game_variables[PENSION][2]
    end
    
    
    def self.set_affinity
      if not(breed_male.is_a?(Pokemon) and breed_female.is_a?(Pokemon))
        return -1
      end
      # Même genre => incompatible
      if (breed_male.male? and breed_female.male?) or
          (breed_male.female? and breed_female.female?) or
          (breed_male.genderless? and breed_female.genderless?)
        return 0
      end
      # Groupe incompatible => incompatible
      if (breed_male.breed_group.include?(15) or
          breed_female.breed_group.include?(15))
        return 0
      end
      # Groupe différent (sauf si l'un est compatible avec tous) => incompatible
      if (breed_male.breed_group & breed_female.breed_group) == [] and
          not (breed_male.breed_group.include?(13) or breed_female.breed_group.include?(13))
        return 0
      end
      
      if breed_male.id == breed_female.id
        if breed_male.trainer_id == breed_female.trainer_id
          return 50 # Meme espèce, meme dresseur
        else
          return 70 # Meme espece, dresseur différent
        end
      else
        if breed_male.trainer_id == breed_female.trainer_id
          return 20 # espèce différente, meme dresseur
        else
          return 50 # espece différente, dresseur différent
        end
      end
    end
    
  end

end