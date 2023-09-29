#==============================================================================
# ■ Game_Event
#------------------------------------------------------------------------------
# 　Classe qui gère les événements. Changement de page d'événement par jugement 
#  de condition et traitement parallèle
#  Possède des fonctions telles que l'exécution d'événements et est utilisé 
#  dans la classe Game_Map.
#==============================================================================
class Game_Event < Game_Character
  #--------------------------------------------------------------------------
  # ● Variables d'instance publique
  #--------------------------------------------------------------------------
  attr_reader   :trigger                  # Déclencheur
  attr_reader   :list                     # Contenu de l'exécution
  attr_reader   :starting                 # Drapeau en cours d'exécution
  attr_reader   :event
  #--------------------------------------------------------------------------
  # ● Initialisation d'objet
  #   map_id : ID de carte
  #   event : Evénement (RPG :: Event)
  #--------------------------------------------------------------------------
  def initialize(map_id, event)
    super()
    @map_id = map_id
    @event = event
    @id = @event.id
    @erased = false
    @starting = false
    @through = true
    # Déplacer vers la position initiale
    moveto(@event.x, @event.y)
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Drapeau de course clair
  #--------------------------------------------------------------------------
  def clear_starting
    @starting = false
  end
  #--------------------------------------------------------------------------
  # ● Jugement de déclenchement excessif (que la même position soit utilisée 
  #   ou non comme condition de départ)
  #--------------------------------------------------------------------------
  def over_trigger?
    # Si le graphique est un caractère et ne glisse pas
    if @character_name != "" and not @through or @event.name == "Obj_invisible"
      # jugement de démarrage est à l'avant
      return false
    end
    # Si cet emplacement est infranchissable sur la carte
    unless $game_map.passable?(@x, @y, 0)
      # Le jugement de démarrage est à l'avant
      return false
    end
    # Le jugement de départ est la même position
    return true
  end
  #--------------------------------------------------------------------------
  # ● Activation d'événement
  #--------------------------------------------------------------------------
  def start
    # Si l'exécution n'est pas vide
    if @list.size > 1
      @starting = true
    end
  end
  #--------------------------------------------------------------------------
  # ● Effacement temporaire
  #--------------------------------------------------------------------------
  def erase
    @erased = true
    refresh
  end
  #--------------------------------------------------------------------------
  # ● Rafraîchir
  #--------------------------------------------------------------------------
  def refresh
    # Initialiser la variable locale new_page
    new_page = nil
    # S'il n'est pas supprimé temporairement
    unless @erased
      # Enquêter dans l'ordre à partir de la page de l'événement avec le plus
      # grand nombre
      for page in @event.pages.reverse
        # Les conditions d'événement peuvent être référencées avec c
        c = page.condition
        # Vérification de l'état du commutateur 1
        if c.switch1_valid
          if $game_switches[c.switch1_id] == false
            next
          end
        end
        # Vérification de l'état du commutateur 2
        if c.switch2_valid
          if $game_switches[c.switch2_id] == false
            next
          end
        end
        # Vérification de l'état variable
        if c.variable_valid
          if $game_variables[c.variable_id] < c.variable_value
            next
          end
        end
        # Vérification de l'état de commutation automatique
        if c.self_switch_valid
          key = [@map_id, @event.id, c.self_switch_ch]
          if $game_self_switches[key] != true
            next
          end
        end
        # Définir la variable locale new_page
        new_page = page
        # Sortez de la boucle
        break
      end
    end
    # Pour la même page d'événement que la dernière fois
    if new_page == @page
      # Fin de la méthode
      return
    end
    # Définissez la page de l'événement en cours sur @page
    @page = new_page
    # Drapeau de course clair
    clear_starting
    # Si aucune page ne remplit les conditions
    if @page == nil
      # Définissez chaque variable d'instance
      @tile_id = 0
      @character_name = ""
      @character_hue = 0
      @move_type = 0
      @through = true
      @trigger = nil
      @list = nil
      @interpreter = nil
      # Fin de la méthode
      return
    end
    # Définissez chaque variable d'instance
    @tile_id = @page.graphic.tile_id
    @character_name = @page.graphic.character_name
    @character_hue = @page.graphic.character_hue
    if @original_direction != @page.graphic.direction
      @direction = @page.graphic.direction
      @original_direction = @direction
      @prelock_direction = 0
    end
    if @original_pattern != @page.graphic.pattern
      @pattern = @page.graphic.pattern
      @original_pattern = @pattern
    end
    @opacity = @page.graphic.opacity
    @blend_type = @page.graphic.blend_type
    @move_type = @page.move_type
    @move_speed = @page.move_speed
    @move_frequency = @page.move_frequency
    @move_route = @page.move_route
    @move_route_index = 0
    @move_route_forcing = false
    @walk_anime = @page.walk_anime
    @step_anime = @page.step_anime
    @direction_fix = @page.direction_fix
    @through = @page.through
    @always_on_top = @page.always_on_top
    @trigger = @page.trigger
    @list = @page.list
    @interpreter = nil
    # Lorsque le déclencheur est "Traitement parallèle"
    if @trigger == 4
      # Créer un interprète pour le traitement parallèle
      @interpreter = Interpreter.new
    end
    # Jugement d'activation d'événement automatique
    check_event_trigger_auto
  end
  #--------------------------------------------------------------------------
  # ● Jugement d'activation de l'événement de contact
  #--------------------------------------------------------------------------
  def check_event_trigger_touch(x, y)
    # Lorsqu'un événement est en cours d'exécution
    if $game_system.map_interpreter.running?
      return
    end
    # Si le déclencheur est "contact de l'événement" et correspond aux 
    # coordonnées du joueur
    if @trigger == 2 and x == $game_player.x and y == $game_player.y
      # Sauf lors d'un saut, si le jugement d'activation est un événement 
      # frontal
      if not jumping? and not over_trigger?
        start
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Jugement d'activation d'événement automatique
  #--------------------------------------------------------------------------
  def check_event_trigger_auto
    # Si le déclencheur est "contact de l'événement" et correspond aux 
    # coordonnées du joueur
    if @trigger == 2 and @x == $game_player.x and @y == $game_player.y
      # Si le jugement d'activation est le même événement de position sauf 
      # en sautant
      if not jumping? and over_trigger?
        start
      end
    end
    # Lorsque le déclencheur est [Automatique]
    if @trigger == 3
      start
    end
  end
  #--------------------------------------------------------------------------
  # ● Mise à jour du cadre
  #--------------------------------------------------------------------------
  def update
    super
    # Jugement d'activation d'événement automatique
    check_event_trigger_auto
    # Lorsque le traitement parallèle est activé
    if @interpreter != nil
      # Si pas en cours d'exécution
      unless @interpreter.running?
        # Organiser un événement
        @interpreter.setup(@list, @event.id)
      end
      # Mettre à jour l'interprète
      @interpreter.update
    end
  end
  
  # Autorise le héros à passer au-dessus d'un évent
  # Instructions: ajouter _b à la fin du nom de l'évent
  def screen_z(height = 0)   
    if @always_on_top  
      return 999  
    end   
    z = (@real_y - $game_map.display_y + 3) / 4 + 32   
    if @tile_id > 0  
      return z + $game_map.priorities[@tile_id] * 32    
    else   
      if @event.name[-2,2] == "_b"
        return z - 32
      end
      return z + ((height > 32) ? 31 : 0)  
    end  
  end
end