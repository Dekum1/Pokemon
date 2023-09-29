#============================================================================== 
# ■ Sprite_Reflection 
# Based on Sprite_Mirror, Modified By: JmsPlDnl, rewritten entirely by Rataime 
# 18/04/07 : Script modifié par MGCaladtogel pour améliorer le rendu visuel 
# 23/02/09 : Script modifié par Palbolsky
#============================================================================== 
CATERPILLAR_COMPATIBLE = true 
EAU_TAG = 2
#---------------------------------------------------------------------------- 
class Game_Party 
 attr_reader :characters 
end 
#---------------------------------------------------------------------------- 
class Sprite_Reflection < RPG::Sprite 
  attr_accessor :character 
  #-------------------------------------------------------------------------- 
  def initialize(viewport=nil, character=nil,self_angle = 180) 
    super(viewport) 
    @character = character 
    @self_angle=self_angle 
    self.opacity=0 
    @reflected=false 
    @former=false 
    @moving=false 
    @c_h = false 
    @c_g = 0 
    @c_d = 0 
    if $game_map.system_tag(@character.real_x/128,@character.real_y/128+1) == EAU_TAG 
      corr_auto(@character.real_x/128,@character.real_y/128+1) 
      @reflected=true 
      @former=true 
    end 
    update 
  end 
  #-------------------------------------------------------------------------- 
  def type_auto(x, y) 
    val = $game_map.system_tag(x, y) 
    return (val != EAU_TAG ? false : true) 
  end 
  #-------------------------------------------------------------------------- 
  def corr_auto(x, y) 
    val0 = $game_map.system_tag(x,y) 
    val1 = $game_map.system_tag(x-1,y) 
    val2 = $game_map.system_tag(x+1,y) 
    if val1 != EAU_TAG and @cw
      @c_g = (@cw-32)/2 if val0 == EAU_TAG
      @c_g += 13 if val0 == EAU_TAG # Coupe le héros sur le bord gauche
    end 
    if val2 != EAU_TAG and @cw
      @c_d = (@cw-32)/2 if val0 == EAU_TAG
      @c_d += 11 if val0 == EAU_TAG # Coupe le héros sur le bord droit 
    end 
  end 
  #-------------------------------------------------------------------------- 
  def update 
    @c_h = false 
    @c_g = 0 
    @c_d = 0 
    @m = false 
    super 
    if @tile_id != @character.tile_id or 
      @character_name != @character.character_name or 
      @character_hue != @character.character_hue 
      @tile_id = @character.tile_id 
      @character_name = @character.character_name 
      @character_hue = @character.character_hue 
      if @tile_id >= 384 
        self.bitmap = RPG::Cache.tile($game_map.tileset_name, 
        @tile_id, @character.character_hue) 
        self.src_rect.set(0, 0, 32, 32) 
        self.ox = 16 
        self.oy = 32 
      else 
        self.bitmap = RPG::Cache.character(@character.character_name, 
        @character.character_hue) 
        @cw = bitmap.width / 4 
        @ch = bitmap.height / 4 
        self.ox = @cw / 2 
        self.oy = @ch 
      end 
    end 
    self.visible = (not @character.transparent) 
    if @tile_id == 0 
      sx = (@character.pattern) * @cw 
      sy = (@character.direction - 2) / 2 * @ch 
      if @character.direction== 6 
        sy = ( 4- 2) / 2 * @ch 
      end 
      if @character.direction== 4 
        sy = ( 6- 2) / 2 * @ch 
      end 
      if @character.direction != 4 and @character.direction != 6
        sy = (@character.direction - 2) / 2 * @ch 
      end 
    end 
    
    
    self.x = @character.screen_x-1 # Ne pas toucher SVP, corrige un décalage !
    # Pour régler la position du reflet, verticalement  
    if $game_switches[GRAPHISME_5G]
      self.y = @character.screen_y-6
    elsif $game_switches[GRAPHISME_4G]
      self.y = @character.screen_y-1
    else # Graphisme 3G
      self.y = @character.screen_y-7
    end
    @moving=!(@character.real_x%128==0 and @character.real_y%128==0) 
    @d=@character.direction 
    @rect=[sx, sy, @cw, @ch] 
    if !(@moving) 
      if $game_map.system_tag(@character.real_x/128,@character.real_y/128+1) == EAU_TAG
        corr_auto(@character.real_x/128,@character.real_y/128+1) 
        @reflected=true 
        @former=true 
      else 
        @reflected=false 
        @former=false 
      end 
    else 
      case @d 
      when 2 
        if $game_map.system_tag(@character.real_x/128,@character.real_y/128+2) == EAU_TAG
          corr_auto(@character.real_x/128,@character.real_y/128+2) 
          @reflected=true 
          if @former==false 
            @offset = @ch - (32 - ((@character.real_y/4)%32)) 
            @rect=[sx, sy, @cw, @offset] 
          end 
        else 
          @reflected = ($game_map.system_tag(@character.real_x/128, @character.real_y/128+1) == EAU_TAG) 
          if @reflected 
            @offset = @ch - ((32+5) - (@character.real_y/4)%32) 
            @rect=[sx, sy + @offset, @cw, @ch - @offset] 
            self.y -= @offset 
          end 
        end 
      when 4 
        if $game_map.system_tag((@character.real_x+127)/128 - 1,@character.real_y/128+1) != EAU_TAG
          if $game_map.system_tag((@character.real_x+127)/128,@character.real_y/128+1) == EAU_TAG
            @offset = (@character.real_x/4)%32 + (@cw-32)/2 
            @offset -= 8 if type_auto((@character.real_x+127)/128,@character.real_y/128+1) 
            @rect=[sx, sy, @offset, @ch] 
            @reflected=true 
            @c_h = true 
          end 
        else 
          @reflected=true 
          if @former==false 
            @offset = (@character.real_x/4)%32 + (@cw-32)/2 
            @offset += 12 if type_auto((@character.real_x)/128,@character.real_y/128+1) 
            @rect=[sx+@offset, sy, @cw-@offset, @ch] 
            self.x -= @offset 
          end 
        end 
      when 6 
        if $game_map.system_tag(@character.real_x/128+1,@character.real_y/128+1) != EAU_TAG
          if $game_map.system_tag(@character.real_x/128,@character.real_y/128+1) == EAU_TAG
            @offset = (@character.real_x/4)%32 + (@cw-32)/2 
            @offset += 8 if type_auto(@character.real_x/128,@character.real_y/128+1) 
            @rect=[sx+@offset, sy, @cw-@offset, @ch] 
            self.x -= @offset 
            @reflected=true 
          end 
        else 
          @reflected=true 
          if @former==false 
            @offset = (@character.real_x / 4)%32 + (@cw-32)/2 
            @offset -= 8 if type_auto((@character.real_x+127)/128,@character.real_y/128+1) 
            @rect=[sx, sy, @offset, @ch] 
            @c_h = true 
          end 
        end 
      when 8 
        if $game_map.system_tag(@character.real_x/128,@character.real_y/128+2) == EAU_TAG
          corr_auto(@character.real_x/128,@character.real_y/128+2) 
          @reflected=true 
          if $game_map.system_tag(@character.real_x/128,@character.real_y/128+1) != EAU_TAG
            @offset = @ch - (32 - ((@character.real_y/4)%32)) 
            @rect=[sx, sy, @cw, @offset] 
          end 
        else 
          @reflected = ($game_map.system_tag(@character.real_x/128, @character.real_y/128+1) == EAU_TAG) 
          if @reflected 
            @offset = @ch - ((32+5) - (@character.real_y/4)%32) 
            @rect=[sx, sy + @offset, @cw, @ch - @offset] 
            self.y -= @offset 
          end 
        end 
      end 
    end 
    if @reflected and @character.opacity > 0
      self.opacity=128
    else 
    @rect=[sx, sy, @cw, @ch] 
    self.opacity=0 
    end 
    if @reflected and $game_map.system_tag((@character.real_x+64)/128, (@character.real_y+127)/128+2) != EAU_TAG
      if $game_map.system_tag((@character.real_x+64)/128, (@character.real_y+127)/128) == EAU_TAG and 
      $game_map.system_tag((@character.real_x+64)/128, (@character.real_y+127)/128+1) == EAU_TAG
        @offset = [(@ch - (32+3)) - (32 - (@character.real_y/4)%32)%32, 0].max # !
        @rect[1] += @offset 
        @rect[3] -= @offset 
        self.y -= @offset 
      else 
        lim = (type_auto((@character.real_x+64)/128, 
        (@character.real_y+127)/128+1) ? (32- 8)  : (32+3)) # !
        if @rect[3] > lim 
          diff = @rect[3] - lim 
          @rect[1] += diff 
          @rect[3] = lim 
          self.y -= diff 
        end 
      end 
    else 
      @reflected=false 
    end 
    corr_h = 0 
    if @c_h or ($game_map.system_tag((@character.real_x)/128, (@character.real_y+127)/128) != EAU_TAG and 
      $game_map.system_tag((@character.real_x)/128, (@character.real_y+127)/128+1) == EAU_TAG) 
      if type_auto((@character.real_x)/128, (@character.real_y+127)/128+1) or 
        type_auto((@character.real_x+127)/128, (@character.real_y+127)/128+1) 
        corr_h = 16 # Coupe le héros sur le bord haut 
      else 
        corr_h = 4 
      end 
    end 
    self.x -= @c_d 
    if @rect[0]
      self.src_rect.set(@rect[0] + @c_d, @rect[1], @rect[2] - @c_g - @c_d, 
      @rect[3] - corr_h) 
    end
    @character.is_a?(Game_Player) ? self.z = 9 : self.z = 5 
    self.blend_type = @character.blend_type 
    self.bush_depth = @character.bush_depth 
    if @character.animation_id != 0 
      animation = $data_animations[@character.animation_id] 
      animation(animation, true) 
      @character.animation_id = 0 
    end 
    self.angle = @self_angle 
  end 
