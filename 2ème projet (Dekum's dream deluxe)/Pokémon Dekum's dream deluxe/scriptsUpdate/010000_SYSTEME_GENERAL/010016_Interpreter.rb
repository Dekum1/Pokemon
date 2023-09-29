#==============================================================================
# ■ Interpreter
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène à modifier à loisir
#-----------------------------------------------------------------------------
# Fonctions personnelles "Insérer un script"
#-----------------------------------------------------------------------------


class Interpreter
  include POKEMON_S

  #-----------------------------------------------------------------------------
  # call_battle_wild
  #   Appel d'un combat contre un Pokémon sauvage quelconque
  #   (Pour un légendaire mobile, cf fonction suivante)
  #   id: id Pokémon
  #   level: niveau du Pokémon sauvage
  #-----------------------------------------------------------------------------
  def call_battle_wild(id_data, level, shiny = false, ia = false)
    return false if $pokemon_party.size == 0
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    pokemon = Pokemon.new(id, level, shiny)
    $scene = Pokemon_Battle_Wild.new($pokemon_party, pokemon, ia)
    @wait_count = 2
    return true
  end
  alias demarrer_combat call_battle_wild
  
  #-----------------------------------------------------------------------------
  # demarre_combat_param(hash)
  #   Appel d'un combat contre un Pokémon sauvage défini
  #   (Pour un légendaire mobile, cf fonction suivante)
  #   id: id Pokémon
  #   level: niveau du Pokémon sauvage
  #-----------------------------------------------------------------------------
  def demarre_combat_param(hash)
    if hash["ID"] == nil or hash["NV"] == nil
      return
    end
    pokemon = Pokemon.new(hash["ID"], hash["NV"], hash["SHINY"])
    if hash["GR"] != nil and [0, 1, 2, "F", "G", "I"].include?(hash["GR"])
      pokemon.gender=(hash["GR"])
    end
    if hash["FORM"] != nil
      pokemon.form = hash["FORM"]
    end
    if hash["MOVE"] != nil and hash["MOVE"].type == Array
      i = 0
      for skill in hash["MOVE"]
        if skill != nil and skill != "AUCUN"
          pokemon.skills_set[i] = Skill.new(Skill_Info.id(skill))
        end
        if skill == "AUCUN"
          pokemon.skills_set[i] = nil
        end
        i += 1
      end
      pokemon.skills_set.compact!
    end
    if hash["OBJ"] != nil
      if hash["OBJ"].type == Fixnum
        pokemon.item_hold = hash["OBJ"]
      elsif hash["OBJ"].type == String
        pokemon.item_hold = POKEMON_S::Item.id(hash["OBJ"])
      end
    end
    if hash["STAT"] != nil and hash["STAT"].type == Array and
        hash["STAT"].length == 6
      pokemon.dv_modifier(hash["STAT"])
    end
    if hash["IA"] == nil
      hash["IA"] = false
    end
    $game_temp.map_bgm = $game_system.playing_bgm
    $scene = Pokemon_Battle_Wild.new($pokemon_party, pokemon, hash["IA"])
    @wait_count = 2
    return true
  end

  #-----------------------------------------------------------------------------
  # call_battle_existing
  #   Appel d'un combat contre un Pokémon défini
  #   (Pour un légendaire mobile par exemple déjà créé)
  #   pokemon: class Pokemon
  #-----------------------------------------------------------------------------
  def call_battle_existing(pokemon, ia = false)
    return false if $pokemon_party.size == 0
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    if pokemon == nil or pokemon.dead?
      return false
    end
    $scene = Pokemon_Battle_Wild.new($pokemon_party, pokemon, ia)
    @wait_count = 2
    return true
  end
  alias demarrer_combat_existant call_battle_existing
  
  #-----------------------------------------------------------------------------
  # call_battle_trainer
  #   Appel d'un combat contre un Dresseur
  #   id: id Dresseur
  #-----------------------------------------------------------------------------
  def call_battle_trainer(id, ia = true, run_able = false, lose_able = false)
    return false if $pokemon_party.size == 0
    $game_temp.map_bgm = $game_system.playing_bgm
    $game_system.bgm_stop
    $scene = Pokemon_Battle_Trainer.new($pokemon_party, id, ia, run_able, lose_able)
    @wait_count = 2
    return true
  end
  
  #-----------------------------------------------------------------------------
  # set_encounter(rate, listx)
  #   Définition de liste de rencontre des Pokémons
  #   rate: de 1 à 50 de préférence
  #   listx: (x = tag du terrain) [[id, level, rareté], [id, level], ...]
  #-----------------------------------------------------------------------------  
  def set_encounter(rate = 0, list = [])
    return unless list.is_a?(Array) and !list.empty?
    $random_encounter.reset
    $random_encounter.rate = rate
    size = [list.size, TAG_SYS::T_SIZE].min
    1.upto(size-1) do |i|
      next unless list[i].is_a?(Array)
      $random_encounter[i] = [Encounter.new(0,0)]
      $random_encounter[i][0].tag_terrain = i
      list[i].each do |pokemon|
        $random_encounter[i][0].add_pokemon(pokemon[0], pokemon[1..2])
      end
    end
    @wait_count = 2
    return false
  end
  
  def set_encounter_name(rate, list = [])
    return unless list.is_a?(Array) and !list.empty?
    $random_encounter.reset
    $random_encounter.rate = rate
    size = [list.size, TAG_SYS::T_SIZE].min
    1.upto(size-1) do |i|
      next unless list[i].is_a?(Array)
      $random_encounter[i] = [Encounter.new(0,0)]
      $random_encounter[i][0].tag_terrain = i
      list[i].each do |pokemon|
        $random_encounter[i][0].add_pokemon(id_conversion(pokemon[0]), pokemon[1..2])
      end
    end
    @wait_count = 2
    return false
  end
  
  #-----------------------------------------------------------------------------
  # run_computer
  #   Appel de PC
  #-----------------------------------------------------------------------------
  def run_computer
    $scene = Pokemon_Computer.new
    @wait_count = 2
    return false
  end
  alias demarrer_pc run_computer
  
  def enable_pokedex
    $pokedex.enable
  end
  alias activer_pokedex enable_pokedex
  
  #-----------------------------------------------------------------------------
  # heal_party
  #   Refill du Centre Pokémon
  #-----------------------------------------------------------------------------  
  def heal_party_center
    $pokemon_party.refill_party
  end
  alias soigner_equipe heal_party_center
  
  #-----------------------------------------------------------------------------
  # add_pokemon(id_data, level, shiny)
  #   Ajout d'un Pokémon dans l'équipe
  #----------------------------------------------------------------------------- 
  def add_pokemon(id_data, level = 5, shiny = false, no_shiny = false)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    pokemon = Pokemon.new(id, level, shiny, no_shiny)
    $pokemon_party.add(pokemon)
  end
  alias ajouter_pokemon add_pokemon
  
  #-----------------------------------------------------------------------------
  # add_random_pokemon(level, taux_shiny, min_pokedex, max_pokedex)
  #   Ajout d'un Pokémon aléatoire dans l'équipe
  # level : le niveau du pokémon
  # taux_shiny : Le pourcentage de chance d'avoir un shiny :
  #              - Si < 0 alors impossible (0% de chance)
  #              - Si = 0 alors taux normal (1 chance sur 8192)
  #              - Si > 0 alors taux définie. Exemple : Si 256 alors 
  #                                                     1 chance sur 256
  # min_pokedex : L'ID minimum du pokédex national (si < 0 alors => 1)
  # max_pokedex : L'ID maximal du pokédex national (si > $data_pokedex.size - 1
  #                                                 => $data_pokedex.size - 1
  #----------------------------------------------------------------------------- 
  # Méthode Enveloppe : ajoute un pokémon à l'équipe
  def add_random_pokemon(level = 5, taux_shiny = 0, min_pokedex = 1,
                         max_pokedex = ($pokedex.size - 1))
     data = random_pokemon(level, taux_shiny, min_pokedex, max_pokedex)
     add_pokemon(data[0], data[1], data[2], data[3])
  end
  alias ajouter_pokemon_aleatoire add_random_pokemon
  
  # Méthode Enveloppe : ajoute un pokémon à l'équipe ou le stock dans le PC
  #                     s'il n'y a pas assez de place dans l'équipe
  def add_or_store_random_pokemon(level = 5, taux_shiny = 0, min_pokedex = 1,
                                  max_pokedex = ($pokedex.size - 1))
   data = random_pokemon(level, taux_shiny, min_pokedex, max_pokedex)
   add_or_store_pokemon(data[0], data[1], data[2], data[3])
  end
  alias ajouter_stocker_pokemon_aleatoire add_or_store_random_pokemon
          
  # Renvoie l'identifiant du pokémon recherché aléatoirement, son niveau,
  # s'il est shiny, s'il est possible ou non qu'il soit shiny
  def random_pokemon(level = 5, taux_shiny = 0, min_pokedex = 1,
                     max_pokedex = ($pokedex.size - 1))
    no_shiny = taux_shiny < 0
    # Détermine si les intervalles saisis sont correctts
    if min_pokedex < 1 
      min_pokedex = 1
    end
    if max_pokedex > $pokedex.size - 1
      max_pokedex = $pokedex.size - 1
    end
    # Permute si les intervalles sont inversées
    if min_pokedex > max_pokedex
      tmp = min_pokedex
      min_pokedex = max_pokedex
      max_pokedex = tmp
    end
    # Vérifie si le niveau est correct
    if level <= 0
      level = 1
    end
    # Recherche de l'ID du Pokémon aléatoirement
    id = rand(max_pokedex) + min_pokedex
    if not no_shiny
      if taux_shiny == 0
        taux_shiny = 4096 # Taux de base
      end
      # Détermine si le Pokémon est shiny ou non 
      shiny = (rand(taux_shiny) == 1)
    else
      shiny = false
    end      
    # Ajoute ou Stock un Pokémon
    return [id, level, shiny, no_shiny]
  end
  
  def add_or_store_pokemon(id_data, level = 5, shiny = false, no_shiny = false)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    pokemon = Pokemon.new(id, level, shiny, no_shiny)
    $pokemon_party.add_or_store(pokemon)
  end
  alias ajouter_stocker_pokemon add_or_store_pokemon
  
  def add_pokemon_parameter(hash)
    if hash["ID"] == nil or hash["NV"] == nil
      return
    end
    pokemon = Pokemon.new(hash["ID"], hash["NV"], hash["SHINY"])
    if hash["GR"] != nil and [0, 1, 2, "F", "G", "I"].include?(hash["GR"])
      pokemon.gender=(hash["GR"])
    end
    if hash["FORM"] != nil
      pokemon.form = hash["FORM"]
    end
    if hash["MOVE"] != nil and hash["MOVE"].type == Array
      i = 0
      for skill in hash["MOVE"]
        if skill != nil and skill != "AUCUN"
          pokemon.skills_set[i] = Skill.new(Skill_Info.id(skill))
        end
        if skill == "AUCUN"
          pokemon.skills_set[i] = nil
        end
        i += 1
      end
      pokemon.skills_set.compact!
    end
    if hash["OBJ"] != nil
      if hash["OBJ"].type == Fixnum
        pokemon.item_hold = hash["OBJ"]
      elsif hash["OBJ"].type == String
        pokemon.item_hold = POKEMON_S::Item.id(hash["OBJ"])
      end
    end
    if hash["STAT"] != nil and hash["STAT"].type == Array and 
        hash["STAT"].length == 6
      pokemon.dv_modifier(hash["STAT"])
    end
    if hash["DO"] and hash["DO"].type == String
      pokemon.trainer_name = hash["DO"]
    end
    if hash["IDo"] and hash["IDo"].type == String
      pokemon.trainer_id = hash["IDo"]
    end
    if hash["SURNOM"] and hash["SURNOM"].type == String
      pokemon.given_name = hash["SURNOM"]
    end
    if hash["BALL"] and hash["BALL"].type == Fixnum
      pokemon.id_ball = hash["BALL"]
    end
    if hash["EV"] != nil and hash["EV"].type == Array and
        hash["EV"].length == 6
      pokemon.ev_modifier(hash["EV"])
    end
    if hash["ABILITY"] != nil and hash["ABILITY"].type == Fixnum
      pokemon.ability=(hash["ABILITY"])
    end
    if hash["NATURE"] != nil and hash["NATURE"].type == String
      pokemon.nature_force(hash["NATURE"])
    elsif hash["NATURE"] != nil and hash["NATURE"].type == Fixnum
      pokemon.nature = pokemon.nature_generation(hash["NATURE"])
    end
    if hash["LOYALTY"] != nil
      pokemon.loyalty = hash["LOYALTY"]
    end
    if hash["TSTATS"] != nil
      pokemon.stats_modifier(hash["TSTATS"])
    end
    ajouter_pokemon_cree(pokemon)
  end
  alias ajouter_pokemon_param add_pokemon_parameter
  
  def store_pokemon(id_data, level = 5, shiny = false)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    pokemon = Pokemon.new(id, level, shiny)
    $pokemon_party.store_captured(pokemon)
  end
  alias stocker_pokemon store_pokemon
  
  #-----------------------------------------------------------------------------
  # add_and_name_pokemon(id_data, level)
  #   Ajout d'un Pokémon dans l'équipe
  #----------------------------------------------------------------------------- 
  def add_and_name_pokemon(id_data, level = 5, shiny = false, no_shiny = false)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    pokemon = Pokemon.new(id, level, shiny, no_shiny)
    name_pokemon(pokemon)
    $pokemon_party.add(pokemon)
  end
  alias ajouter_et_nommer_pokemon add_and_name_pokemon
  
  #-----------------------------------------------------------------------------
  # add_created_pokemon(pokemon)
  #   Ajout d'un Pokémon (objet de classe Pokemon) dans l'équipe
  #----------------------------------------------------------------------------- 
  def add_created_pokemon(pokemon)
    $pokemon_party.add(pokemon)
  end
  alias ajouter_pokemon_cree add_created_pokemon
  
  def add_store_created_pokemon(pokemon)
    $pokemon_party.add_or_store(pokemon)
  end
  alias ajouter_stocker_pokemon_cree add_store_created_pokemon
  
  #-----------------------------------------------------------------------------
  # remove_pokemon(id_data)
  #   Enleve un seul Pokémon de l'équipe par son ID ou son nom
  #----------------------------------------------------------------------------- 
  def remove_pokemon(id_data)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    elsif id_data.type == Pokemon
      $pokemon_party.actors.delete(id_data)
      return
    end
    $pokemon_party.remove_id(pokemon_index(id))
  end
  alias retirer_pokemon remove_pokemon
  
  #-----------------------------------------------------------------------------
  # remove_pokemon_index(index)
  #   Enleve un seul Pokémon de l'équipe par son index
  #----------------------------------------------------------------------------- 
  def remove_pokemon_index(index)
    $pokemon_party.remove_id(index)
  end
  alias retirer_pokemon_index remove_pokemon_index
  
  
  #-----------------------------------------------------------------------------
  # create_pokemon(id, level)
  #   Crèe un Pokémon, à utiliser comme il se doit
  #----------------------------------------------------------------------------- 
  def create_pokemon(id_data, level, shiny = false, no_shiny = false)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    return pokemon = Pokemon.new(id, level, shiny, no_shiny)
  end
  
  #-----------------------------------------------------------------------------
  # make_pokemon(slot, id, level, shiny)
  #   Crèe un Pokémon, et le stocke
  #----------------------------------------------------------------------------- 
  def make_pokemon(slot, id_data, level, shiny = false, no_shiny = false)
    if id_data.type == Fixnum
      id = id_data
    elsif id_data.type == String
      id = id_conversion(id_data)
    end
    if $existing_pokemon[slot] == nil
      $existing_pokemon[slot] = Pokemon.new(id, level, shiny, no_shiny)
    end
  end
  alias enregistrer_pokemon make_pokemon
  
  #-----------------------------------------------------------------------------
  # existing_pokemon?(slot)
  #   Demande si un slot est occupé
  #----------------------------------------------------------------------------- 
  def existing_pokemon?(slot)
    if $existing_pokemon[slot] != nil
      return true
    end
    return false
  end
  alias pokemon_existant? existing_pokemon?
  
  #-----------------------------------------------------------------------------
  # erase_existing_pokemon(slot)
  #   Efface un pokémon au slot
  #----------------------------------------------------------------------------- 
  def erase_existing_pokemon(slot)
    $existing_pokemon[slot] = nil
    return false
  end
  alias effacer_pokemon_existant erase_existing_pokemon
  
  #-----------------------------------------------------------------------------
  # call_pokemon(slot)
  #   Renvoie le pokemon (class) dans un slot.
  #----------------------------------------------------------------------------- 
  def call_pokemon(slot)
    return $existing_pokemon[slot]
  end
  alias appel_pokemon call_pokemon
  
  #-----------------------------------------------------------------------------
  # skill_conversion
  #   Conversion script -> BDD par exportation
  #-----------------------------------------------------------------------------   
  def skill_conversion
    # Conversion
    for id in 1..$data_skills_pokemon.length-1
      skill = Skill.new(id)
      
      if $data_skills[id] == nil
        $data_skills[id] = RPG::Skill.new
      end
      
      $data_skills[id].name = skill.name
      $data_skills[id].element_set = [skill.type]
      if skill.power > 200
        $data_skills[id].atk_f = 200
        $data_skills[id].eva_f = skill.power - 200
      else
        $data_skills[id].atk_f = skill.power
        $data_skills[id].eva_f = 0
      end
      $data_skills[id].hit = skill.accuracy
      $data_skills[id].power = skill.effect
      $data_skills[id].pdef_f = skill.effect_chance
      $data_skills[id].sp_cost = skill.ppmax
      case skill.target
      when 1
        $data_skills[id].scope = 0
      when 0
        $data_skills[id].scope = 1
      when 8
        $data_skills[id].scope = 2
      when 4
        $data_skills[id].scope = 3
      when 20
        $data_skills[id].scope = 4
      when 40
        $data_skills[id].scope = 5
      when 10
        $data_skills[id].scope = 7
      end
      $data_skills[id].animation1_id = skill.user_anim_id
      $data_skills[id].animation2_id = skill.target_anim_id
      $data_skills[id].description = skill.description
      $data_skills[id].variance = skill.direct? ? 1 : 0
      $data_skills[id].mdef_f = skill.priority
      if skill.map_use != 0
        $data_skills[id].occasion = 0
        $data_skills[id].common_event_id = skill.map_use
      else
        $data_skills[id].occasion = 1
        $data_skills[id].common_event_id = 0
      end
      
      # Effacement
      $data_skills[id].plus_state_set = []
      $data_skills[id].minus_state_set = []
      $data_skills[id].agi_f = 0
      $data_skills[id].str_f = 0
      $data_skills[id].dex_f = 0
      $data_skills[id].agi_f = 0
      $data_skills[id].int_f = 0
    end
    
    file = File.open("Skills.rxdata", "wb")
    Marshal.dump($data_skills, file)
    file.close
  end
  
  #-----------------------------------------------------------------------------
  # pokemon_conversion
  #   Conversion script -> BDD par exportation
  # $data_enemies et $data_classes
  #-----------------------------------------------------------------------------   
  def pokemon_conversion
    # Inscription des noms
    for i in 118..175
      if $data_weapons[i-84] == nil
        $data_weapons[i-84] = RPG::Weapon.new
      end
      $data_weapons[i-84].name = POKEMON_S::Item.name(i)
    end
    
    # Inscription des capa spé
    for i in 1..77
      if $data_armors[i+33] == nil
        $data_armors[i+33] = RPG::Armor.new
      end
      $data_armors[i+33].name = $data_ability[i][0]
      $data_armors[i+33].description = $data_ability[i][1]
    end
    
    
    # Conversion
    for id in 1..$data_pokemon.length-1
      pokemon = Pokemon.new(id)
      
      if $data_enemies[id] == nil
        $data_enemies[id] = RPG::Enemy.new
      end
      
      if $data_classes[id] == nil
        $data_classes[id] = RPG::Class.new
      end
      
      # Reset données
      $data_enemies[id].mdef = 0
      $data_enemies[id].pdef = 0
      $data_enemies[id].actions = []
      
      $data_classes[id].weapon_set = []
      $data_classes[id].armor_set = []
      
      # Nom
      $data_enemies[id].name = pokemon.name
      $data_enemies[id].battler_name = "Front_Male/#{sprintf("%03d",id)}.png"
      
      # ID secondaire
      $data_enemies[id].maxsp = id
      
      # Base Stats
      $data_enemies[id].maxhp = pokemon.base_hp
      $data_enemies[id].agi = pokemon.base_spd
      $data_enemies[id].int = pokemon.base_ats
      $data_enemies[id].str = pokemon.base_atk
      $data_enemies[id].dex = pokemon.base_dfe
      $data_enemies[id].atk = pokemon.base_dfs
      
      # Apprentissage des skills
      $data_classes[id].learnings = []
      for skill in pokemon.skills_table
        learning = RPG::Class::Learning.new
        learning.level = skill[1]
        learning.skill_id = skill[0]
        $data_classes[id].learnings.push(learning)
      end
      
      # CT/CS: support script
      
      # Exp Type
      $data_classes[id].weapon_set.push(pokemon.exp_type + 15)
      
      # Evolution
      $data_classes[id].name = ""
      
      # Evolution unique
      if pokemon.evolve_list.length == 2
        # Evolution naturelle seulement
        name = pokemon.evolve_list[1][0]
        data = pokemon.evolve_list[1][1]
        if data.type == Fixnum and name != ""
          $data_classes[id].name = name + "/" + data.to_s
          $data_classes[id].weapon_set.push(22)
        elsif data == "loyal"
          $data_classes[id].name = name#"L" + "/" + name
          $data_classes[id].weapon_set.push(24)
        elsif data == "trade"
          $data_classes[id].name = name#"T" + "/" + name
          $data_classes[id].weapon_set.push(25)
        elsif data == "stone"
          $data_classes[id].name = name#"S" + "/" + name
          $data_classes[id].weapon_set.push(23)
        end
      else
        # Evolution spéciale/multiple
        $data_classes[id].weapon_set.push(26)
      end
      
      # Type
      if pokemon.type1 != 0
        $data_enemies[id].element_ranks[pokemon.type1] = 1
        $data_classes[id].element_ranks[pokemon.type1] = 3
      end
      if pokemon.type2 != 0
        $data_enemies[id].element_ranks[pokemon.type2] = 2
        $data_classes[id].element_ranks[pokemon.type2] = 3
      end
      
      # Rareté
      $data_enemies[id].gold = pokemon.rareness
      
      # Genre
      $data_classes[id].armor_set = []
      case Pokemon_Info.female_rate(id) # Female rate
      when -1
        $data_classes[id].armor_set.push(2)
      when 0
        $data_classes[id].armor_set.push(3)
      when 12.5
        $data_classes[id].armor_set.push(4)
      when 25
        $data_classes[id].armor_set.push(5)
      when 50
        $data_classes[id].armor_set.push(6)
      when 75
        $data_classes[id].armor_set.push(7)
      when 87.5
        $data_classes[id].armor_set.push(8)
      when 100
        $data_classes[id].armor_set.push(9)
      else
        $data_classes[id].armor_set.push(6)
      end
      
      # Loyauté
      case pokemon.loyalty
      when 0
        $data_classes[id].armor_set.push(11)
      when 35
        $data_classes[id].armor_set.push(12)
      when 70
        $data_classes[id].armor_set.push(13)
      when 90
        $data_classes[id].armor_set.push(14)
      when 100
        $data_classes[id].armor_set.push(15)
      when 140
        $data_classes[id].armor_set.push(16)
      else
        $data_classes[id].armor_set.push(13)
      end
      
      # EV et Base Exp
      i = 0
      for element in pokemon.battle_list
        if i == pokemon.battle_list.length-1
          $data_enemies[id].exp = element
          next
        end
        
        case element
        when 1
          $data_classes[id].weapon_set.push(2+i)
        when 2
          $data_classes[id].weapon_set.push(8+i)
        when 3
          $data_classes[id].weapon_set.push(2+i)
          $data_classes[id].weapon_set.push(8+i)
        end
        i += 1
      end
      
      # Breed Groupe
      for group in pokemon.breed_group
        $data_classes[id].armor_set.push(group + 17)
      end
      
      # Egg Hatch
      case pokemon.hatch_step
      when 1280
        $data_classes[id].weapon_set.push(28)
      when 2560
        $data_classes[id].weapon_set.push(29)
      when 3840
        $data_classes[id].weapon_set.push(28)
        $data_classes[id].weapon_set.push(29)
      when 5120
        $data_classes[id].weapon_set.push(30)
      when 6400
        $data_classes[id].weapon_set.push(30)
        $data_classes[id].weapon_set.push(28)
      when 7680
        $data_classes[id].weapon_set.push(30)
        $data_classes[id].weapon_set.push(29)
      when 8960
        $data_classes[id].weapon_set.push(30)
        $data_classes[id].weapon_set.push(29)
        $data_classes[id].weapon_set.push(28)
      when 10240
        $data_classes[id].weapon_set.push(31)
      when 20480
        $data_classes[id].weapon_set.push(32)
      when 30720
        $data_classes[id].weapon_set.push(31)
        $data_classes[id].weapon_set.push(32)
      else
        $data_classes[id].weapon_set.push(30)
      end
      
      # Liste CT/CS
      for element in pokemon.skills_allow
        if element.type == Fixnum
          $data_classes[id].weapon_set.push(33 + element)
        end
        if element.type == Array
          $data_classes[id].weapon_set.push(33 + 50 + element[0])
        end
      end
      
      # Capa Spé
      list = []
      for i in 1..$data_ability.length-1
        list.push($data_ability[i][0])
      end
      for ability in Pokemon_Info.ability_list(id)
        abid = list.index(ability) + 1
        $data_classes[id].armor_set.push(abid + 33)
      end
      
      # Attaque par accouplement
      r = 0
      for skill in pokemon.breed_move
        if $data_enemies[id].actions[r] == nil
          $data_enemies[id].actions[r] = RPG::Enemy::Action.new
        end
        $data_enemies[id].actions[r].kind = 1
        $data_enemies[id].actions[r].skill_id = skill
        r += 1
      end
    end
    
    file = File.open("Enemies.rxdata", "wb")
    Marshal.dump($data_enemies, file)
    file.close
    file = File.open("Classes.rxdata", "wb")
    Marshal.dump($data_classes, file)
    file.close
    file = File.open("Weapons.rxdata", "wb")
    Marshal.dump($data_weapons, file)
    file.close
    file = File.open("Armors.rxdata", "wb")
    Marshal.dump($data_armors, file)
    file.close
  end
  
  #----------------------------------------------------------------------------
  # Ascenseur
  # Crédit : Sphinx, optimisé par Damien Linux
  # args : L'ensemble des arguments à faire passer
  # renvoie false pour le dernier argument (retour) sinon renvoie true
  #-----------------------------------------------------------------------------
  def ascenseur(*args)  
    window = Window_Command.new(1, args, $fontsize)  
    tab = []
    for arg in args 
      tab.push(window.contents.text_size(arg).width)
    end
    width = tab.max + 16
    window.dispose  
    @command = Window_Command.new(width + 32, args, $fontsize)  
    @command.x = 2
    @command.y = 2 
    loop do  
      Graphics.update  
      Input.update  
      @command.update  
      if Input.trigger?(Input::C) 
        if (@command.index < args.size - 1)
          $game_variables[ASCENSEUR] = @command.index + 1
        else 
          $game_variables[ASCENSEUR]  = -1
        end
        @command.dispose  
        @command = nil   
        @wait_count = 2  
        break 
      end 
    end
    return $game_variables[ASCENSEUR] != -1
  end
  
  #-----------------------------------------------------------------------------
  # item_conversion
  #   Conversion script -> BDD par exportation
  # $data_items
  #-----------------------------------------------------------------------------
  def item_conversion
    for i in 1..$data_item.length-1
      data = $data_item[i]
      item = RPG::Item.new
      
      if data == nil or data == []
        $data_items[i] = item
        next
      end
      
      item.id = i
      item.name = data[0]
      item.icon_name = data[1]
      item.description = data[3]
      item.price = data[4]
      
      # Texte objet utilisé
      if data[6] != nil and data[6] != ""
        item.description += "//" + data[6]
      end
      
      # Poche
      case data[2]
      when "ITEM"
        item.element_set.push(28)#23
      when "BALL"
        item.element_set.push(29)
      when "TECH"
        item.element_set.push(30)
      when "BERRY"
        item.element_set.push(31)
      when "KEY"
        item.element_set.push(32)
      else
        item.element_set.push(28)
      end
      
      # Profil
      for j in 0...data[5].length
        if data[5][j]
          item.element_set.push(34 + j)
        end
      end
      
      # Logdata
      if data[8] != nil
        item.recover_hp_rate = data[8][0]
        item.recover_hp = data[8][1]
        item.recover_sp_rate = data[8][2]
        item.recover_sp = data[8][3]
      end
      if data[9] != nil
        item.minus_state_set = data[9]
      end
      
      # Conversion Event
      if data[7] != nil and data[7][0] == "event"
        item.common_event_id = data[7][1]
      end
      
      $data_items[i] = item
      
    end
    
    file = File.open("Items.rxdata", "wb")
    Marshal.dump($data_items, file)
    file.close
  end
    
  #-----------------------------------------------------------------------------
  # id_conversion(name)
  #   Renvoie l'id du Pokémon nommé name
  #-----------------------------------------------------------------------------  
  # Conversion "nom" - > id
  # name : Le nom du Pokémon
  # Retourne l'ID du Pokémon
  def id_conversion(name)
    id = (1...$data_pokemon.size).find do |id|
      name.downcase_remove_accents == Pokemon_Info.name(id).downcase_remove_accents
    end
    if id != nil and name.downcase_remove_accents == Pokemon_Info.name(id).downcase_remove_accents
      return id
    end #else
    return 1
  end
  
  #-----------------------------------------------------------------------------
  # draw_choice
  #   Fenêtre de choix Oui, non
  #-----------------------------------------------------------------------------   
  def draw_choice(arg1 = "OUI", arg2 = "NON")
    window = Window_Command.new(1, [arg1, arg2], $fontsizebig)
    width = [window.contents.text_size(arg1).width, window.contents.text_size(arg2).width].max + 16
    window.dispose
    @command = Window_Command.new(width + 32, [arg1, arg2], $fontsizebig)
    @command.x = 605 - width
    @command.y = 215
    @command.z = 10000
    loop do
      Graphics.update
      Input.update
      @command.update
      if Input.trigger?(Input::C) and @command.index == 0
        @command.dispose
        @command = nil
        #Input.update
        @wait_count = 2
        return true
      end
      if Input.trigger?(Input::C) and @command.index == 1
        @command.dispose
        @command = nil
        #Input.update
        @wait_count = 2
        return false
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # cry_pokemon
  #   Effet sonore: cri du Pokémon
  #----------------------------------------------------------------------------- 
  def cry_pokemon(id_data)
    if id_data.type == String
      id = id_conversion(id_data)
    elsif id_data.type == Fixnum
      id = id_data
    end
    ida = sprintf("%03d", id)
    filename = "Audio/SE/Cries/" + ida + "Cry.wav"
    if FileTest.exist?(filename)
      Audio.se_play(filename)
    end
    return true
  end
  
  #-----------------------------------------------------------------------------
  # complete_pokedex
  #   Complète le Pokédex
  #----------------------------------------------------------------------------- 
  def complete_pokedex
    $pokedex.complete
  end
  
  #-----------------------------------------------------------------------------
  # name_pokemon
  #   Scene de nom
  #----------------------------------------------------------------------------- 
  def name_pokemon(pokemon)
    if pokemon == nil
      return false
    end
    Graphics.freeze
    name_scene = Pokemon_Name.new(pokemon)
    name_scene.main
    name_scene = nil
    Graphics.transition
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Dresseur
  #----------------------------------------------------------------------------- 
  def detect_player(distance, trainer = true)
    character = $game_map.events[@event_id]
    return false if $game_player.moving?
    case character.direction
    when 4 # Détection par la gauche de l'event
      if character.y == $game_player.y and
          character.x - $game_player.x >= 0 and
          (character.x - $game_player.x).abs <= distance
          $game_player.turn_right if trainer != false
        return true
      end
    when 8 # Détection par le haut de l'event
      if character.x == $game_player.x and
          character.y - $game_player.y >= 0 and
          (character.y - $game_player.y).abs <= distance
          $game_player.turn_down if trainer != false
        return true
      end
    when 6 # Détection par la droite de l'event
      if character.y == $game_player.y and
          character.x - $game_player.x <= 0 and
          (character.x - $game_player.x).abs <= distance
          $game_player.turn_left if trainer != false
        return true
      end
    when 2 # Detection par le bas de l'event
      if character.x == $game_player.x and
          character.y - $game_player.y <= 0 and
          (character.y - $game_player.y).abs <= distance
          $game_player.turn_up if trainer != false
        return true
      end
    end
    if trainer != false
      if Input.trigger?(Input::C) and $game_player.front_tile_event == character
        return true
      end
    end
    return false
  end
  alias trainer_spotted detect_player
  
  def player_front_tile
    return $game_player.front_tile
  end
  
  def player_front_terrain_tag
    coord = $game_player.front_tile
    return $game_map.terrain_tag(coord[0], coord[1])
  end
  
  def player_front_passable?
    coord = $game_player.front_tile
    if $game_map.passable?(coord[0],coord[1], 10 - $game_player.direction) and $game_map.passable?($game_player.x,$game_player.y, $game_player.direction)
      for event in $game_map.events.values
        if event.x == coord[0] and event.y == coord[1]
        unless event.through
          if event.character_name != ""
            return false
          end
        end
      end
    end
    return true
    else
    return false
    end
  end
  
  # Ajout spécial Collision (PSPEvolved 0.10 - Nuri Yuri)
  def player_front_passable_or_event?
    x, y = $game_player.front_tile
    if !$game_map.passable?(x, y, 10 - $game_player.direction) || !$game_map.passable?($game_player.x,$game_player.y, $game_player.direction)
      return $game_map.events.values.any? do |event|
        next event.x == x && event.y == y && event.character_name == ''
      end
    else
      return false if $game_map.events.values.any? do |event|
        next event.x == x && event.y == y && !event.through && event.character_name != ''
      end
      return true
    end
  end
  
  # ------------------------------------------------------
  #                       Acessibilité
  # ------------------------------------------------------
  
  # ------------------------------------------------------
  # pokemon_numero(numero)
  #   Renvoie le Pokémon (objet de classe Pokemon) au numéro
  #   dans l'équipe: 0 = premier Pokémon, 1 = 2ème...
  # ------------------------------------------------------
  def pokemon_number(num)
    if num < 0 or num >= $pokemon_party.actors.length
      return nil
    end
    return $pokemon_party.actors[num]
  end
  alias pokemon_numero pokemon_number
  
  def pokemon_selected
    return pokemon_number(var(4))
  end
  alias pokemon_choisi pokemon_selected
  
  # ------------------------------------------------------
  # appel_menu_equipe
  #   Permet d'ouvrir une fenêtre de sélection du Pokémon.
  #   Renvoie -1, ou l'index du Pokémon (0 pour le premier,
  #   1 pour le suivant, 2 pour le suisuivant...
  # ------------------------------------------------------
  def call_party_menu
    Graphics.freeze
    scene = Pokemon_Party_Menu.new(0, 10000, "selection")
    scene.main
    data = scene.return_data
    scene = nil
    Graphics.transition
    $game_variables[INDEX_POKEMON] = data
    return data
  end
  alias appel_menu_equipe call_party_menu
  
  # ------------------------------------------------------
  # enseigner_capacite(pokemon, skill_id)
  #   Permet d'enseigner une capacité à un pokemon (class), et d'écraser 
  #   un skill choisi par le joueur si celui-ci a déjà plus de 4 skills.
  # ------------------------------------------------------
  def teach_skill(pokemon, skill_id)
    if skill_id.type == Fixnum
      id = skill_id
    elsif skill_id.type == String
      id = Skill_Info.id(skill_id)
    end
    if pokemon == nil
      return false
    end
    if not(pokemon.skill_learnt?(id))
      scene = Pokemon_Skill_Learn.new(pokemon, id)
      scene.main
      return scene.return_data
    end
    return false
  end
  alias enseigner_capacite teach_skill
  
  # ------------------------------------------------------
  # skill_selection
  #   Permet d'ouvrir une fenêtre de sélection d'un skill.
  #   Renvoie -1, ou l'index du de l'attaque (0 pour le premier,
  #   1 pour le suivant, 2 pour le suisuivant...
  # ------------------------------------------------------
  def skill_selection(pokemon)
    if pokemon == nil
      return -1
    end
    scene = Pokemon_Skill_Selection.new(pokemon)
    scene.main
    data = scene.return_data
    scene = nil
    $game_variables[INDEX_SKILL] = data
    return data
  end
  
  # ------------------------------------------------------
  # appliquer_objet(skill_id, pokemon)
  #   Permet d'imiter l'usage d'un objet.
  # ------------------------------------------------------
  def apply_item(id_data, pokemon = nil)
    if id_data.type == Fixnum
      item_id = id_data
    elsif id_data.type == String
      item_id = Skill_Info.id(id_data)
    end
    if POKEMON_S::Item.use_on_pokemon?(item_id)
      if pokemon == nil
        item_mode = "item_use"
        if POKEMON_S::Item.item_able_mode?(item_id)
          item_mode = "item_able"
        end
        scene = Pokemon_Party_Menu.new(0, 1000, item_mode, item_id)
        scene.main
        # return_data = [id item_utilisé, utilisé oui/non]
        data = scene.return_data
        scene = nil
        Graphics.transition
        return data[1]
      else
        $game_system.se_play($data_system.decision_se)
        result = POKEMON_S::Item.effect_on_pokemon(item_id, pokemon)
        if result[1] != ""
          draw_text(result[1])
          Input.update
          until Input.trigger?(Input::C)
            Input.update
            Graphics.update
          end
        end
        return result[0]
      end
    else
      data = POKEMON_S::Item.effect(item_id)
      used = data[0]
      string = data[1]
      return used
    end
  end
  alias appliquer_objet apply_item
  
  # ------------------------------------------------------
  # pokemon_possede(id)
  #   Renvoie si le pokémon est possédé ou non.
  # ------------------------------------------------------
  def got_pokemon(id_data)
    return $pokemon_party.got_pokemon(id_data)
  end
  alias pokemon_possede got_pokemon
  
  # ------------------------------------------------------
  # pokemon_index(id)
  #   Renvoie l'index du Pokémon.
  # ------------------------------------------------------
  def get_pokemon(id_data)
    return $pokemon_party.get_pokemon(id_data)
  end
  alias pokemon_index get_pokemon
  
  # ------------------------------------------------------
  # sauv_retour(id)
  #   Enregistre une ou position du joueur dans le point de retour
  # ------------------------------------------------------
  def sauv_retour(map_id = $game_map.map_id, x = $game_player.x, y = $game_player.y)
    $game_variables[MAP_ID] = map_id
    $game_variables[MAP_X] = x
    $game_variables[MAP_Y] = y
  end

  # ------------------------------------------------------
  # var(id)
  #   $game_variables
  # ------------------------------------------------------
  def var(index)
    return $game_variables[index]
  end
  
  def switch(index)
    return $game_switches[index]
  end
  
  def equipe_vide?
    return $pokemon_party.actors.length == 0
  end
  
  # ------------------------------------------------------
  # actualiser_rencontre
  #   Update les rencontres aléatoires après un changement
  #   A appeler manuellement
  # ------------------------------------------------------
  def actualiser_rencontre
    $random_encounter.update
  end
  
  # ------------------------------------------------------
  # ajouter_oeuf
  #   Ajoute un oeuf dont l'espèce est déterminée par id
  # ------------------------------------------------------
  def ajouter_oeuf(mother, father = nil)
    egg = Pokemon.new.new_egg(mother, father)
    ajouter_pokemon_cree(egg)
  end
  
  # ------------------------------------------------------
  # effectif_equipe
  #   Compte combien de membre appelable au combat
  # ------------------------------------------------------
  def effectif_equipe
    resultat = 0
    for member in $pokemon_party.actors
      if not member.egg
        resultat += 1
      end
    end
    return resultat
  end
  
  # ------------------------------------------------------
  #  Parc Safari
  # ------------------------------------------------------
  def call_safari_battle(id, lvl)
      $game_temp.map_bgm = $game_system.playing_bgm
      $game_system.bgm_stop
      pokemon = Pokemon.new(id, lvl, false)
      $scene = POKEMON_S::Pokemon_Battle_Safari.new(pokemon)
    end
    
    def call_safari_battle_define(pokemon)
      $game_temp.map_bgm = $game_system.playing_bgm
      $game_system.bgm_stop
      $scene = Pokemon_Safari_Combat.new(pokemon)
    end
end
  
