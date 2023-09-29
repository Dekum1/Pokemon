#==============================================================================
# ● Base de données - Dresseurs
# Pokemon Script Project - Krosk 
# 29/07/07
# Load_Trainers - Damien Linux
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Load_Data
    class Load_Trainers
      class << self
        def load(name, i)
          # Nom et Type
          data_name = (name.split('/'))[1]
          data_name = data_name.split('_')
          # Vérification page event
          if $data_troops[i].pages == []
            # Effacage car invalide
            $data_trainer[i] = nil
            return
          end
          # Initialisation Groupe (tableau de pages)
          $data_trainer[i] = []
          # Déroulement des pages une par une
          0.upto($data_troops[i].pages.size - 1) do |i_page|
            event_list = $data_troops[i].pages[i_page].list
            if data_name[1] != nil
              $data_trainer[i][i_page] = Trainer.new(i, data_name[1].to_s, data_name[0].to_s)
            else
              $data_trainer[i][i_page] = Trainer.new(i, data_name[0].to_s)
            end
            # Effacage si aucun event
            if event_list == []
              $data_trainer[i][i_page] = nil
              next
            end
            tag = ""
            index_script = 0
            event_list.each do |event|
              case event.code
              when 322 # Changer Apparence => Définition battler
                battler = event.parameters[3]
                $data_trainer[i][i_page].battler = battler
              when 355 # Script
                index_script = 0
                tag = event.parameters[0].downcase
              when 655 # Script suite
                method_to_call = "add_#{tag}"
                if methods.include?(method_to_call)
                  send(method_to_call, index_script, event, i, i_page)
                  index_script += 1
                end
              end
            end
          end
        end

        # Ajoute les informations d'un Pokémon
        # index_script : La position dans le script "Pokemon"
        # event : L'event analysé sur l'index index_script
        # i : L'index dans "Groupes"
        # i_page : Le numéro de page
        def add_pokemon(index_script, event, i, i_page)
          if $data_troops[i].members[index_script]
            script = event.parameters[0]
            id = $data_troops[i].members[index_script].enemy_id
            $data_trainer[i][i_page].add_pokemon(id, eval(script)) if id < $data_pokemon.size
          end
        end

        # Ajoute les informations d'un Dresseur
        # index_script : La position dans le script "Pokemon"
        # event : L'event analysé sur l'index index_script
        # i : L'index dans "Groupes"
        # i_page : Le numéro de page
        def add_dresseur(index_script, event, i, i_page)
          script = event.parameters[0]
          case index_script
          when 0 # Argent
            $data_trainer[i][i_page].money = script.to_i
          when 1, 2 # String Victoire (système < PSPE 0.10)
            $data_trainer[i][i_page].victory_texts.push(script != nil ? script : "")
          when 3, 4 # String Defaite (système < PSPE 0.10)
            $data_trainer[i][i_page].defeat_texts.push(script != nil ? script : "")
          end
        end

        # Ajoute le texte de victoire
        # index_script : La position dans le script "Pokemon"
        # event : L'event analysé sur l'index index_script
        # i : L'index dans "Groupes"
        # i_page : Le numéro de page
        def add_victoire(index_script, event, i, i_page)
          script = event.parameters[0]
          $data_trainer[i][i_page].victory_texts.push(script != nil ? script : "")
        end

        # Ajoute le texte de défaite
        # index_script : La position dans le script "Pokemon"
        # event : L'event analysé sur l'index index_script
        # i : L'index dans "Groupes"
        # i_page : Le numéro de page
        def add_defaite(index_script, event, i, i_page)
          script = event.parameters[0]
          $data_trainer[i][i_page].defeat_texts.push(script != nil ? script : "")
        end

        # Ajoute les objets utilisables en combat par un dresseur
        # index_script : La position dans le script "Pokemon"
        # event : L'event analysé sur l'index index_script
        # i : L'index dans "Groupes"
        # i_page : Le numéro de page
        def add_objet(index_script, event, i, i_page)
          script = event.parameters[0]
          if eval(script).is_a?(Hash)
            $data_trainer[i][i_page].objects.push(eval(script))
          else
            $data_trainer[i][i_page].objects = script != nil ? eval(script) : nil
          end
        end
      end
    end
  end
end