end 

#=================================================== 
# ? CLASS Sprite_Character edit 
#=================================================== 

class Sprite_Character < RPG::Sprite 
  alias reflect_initialize initialize 
  #-------------------------------------------------------------------------- 
  def initialize(viewport, character = nil) 
    @character = character 
    @reflection = [] 
    super(viewport) 
    if (character.is_a?(Game_Event) and character.list!=nil and character.list[0].code == 108)
      @reflection.push(Sprite_Reflection.new(viewport,@character)) 
    end 
    if (character.is_a?(Follower_Pkm) and $game_party.follower_pkm.character_name.length > 0)
      @reflection.push(Sprite_Reflection.new(viewport,@character))
    end
    if (character.is_a?(Game_Event) and character.list!=nil and character.list[0].code == 108)
      @reflection.push(Sprite_Reflection.new(viewport,$game_player)) 
#=================================================== 
# ? Compatibility with fukuyama's caterpillar scrîpt 
#=================================================== 
      if CATERPILLAR_COMPATIBLE and $game_party.characters!=nil 
        for member in $game_party.characters 
          @reflection.push(Sprite_Reflection.new(viewport,member)) 
        end 
      end 
#=================================================== 
# ? End of the compatibility 
#=================================================== 
    end 
    reflect_initialize(viewport, @character) 
  end 
  #-------------------------------------------------------------------------- 
  alias reflect_update update 
  #-------------------------------------------------------------------------- 
  def update 
    reflect_update 
    if @reflection!=nil 
      for reflect in @reflection 
        reflect.update 
      end 
    end 
  end 
end