#==============================================================================
# ■ Game_Map
# Pokemon Script Project - Krosk 
# 10/11/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
class Game_Map
 def setup(map_id, reload_map = false)
    if reload_map
      @map_id = @save_map_id
      @map = @save_map
      tileset = $data_tilesets[@map.tileset_id]
      @events = @save_events
      @common_events = @save_common_events
      $game_screen = @save_game_screen
      $game_party.follower_pkm = @save_follower_pkm
      $game_switches[PKM_TRANSPARENT_SWITCHES] = @save_follower_pkm_visible
      @fog_name = @save_fog[:name]
      @fog_hue = @save_fog[:hue]
      @fog_opacity = @save_fog[:opacity]
      @fog_blend_type = @save_fog[:blend_type]
      @fog_zoom = @save_fog[:zoom]
      @fog_sx =@save_fog[:sx]
      @fog_sy = @save_fog[:sy]
      @fog_ox = @save_fog[:ox]
      @fog_oy = @save_fog[:oy]
      @fog_tone = @save_fog[:tone]
      @fog_tone_target = @save_fog[:tone_target]
      @fog_tone_duration = @save_fog[:tone_duration]
      @fog_opacity_duration =@save_fog[:opacity_duration]
      @fog_opacity_target = @save_fog[:opacity_target]
    else
      @map_id = map_id
      @map = load_data(sprintf("Data/Map%03d.rxdata", @map_id))
      tileset = $data_tilesets[@map.tileset_id]
      @events = {}
      for i in @map.events.keys
        @events[i] = Game_Event.new(@map_id, @map.events[i])
      end
      @common_events = {}
      for i in 1...$data_common_events.size
        @common_events[i] = Game_CommonEvent.new(i)
      end
      @fog_name = tileset.fog_name
      @fog_hue = tileset.fog_hue
      @fog_opacity = tileset.fog_opacity
      @fog_blend_type = tileset.fog_blend_type
      @fog_zoom = tileset.fog_zoom
      @fog_sx = tileset.fog_sx
      @fog_sy = tileset.fog_sy
      @fog_ox = 0
      @fog_oy = 0
      @fog_tone = Tone.new(0, 0, 0, 0)
      @fog_tone_target = Tone.new(0, 0, 0, 0)
      @fog_tone_duration = 0
      @fog_opacity_duration = 0
      @fog_opacity_target = 0
    end
    @tileset_name = tileset.tileset_name
    @autotile_names = tileset.autotile_names
    @panorama_name = tileset.panorama_name
    @panorama_hue = tileset.panorama_hue
    @battleback_name = tileset.battleback_name
    @passages = tileset.passages
    @priorities = tileset.priorities
    @terrain_tags = tileset.terrain_tags
    @display_x = 0
    @display_y = 0
    @need_refresh = false
    @scroll_direction = 2
    @scroll_rest = 0
    @scroll_speed = 4
    if map_id == POKEMON_S::_WMAPID
      @need_refresh = true
    end
  end
  
  def save_game_map(game_screen, follower_pkm, follower_pkm_visible)
    @save_game_screen = game_screen
    @save_follower_pkm = follower_pkm
    @save_follower_pkm_visible = follower_pkm_visible
    @save_map_id = @map_id
    @save_map = @map
    @save_events = @events
    @save_common_events = @common_events
    @save_fog = {
      :name => @fog_name,
      :hue => @fog_hue,
      :opacity => @fog_opacity,
      :blend_type => @fog_blend_type,
      :zoom => @fog_zoom,
      :sx => @fog_sx,
      :sy => @fog_sy,
      :ox => @fog_ox, 
      :oy => @fog_oy,
      :tone => @fog_tone,
      :tone_target => @fog_tone_target,
      :tone_duration => @fog_tone_duration,
      :opacity_duration => @fog_opacity_duration,
      :opacity_target => @fog_opacity_target
    }
  end
  
  def passable?(x, y, d, self_event = nil)
    # Si les coordonnées données sont en dehors de la carte
    unless valid?(x, y)
      # Impraticable
      return false
    end
    # Convertir la direction (0,2,4,6,8,10) en bit d'obstacle (0,1,2,4,8,0)
    bit = (1 << (d / 2 - 1)) & 0x0f
    # すべてのイベントでループ
    for event in events.values
      # Si les coordonnées correspondent à d'autres tuiles
      if event.tile_id >= 0 and event != self_event and
         event.x == x and event.y == y and not event.through
        # Lorsque le bit d'obstacle est réglé
        if @passages[event.tile_id] & bit != 0
          # Impraticable
          return false
        # Si le bit d'obstacle omnidirectionnel est activé
        elsif @passages[event.tile_id] & 0x0f == 0x0f
          # Impraticable
          return false
        # Sinon, si la priorité est 0
        elsif @priorities[event.tile_id] == 0
          # Autorisé
          return true
        end
      end
    end
    
    # Surf
    if self_event != nil
      if $game_map.terrain_tag(x, y) == 7 and self_event.terrain_tag != 7
        return false
      end
      if $game_map.terrain_tag(x, y) != 7 and self_event.terrain_tag == 7
        if self_event.type == Game_Player
          # Retour au skin normal
          $game_temp.common_event_id = POKEMON_S::Skill_Info.map_use(POKEMON_S::Skill_Info.id("SURF"))
        end
        return false
      end
    end
    
    # Boucle à vérifier depuis le haut du calque
    for i in [2, 1, 0]
      # Obtenir l'ID de tuile
      tile_id = data[x, y, i]
      # Échec de l'acquisition d'ID de tuile
      if tile_id == nil
        # Impraticable
        return false
      # Lorsque le bit d'obstacle est réglé
      elsif @passages[tile_id] & bit != 0
        # Impraticable
        return false
      # Si le bit d'obstacle omnidirectionnel est activé
      elsif @passages[tile_id] & 0x0f == 0x0f
        # Impraticable
        return false
      # Sinon, si la priorité est 0
      elsif @priorities[tile_id] == 0
        # Autorisé
        return true
      end
    end
    # Autorisé
    return true
  end
  
  def bgm
    return @map.bgm
  end
  
  def refresh
    if @map_id > 0
      for event in @events.values
        event.refresh
      end
      for common_event in @common_events.values
        common_event.refresh
      end
    end
    if @map_id == POKEMON_S::_WMAPID and $scene.type == Scene_Map
      $scene.initialize_world_map
    end
    @need_refresh = false
  end
  
  def terrain_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil or @terrain_tags[tile_id] == nil
          return 0
        elsif @terrain_tags[tile_id] != nil and @terrain_tags[tile_id] > 0
          return @terrain_tags[tile_id]
        end
      end
    end
    return 0
  end
 
end