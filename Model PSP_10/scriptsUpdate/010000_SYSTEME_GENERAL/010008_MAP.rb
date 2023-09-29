#==============================================================================
# ■ MAP
# Pokemon Script Project - Krosk 
# 21/08/08
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Gestion de carte du jeu
#-----------------------------------------------------------------------------
# Englobe les fonctions de carte du jeu, de CS Vol, et de localisation Pokédex
#-----------------------------------------------------------------------------
class Game_Temp
  attr_accessor :map_temp
  attr_accessor :back_calling
  attr_accessor :world_map_event_checking
  
  def fly_mode
    return @map_temp[0] == "FLY"
  end
  
end


class Game_Character
  attr_reader :step_anime
  def set_map_character(character_name = self.character_name, character_hue = self.character_hue)
    @character_name = character_name
    @character_hue = character_hue
  end
  def set_through(state = true)
    @through = state
  end
  def set_step_anime(state = true)
    @step_anime = state
  end
  def set_opacity(value)
    @opacity = value
  end
  def set_direction_fix
    @direction_fix = true
  end
  def set_move_speed(value)
    @move_speed = value
  end
  def set_direction(value = 2)
    @direction = value
  end
end


class Game_Player < Game_Character
  def check_world_map
    unless moving? or $game_map.map_id != POKEMON_S::_WMAPID
      if $game_temp.world_map_event_checking
        $scene.clear_map_window
        $game_temp.world_map_event_checking = false
        for event in $game_map.events.values
          if event.x == @x and event.y == @y
            $scene.refresh_map_window(event)
          end
        end
      end
    end
  end
end


