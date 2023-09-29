#==============================================================================
# ■ MAPLINK
# Pokemon Script Project - Krosk 
# 19/01/08
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Gestion de jonction de cartes
#-----------------------------------------------------------------------------
if POKEMON_S::MAPLINK  
  class Spriteset_Map
    def initialize
      @viewport1 = Viewport.new(0, 0, 640, 480)
      @viewport2 = Viewport.new(0, 0, 640, 480)
      @viewport3 = Viewport.new(0, 0, 640, 480)
      @viewportc = Viewport.new(0, 0, 640, 480)
      @viewportc.z = 2
      
      @viewport2.z = 200
      @viewport3.z = 5000
    
      @viewportlink1 = Viewport.new(0, -240, 640, 240)
      @viewportlink1.z = 1
      @viewportlink2 = Viewport.new(640, 0, 320, 480)
      @viewportlink2.z = 1
      @viewportlink3 = Viewport.new(0, 480, 640, 240)
      @viewportlink3.z = 1  
      @viewportlink4 = Viewport.new(-320, 0, 320, 480)
      @viewportlink4.z = 1
      
      # Bordures 1
      if $map_link[1] != nil and $map_link[1][0] != 0
        @tilemaplink1 = Tilemap.new(@viewportlink1)
        map = load_data(sprintf("Data/Map%03d.rxdata", $map_link[1][0]))
        tileset = $data_tilesets[map.tileset_id]
        tileset_name = tileset.tileset_name
        @tilemaplink1.tileset = RPG::Cache.tileset(tileset.tileset_name)
        for i in 0..6
          autotile_name = tileset.autotile_names[i]
          @tilemaplink1.autotiles[i] = RPG::Cache.autotile(autotile_name)
        end
        @tilemaplink1.map_data = map.data
        @tilemaplink1.priorities = tileset.priorities
        @tilemaplink1.oy = map.height * 32 - 240 - 96# + $game_map.display_y / 4
      else
        @tilemaplink1 = Plane.new(@viewportlink1)
        @tilemaplink1.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
      end
      
      # Bordures 2
      if $map_link[2] != nil and $map_link[2][0] != 0
        @tilemaplink2 = Tilemap.new(@viewportlink2)
        map = load_data(sprintf("Data/Map%03d.rxdata", $map_link[2][0]))
        tileset = $data_tilesets[map.tileset_id]
        tileset_name = tileset.tileset_name
        @tilemaplink2.tileset = RPG::Cache.tileset(tileset.tileset_name)
        for i in 0..6
          autotile_name = tileset.autotile_names[i]
          @tilemaplink2.autotiles[i] = RPG::Cache.autotile(autotile_name)
        end
        @tilemaplink2.map_data = map.data
        @tilemaplink2.priorities = tileset.priorities
        @tilemaplink2.ox = 96
      else
        @tilemaplink2 = Plane.new(@viewportlink2)
        @tilemaplink2.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
      end
      
      # Bordures 3
      if $map_link[3] != nil and $map_link[3][0] != 0
        @tilemaplink3 = Tilemap.new(@viewportlink3)
        map = load_data(sprintf("Data/Map%03d.rxdata", $map_link[3][0]))
        tileset = $data_tilesets[map.tileset_id]
        tileset_name = tileset.tileset_name
        @tilemaplink3.tileset = RPG::Cache.tileset(tileset.tileset_name)
        for i in 0..6
          autotile_name = tileset.autotile_names[i]
          @tilemaplink3.autotiles[i] = RPG::Cache.autotile(autotile_name)
        end
        @tilemaplink3.map_data = map.data
        @tilemaplink3.priorities = tileset.priorities
        @tilemaplink3.oy = 96
      else
        @tilemaplink3 = Plane.new(@viewportlink3)
        @tilemaplink3.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
      end
      
      # Bordures 4
      if $map_link[4] != nil and $map_link[4][0] != 0
        @tilemaplink4 = Tilemap.new(@viewportlink4)
        map = load_data(sprintf("Data/Map%03d.rxdata", $map_link[4][0]))
        tileset = $data_tilesets[map.tileset_id]
        tileset_name = tileset.tileset_name
        @tilemaplink4.tileset = RPG::Cache.tileset(tileset.tileset_name)
        for i in 0..6
          autotile_name = tileset.autotile_names[i]
          @tilemaplink4.autotiles[i] = RPG::Cache.autotile(autotile_name)
        end
        @tilemaplink4.map_data = map.data
        @tilemaplink4.priorities = tileset.priorities
        @tilemaplink4.ox = map.width * 32 - 320 - 96
      else
        @tilemaplink4 = Plane.new(@viewportlink4)
        @tilemaplink4.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
      end
    
      @tilemap = Tilemap.new(@viewport1)
      @tilemap.tileset = RPG::Cache.tileset($game_map.tileset_name)
      for i in 0..6
        autotile_name = $game_map.autotile_names[i]
        @tilemap.autotiles[i] = RPG::Cache.autotile(autotile_name)
      end
      @tilemap.map_data = $game_map.data
      @tilemap.priorities = $game_map.priorities
      
      @panorama = Plane.new(@viewportc)
      @panorama.z = -1000
      
      @fog = Plane.new(@viewportc)
      @fog.z = 3000
      
      @character_sprites = []
      for i in $game_map.events.keys.sort
        sprite = Sprite_Character.new(@viewport1, $game_map.events[i])
        @character_sprites.push(sprite)
      end
      @character_sprites.push(Sprite_Character.new(@viewport1, $game_player))
      
      @weather = RPG::Weather.new(@viewportc)
      
      @picture_sprites = []
      for i in 1..50
        @picture_sprites.push(Sprite_Picture.new(@viewport2,
          $game_screen.pictures[i]))
      end
      
      @timer_sprite = Sprite_Timer.new
      
      if POKEMON_S::_MAPLINK != nil and not POKEMON_S::_MAPLINK
        @viewportlink1.visible = false
        @viewportlink2.visible = false
        @viewportlink3.visible = false
        @viewportlink4.visible = false
      end
      
      update
    end
    #--------------------------------------------------------------------------
    # ● 解放
    #--------------------------------------------------------------------------
    def dispose
      @tilemap.tileset.dispose
      for i in 0..6
        @tilemap.autotiles[i].dispose
      end
      @tilemap.dispose
      # パノラマプレーンを解放
      @panorama.dispose
      # フォグプレーンを解放
      @fog.dispose
      # キャラクタースプライトを解放
      for sprite in @character_sprites
        sprite.dispose
      end
      # 天候を解放
      @weather.dispose
      # ピクチャを解放
      for sprite in @picture_sprites
        sprite.dispose
      end
      # タイマースプライトを解放
      @timer_sprite.dispose
      # ビューポートを解放
      @viewport1.dispose
      @viewport2.dispose
      @viewport3.dispose
      @viewportc.dispose
      @viewportlink1.dispose
      @viewportlink2.dispose
      @viewportlink3.dispose
      @viewportlink4.dispose
    end
    #--------------------------------------------------------------------------
    # ● フレーム更新
    #--------------------------------------------------------------------------
    def update
      # パノラマが現在のものと異なる場合
      if @panorama_name != $game_map.panorama_name or
         @panorama_hue != $game_map.panorama_hue
        @panorama_name = $game_map.panorama_name
        @panorama_hue = $game_map.panorama_hue
        if @panorama.bitmap != nil
          @panorama.bitmap.dispose
          @panorama.bitmap = nil
        end
        if @panorama_name != ""
          @panorama.bitmap = RPG::Cache.panorama(@panorama_name, @panorama_hue)
        end
        Graphics.frame_reset
      end
      # フォグが現在のものと異なる場合
      if @fog_name != $game_map.fog_name or @fog_hue != $game_map.fog_hue
        @fog_name = $game_map.fog_name
        @fog_hue = $game_map.fog_hue
        if @fog.bitmap != nil
          @fog.bitmap.dispose
          @fog.bitmap = nil
        end
        if @fog_name != ""
          @fog.bitmap = RPG::Cache.fog(@fog_name, @fog_hue)
        end
        Graphics.frame_reset
      end
      
      @tilemap.ox = $game_map.display_x / 4
      @tilemap.oy = $game_map.display_y / 4
      @tilemap.update
    
      xo = [$game_player.real_x/4 - 320 + 16, 0].min
      yo = [$game_player.real_y/4 - 240 + 16, 0].min
      xd = [320 + 16 - ($game_map.width * 32 - $game_player.real_x/4), 0].max
      yd = [240 + 16 - ($game_map.height * 32 - $game_player.real_y/4), 0].max
      
      @viewportlink1.rect.y = -240-yo
      if yo != 0
        if $map_link[1] != nil and $map_link[1][0] != 0
          @tilemaplink1.ox = $game_map.display_x / 4 - $map_link[1][1] * 32
          @tilemaplink1.update
        end
        @viewportlink1.update
      end
      
      @viewportlink2.rect.x = 640-xd
      if xd != 0
        if $map_link[2] != nil and $map_link[2][0] != 0
          @tilemaplink2.oy = $game_map.display_y / 4 - $map_link[2][1] * 32
          @tilemaplink2.update
        end
        @viewportlink2.update
      end
      
      @viewportlink3.rect.y = 480-yd
      if yd != 0
        if $map_link[3] != nil and $map_link[3][0] != 0
          @tilemaplink3.ox = $game_map.display_x / 4 - $map_link[3][1] * 32
          @tilemaplink3.update
        end
        @viewportlink3.update
      end
      
      @viewportlink4.rect.x = -320 - xo
      if xo != 0
        if $map_link[4] != nil and $map_link[4][0] != 0
          @tilemaplink4.oy = $game_map.display_y / 4 - $map_link[4][1] * 32
          @tilemaplink4.update
        end
        @viewportlink4.update
      end
    
      # パノラマプレーンを更新
      @panorama.ox = $game_map.display_x / 8
      @panorama.oy = $game_map.display_y / 8
      # フォグプレーンを更新
      @fog.zoom_x = $game_map.fog_zoom / 100.0
      @fog.zoom_y = $game_map.fog_zoom / 100.0
      @fog.opacity = $game_map.fog_opacity
      @fog.blend_type = $game_map.fog_blend_type
      @fog.ox = $game_map.display_x / 4 + $game_map.fog_ox
      @fog.oy = $game_map.display_y / 4 + $game_map.fog_oy
      @fog.tone = $game_map.fog_tone
      # キャラクタースプライトを更新
      for sprite in @character_sprites
        sprite.update
      end
      # 天候グラフィックを更新
      @weather.type = $game_screen.weather_type
      @weather.max = $game_screen.weather_max
      @weather.ox = $game_map.display_x / 4
      @weather.oy = $game_map.display_y / 4
      @weather.update
      # ピクチャを更新
      for sprite in @picture_sprites
        sprite.update
      end
      # タイマースプライトを更新
      @timer_sprite.update
      # 画面の色調とシェイク位置を設定
      @viewportc.tone = $game_screen.tone
      @viewport1.ox = $game_screen.shake
      # 画面のフラッシュ色を設定
      @viewport3.color = $game_screen.flash_color
      # ビューポートを更新
      @viewport1.update
      @viewport3.update
      @viewportc.update
    end
  end

  class Game_Map
    def scroll_down(distance)
      if POKEMON_S::_MAPLINK != nil and POKEMON_S::_MAPLINK
        @display_y = @display_y + distance
      else
        @display_y = [@display_y + distance, (self.height - 15) * 128].min
      end
    end
    
    def scroll_left(distance)
      if POKEMON_S::_MAPLINK != nil and POKEMON_S::_MAPLINK
        @display_x = @display_x - distance
      else
        POKEMON_S::_MAPLINK = false
        @display_x = [@display_x - distance, 0].max
      end
    end
    
    def scroll_right(distance)
      if POKEMON_S::_MAPLINK != nil and POKEMON_S::_MAPLINK
        @display_x = @display_x + distance
      else
        POKEMON_S::_MAPLINK = false
        @display_x = [@display_x + distance, (self.width - 20) * 128].min
      end
    end
    
    def scroll_up(distance)
      if POKEMON_S::_MAPLINK != nil and POKEMON_S::_MAPLINK
        @display_y = @display_y - distance
      else
        POKEMON_S::_MAPLINK = false
        @display_y = [@display_y - distance, 0].max
      end
    end
  end
  
  class Game_Player < Game_Character
    def center(x, y)
      if POKEMON_S::_MAPLINK != nil and POKEMON_S::_MAPLINK
        $game_map.display_x = x * 128 - CENTER_X
        $game_map.display_y = y * 128 - CENTER_Y
      else
        max_x = ($game_map.width - 20) * 128
        max_y = ($game_map.height - 15) * 128
        $game_map.display_x = [0, [x * 128 - CENTER_X, max_x].min].max
        $game_map.display_y = [0, [y * 128 - CENTER_Y, max_y].min].max       
      end
    end
  end
  

  
  class Interpreter
    # ------------------------------------------------------
    # jonction_map(N_id, N_x, E_id, E_y, S_id, S_x, O_id, O_y)
    # ------------------------------------------------------
    def jonction_map(n_id = 0, n_x = 0, e_id = 0, e_y = 0, s_id = 0, s_x = 0, o_id = 0, o_y = 0)
      if $map_link == nil
        $map_link = {}
      end
      $map_link[1] = [n_id, n_x]
      $map_link[2] = [e_id, e_y]
      $map_link[3] = [s_id, s_x]
      $map_link[4] = [o_id, o_y]
    end
    
    def command_201
      if $game_temp.in_battle
        return true
      end
      if $game_temp.player_transferring or
         $game_temp.message_window_showing or
         $game_temp.transition_processing
        return false
      end
      $game_temp.player_transferring = true
      if @parameters[0] == 0
        $game_temp.player_new_map_id = @parameters[1]
        $game_temp.player_new_x = @parameters[2]
        $game_temp.player_new_y = @parameters[3]
        $game_temp.player_new_direction = @parameters[4]
      else
        $game_temp.player_new_map_id = $game_variables[@parameters[1]]
        $game_temp.player_new_x = $game_variables[@parameters[2]]
        $game_temp.player_new_y = $game_variables[@parameters[3]]
        $game_temp.player_new_direction = @parameters[4]
      end
      jonction_map
      @index += 1
      if @parameters[5] == 0
        Graphics.freeze
        $game_temp.transition_processing = true
        $game_temp.transition_name = ""
      end
      return false
    end
  end
else
  class Interpreter
    def jonction_map(n_id = 0, n_x = 0, e_id = 0, e_y = 0, s_id = 0, s_x = 0, o_id = 0, o_y = 0)
      print("MAPLINK est désactivé.")
      POKEMON_S::_MAPLINK = false
    end
    
    def desactiver_maplink
      POKEMON_S::_MAPLINK = false
    end
    
    def activer_maplink
      POKEMON_S::_MAPLINK = true
    end
  end
end