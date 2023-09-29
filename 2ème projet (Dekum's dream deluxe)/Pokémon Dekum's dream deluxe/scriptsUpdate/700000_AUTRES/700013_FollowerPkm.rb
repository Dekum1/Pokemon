#==============================================================================
# ¦ Follow Me Pokémon
# par Brendan75
#-----------------------------------------------------------------------------
# Rend le premier pokémon de l'équipe visible sur la map.
#  A LAISSER A TOUT PRIS AU-DESSUS DE Animation_partout
#==============================================================================
class Follower_Pkm < Game_Character 
  include POKEMON_S
  
  def initialize
    super()
    @through = false
    @step_anime = true
    @pkm_id = 0
  end
  
  def x=(x)
    @x = x
  end
   
  def update
    if $pokemon_party.size != 0
      @pkm_id = $pokemon_party.actors[0].id
     string = "#{sprintf('%03d', @pkm_id)}"
     string += "s" if $pokemon_party.actors[0].shiny
     string += ".png"
     # Supprime le shiny
     if not ( $picture_data["Graphics/Characters/#{string}"] )
      string = "#{sprintf('%03d', @pkm_id)}.png"
    end
    # Si inexistant retire
    if not ( $picture_data["Graphics/Characters/#{string}"] )
      string = ""
    end
      if @character_name != string
        @character_name = string
        @character_hue = 0
        @opacity = 255
        @blend_type = 0
      end
      if string.length > 0
        if @opacity != ($game_switches[PKM_TRANSPARENT_SWITCHES] ? 255 : 0)
          @opacity = ($game_switches[PKM_TRANSPARENT_SWITCHES] ? 255 : 0)
        end
      else
        @opacity = 0
      end
    else
      @character_name = ""
    end
    self.move_speed = $game_player.move_speed
    super
  end
   
  def screen_z(height = 0) 
    if $game_player.x == @x and $game_player.y == @y
      return $game_player.screen_z(height) - 1
    end
    super(height) 
  end
   
  def check_event_trigger_touch(x, y) end
     
  def passable?(x, y, d)
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    return true
  end
end 
 
#-----------------------------------------------------------------------------
# ? Spriteset Map
#-----------------------------------------------------------------------------
class Spriteset_Map
  alias follow_me_initialize initialize
  def initialize
    follow_me_initialize
    @character_sprites.push(Sprite_Character.new(@viewport1, $game_party.follower_pkm))
    update
  end
end
 
#-----------------------------------------------------------------------------
# ? Scene Map
#-----------------------------------------------------------------------------
class Scene_Map
  alias follow_me_transfer_player transfer_player
  def transfer_player
    $game_party.erase_moves
    follow_me_transfer_player
  end
   
  alias follow_me_update update
  def update
    follow_me_update
    $game_party.follower_pkm.update
  end
end
 
#-----------------------------------------------------------------------------
# ? Game Player
#-----------------------------------------------------------------------------
class Game_Player
  alias follow_me_moveto moveto
  def moveto(x, y)
    follow_me_moveto(x, y)
    $game_party.follower_pkm.moveto(x, y)
  end
   
  def move_down(turn_enabled = true)
    if passable?(@x, @y, 2)
      $game_party.move_party_actors
      $game_party.add_move_list(Input::DOWN, turn_enabled)
    end
    super(turn_enabled)
  end
   
  def move_left(turn_enabled = true)
    if passable?(@x, @y, 4)
      $game_party.move_party_actors
      $game_party.add_move_list(Input::LEFT, turn_enabled)
    end
    super(turn_enabled)
  end
   
  def move_right(turn_enabled = true)
    if passable?(@x, @y, 6)
      $game_party.move_party_actors
      $game_party.add_move_list(Input::RIGHT, turn_enabled)
    end
    super(turn_enabled)
  end
   
  def move_up(turn_enabled = true)
    if passable?(@x, @y, 8)
      $game_party.move_party_actors
      $game_party.add_move_list(Input::UP, turn_enabled)
    end
    super(turn_enabled)
  end
  
  def speak_with_pokemon
    if $game_switches[PKM_TRANSPARENT_SWITCHES] and 
       $pokemon_party.size > 0 and position_speak
      if Input.trigger?(Input::C) and (@text_speak_pokemon == nil or 
                                       not @text_speak_pokemon.visible)
        $game_party.turn_on_player_follower
        filename = $pokemon_party.actors[0].cry
        if FileTest.exist?(filename)
          Audio.se_play(filename)
        end
        #@text_speak_pokemon ||= create_text
        #draw_text("Il ne reste plus qu'à paramétrer les approches")
        #loop do
        #  Graphics.update
        #  Input.update
        #  break if Input.trigger?(Input::C)
        #end
        #@text_speak_pokemon.visible = false
      end
    end
  end
  
  def position_speak
    valide = false
    case $game_player.direction
    when 2 #bas
      valide = $game_party.follower_pkm.y == $game_player.y + 1
    when 4 #gauche
      valide = $game_party.follower_pkm.x == $game_player.x - 1
    when 6 #droite
      valide = $game_party.follower_pkm.x == $game_player.x + 1
    when 8 #haut
      valide = $game_party.follower_pkm.y == $game_player.y - 1
    end
    return valide
  end
  
  # Création d'une fenêtre de texte
  # Renvoie les détails de la fenêtre
  def create_text
    text_window = Window_Base.new(0, 375, 632, $fontsize * 2 + 34)
    text_window.contents = Bitmap.new(600, 104)
    text_window.contents.font.name = $fontface
    text_window.contents.font.size = $fontsize
    return text_window
  end
    
  # Ecriture sur la fenêtre de texte d'une taille de 2 lignes
  # line1 : La première ligne du block de texte
  # line2 : La deuxième ligne du block de texte
  def draw_text(line1 = "", line2 = "")
    @text_speak_pokemon.visible = true
    @text_speak_pokemon.contents.clear
    @text_speak_pokemon.draw_text(0, -8, 460, 50, line1, 0, @text_speak_pokemon.normal_color)
    @text_speak_pokemon.draw_text(0, 22, 460, 50, line2, 0, @text_speak_pokemon.normal_color)
  end
end
 
#-----------------------------------------------------------------------------
# ? Game Party
#-----------------------------------------------------------------------------
class Game_Party
  include POKEMON_S
  attr_accessor :follower_pkm
   
  alias follow_me_initialize initialize
  def initialize
    follow_me_initialize
    @follower_pkm = Follower_Pkm.new
    @next_move = nil
  end
   
  def move_party_actors
    case @next_move.type
    when Input::DOWN
      @follower_pkm.move_down(@next_move.turn_enabled)
    when Input::LEFT
      @follower_pkm.move_left(@next_move.turn_enabled)
    when Input::RIGHT
      @follower_pkm.move_right(@next_move.turn_enabled)
    when Input::UP
      @follower_pkm.move_up(@next_move.turn_enabled)
    else
      return
    end
    resynchro_follower
    erase_moves
  end

 def resynchro_follower
    loop do
     if $game_player.y < follower_pkm.y
       @follower_pkm.move_up(true)
     elsif $game_player.y > follower_pkm.y
       @follower_pkm.move_down(true)
     elsif $game_player.x > follower_pkm.x
       @follower_pkm.move_right(true)
     elsif $game_player.x < follower_pkm.x
       @follower_pkm.move_left(true)
     else
       break
     end
   end
 end
 
 def turn_on_player_follower
  if $game_player.y < follower_pkm.y
    @follower_pkm.turn_up
  elsif $game_player.y > follower_pkm.y
    @follower_pkm.turn_down
  elsif $game_player.x > follower_pkm.x
    @follower_pkm.turn_right
  elsif $game_player.x < follower_pkm.x
    @follower_pkm.turn_left
  end
 end
     
  def add_move_list(type, turn_enabled) 
    @next_move = Move_List_Element.new(type, turn_enabled)
  end
   
  def erase_moves
    @next_move = nil
  end
  
  def watch_pokemon
    if $pokemon_party.size != 0
      if $game_player.y < $game_party.follower_pkm.y
        $game_player.turn_down
      elsif $game_player.y > $game_party.follower_pkm.y
        $game_player.turn_up
      elsif $game_player.x < $game_party.follower_pkm.x
        $game_player.turn_right
      elsif $game_player.x > $game_party.follower_pkm.x
        $game_player.turn_left
      end
    end
  end
end
 
#-----------------------------------------------------------------------------
# ? Move List Element
#-----------------------------------------------------------------------------
class Move_List_Element 
  attr_reader :type
  attr_reader :turn_enabled
   
  def initialize(type, turn_enabled)
    @type = type
    @turn_enabled = turn_enabled
  end
end

class Interpreter
  def watch_pokemon
    if $pokemon_party.size != 0
      if $game_player.y < $game_party.follower_pkm.y
        $game_player.turn_down
      elsif $game_player.y > $game_party.follower_pkm.y
        $game_player.turn_up
      elsif $game_player.x < $game_party.follower_pkm.x
        $game_player.turn_right
      elsif $game_player.x > $game_party.follower_pkm.x
        $game_player.turn_left
      end
    end
  end
  alias regarder_follower watch_pokemon
  
  def follower_back_position
    case $game_player.direction
    when 2 #bas
      $game_party.follower_pkm.moveto($game_player.x,$game_player.y-1)
      $game_party.follower_pkm.turn_down
      $game_party.add_move_list(Input::DOWN, true)
    when 4 #gauche
      $game_party.follower_pkm.moveto($game_player.x+1,$game_player.y)
      $game_party.follower_pkm.turn_left
      $game_party.add_move_list(Input::LEFT, true)
    when 6 #droite
      $game_party.follower_pkm.moveto($game_player.x-1,$game_player.y)
      $game_party.follower_pkm.turn_right
      $game_party.add_move_list(Input::RIGHT, true)
    when 8 #haut
      $game_party.follower_pkm.moveto($game_player.x,$game_player.y+1)
      $game_party.follower_pkm.turn_up
      $game_party.add_move_list(Input::UP, true)
    end
  end
  alias follower_derriere follower_back_position
end