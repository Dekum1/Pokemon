#==============================================================================
# ■ Game_Player
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------

class Game_Player < Game_Character
  def update
   # Rappelez-vous si le passage aux variables locales
    last_moving = moving?
    # En se déplaçant, en exécutant un événement, en forçant un itinéraire en 
    # mouvement, si aucune des fenêtres de message ne s'affiche
    unless moving? or $game_system.map_interpreter.running? or
           @move_route_forcing or $game_temp.message_window_showing
      # Si le bouton de direction est enfoncé, déplacez le joueur dans cette 
      # direction
      speak_with_pokemon
      case Input.dir4
      when 2
        if @direction != 2
          turn_down
          wait(2)
        else
          move_down
        end
      when 4
        if @direction != 4
          turn_left
          wait(2)
        else
          move_left
        end
      when 6
        if @direction != 6
          turn_right
          wait(2)
        else
          move_right
        end
      when 8
        if @direction != 8
          turn_up
          wait(2)
        else
          move_up
        end
      end
    end
    # Stocker les coordonnées dans des variables locales
    last_real_x = @real_x
    last_real_y = @real_y
    super
    # Si le personnage descend et que la position sur l'écran est en dessous 
    # du centre
    if @real_y > last_real_y and @real_y - $game_map.display_y > CENTER_Y
      # Faire défiler la carte vers le bas
      $game_map.scroll_down(@real_y - last_real_y)
    end
    # Lorsque le personnage se déplace vers la gauche et que la position sur 
    # l'écran est à gauche du centre
    if @real_x < last_real_x and @real_x - $game_map.display_x < CENTER_X
      # Faire défiler la carte vers la gauche
      $game_map.scroll_left(last_real_x - @real_x)
    end
    # Lorsque le personnage se déplace vers la droite et que la position sur 
    # l'écran est à droite du centre
    if @real_x > last_real_x and @real_x - $game_map.display_x > CENTER_X
      # Faire défiler la carte vers la droite
      $game_map.scroll_right(@real_x - last_real_x)
    end
    # Lorsque le personnage monte et que la position sur l'écran est plus haute 
    # que le centre
    if @real_y < last_real_y and @real_y - $game_map.display_y < CENTER_Y
      # Faire défiler la carte
      $game_map.scroll_up(last_real_y - @real_y)
    end
    # Si vous n'êtes pas en déplacement
    unless moving?
      # La dernière fois que le joueur bougeait
      if last_moving
        # Jugement d'activation d'événement par contact avec l'événement au 
        # même endroit
        result = check_event_trigger_here([1,2])
        # Si aucun événement n'a commencé
        if not result
          # Sauf si le mode de débogage est activé et que la touche CTRL 
          # est enfoncée
          unless $DEBUG and Input.press?(Input::CTRL)
            rate = $random_encounter.rate
            rate *= 2 if @move_speed > 4
            if rand(2874) < rate * 16
              @encounter_count = 0
            else
              @encounter_count = 1
            end
          end
        end
      end
      # Lorsque le bouton C est enfoncé
      if Input.trigger?(Input::C)
        # Jugement d'activation d'événement de la même position et du même front
        check_event_trigger_here([0])
        check_event_trigger_there([0,1,2])
        # Implémentation Surf
        if $game_map.passable?(front_tile[0],front_tile[1], 10 - $game_player.direction) and 
            terrain_tag != 7 and $game_map.terrain_tag(front_tile[0], front_tile[1]) == 7 and 
            not $game_system.map_interpreter.running?
          $game_temp.common_event_id = POKEMON_S::Skill_Info.map_use(POKEMON_S::Skill_Info.id("SURF"))
        end
      end
      @save_move_speed ||= @move_speed
      @course ||= false
      @map ||= false
      # Implémentation chaussures de sport
      # Utilise l'interrupteur n°20 par défaut 
      # Par défaut il faut appuyer sur la touche Shift pour utiliser les chaussures
      if Input.press?(Input::A) and $game_switches[CHAUSSURE_DE_SPORT] and
         not $game_switches[EN_BICYCLETTE] and $game_player.terrain_tag != 7 and
         $game_map.terrain_tag(front_tile[0], front_tile[1]) != 7 and
         not $game_system.map_interpreter.running? and 
         $game_temp.player_new_map_id != POKEMON_S._WMAPID
        if (!@character_name.include?("_sport"))
          @name = @character_name
        end
        if Input.press?(Input::UP) or Input.press?(Input::DOWN) or
            Input.press?(Input::RIGHT) or Input.press?(Input::LEFT)            
          if $game_map.passable?(front_tile[0],front_tile[1], 10 - $game_player.direction)
            $game_player.set_map_character("#{@name}_sport", $game_player.direction)
            @save_move_speed = @move_speed if not @course
            @course = true
            @move_speed = 5
          else         
            $game_player.set_map_character(@name, $game_player.direction)  
            @move_speed = @save_move_speed
          end         
        else
          $game_player.set_map_character(@name, $game_player.direction)  
          @move_speed = @save_move_speed
        end
      else
        if $game_temp.player_new_map_id == POKEMON_S._WMAPID and not @map
          @save_move_speed = @move_speed
          @move_speed = 4
          @map = true
        elsif @character_name.include?("_sport")  and @course
          $game_player.set_map_character(@name, $game_player.direction)
          @move_speed = @save_move_speed
          @course = false
        elsif $game_map.map_id != POKEMON_S._WMAPID and @map and
          @move_speed = @save_move_speed
          @map = false
        end           
      end
    end
  end
  
  def increase_steps
    super
    if not @move_route_forcing and $game_map.map_id != POKEMON_S::_WMAPID
      $pokemon_party.increase_steps
      # Poison damage
      if $pokemon_party.steps % 4 == 0
        # Vérification des dommages par glissement
        $pokemon_party.check_map_slip_damage
      end
      # Loyalty
      if $pokemon_party.steps % 512 == 0
        for pokemon in $pokemon_party.actors
          pokemon.loyalty += pokemon.rate_loyalty
          if pokemon.loyalty > 255
            pokemon.loyalty = 255
          end
        end
      end
    end
  end
  
  # Renvoie les coordonnées de la case devant  le héros
  def front_tile
    xf = @x + (@direction == 6 ? 1 : @direction == 4 ? -1 : 0)
    yf = @y + (@direction == 2 ? 1 : @direction == 8 ? -1 : 0)
    return [xf, yf]
  end
  
  # Renvoie l'event
  def front_tile_event
    xf = front_tile[0]
    yf = front_tile[1]
    for event in $game_map.events.values
      if event.x == xf and event.y == yf
        return event
      end
    end
    return nil
  end
  
  # Détecte le nom de l'objet devant soit
  def front_name_detect(name)
    if front_tile_event != nil and front_tile_event.event.name == name
      return true
    end
    return false
  end
  
  # Renvoie l'ID de l'objet devant soit
  def front_tile_id
    if front_tile_event != nil
      return front_tile_event.event.id
    end
    return 0
  end
  
  def wait(frame)
    i = 0
    loop do
      i += 1
      Graphics.update
      if i >= frame
        break
      end
    end
  end
end