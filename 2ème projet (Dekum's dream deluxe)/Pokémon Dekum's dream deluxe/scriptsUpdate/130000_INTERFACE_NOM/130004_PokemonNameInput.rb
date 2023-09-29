#==============================================================================
# ■ Pokemon_NameInput
# Pokemon Script Project - Krosk 
# 17/08/07
# Amélioré par Damien Linux - 02/02/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier
#-----------------------------------------------------------------------------
# Script original: Window_NameInput
module POKEMON_S
  class Pokemon_NameInput < Window_Base
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
     "!","?",":" ,";",",", # @: PKM, #: No
     "«","»",".","(",")",
     
     "é","è","ê","ë","",
     "à","ä","ç","œ","",
     "ï","ì","í","î","",
     "ö","ò","ó","ô","",
     "ü","ù","ú","û","",
     "[" ,"]" ,"<" ,">" ,"|",
     "-","+","=","/","*",
     "$","\\","'","_","@",
     "%","&","♂","♀","~"
    ]
    
    CHARACTER_TABLE_EX =
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
     "!","?","" ,"","", # @: PKM, #: No
     "","","","","",
     
     "","","","","",
     "","","","","",
     "","","","","",
     "","","","","",
     "","","","","",
     "","","","","",
     "","","","","",
     "","","","","",
     "","","","",""
    ]

    def initialize(ex_table = false)
      super(30, 150, 555, 300)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = $fontface
      self.contents.font.size = $fontsize
      self.contents.font.color = normal_color
      self.opacity = 0
      @index = 0
      @ex_table = ex_table
      refresh
      update_cursor_rect
    end

    def character
      return CHARACTER_TABLE[@index]
    end

    def refresh
      self.contents.clear
      for i in 0..134
        x = 24 + i / 5 / 9 * 152 + i % 5 * 28
        y = 9 + i / 5 % 9 * 29
        if @ex_table
          self.contents.draw_text(x, y, 28, 32, CHARACTER_TABLE_EX[i], 1)
        else
          self.contents.draw_text(x, y, 28, 32, CHARACTER_TABLE[i], 1)
        end
      end
      self.contents.draw_text(0, 9 + 8 * 29, 511, 32, "OK", 2)
    end  
    
    def character
      if @ex_table
        return CHARACTER_TABLE_EX[@index]
      end
      return CHARACTER_TABLE[@index]
    end

    def update_cursor_rect
      if @index >= 135
        self.cursor_rect.set(483, 9 + 8 * 29, 32, 32)
      else
        x = 24 + @index / 5 / 9 * 152 + @index % 5 * 28
        y = 9 + @index / 5 % 9 * 29
        self.cursor_rect.set(x, y, 32, 32)
      end
    end

    def update
      super
      if @index >= 135
        @index = 135
        if Input_Scene.trigger?(Input_Scene::LEFT)
          $game_system.se_play($data_system.cursor_se)
          @index = 134
        end
        if Input_Scene.trigger?(Input_Scene::RIGHT)
          $game_system.se_play($data_system.cursor_se)
          @index = 40
        end
      else
        if Input_Scene.repeat?(Input_Scene::RIGHT)
          if Input_Scene.trigger?(Input_Scene::RIGHT) or
             @index / 45 < 2 or @index % 5 < 4
            $game_system.se_play($data_system.cursor_se)
            if @index % 5 < 4
              @index += 1
            else
              @index += 45 - 4
            end
            if @index >= 135
              @index -= 135
            end
            if @index == 40
              @index = 135
            end
          end
        end
        if Input_Scene.repeat?(Input_Scene::LEFT)
          if Input_Scene.trigger?(Input_Scene::LEFT) or
             @index / 45 > 0 or @index % 5 > 0
            $game_system.se_play($data_system.cursor_se)
            if @index % 5 > 0
              @index -= 1
            else
              @index -= 45 - 4
            end
            if @index < 0
              @index += 135
            end
            if @index == 134
              @index = 135
            end
          end
        end
        if Input_Scene.repeat?(Input_Scene::DOWN)
          if Input_Scene.trigger?(Input_Scene::DOWN) or @index % 45 < 40
            $game_system.se_play($data_system.cursor_se)
            if @index % 45 < 40
              @index += 5
            else
              @index -= 40
            end
          end
        end
        if Input_Scene.repeat?(Input_Scene::UP)
          if Input_Scene.trigger?(Input_Scene::UP) or @index % 45 >= 5
            $game_system.se_play($data_system.cursor_se)
            if @index % 45 >= 5
              @index -= 5
            else
              @index += 40
            end
          end
        end
        if Input_Scene.repeat?(Keys::TAB)
          $game_system.se_play($data_system.cursor_se)
          if @index / 45 < 2
            @index += 90
          else
            @index -= 90
          end
        end
        if Input_Scene.repeat?(Keys::ESCAPE)
          @index = @ex_table ? CHARACTER_TABLE_EX.size : CHARACTER_TABLE.size
        end
      end
      update_cursor_rect
    end
    
    def char_authorize?(char)
      return @ex_table ? CHARACTER_TABLE_EX.include?(char) :
                         CHARACTER_TABLE.include?(char)
    end
  end
end