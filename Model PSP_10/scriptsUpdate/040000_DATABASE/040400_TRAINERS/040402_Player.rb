#==============================================================================
# ● Base de données - Dresseurs
# Pokemon Script Project - Krosk 
# 29/07/07
# Mis à jour par Damien Linux
# 29/04/2020
#==============================================================================
module POKEMON_S
  # -----------------------------------------------------------------
  #   Classe d'information du joueur
  # -----------------------------------------------------------------
  class Player
    class << self
      def id
        return sprintf("%05d", $game_variables[TRAINER_CODE]%(2**16))
      end
    
      def code
        return $game_variables[TRAINER_CODE]
      end
      
      def name
        return $game_party.actors[0].name
      end
      
      def battler
        return $game_party.actors[0].battler_name
      end
      
      def set_trainer_code(value)
        $game_variables[TRAINER_CODE] = value
      end
      
      def trade_list
        if not $game_variables[ECHANGE_DATA].is_a?(Array)
          $game_variables[ECHANGE_DATA] = []
        end
        return $game_variables[ECHANGE_DATA]
      end
      
      def register_code(value)
        if not $game_variables[ECHANGE_DATA].is_a?(Array)
          $game_variables[ECHANGE_DATA] = []
        end
        $game_variables[ECHANGE_DATA].push(value)
        $game_variables[ECHANGE_DATA].uniq!
      end
      
      def erase_code(value)
        if not $game_variables[ECHANGE_DATA].is_a?(Array)
          $game_variables[ECHANGE_DATA] = []
        end
        $game_variables[ECHANGE_DATA].delete(value)
      end
    end
  end
end