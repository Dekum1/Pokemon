class Interpreter
  #----------------------------------------------------------------------------
  # Compléter le pokédex manuellement par ID du pkm
  #----------------------------------------------------------------------------
  def pokedex_completer_page(id, female = false, shiny = false, form = 0, mega = 0)
    $pokedex.complete_page(id, female, shiny, form, mega)
  end
  #----------------------------------------------------------------------------
  # Voir un pkm manuellement par son ID
  #----------------------------------------------------------------------------
  def pokedex_vu_page(id, female = false, shiny = false, form = 0, mega = 0)
    $pokedex.seen_page(id, female, shiny, form, mega)
  end

  #---------------------------------------------------------------------------
  # afficher_page
  #   Affiche la page du pokedex
  #---------------------------------------------------------------------------
  def afficher_page(id)
    Graphics.freeze
    $scene = POKEMON_S::Pokemon_Detail.new(id, 0, :map )
    Graphics.transition
  end  
  #----------------------------------------------------------------------------
  # Régler le pokédex au niveau "seulement régional"
  #----------------------------------------------------------------------------
  def pokedex_regional
    $pokedex.set_lv_regional
  end
  #----------------------------------------------------------------------------
  # Régler le pokédex au niveau "seulement national"
  #----------------------------------------------------------------------------
  def pokedex_national
    $pokedex.set_lv_national
  end
  #----------------------------------------------------------------------------
  # Régler le pokédex au niveau "Régional et national disponibles"
  #----------------------------------------------------------------------------
  def pokedex_regional_national
    $pokedex.set_lv_all
  end
  
  #-----------------------------------------------------------------------------
  # Ajout d'une ville visitée : utile pour VOL
  # si val est nil, on enregistre le nom enregistré dans data_mapzone associé à
  # la map où se trouve le héros. Si val égale un entier i, on utilise le nom 
  # enregistré dans data_zone[i]. Si val est un string, on enregistre directement
  # la chaîne.
  #-----------------------------------------------------------------------------
  def add_city(val = nil)
    data = val
    # A partir de la position du héros et de data_mapzone
    if data == nil
      if $game_map.map_id == nil
        print "Erreur Interpreter.Add_city : $game_map.map_id == nil."
        return
      end
      data = $data_mapzone[$game_map.map_id][1]
    end
    # Ce qui est enregistré dans data_zone
    if data.type == Fixnum
      if $data_zone[data] == nil
        print("Erreur Interpreter.Add_city : Aucune zone trouvée associée à 
              l'entier entré.")
        return
      end
      data = $data_zone[data][0]
    end
    if data.type != String
      print "Erreur Iterpreter.Add_city : mauvais argument."
      return
    end
    if $pokemon_party
      $pokemon_party.add_city(data)
    end
  end
  alias ajouter_ville add_city
 
  #-----------------------------------------------------------------------------
  # Vérifier si une ville a été visitée : utilie pour VOL
  # data peut être l'id associée à data_zone ou directement le nom de la ville
  #-----------------------------------------------------------------------------
  def city_visited?(val)
    data = val
    # si on entre l'id associée dans data_zone
    if data.type == Fixnum
      if $data_zone[data] == nil
        print("Erreur Interpreter.City_visited : Aucune zone trouvée associée à 
              l'entier entré.")
        return false
      end
      data = $data_zone[data][0]
    end
    if data.type != String
      print "Erreur Interpreter.City_visited : mauvais argument."
      return false
    end
    return $pokemon_party.cities.include?(data)
  end
  alias ville_visite? city_visited?
  
  #-----------------------------------------------------------------------------
  # enlever une ville dans la liste des villes visitées
  # val peut-être l'id associée à la map dans data_zone ou directement le nom de 
  # la ville
  #-----------------------------------------------------------------------------
  def remove_city(val)
    data = val
    if data.type == Fixnum
      if $data_zone[data] == nil
        print("Erreur Interpreter.Remove_city : Aucune zone trouvée associée à 
              l'entier entré.")
        return
      end
      data = $data_zone[data][0]
    end
    if data.type != String
      print "Erreur Interpreter.Remove_city : mauvais argument."
      return
    end
    if $pokemon_party.cities.include?(data)
      $pokemon_party.cities.delete(data)
    end
  end
  alias enlever_ville remove_city
  
  #-----------------------------------------------------------------------------
  # Vider la liste des villes visitées
  #-----------------------------------------------------------------------------
  def reset_cities
    $pokemon_party.reset_cities
  end
  alias reinitialiser_villes reset_cities
end