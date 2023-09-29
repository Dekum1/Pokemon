#==============================================================================
# ■ Interpreter
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène à modifier à loisir
#-----------------------------------------------------------------------------
# Fonctions du logiciel
#-----------------------------------------------------------------------------
class Interpreter
  #--------------------------------------------------------------------------
  # Fonction communes
  #     parameter : 1 ID、0 Equipe
  #--------------------------------------------------------------------------
  def iterate_actor(parameter)
    if parameter == 0
      for actor in $pokemon_party.actors
        yield actor
      end
    else
      actor = $pokemon_party.actors[$game_variables[INDEX_POKEMON]]
      yield actor if actor != nil
    end
  end
  
  #--------------------------------------------------------------------------
  # Ajouter / Retirer monnaie
  #--------------------------------------------------------------------------
  def command_125
    value = operate_value(@parameters[0], @parameters[1], @parameters[2])
    $pokemon_party.add_money(value)
    return true
  end
  
  #--------------------------------------------------------------------------
  # Ajouter / Retirer objets
  #--------------------------------------------------------------------------
  def command_126
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    $pokemon_party.add_item(@parameters[0], value)
    return true
  end
  
  #--------------------------------------------------------------------------
  # Modifier les PV
  #--------------------------------------------------------------------------
  def command_311
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    iterate_actor(@parameters[0]) do |actor|
      if actor.hp > 0
        if not @parameters[4] and actor.hp + value <= 0
          actor.hp = 1
        else
          actor.hp += value
        end
      end
    end
    $game_temp.gameover = $pokemon_party.dead?
    return true
  end
  
  #--------------------------------------------------------------------------
  # Infliger statut
  #--------------------------------------------------------------------------
  def command_313
    iterate_actor(@parameters[0]) do |actor|
      if @parameters[1] == 0
        if @parameters[2] == 9
          actor.hp = 0
        else
          actor.status = @parameters[2]
        end
      elsif actor.status == @parameters[2]
        actor.cure
      elsif actor.dead? and @parameters[2] == 9
        actor.hp = actor.max_hp
      end
    end
    return true
  end

  #--------------------------------------------------------------------------
  # Soigner complètement
  #--------------------------------------------------------------------------  
  def command_314
    iterate_actor(@parameters[0]) do |actor|
      actor.refill
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # Ajouter de l'exp
  #--------------------------------------------------------------------------   
  def command_315
    # Obtenez de la valeur pour opérer
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    # Processus avec itérateur
    iterate_actor(@parameters[0]) do |actor|
      # Changer d'acteur XP
      actor.exp += value
      if actor.level_check
        actor.level_up
        if actor.evolve_check != false
          scenebis = Pokemon_Evolve.new(actor, actor.evolve_check)
          scenebis.main
          Graphics.transition
        end
      end
    end
    # Continuez
    return true
  end
  
  #--------------------------------------------------------------------------
  # Régler le niveau
  #--------------------------------------------------------------------------
  def command_316
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    iterate_actor(@parameters[0]) do |actor|
      if value > 0
        for i in 1..value
          actor.level_up
          if actor.evolve_check != false
            scenebis = Pokemon_Evolve.new(actor, actor.evolve_check)
            scenebis.main
            Graphics.transition
          end
        end
      else
        actor.level += value
        if actor.level <= 0
          actor.level = 1
        end
      end
      actor.statistic_refresh
    end
    return true
  end
  
  #--------------------------------------------------------------------------
  # Enseigner compétence
  #--------------------------------------------------------------------------
  def command_318
    actor = $pokemon_party.actors[$game_variables[INDEX_POKEMON]]
    if actor != nil
      if @parameters[1] == 0
        enseigner_capacite(actor, @parameters[2])
      else
        actor.forget_skill(@parameters[2])
      end
    end
    # Continuez
    return false
  end
  
  #--------------------------------------------------------------------------
  # Modifier nom
  #--------------------------------------------------------------------------
  def command_320
    # Obtenez acteur
    actor = $pokemon_party.actors[$game_variables[INDEX_POKEMON]]
    # Renommer
    if actor != nil
      
      if @parameters[1] != ""
        actor.given_name = @parameters[1]
      else
        name_pokemon(actor)
      end
    end
    # Continuez
    return true
  end
  
  #--------------------------------------------------------------------------
  # Démarrer un combat
  #--------------------------------------------------------------------------  
  def command_301
    call_battle_trainer(@parameters[0], true, @parameters[1], @parameters[2])
    current_indent = @list[@index].indent
    $game_temp.battle_proc = Proc.new { |n| @branch[current_indent] = n }
    return true
  end
  
  #--------------------------------------------------------------------------
  # Action conditionnelle
  #-------------------------------------------------------------------------- 
  def command_111
    # Initialiser le résultat de la variable locale
    result = false
    # Jugement conditionnel
    case @parameters[0]
    when 0  # Commutateur
      result = ($game_switches[@parameters[1]] == (@parameters[2] == 0))
    when 1  # Variable
      value1 = $game_variables[@parameters[1]]
      if @parameters[2] == 0
        value2 = @parameters[3]
      else
        value2 = $game_variables[@parameters[3]]
      end
      case @parameters[4]
      when 0  # Équivalent à
        result = (value1 == value2)
      when 1  # Plus que
        result = (value1 >= value2)
      when 2  # Moins de
        result = (value1 <= value2)
      when 3  # Superérieur à
        result = (value1 > value2)
      when 4  # Moins de
        result = (value1 < value2)
      when 5  # Autre que
        result = (value1 != value2)
      end
    when 2  # Commutateur automatique
      if @event_id > 0
        key = [$game_map.map_id, @event_id, @parameters[1]]
        if @parameters[2] == 0
          result = ($game_self_switches[key])
        else
          result = (not $game_self_switches[key])
        end
      end
    when 3  # Minuterie
      if $game_system.timer_working
        sec = $game_system.timer / Graphics.frame_rate
        if @parameters[2] == 0
          result = (sec >= @parameters[1])
        else
          result = (sec <= @parameters[1])
        end
      end
    when 4  # Acteur
      if pokemon_numero($game_variables[INDEX_POKEMON]) != nil
        case @parameters[2]
        when 1
          result = (pokemon_numero($game_variables[INDEX_POKEMON]).name == @parameters[3])
        when 2  # Compétence
          result = (pokemon_numero($game_variables[INDEX_POKEMON]).skill_learnt?(@parameters[3]))
        when 5
          if @parameters[3] == 9
            result = pokemon_numero($game_variables[INDEX_POKEMON]).dead?
          else
            result = (pokemon_numero($game_variables[INDEX_POKEMON]).status == @parameters[3])
          end
        end
      end
    when 6 # Caractère
      character = get_character(@parameters[1])
      if character != nil
        result = (character.direction == @parameters[2])
      end
    when 7  # De l'argent
      if @parameters[2] == 0
        result = ($pokemon_party.money >= @parameters[1])
      else
        result = ($pokemon_party.money <= @parameters[1])
      end
    when 8  # Articles
      result = ($pokemon_party.item_number(@parameters[1]) > 0)
    when 11  # Bouton
      result = (Input.press?(@parameters[1]))
    when 12  # Script
      result = eval(@parameters[1])
    end
    # Le jugement du magasin entraîne un hachage
    @branch[@list[@index].indent] = result
    # Lorsque le résultat du jugement est vrai
    if @branch[@list[@index].indent]
      # Supprimer les données de branche
      @branch.delete(@list[@index].indent)
      # Continuez
      return true
    end
    # Si non applicable : Ignorer la commande
    return command_skip
  end
  
  #--------------------------------------------------------------------------
  # Shop
  #-------------------------------------------------------------------------- 
  def command_302
    shop_list = [@parameters[1]]
    loop do
      @index += 1
      if @list[@index].code == 605
        shop_list.push(@list[@index].parameters[1])
      else
        break
      end
    end
    if $game_switches[DISTRIBUTEUR]
      $scene = Pokemon_Shop_Distrib.new(shop_list)
    else
      $scene = Pokemon_Shop.new(shop_list)
    end
    @wait_count = 2
    @index -= 1
    return true
  end
  
  #--------------------------------------------------------------------------
  # Gestion de Variables
  #-------------------------------------------------------------------------- 
  def command_122
    # Initialiser la valeur
    value = 0
    # Branche par opérande
    case @parameters[3]
    when 0  # Constante
      value = @parameters[4]
    when 1  # Variable
      value = $game_variables[@parameters[4]]
    when 2  # Numéro aléatoire
      value = @parameters[4] + rand(@parameters[5] - @parameters[4] + 1)
    when 3  # Articles
      value = $pokemon_party.item_number(@parameters[4])
    when 4  # Acteur
      actor = $pokemon_party.actors[$game_variables[INDEX_POKEMON]]
      if actor != nil
        case @parameters[5]
        when 0  # Niveau
          value = actor.level
        when 1  # EXP
          value = actor.exp
        when 2  # Type1
          value = actor.type1
        when 3  # type2
          value = actor.type2
        when 4  # HP
          value = actor.hp
        when 5  # max_hp
          value = actor.max_hp
        when 6  # La force
          value = actor.atk
        when 7  # Dextérité
          value = actor.dfe
        when 8  # Rapidité
          value = actor.spd
        when 9  # La magie
          value = actor.ats
        when 10  # Puissance d'attaque
          value = actor.dfs
        when 11  # Défense physique
          value = actor.gender
        when 12  # Défense magique
          value = actor.id
        when 13  # Solution de contournement
          value = actor.loyalty
        end
      end
    when 6  # Personnage
      character = get_character(@parameters[4])
      if character != nil
        case @parameters[5]
        when 0  # Coordonnée X
          value = character.x
        when 1  # Coordonnée Y
          value = character.y
        when 2  # Orientation
          value = character.direction
        when 3  # Coordonner l'écran X
          value = character.screen_x
        when 4  # Coordonner l'écran Y
          value = character.screen_y
        when 5  # Étiquette de terrain
          value = character.terrain_tag
        end
      end
    when 7  # Autre
      case @parameters[4]
      when 0  # ID de la carte
        value = $game_map.map_id
      when 1  # Nombre de parties
        value = $pokemon_party.actors.size
      when 2  # De l'argent
        value = $pokemon_party.money
      when 3  # Étapes
        value = $pokemon_party.steps
      when 4  # Temps de jeu
        value = Graphics.frame_count / Graphics.frame_rate
      when 5  # Minuterie
        value = $game_system.timer / Graphics.frame_rate
      when 6  # Nombre de sauvegardes
        value = $game_system.save_count
      end
    end
    for i in @parameters[0] .. @parameters[1]
      # Succursale par opération
      case @parameters[2]
      when 0 # Affectation
        $game_variables[i] = value
      when 1 # Addition
        $game_variables[i] += value
      when 2 # Soustraction
        $game_variables[i] -= value
      when 3 # Multiplication
        $game_variables[i] *= value
      when 4 # Division
        if value != 0
          $game_variables[i] /= value
        end
      when 5 # Excédent
        if value != 0
          $game_variables[i] %= value
        end
      end
      # Contrôle de limite supérieure
      if $game_variables[i] > 99999999
        $game_variables[i] = 99999999
      end
      # Contrôle de limite inférieure
      if $game_variables[i] < -99999999
        $game_variables[i] = -99999999
      end
    end
    # Actualiser la carte
    $game_map.need_refresh = true
    # Continuez
    return true
  end
  
  #--------------------------------------------------------------------------
  # Inserer un script
  #--------------------------------------------------------------------------
  def command_355
    # Définir la première ligne sur le script
    script = @list[@index].parameters[0] + "\n"
    # Boucle
    loop do
      # Si la commande d'événement suivante est la deuxième ligne ou 
      # la ligne suivante du script
      if @list[@index+1].code == 655
        # Ajouter la deuxième ligne et les lignes suivantes au script
        script += @list[@index+1].parameters[0] + "\n"
      # Si la commande d'événement n'est pas sur la deuxième ligne ou 
      # la ligne suivante du script
      else
        # Rupture de boucle
        break
      end
      # Indice incrémenté
      @index += 1
    end
    $running_script = "MAP #{@map_id} EVENT #{@event_id}\nSCRIPT\n#{script}"
    (eval(script) or true)
  end
  
end