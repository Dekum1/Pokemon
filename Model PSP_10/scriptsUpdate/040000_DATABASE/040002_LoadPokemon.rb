#==============================================================================
# ● Base de données - Pokémon
# Pokemon Script Project - Krosk 
# Load_Pokemon - Damien LinuxT
# 14/11/2020
#==============================================================================
module POKEMON_S
  class Load_Data
    class Load_Pokemon
      class << self
        def load
          #============================================================================
          # Base de données des Pokémons à modifier, avec les infos concernant le Pokédex
          #============================================================================
          $data_pokemon = []#Array.new(386)
          if FileTest.exist?("Data/data_pokemon.txt")
            begin
              file = File.open("Data/data_pokemon.txt", "rb")
              file.readchar
              file.readchar
              file.readchar
              file.each {|line| eval(line) }
              file.close
            rescue Exception => exception
              EXC::error_handler(exception, file)
            end
          end

          #============================================================================
          # Bass de données des formes des Pokémons
          # A modifier avec les infos concernant le Pokédex
          #============================================================================
          $data_form = {}
          if FileTest.exist?("Data/data_form.txt")
            begin
              file = File.open("Data/data_form.txt", "rb")
              file.readchar
              file.readchar
              file.readchar
              file.each {|line| eval(line) }
              file.close
            rescue Exception => exception
              EXC::error_handler(exception, file)
            end
          else
            $data_form = load_data("Data/data_form.rxdata")
          end
          
          warning_a = []
          warning_b = []
          warning_c = []
          warning_d = []
          
          if FileTest.exist?("Data/data_pokemon.txt")
            $data_classes       = load_data("Data/Classes.rxdata")
            $data_weapons       = load_data("Data/Weapons.rxdata")
            $data_armors        = load_data("Data/Armors.rxdata")
            $data_enemies       = load_data("Data/Enemies.rxdata")
            # Génération des talents
            $data_ability = []
            $data_ability.push([]) # Element en 0 vide pour rester compatible avec les
                                  # Versions utilisant la BDS avant PSP 1.0
            34.upto($data_armors.size - 1) do |id|
              ability = $data_armors[id]
              $data_ability.push(Array.new)
              $data_ability[id-33].push(ability.name)
              $data_ability[id-33].push(ability.description)
              $data_ability[id-33].push(ability.price)
            end
            # Cycle de conversion
            1.upto($data_pokemon.length - 1) do |id|
              # Vérification d'onglet Evolution
              if $data_classes[id] == nil# or $data_classes[id].weapon_set == [] or $data_classes[id].armor_set == []
                warning_b.push(id)
                warning_d.push("EVOLUTION #{id} : Fiche inexistante.")
                $data_classes[id] = RPG::Class.new
                $data_classes[id].weapon_set.push(16) # Type exp
                $data_classes[id].weapon_set.push(30) # Nombre de pas
                $data_classes[id].armor_set.push(6) # Genre
                $data_classes[id].armor_set.push(13) # Loyauté par défaut
                $data_classes[id].armor_set.push(32) # groupe d'oeuf par défaut
                $data_classes[id].armor_set.push(76+33) # Capacité spé par défaut
                $data_classes[id].learnings.push(RPG::Class::Learning.new)
              end
                
              # On crée la liste d'évolution
              weapon_set = $data_classes[id].weapon_set
              list = []
              count = 0
                
              weapon_set.compact!
              
              # Exp code
              weapon_set.each do |code|
                if (Array.new(5) {|i| i}).include?(code-15)
                  list[0] = code - 15
                end
                
                # Compteur evolution (détection d'erreur)
                if (Array.new(5) {|i| i+22}).include?(code)
                  count += code
                end
              end
              
              if list[0] == nil
                warning_d.push("EVOLUTION #{id} : Pokémon n'a pas d'EXP Type réglé.")
                list[0] = 2 # EXP Type normal par défaut
              end
                
              # Type evolution
              #print "#{$data_classes[id].name}\n#{$data_pokemon[id][0]}"
              if count > 26
                # Pas d'évolution / Trop d'évolution
                list.push(["", []])
              elsif count == 0
                # Pas d'évolution
                list.push(["", []])
              else
                name = $data_classes[id].name
                case count
                # Evolution normale
                when 22
                  temp_list = name.split('/')
                  temp_list[1] = temp_list[1].to_i
                  if temp_list[1] == nil 
                    warning_d.push("EVOLUTION #{id} : Erreur code évolution naturelle.")
                    list.push(["", ])
                  elsif temp_list[1] == 0
                    warning_d.push("EVOLUTION #{id} : Erreur code évolution naturelle.")
                    list.push(["", ])
                  else
                    list.push(temp_list)
                  end
                    
                # Evolution par pierre
                when 23
                  if name == ""
                    warning_d.push("EVOLUTION #{id} : Manque code évolution par pierre.")
                    list.push(["", ])
                  elsif $data_pokemon[id].length > 3 or $data_pokemon[id][2] == nil or $data_pokemon[id][2][1] == nil
                    warning_d.push("EVOLUTION #{id} : Erreur data_pokemon.txt dans les données Evolution.")
                    list.push(["", ])
                  elsif $data_pokemon[id][2][1].type == Array and $data_pokemon[id][2][1][0] != "stone"
                    warning_d.push("EVOLUTION #{id} : Erreur data_pokemon.txt dans les données Evolution.")
                    list.push(["", ])
                  else
                    if $data_pokemon[id][2][1].type == Array and $data_pokemon[id][2][1][0] == "stone"
                      string = $data_pokemon[id][2][1][1].to_s
                    elsif $data_pokemon[id][2][1].to_s == "stone"
                      string = $data_pokemon[id][2][2].to_s
                    else
                      string = $data_pokemon[id][2][1].to_s
                    end
                    list.push([name, ["stone", string]])
                  end
                  
                # Evolution par bonheur
                when 24
                  if name == ""
                    warning_d.push("EVOLUTION #{id} : Manque code évolution par bonheur.")
                    list.push(["", ])
                  else
                    list.push([name, "loyal"])
                  end
                
                # Evolution par Echange
                when 25
                  if name == ""
                    warning_d.push("EVOLUTION #{id} : Manque code évolution par échange.")
                    list.push(["", ])
                  else
                    temp_list = [name, "trade"]
                    list = list.push(temp_list)
                  end
                  
                # Evolution spéciale
                when 26
                  2.upto($data_pokemon[id].size-1) do |i|
                    list.push($data_pokemon[id][i])
                  end
                end
              end
              
              # Vérification en cas de non remplissage de $data_pokemon
              if $data_pokemon[id] == nil
                warning_a.push(id)
              end
              
              # Insertion
              $data_pokemon[id][5] = list
                
              # Description
              $data_pokemon[id][9] = "Aucune description."
              $data_pokemon[id][9] = $data_pokemon[id][1] if $data_pokemon[id][1] != nil
              # Localisation
              $data_pokemon[id][9][4] = []
              
              # Vérification en cas de non remplissage de l'onglet Pokémon
              if $data_enemies[id] == nil
                warning_c.push(id)
                warning_d.push("POKEMON #{id} : Fiche inexistante.")
                $data_enemies[id] = RPG::Enemy.new
                $data_enemies[id].name = $data_pokemon[id][0] # Nom
                $data_enemies[id].maxsp = id # ID Bis
                $data_enemies[id].gold = 255
                $data_enemies[id].element_ranks.resize(26)
                $data_enemies[id].element_ranks[1] = 1 # Type normal par défaut
              end
                
              # Nom
              data_sheet = $data_enemies[id]
              $data_pokemon[id][0] = data_sheet.name
              $data_pokemon[id][1] = data_sheet.maxsp
            
              # Base_stats
              base_stat = [data_sheet.maxhp, data_sheet.str, data_sheet.dex, data_sheet.agi, data_sheet.int, data_sheet.atk]
              $data_pokemon[id][2] = base_stat
                
              # Liste des attaques apprises
              skill_list = []
              $data_classes[id].learnings.each do |learning|
                skill_list.push(learning.level)
                skill_list.push(learning.skill_id)
              end
              $data_pokemon[id][3] = skill_list
                
              # CT/CS
              ct_list = []
              weapon_set.each do |code|
                if code > 33 and code <= 133
                  label = $data_weapons[code].name[0..1]
                  if label == "CT"
                    number = $data_weapons[code].name[2..3].to_i
                    ct_list.push(number)
                  elsif label == "CS"
                    number = $data_weapons[code].name[2..3].to_i
                    ct_list.push([number])
                  end
                end
              end
              $data_pokemon[id][4] = ct_list
                
              # Type
              $data_pokemon[id][6] = []
              1.upto(25) do |t|
                type = $data_enemies[id].element_ranks[t]
                if type == 1
                  $data_pokemon[id][6][0] = t
                end
                if type == 2
                  $data_pokemon[id][6][1] = t
                end
              end
                
              if $data_pokemon[id][6] == []
                warning_d.push("POKEMON #{id} : Pas de types spécifiés.")
                $data_pokemon[id][6][0] = 1
              end
                
              # Data ext
              $data_pokemon[id][7] = []
              # Rareté
              $data_pokemon[id][7][0] = $data_enemies[id].gold
              # Chance femelle
              2.upto(9) do |t|
                if $data_classes[id].armor_set.include?(t)
                  case t
                  when 2
                    $data_pokemon[id][7][1] = -1
                  when 3
                    $data_pokemon[id][7][1] = 0
                  when 4
                    $data_pokemon[id][7][1] = 12.5
                  when 5
                    $data_pokemon[id][7][1] = 25
                  when 6
                    $data_pokemon[id][7][1] = 50
                  when 7
                    $data_pokemon[id][7][1] = 75
                  when 8
                    $data_pokemon[id][7][1] = 87.5
                  when 9
                    $data_pokemon[id][7][1] = 100
                  end
                end
              end
              if $data_pokemon[id][7][1] == nil
                $data_pokemon[id][7][1] = 50
                warning_d.push("EVOLUTION #{id} : Pourcentage femelle non spécifié.")
              end
              
              # Loyauté
              11.upto(16) do |t|
                if $data_classes[id].armor_set.include?(t)
                  case t
                  when 11
                    $data_pokemon[id][7][2] = 0
                  when 12
                    $data_pokemon[id][7][2] = 35
                  when 13
                    $data_pokemon[id][7][2] = 70
                  when 14
                    $data_pokemon[id][7][2] = 90
                  when 15
                    $data_pokemon[id][7][2] = 100
                  when 16
                    $data_pokemon[id][7][2] = 140
                  end
                end
              end
              if $data_pokemon[id][7][2] == nil
                $data_pokemon[id][7][2] = 70
                warning_d.push("EVOLUTION #{id} : Bonheur par défaut non spécifié.")
              end
              
              # Capacité
              code1 = 0
              code2 = 0
              34.upto($data_armors.length-1) do |t|
                if $data_classes[id].armor_set.include?(t)
                  if code1 == 0
                    code1 = t
                  elsif code2 == 0
                    code2 = t
                  end
                end
              end
              if code1 == 0
                warning_d.push("EVOLUTION #{id} : Pas de capacité spéciale spécifiée.")
                code1 = 76+33
              end
              ability_list = code2 == 0 ? [$data_ability[code1-33][0]] : [$data_ability[code1-33][0], $data_ability[code2-33][0]]
              $data_pokemon[id][7][3] = ability_list
              
              # Groupe compatible
              breed_group = []
              18.upto(32) do |t|
                if $data_classes[id].armor_set.include?(t) and breed_group.length < 2
                  breed_group.push(t-17)
                end
              end
              if breed_group.length == 1
                breed_group[1] = breed_group[0]
              end
              if breed_group.length == 0
                warning_d.push("EVOLUTION #{id} : Pas de groupe d'oeuf spécifié.")
                breed_group = [15,15]
              end
              $data_pokemon[id][7][4] = breed_group
              
              # Breed move
              breed_move = []
              $data_enemies[id].actions.each do |action|
                breed_move.push(action.skill_id)
              end
              $data_pokemon[id][7][5] = breed_move
              
              # Hatch_step
              step = 0
              28.upto(32) do |t|
                if $data_classes[id].weapon_set.include?(t)
                  case t
                  when 28
                    step += 1280
                  when 29
                    step += 1280*2
                  when 30
                    step += 1280*4
                  when 31
                    step += 1280*8
                  when 32
                    step += 1280*16
                  end
                end
              end
              if step == 0
                step = 1280*4
                warning_d.push("EVOLUTION #{id} : Nbr Pas avant éclosion non spécifié.")
              end
              $data_pokemon[id][7][6] = step
              
              # EV
              battle_list = [0,0,0,0,0,0,0]
              2.upto(7) do |t|
                if $data_classes[id].weapon_set.include?(t)
                  battle_list[-2+t] += 1
                end
              end
              8.upto(13) do |t|
                if $data_classes[id].weapon_set.include?(t)
                  battle_list[-8+t] += 2
                end
              end
              battle_list[6] = $data_enemies[id].exp
              $data_pokemon[id][8] = battle_list
            end
          else
            $data_armors        = load_data("Data/Armors.rxdata")
            # Génération des talents
            $data_ability = []
            $data_ability.push([]) # Element en 0 vide pour rester compatible avec les
                                  # Versions utilisant la BDS avant PSP 1.0
            34.upto($data_armors.size - 1) do |id|
              ability = $data_armors[id]
              $data_ability.push(Array.new)
              $data_ability[id-33].push(ability.name)
              $data_ability[id-33].push(ability.description)
              $data_ability[id-33].push(ability.price)
            end
            $data_pokemon = load_data("Data/data_pokemon.rxdata")
          end

          file = File.open("LoadingLog.txt", "w")
          if warning_a != []
            file.write("--- Chargement des Pokémons : $data_pokemon ---\n")
            file.write("Il manque des données dans data_pokemon.txt pour les Pokémons suivants. Veuillez vérifier.\n")
            file.write("Liste des ID : #{warning_a.inspect}\n\n")
          end
          if warning_b != []
            file.write("--- Chargement des Pokémons : Evolution ---\n")
            file.write("Il manque des données dans l'onglet Evolution (Classes) pour les Pokémons suivants. Veuillez vérifier.\n")
            file.write("Liste des ID : #{warning_b.inspect}\n\n")
          end
          if warning_c != []
            file.write("--- Chargement des Pokémons : Pokémons ---\n")
            file.write("Il manque des données dans l'onglet Pokémons (Monstres) pour les Pokémons suivants. Veuillez vérifier.\n")
            file.write("Liste des ID : #{warning_c.inspect}\n\n")
          end
          if warning_d != []
            file.write("--- Chargement des Pokémons : Détails ---\n")
            file.write("Liste des problèmes :\n")
            file.write("ONGLET ID : nature du problème\n")
            warning_d.each do |string|
              file.write("#{string}\n")
            end
          end
          file.close
          
          if warning_a != [] or warning_b != [] or warning_c != [] or warning_d != []
            print("La base de données des Pokémons contient des erreurs.\nInspectez LoadingLog.txt.")
          end
        end
      end
    end
  end
end