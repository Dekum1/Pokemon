#==============================================================================
# ¦ Window_NameInput
#------------------------------------------------------------------------------
#  ???????????????????????
#==============================================================================
#Merci à Aramil Naïlo pour son aide

class Window_NameInput < Window_Base
CHARACTER_TABLE =
[
 "A","B","C","D","E",
 "F","G","H","I","J",
 "K","L","M","N","O",
 "P","Q","R","S","T",
 "U","V","W","X","Y",
 "Z","","","","",
 "","","","","",
 "1","2","3","4","5",
 "6","7","8","9","0",
 "a","b","c","d","e",
 "f","g","h","i","j",
 "k","l","m","n","o",
 "p","q","r","s","t",
 "u","v","w","x","y",
 "z","","","","",
 "","","","","",
 "!","@","#","$","%",
 "^","&","*","(",")",
 "é","è","ê","ë","",
 "à","ä","ç","œ","",
 "ï","ì","í","î","",
 "ö","ò","ó","ô","",
 "ü","ù","ú","û","",
 "©","®","™","€","»",
 "-","+","=","/","|",
 ";",":","'","_","?",
 ",",".","<",">","~",
 "`","[","]","{","}",
 "","","","","",
 "","","","","",
 "","","","","",
 "","","","","",
 "","","","","",
 "","","","","",
 "","","","","",
 "","","","","",
]
#--------------------------------------------------------------------------
# ? ?????????
#--------------------------------------------------------------------------
def initialize
  super(0, 128, 640, 352)
  self.contents = Bitmap.new(width - 32, height - 32)
  self.contents.font.name = "Arial"
  @index = 0
  refresh
  update_cursor_rect
end
#--------------------------------------------------------------------------
# ? ?????
#--------------------------------------------------------------------------
def character
  return CHARACTER_TABLE[@index]
end
#--------------------------------------------------------------------------
# ? ??????
#--------------------------------------------------------------------------
def refresh
  self.contents.clear
  for i in 0..179
    x = 4 + i / 5 / 9 * 152 + i % 5 * 28
    y = i / 5 % 9 * 32
    self.contents.draw_text(x, y, 28, 32, CHARACTER_TABLE[i], 1)
  end
  self.contents.draw_text(510, 9 * 32, 100, 32, "Confirmer", 1)
end
#--------------------------------------------------------------------------
# ? ?????????
#--------------------------------------------------------------------------
def update_cursor_rect
  # ??????? [??] ???
  if @index >= 180
    self.cursor_rect.set(505, 9 * 32, 110, 32)
  # ??????? [??] ?????
  else
    x = 4 + @index / 5 / 9 * 152 + @index % 5 * 28
    y = @index / 5 % 9 * 32
    self.cursor_rect.set(x, y, 28, 32)
  end
end
#--------------------------------------------------------------------------
# ? ??????
#--------------------------------------------------------------------------
def update
  super
  # ??????? [??] ???
  if @index >= 180
    # ?????
    if Input.trigger?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      @index -= 180
    end
    # ?????
    if Input.repeat?(Input::UP)
      $game_system.se_play($data_system.cursor_se)
      @index -= 180 - 40
    end
  # ??????? [??] ?????
  else
    # ??????????????
    if Input.repeat?(Input::RIGHT)
      # ????????????????
      # ???????????????
      if Input.trigger?(Input::RIGHT) or
         @index / 45 < 3 or @index % 5 < 4
        # ?????????
        $game_system.se_play($data_system.cursor_se)
        if @index % 5 < 4
          @index += 1
        else
          @index += 45 - 4
        end
        if @index >= 180
          @index -= 180
        end
      end
    end
    # ??????????????
    if Input.repeat?(Input::LEFT)
      # ????????????????
      # ???????????????
      if Input.trigger?(Input::LEFT) or
         @index / 45 > 0 or @index % 5 > 0
        # ?????????
        $game_system.se_play($data_system.cursor_se)
        if @index % 5 > 0
          @index -= 1
        else
          @index -= 45 - 4
        end
        if @index < 0
          @index += 180
        end
      end
    end
    # ??????????????
    if Input.repeat?(Input::DOWN)
      # ?????????
      $game_system.se_play($data_system.cursor_se)
      if @index % 45 < 40
        @index += 5
      else
        @index += 180 - 40
      end
    end
    # ??????????????
    if Input.repeat?(Input::UP)
      # ????????????????
      # ???????????????
      if Input.trigger?(Input::UP) or @index % 45 >= 5
        # ?????????
        $game_system.se_play($data_system.cursor_se)
        if @index % 45 >= 5
          @index -= 5
        else
          @index += 180
        end
      end
    end
    # L ???? R ??????????
    if Input.repeat?(Input::L) or Input.repeat?(Input::R)
      # ???? / ???? ??
      $game_system.se_play($data_system.cursor_se)
      if @index / 45 < 2
        @index += 90
      else
        @index -= 90
      end
    end
  end
  update_cursor_rect
end
end

