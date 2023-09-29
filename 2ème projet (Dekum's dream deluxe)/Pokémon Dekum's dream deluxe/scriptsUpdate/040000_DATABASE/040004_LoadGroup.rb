#==============================================================================
# ● Base de données - Dresseurs
# Pokemon Script Project - Krosk 
# 29/07/07
# Load_Trainers - Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Load_Data
    class Load_Group
      class << self
        def load
          $data_trainer = []
          $data_encounter = []
          $data_encounter[0] = nil
          $data_troops = load_data("Data/Troops.rxdata")
          1.upto($data_troops.size - 1) do |i|
            name = $data_troops[i].name
            # Vérification Tag
            tag = (name.split('/'))[0]
            if tag != "T"
              $data_trainer[i] = nil
              Load_Encounter.load(tag, i)
              next
            else
              $data_encounter[i] = nil
              Load_Trainers.load(name, i)
            end
          end
        end

        def load_infos_zone
          Load_Encounter.load_infos_zone
        end
      end
    end
  end
end