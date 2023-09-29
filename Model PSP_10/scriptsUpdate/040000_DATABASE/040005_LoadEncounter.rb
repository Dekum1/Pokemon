#==============================================================================
# ● Base de données - Pokémons sauvages
# Pokemon Script Project - Krosk 
# 29/09/07
#------------------------------------------------------------------------------
# G!n0 - Intégration du tag horaire
#------------------------------------------------------------------------------
# Load_Encounter - Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Load_Data
    class Load_Encounter
      class << self
        def load(data, i)
          # Apparition suivant heure
          data = data.split('_') if data
          $data_encounter[i] = []
          0.upto($data_troops[i].pages.size - 1) do |i_page|
            unless data # Sans nom
              $data_encounter[i][i_page] = nil
              next
            end
            # Tag terrain
            t_tag = data[0].to_i
            $data_encounter[i][i_page] = Encounter.new(i, i_page)
            if t_tag > 0 and t_tag < TAG_SYS::T_SIZE
              $data_encounter[i][i_page].tag_terrain = t_tag
            else
              $data_encounter[i][i_page] = nil
              next
            end
            # Tag horaire
            if data[1] != nil
              # Jour
              if data[1] == "J"
                $data_encounter[i][i_page].tag_horaire = [6, 18]
              # Nuit
              elsif data[1] == "N"
                $data_encounter[i][i_page].tag_horaire = [18, 6]
              else
                intervalle_horaire = eval(data[1])
                # Une heure
                if intervalle_horaire.is_a?(Fixnum)
                  $data_encounter[i][i_page].tag_horaire = [intervalle_horaire, intervalle_horaire + 1]
                # Une fourchette horaire
                elsif intervalle_horaire.is_a?(Array)
                  $data_encounter[i][i_page].tag_horaire = [intervalle_horaire[0], intervalle_horaire[1]]
                end
              end
            end
            # Vérification page event
            if $data_troops[i].pages.size <= 0
              # Effacage car invalide
              $data_encounter[i][i_page] = nil
              next
            end
            # Event Page1
            event_list = $data_troops[i].pages[i_page].list
            # Effacage si aucun event
            if event_list.size <= 0
              $data_encounter[i][i_page] = nil
              next
            end
            # Condition par switch
            if $data_troops[i].pages[i_page].condition.switch_valid
              $data_encounter[i][i_page].condition = $data_troops[i].pages[i_page].condition.switch_id
            end
            index_script = 0
            event_list.each do |event|
              case event.code
              when 355 # Script
                index_script = 0
                index_encounter = 0
                script = event.parameters[0]
                if eval(script).is_a?(Fixnum) and eval(script) > 0
                  ecart = eval(script)
                  $data_encounter[i][i_page].difference = ecart if ecart.is_a?(Fixnum) and ecart > 0
                end
              when 655 # Script suite
                script = event.parameters[0]
                if $data_troops[i].members[index_script]
                  $data_encounter[i][i_page].add_pokemon($data_troops[i].members[index_script].enemy_id, eval(script))
                end
                index_script += 1
              end
            end
            $data_encounter[i][i_page].adaptation_rarity if $data_encounter[i][i_page]
          end
        end
        
        def load_infos_zone
          map_infos = load_data("Data/MapInfos.rxdata")
          map_infos.each do |key, value|
            zone = (value.name.split('/'))
            if zone.size == 1
              next
            end
            zone = eval(zone[0])
            if zone.is_a?(Array)
              zone = zone[0]
            end
            map = load_data(sprintf("Data/Map%03d.rxdata", key))
            map.encounter_list.each do |id|
              if $data_encounter[id][Encounter.index_page(id)]
                $data_encounter[id][Encounter.index_page(id)].info_pokemon.each do |pokemon_wild|
                  next if pokemon_wild.id > $data_pokemon.size
                  if $data_pokemon[pokemon_wild.id][9][4] == nil
                    $data_pokemon[pokemon_wild.id][9][4] = []
                  end
                  $data_pokemon[pokemon_wild.id][9][4].push(zone)
                  $data_pokemon[pokemon_wild.id][9][4].uniq!
                end
              end
            end
          end
        end
      end
    end
  end
end