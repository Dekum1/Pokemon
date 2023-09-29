#==============================================================================
# ● SaveFile
# Pokemon Script Project - Krosk 
# SaveFile - Damien Linux
# 03/04/2020
#==============================================================================
# Avec l'aide de : Nuri Yuri
#==============================================================================
# Modulable uniquement pour les parties spécifiées en commentaires (indications)
# N'y touchez que si vous savez ce que vous faites
#==============================================================================
class SaveFile
  attr_accessor :characters
  attr_accessor :frame_count
  attr_accessor :game_system
  attr_accessor :game_switches
  attr_accessor :game_variables
  attr_accessor :game_self_switches
  attr_accessor :game_self_variables
  attr_accessor :game_screen
  attr_accessor :game_actors
  attr_accessor :game_party
  attr_accessor :game_troop
  attr_accessor :game_map
  attr_accessor :game_player
  attr_accessor :read_data
  attr_accessor :pokemon_party
  attr_accessor :random_encounter
  attr_accessor :pokedex
  attr_accessor :data_storage
  attr_accessor :battle_var
  attr_accessor :existing_pokemon
  attr_accessor :string
  attr_accessor :version
  # Si votre sauvegarde contient plus d'informations. Imaginons qu'une variable
  # globale $game_var y est sockée, ajoutez ici (puis allez voir assignation_var
  # et data_update plus bas) :
  # attr_accessor :game_var

  # Charge les données d'une ancienne Sauvegarde (<= PSP 0.9.2 remastered) 
  # pour la rendre compatible au système de sauvegarde installé depuis PSP 1.0
  # filename : Le nom du fichier de sauvegarde
  def load_from_old_save(filename)
    File.open("#{filename}.rxdata", 'rb') do |f|
      POKEMON_S::LISTOLDSAVE.each do |object| 
        # Nouvelle Gestion Pokédex
        case object
        when "data_pokedex"
          instance_variable_set("@pokedex", conversion_pokedex(Marshal.load(f)))
        when "random_encounter"
          Marshal.load(f) # Chargement de l'ancien Random Encounter dans le vide
          instance_variable_set("@random_encounter", POKEMON_S::Random_Encounter.new)
        else
          instance_variable_set("@#{object}", Marshal.load(f))
        end
      end
    end
    File.open("Saves/#{filename}.rxsav", "wb") { |f| Marshal.dump(self, f) }
    File.delete("#{filename}.rxdata")
  end
  
  # Charge les données d'une ancienne Sauvegarde provenant de 
  # PSP 1.0 - Alpha 0.9a pour la rendre au système de sauvegarde installé peu
  # de temps après ce précédent système
  # filename : Le nom du dossier de sauvegarde
  def load_from_old_save_directory(filename)
    loaded = []
    POKEMON_S::NAMESFILESAVES.each do |under_filename|
      if FileTest.exist?("#{filename}/#{under_filename}.rxdata")
        File.open("#{filename}/#{under_filename}.rxdata", 'rb') do |f|
          # Nouvelle Gestion Pokédex
          case under_filename
          when "DataPokedex"
            loaded.push(conversion_pokedex(Marshal.load(f)))
          when "RandomEncounter"
            loaded.push(POKEMON_S::Random_Encounter.new)
          else
            loaded.push(Marshal.load(f))
          end
        end
      else
        loaded.push(nil)
      end
    end
    @characters = loaded[0]
    @frame_count = loaded[1]
    @game_system = loaded[2]
    @game_switches = loaded[3]
    @game_variables = loaded[4]
    @game_self_switches = loaded[5]
    @game_self_variables = loaded[6]
    @game_screen = loaded[7]
    @game_actors = loaded[8]
    @game_party = loaded[9]
    @game_troop = loaded[10]
    @game_map = loaded[11]
    @game_player = loaded[12]
    @read_data = loaded[13]
    @pokemon_party = loaded[14]
    @random_encounter = loaded[15]
    @pokedex = loaded[16]
    @data_storage = loaded[17]
    @battle_var = loaded[18]
    @existing_pokemon = loaded[19]
    @string = loaded[20]
    File.open("Saves/#{filename}.rxsav", 'wb') { |f| Marshal.dump(self, f) }
    delete_dir(filename)
  end
  
  # Supprime les du répertoire de sauvegarde (spécifique à la migration des 
  # sauvegardes sur PSP 1.0 - Alpha 0.9a) puis le répertoire en question
  # dirname : Le nom du répertoire
  def delete_dir(dirname)
    POKEMON_S::NAMESFILESAVES.each do |filename| 
      path = "#{dirname}/#{filename}.rxdata"
      if FileTest.exist?(path)
        File.delete(path) 
      end
    end
    if Dir.entries(dirname).size <= 2
      Dir.delete(dirname)
    else
      print "Impossible de supprimer l'ancien dossier de sauvegarde, à vous " +
            "de le supprimer manuellement."
    end
  end
  
  # Détermine la sauvegarde existe dans le projet
  # - Assure la compatibilité avec la version actuelle :
  #   - Transfère les sauvegardes <= PSP 0.9.2 remastered sur le nouveau système
  #   - Transfère les sauvegardes PSP 1.0 - Alpha 0.9a sur le nouveau système
  # Créé le dossier Saves si ce dernier n'existe pas
  # Renvoie : true si la sauvegarde existe
  #           false sinon
  def save_exist(filename)
    if not File.directory?("Saves")
      Dir.mkdir("Saves") # Création du répertoire de sauvegardes
    end
    exist = FileTest.exist?("Saves/#{filename}.rxsav")
    if not exist
      if FileTest.exist?("#{filename}.rxdata")
        # Version <= PSP 0.9.2 remastered
        load_from_old_save(filename)
        exist = true
      elsif File.directory?(filename)
        # Version PSP 1.0 - Alpha 0.9a
        load_from_old_save_directory(filename)
        exist = true
      end
      @version = VERSION if exist
    end
    return exist
  end

  def read_preview(filename)
    pokemon_save_read = nil
    File.open("Saves/#{filename}.rxsav", 'rb') do |f| 
      pokemon_save_read = Marshal.load(f)
    end
    frame_count = pokemon_save_read.frame_count
    game_var = pokemon_save_read.game_variables
    total_sec = frame_count / Graphics.frame_rate
    g_actors = pokemon_save_read.game_actors
    pkmn_party = pokemon_save_read.pokemon_party
    game_switche = pokemon_save_read.game_switches
    pkdex = pokemon_save_read.pokedex
    return [pokemon_save_read.read_data, total_sec, game_var, pkmn_party, g_actors, pkdex, game_switche]
  end
  
  # Détermine les variables globales permettant le bon fonctionnement
  # du starter-kit
  def assignation_var
    Graphics.frame_count = @frame_count if @frame_count != nil
    $game_system = @game_system != nil ? @game_system : Game_System.new
    $game_switches = @game_switches != nil ? @game_switches : Game_Switches.new
    $game_variables = @game_variables != nil ? @game_variables : 
                                               Game_Variables.new
    $game_self_switches = @game_self_switches != nil ? @game_self_switches :
                                                       Game_SelfSwitches.new
    $game_self_variables = @game_self_variables != nil ? @game_self_variables :
                                                         Game_SelfVariables.new
    $game_screen = @game_screen != nil ? @game_screen : Game_Screen.new
    $game_actors = @game_actors != nil ? @game_actors : Game_Actors.new
    $game_party = @game_party != nil ? @game_party : Game_Party.new
    $game_troop = @game_troop != nil ? @game_troop : Game_Troop.new
    $game_map = @game_map != nil ? @game_map : Game_Map.new
    $game_player = @game_player != nil ? @game_player : Game_Player.new
    $read_data = @read_data
    $pokemon_party = @pokemon_party
    $random_encounter = @random_encounter.is_a?(Array) ? POKEMON_S::Random_Encounter.new : @random_encounter
    $pokedex = @pokedex != nil ? @pokedex : conversion_pokedex(@data_pokedex) 
    $data_storage = @data_storage
    $battle_var = @battle_var
    $existing_pokemon = @existing_pokemon
    $string = @string
    # Exemple de variable à stocker dans votre sauvegarde : 
    # Game_Var ci-dessous est le nom de la class correspondante, ici
    # par exemple la class est SaveFile, donc à adapter
    # $game_var = @game_var != nil ? @game_var : Game_Var.new
  end
  
  # Sauvegarde de la partie courante
  # Création ou écrasement du fichier de sauvegarde
  # filename : Le nom du fichier de sauvegarde
  # characters : Les personnage en jeu
  def save(filename, characters)
    data_update(characters)
    File.open("Saves/#{filename}.rxsav", "wb") { |f| Marshal.dump(self, f) }
  end
  
  # Mise à jour des données de la sauvegarde : affectation des variables
  # globales
  # characters : Les personnage en jeu
  def data_update(characters)
    @characters = characters
    @frame_count = Graphics.frame_count
    @game_system = $game_system
    @game_switches = $game_switches
    @game_variables = $game_variables
    @game_self_switches = $game_self_switches
    @game_self_variables = $game_self_variables
    @game_screen = $game_screen
    @game_actors = $game_actors
    @game_party = $game_party
    @game_troop = $game_troop
    @game_map = $game_map
    @game_player = $game_player
    @read_data = $read_data
    @pokemon_party = $pokemon_party
    @random_encounter = $random_encounter
    @pokedex = $pokedex
    @data_storage = $data_storage
    @battle_var = $battle_var
    @existing_pokemon = $existing_pokemon
    @string = $string
    @version = VERSION if @version == nil
    # Exemple de variable à mettre à jour dans votre sauvegarde : 
    # @game_var = $game_var
  end

  # Pour passer de l'ancienne à la nouvelle gestion du Pokédex
  # data_pokedex : Les données du pokédex
  # retourne les pokédex compatible avec la version actuelle
  def conversion_pokedex(data_pokedex)
    pokedex = POKEMON_S::Pokedex.new($data_pokemon.size - 1)
    pokedex.enable if data_pokedex[0]
    1.upto(data_pokedex.size-1) do |id|
      if data_pokedex[id][1] # Capturé
        pokedex.complete_page(id)
      elsif data_pokedex[id][0] # vu
        pokedex.seen_page(id)
      end
    end
    return pokedex
  end
end