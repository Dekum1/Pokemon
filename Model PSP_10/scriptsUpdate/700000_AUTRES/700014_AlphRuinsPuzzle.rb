#--------------------------------------------
# Puzzle des Ruines Alpha
# Par FL0RENT_
#--------------------------------------------
class Interpreter
  def puzzle_alpha(id = 1)
    $victoire_puzzle_alpha = false
    $scene = Alph_Ruins_Puzzle.new(id)
  end
end
 
class Alph_Ruins_Puzzle
  def initialize(id)
    Graphics.freeze
    @background = Plane.new
    @background.bitmap = RPG::Cache.picture(DATA_PUZZLE_ALPHA[:fond1])
    @background2 = Sprite.new
    @background2.bitmap = RPG::Cache.picture(DATA_PUZZLE_ALPHA[:fond2])
    @background2.x = 192
    @background2.y = 96
    @grid = []
    6.times do
      @grid.push Array.new(6)
    end
    @pieces = []
    @cursor_piece = nil
    @cursor = Sprite.new
    @cursor.bitmap = RPG::Cache.picture(DATA_PUZZLE_ALPHA[:curseur])
    @cursor.z = 9001
    @cursor_x = 0
    @cursor_y = 0
    @cursor_wait = 0
    4.times do |x|
      4.times do |y|
        img = Sprite.new
        img.bitmap = RPG::Cache.picture("Puzzle_Ruines/" + id.to_s)
        img.src_rect = Rect.new(x * 72, y * 72, 72, 72)
        @pieces.push img
      end
    end
    for piece in @pieces
      verif = false
      until verif
        a = rand(3)
        case a
        when 0
          b = rand(6)
          if @grid[0][b] == nil
            verif = true
            @grid[0][b] = piece
          end
        when 1
          b = rand(6)
          if @grid[5][b] == nil
            verif = true
            @grid[5][b] = piece
          end
        when 2
          b = rand(4)
          if @grid[b + 1][0] == nil
            verif = true
            @grid[b + 1][0] = piece
          end
        end
         
      end
    end
  end
   
  def main
    pieces_position
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if victory_check
        $victoire_puzzle_alpha = true
        if VICTORY_THEME != nil
          Audio.bgm_play("Audio/ME/#{DATA_AUDIO_ME[:acquisition_quete]}")
          wait(80)
          wait_hit
          $scene = Scene_Map.new
          $game_system.bgm_play($game_map.bgm)
        else
          wait(120)
          $scene = Scene_Map.new
        end
      end
      if $scene != self
        break
      end
    end
     
    Graphics.freeze
    dispose
  end
   
   
  def update
    if @cursor_piece == nil
      @cursor_wait += 1
      @cursor_wait = 0 if @cursor_wait > 40
      @cursor.opacity = 0 if @cursor_wait == 20
      @cursor.opacity = 255 if @cursor_wait == 0
    end
    if Input.trigger?(Input::B)
      $scene = Scene_Map.new
    end
    if Input.trigger? (Input::DOWN)
      unless @cursor_y >= 5 or (@cursor_y == 4 and @cursor_x != 0 and @cursor_x != 5)
        @cursor_y += 1
        move
      end
    end
    if Input.trigger? (Input::UP)
      unless @cursor_y == 0
        @cursor_y -= 1
        move
      end
    end
    if Input.trigger? (Input::RIGHT)
      unless @cursor_x >= 5 or @cursor_y == 5
        @cursor_x += 1
        move
      end
    end
    if Input.trigger? (Input::LEFT)
      unless @cursor_x == 0 or @cursor_y == 5
        @cursor_x -= 1
        move
      end
    end
    if Input.trigger?(Input::C)
      if @cursor_piece == nil
        if @grid[@cursor_x][@cursor_y] != nil
          wait 4
          @cursor_piece = @grid[@cursor_x][@cursor_y]
          @grid[@cursor_x][@cursor_y] = nil
          @cursor.bitmap = RPG::Cache.picture(DATA_PUZZLE_ALPHA[:curseurB])
          @cursor.opacity = 255
          @cursor_wait = 0
        end
      else
        if @grid[@cursor_x][@cursor_y] == nil
          wait 4
          @grid[@cursor_x][@cursor_y] = @cursor_piece
          @cursor_piece = nil
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:place_piece]}")
          @cursor.bitmap = RPG::Cache.picture(DATA_PUZZLE_ALPHA[:curseur])
        end
      end
    end
    pieces_position
  end
   
  def dispose
    @background.dispose
    @background2.dispose
    @cursor.dispose
    @pieces.each do |p|
      p.dispose
    end
  end
   
   
  def victory_check
    4.times do |x|
      4.times do |y|
        if @grid[x + 1][y + 1] != @pieces[y + (4 * x)]
          return false
        end
      end
    end
    return true
  end
   
  def pieces_position
    @cursor.x = 120 + @cursor_x * 72
    @cursor.y = 24 + @cursor_y * 72
     
    for piece in @pieces
      if @cursor_piece == piece
        piece.x = 120 + @cursor_x * 72
        piece.y = 24 + @cursor_y * 72
        piece.z = 1
      else
        for line in @grid
          if line.include?(piece)
            x = @grid.index(line)
            y = line.index(piece)
            piece.x = 120 + x * 72
            piece.y = 24 + y * 72
            piece.z = 0
          end
        end
      end
    end
  end
   
  def wait(x)
    x.times do
      Graphics.update
    end
  end
   
  def wait_hit
    loop do
      Graphics.update
      Input.update
      if Input.trigger?(Input::C) or Input.trigger?(Input::B)
        break
      end
    end
  end
   
  def move
    if @cursor_piece == nil
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:menu_puzzle]}", 80)
      wait(5)
      @cursor.opacity = 255
      @cursor_wait = 0
    else
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:degat_moins]}", 80)
      wait(5)
    end
  end
end