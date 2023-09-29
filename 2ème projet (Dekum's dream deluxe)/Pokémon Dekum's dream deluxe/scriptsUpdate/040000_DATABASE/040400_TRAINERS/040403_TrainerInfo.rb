#==============================================================================
# ● Base de données - Dresseurs
# Pokemon Script Project - Krosk 
# 29/07/07
# Mis à jour par Damien Linux
# 29/04/2020
#==============================================================================
module POKEMON_S
  class Trainer_Info
    class << self
      def index(id)
        if $game_variables
          index = $game_variables[INDEX_BATTLE] - 1
          if index > 0 and $data_trainer[id][index] != nil
            return index
          end #else
        end #else
        return 0 # Page 1
      end
      
      def battler(id)
        return $data_trainer[id][index(id)].battler
      end
      
      def type(id)
        return $data_trainer[id][index(id)].type_trainer
      end
      
      def name(id)
        name_string = $data_trainer[id][index(id)].name
        return name_string
      end
      
      def string(id)
        return "#{type(id)} #{name(id)}"
      end
      
      def money(id)
        return $data_trainer[id][index(id)].money
      end
      
      def pokemon(id, index)
        return $data_trainer[id][index(id)].info_pokemon[index]
      end
      
      def pokemon_list(id)
        return $data_trainer[id][index(id)].info_pokemon
      end
      
      def string_victory(id)
        return $data_trainer[id][index(id)].victory_texts
      end
      
      def string_defeat(id)
        return $data_trainer[id][index(id)].defeat_texts
      end
      
      def objects(id)
        return $data_trainer[id][index(id)].objects
      end
    end
  end
end