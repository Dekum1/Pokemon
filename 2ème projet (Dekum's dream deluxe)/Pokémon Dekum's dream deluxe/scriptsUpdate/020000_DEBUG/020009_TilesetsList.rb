#===============================================================================
# Menu d'édition des tags - G!n0
#-------------------------------------------------------------------------------
# Liste des tilesets
#===============================================================================
module TAG_SYS
  
  class Tilesets_List < Window_Base

    #----------------------------------------------------
    # Les Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FONTSIZE = 20
    LINES = 9 # nombre de lignes visibles
    LH = 41 # hauteur d'une ligne
    
    
    #----------------------------------------------------
    # Initialisation
    # @t_list = list des tilsets
    # @selected = index de l'item sélectionné
    #----------------------------------------------------
    def initialize
      super(-8, 67, 182+32, LH*LINES+32)
      self.opacity = 0
      
      # Liste des tilesets
      @t_list = []
      1.upto($data_tilesets.size-1) do |i|
        @t_list.push($data_tilesets[i].name)
      end
      
      # Infos pour index
      @item_max = @t_list.size
      @index = 0
      
      # item selectionné
      @selected = 0
      
      # Effet de mouvement curseur
      @cpt_cursor = 0
      
      # Initialisation du bitmap contents
      self.contents = Bitmap.new(self.width - 32, self.height - 32)
      self.contents.font.name = FONTFACE
      self.contents.font.size = FONTSIZE
      
      # Sprite curseur
      @cursor_sprite = Sprite.new
      @cursor_sprite.bitmap = RPG::Cache.picture(DATA_TAG_EDITOR[:cursor])
      @cursor_sprite.x = 10
      @cursor_sprite.y = 92
      @cursor_sprite.z = self.z+10
      
      # Barre de progression
      @progress_bar = Sprite.new
      @progress_bar.bitmap = Bitmap.new(8,375)
      @progress_bar.x = 191
      @progress_bar.y = 81
      @progress_bar.z = self.z + 10
      
      # Rafraichissement
      update
      refresh
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      super
      @cursor_sprite.dispose
      @progress_bar.bitmap.dispose
      @progress_bar.dispose
      @cursor_sprite = nil
      @progress_bar = nil
    end
    
    #----------------------------------------------------
    # Mise à jour
    #----------------------------------------------------
    def update
      # Animation du curseur
      cursor_animation
      
      # Si la fenêtre est active
      if self.active and @item_max > 0 and @index >= 0
        if Input.repeat?(Input::DOWN)
          if Input.trigger?(Input::DOWN) or @index < @item_max - 1
            $game_system.se_play($data_system.cursor_se)
            increase_index
            return
          end
        end
        
        if Input.repeat?(Input::UP)
          if Input.trigger?(Input::UP) or @index >= 1
            $game_system.se_play($data_system.cursor_se)
            decrease_index
            return
          end
        end
        
      end
    end
    
    #----------------------------------------------------
    # Gestion index, top_index et bottom_index
    #----------------------------------------------------
    def index
      return @index
    end
    
    def top_index
      mid = LINES / 2
      if @index >= @item_max - mid
        return max(@item_max - LINES, 0)
      end
      return max(@index - mid, 0)
    end
    
    def bottom_index
      mid = LINES / 2
      if @index < mid
        return min(LINES - 1, @item_max - 1)
      end
      return min(@index + mid, @item_max - 1)
    end
    
    def increase_index
      # Enregistrement de l'ancien top_index
      old_top = top_index
      # AUgmenter l'index et rafraichir le curseur
      @index = (@index + 1) % @item_max
      cursor_refresh
      # Rafraichissement du texte et de progress_bar si top_index a changé
      new_top = top_index
      if new_top != old_top
        new_top == 0 ? text_refresh : text_move_up
        progress_bar_refresh
      end
    end
    
    def decrease_index
      # Enregistrement de l'ancien bottom_index
      old_bottom = bottom_index
      # Diminution de l'index et rafraichissement du curseur
      @index = (@index - 1 + @item_max) % @item_max
      cursor_refresh
      # Rafraichissement du texte et de progress_bar si top_index a changé
      new_bottom = bottom_index
      if new_bottom != old_bottom
        new_bottom == @item_max - 1 ? text_refresh : text_move_down
        progress_bar_refresh
      end
    end
    
    #----------------------------------------------------
    # Animation du curseur
    #----------------------------------------------------
    def cursor_animation
      if @cursor_sprite.visible
        val = 0.10471976 #pi/30
        @cpt_cursor = (@cpt_cursor + 1) % 30
        @cursor_sprite.x = 5 + Integer(5*Math.sin(val*(@cpt_cursor)))
      end
    end
    
    def set_cursor_visible
      @cursor_sprite.visible = true
    end
    
    def set_cursor_invisible
      @cursor_sprite.visible = false
    end
    
    # Disparition/apparition suivant l'activation de fenêtre
    def active=(bool)
      super(bool)
      bool ? set_cursor_visible : set_cursor_invisible
    end
    
    #----------------------------------------------------
    # Rafraichissement des sprites et du texte
    #----------------------------------------------------
    def refresh
      text_refresh
      cursor_refresh
      progress_bar_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement de la position du curseur
    #----------------------------------------------------
    def cursor_refresh
      @cursor_sprite.y = ((@index - self.top_index))*LH + 92
    end
    
    #----------------------------------------------------
    # Rafraichissement progress_bar
    #----------------------------------------------------
    def progress_bar_refresh
      if @item_max > 0
        rect = Rect.new(0, 0, 8, 375)
        @progress_bar.bitmap.fill_rect(rect, Color.new(240,240,240,255))
        # taille curseur
        tail = max(375*LINES/@item_max, 20)
        # Placement curseur
        rect = Rect.new(0, (375-tail)*top_index/max(1,@item_max-LINES), 8, tail)
        @progress_bar.bitmap.fill_rect(rect, Color.new(205,205,205,255))
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement du text
    #----------------------------------------------------
    def text_refresh
      self.contents.clear
      self.contents.font.color = normal_color
      top = top_index
      bottom = bottom_index
      top.upto(bottom) do |ind|
        draw_line(ind)
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement de la première ligne du text
    #----------------------------------------------------
    def text_refresh_first_line
      self.contents.font.color = normal_color
      draw_line(top_index)
    end
    
    #----------------------------------------------------
    # Rafraichissement de la dernière ligne du text
    #----------------------------------------------------
    def text_refresh_last_line
      self.contents.font.color = normal_color
      draw_line(bottom_index)
    end
    
    #----------------------------------------------------
    # Décaler le text d'une ligne vers le haut
    #----------------------------------------------------
    def text_move_up
      # On copie le text sauf la première ligne
      bitmap = Bitmap.new(self.contents.width, self.contents.height-LH)
      src_rect = Rect.new(0, LH, bitmap.width, bitmap.height)
      bitmap.blt(0, 0, self.contents, src_rect, 255)
      # On efface et on colle le text copié décalé d'une ligne vers le haut
      self.contents.clear
      src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      self.contents.blt(0, 0, bitmap, src_rect, 255)
      bitmap.dispose
      # Rafraichissement de la dernière ligne
      text_refresh_last_line
    end
    
    #----------------------------------------------------
    # Décaler le text d'une ligne vers le bas
    #----------------------------------------------------
    def text_move_down
      # On copie le text sauf la dernière ligne
      bitmap = Bitmap.new(self.contents.width, self.contents.height-LH)
      src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      bitmap.blt(0, 0, self.contents, src_rect, 255)
      # On efface et on colle le text copié décalé d'une ligne vers le bas
      self.contents.clear
      src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
      self.contents.blt(0, LH, bitmap, src_rect, 255)
      bitmap.dispose
      # Rafraichissement de la première ligne
      text_refresh_first_line
    end
    
    #----------------------------------------------------
    # Affichage d'une ligne
    #----------------------------------------------------
    def draw_line(index)
      # Position y
      y = LH * (index - top_index)
      
      if index == @selected
        self.contents.font.color = Color.new(255, 64, 64, 255)
      end
      
      string = "N°#{sprintf('%03d', index+1)}"
      self.contents.draw_text(18, y, 480, LH, string)
      
      string = @t_list[index]
      string = "---------" if string ==""
      self.contents.draw_text(72, y, 182, LH, string)
      
      if index == @selected
        self.contents.font.color = normal_color
      end
    end
    
    #----------------------------------------------------
    # Effaçage d'une ligne
    #----------------------------------------------------
    def clear_line(index)
      rect = Rect.new(0, LH*(index - top_index), self.contents.width, LH)
      self.contents.fill_rect(rect, Color.new(0,0,0,0))
    end
    
    #----------------------------------------------------
    # Changement de l'item sélectionné
    #----------------------------------------------------
    def change_selected
      old_selected = @selected
      @selected = @index
      if old_selected - top_index >= 0
        clear_line(old_selected)
        draw_line(old_selected)
      end
      clear_line(@selected)
      draw_line(@selected)
    end
    
  end
  
end