class Scene_Map
  
  def initialize_map_window
    @map_window = Window_Base.new(320, 385, 300, 76)
    @map_window.active = true
    @map_window.visible = true
    @map_window.contents = Bitmap.new(300-32, 76-32)
    @map_window.contents.font.name = $fontface
    @map_window.contents.font.size = $fontsize
    @map_window.contents.font.color = Color.new(0, 0, 0)
    @map_window.z = 50000
    clear_map_window
    $game_temp.world_map_event_checking = true
  end
  
  def refresh_map_window(event)
    #clear_map_window
    if @map_window != nil
      map_zone = event.event.name.split('/')[0].to_i
      if $data_zone[map_zone] != nil
        zone_name = $data_zone[map_zone][0]
      else
        zone_name = ""
      end
      if $game_player.screen_x > 288 and $game_player.screen_y > 353
        @map_window.y = 20
      else
        @map_window.y = 385
      end
      @map_window.visible = true
      @map_window.contents.draw_text(0, 0, 300-32, 76-32, zone_name, 1)
      @map_window.update
    end
  end
  
  def clear_map_window
    if @map_window != nil
      @map_window.visible = false
      @map_window.contents.clear
      @map_window.update
    end
  end
  
  def call_back_world_map
    Graphics.freeze
    $game_player.straighten
    @map_window.dispose if @map_window != nil
    $game_temp.back_calling = false
    $game_system.se_play($data_system.cancel_se)
    $game_temp.player_new_map_id = $game_temp.map_temp[2]
    $game_temp.player_new_x = $game_temp.map_temp[3]
    $game_temp.player_new_y = $game_temp.map_temp[4]
    $game_temp.player_new_direction = $game_temp.map_temp[5]
    $game_player.set_map_character($game_temp.map_temp[6], $game_temp.map_temp[7])
    $game_player.set_step_anime($game_temp.map_temp[8])
    $game_system.menu_disabled = $game_temp.map_temp[9]
    POKEMON_S::_MAPLINK = $game_temp.map_temp[10]
    if ["VIEW","FLY","PKDX","PKDX_DETAIL"].include?($game_temp.map_temp[0])
      $game_map.setup($game_temp.player_new_map_id, true)
    else
      $game_map.setup($game_temp.player_new_map_id)
    end
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)
    $game_player.set_direction($game_temp.player_new_direction)
    #$game_temp.player_transferring = true
    #$game_temp.transition_processing = true
    #$game_temp.transition_name = ""
    TIMESYS::reset_tone(0) if $game_switches[SWITCH_EXTERIEUR]
    if $game_temp.map_temp[0] == "VIEW" or $game_temp.map_temp[0] == "FLY"
      $game_map.autoplay
      $game_map.update
      $scene = Scene_Map.new
    elsif $game_temp.map_temp[0] == "PKDX"
      $scene = POKEMON_S::Pokemon_Pokedex.new($game_temp.map_temp[12], $game_temp.map_temp[13])
    elsif $game_temp.map_temp[0] == "PKDX_DETAIL"
      $scene = POKEMON_S::Pokemon_Detail.new($game_temp.map_temp[11], $game_temp.map_temp[12])
    end
  end
  
  
  def initialize_world_map
    TIMESYS::set_tone(:default,0)
    if $game_temp.map_temp[1]
      return
    end
    $game_temp.map_temp[1] = true
    map_id = $game_temp.map_temp[2]
    map_zone = $data_mapzone[map_id][0]
    $game_system.menu_disabled = true
    found = false
      
    if $game_temp.map_temp[0] == "VIEW" or $game_temp.map_temp[0] == "FLY"
      for element in $game_map.events.values
        # Pre-process
        array_tag = element.event.name.split('/')
        # Position du joueur
        if array_tag.include?(map_zone.to_s) and not array_tag.include?("*")
          found = [element.x, element.y]
        end
        # Character dummy du joueur
        if array_tag.include?('~')
          actor_character = element
        end
        element.set_through
      end
    end
    # ---------------------------------------------------------
    if $game_temp.map_temp[0] == "PKDX" or $game_temp.map_temp[0] == "PKDX_DETAIL"
      pokemon_id = $game_temp.map_temp[11]
      
      for element in $game_map.events.values
        # Pre-process
        array_tag = element.event.name.split('/')
        element.set_through
        # Position du joueur
        if array_tag.include?(map_zone.to_s) and not array_tag.include?("*")
          found = [element.x, element.y]
        end
        # Character dummy du joueur
        if array_tag.include?('~')
          actor_character = element
        end
        # Pokédex
        if POKEMON_S::Pokemon_Info.where(pokemon_id).include?(array_tag[0].to_i)
          element.set_opacity(255)
          element.set_direction_fix
          element.set_step_anime
          element.set_move_speed(4)
        end
      end
    end
    
    if found
      actor_character.set_map_character($game_player.character_name, $game_player.character_hue)
      actor_character.moveto(found[0], found[1])
      actor_character.set_through
      $game_player.moveto(found[0], found[1])
    end
    
    initialize_map_window
    
    $game_player.set_step_anime
    $game_player.set_map_character("MAP.PNG", 0)
  end
  
  
end


class Interpreter
  def call_world_map(mode = "VIEW")
    $game_map.save_game_map($game_screen, $game_party.follower_pkm, $game_switches[PKM_TRANSPARENT_SWITCHES])
    $game_switches[PKM_TRANSPARENT_SWITCHES] = false
    $game_party.follower_pkm.update
    $game_screen = Game_Screen.new
    $game_temp.map_temp = [mode, false, $game_map.map_id, $game_player.x, 
      $game_player.y, $game_player.direction, $game_player.character_name, 
      $game_player.character_hue, $game_player.step_anime, 
      $game_system.menu_disabled, POKEMON_S::_MAPLINK]
    $game_temp.player_new_map_id = POKEMON_S::_WMAPID
    $game_temp.player_transferring = true
    Graphics.freeze
    $game_temp.transition_processing = true
    $game_temp.transition_name = ""
    POKEMON_S::_MAPLINK = false
  end 
  alias carte_du_monde call_world_map
  
  def call_back_world_map
    $scene.call_back_world_map
  end
  alias retour call_back_world_map
end