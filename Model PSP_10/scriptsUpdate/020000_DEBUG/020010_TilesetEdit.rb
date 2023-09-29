#===============================================================================
# Menu d'édition des tags - G!n0
#-------------------------------------------------------------------------------
# Fenêtre d'édition du tileset
#
# Permet de selectionner un tile et de modifier son terrain_tag/system_tag
#===============================================================================

module TAG_SYS
  
  class Tilesets_Edit < Window_Base
    
    #----------------------------------------------------
    # Les Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FS_BIG = 24
    LINES = 13 # nombre de lignes visibles
    COLUMNS = 8 # Nombre de colonnes
    LH = 32 # hauteur d'une ligne
    CW = 32 # Largeur d'une colonne
    
    
    #----------------------------------------------------
    # Initialisation
    #----------------------------------------------------
    def initialize
      super(205, 24, COLUMNS*CW+32, LINES*LH+32)
      self.opacity = 0
      
      # id du tileset
      @tileset_id = 1
      
      # création des system_tags s'ils n'existent pas
      TAG_SYS::system_tags_check
      
      # données sur les tags
      @data_tags = Array.new(1)
      1.upto($data_tilesets.size-1) do |i|
        tileset = $data_tilesets[i]
        @data_tags.push(Tileset_Tags.new(tileset))
      end
      
      # mode : terrain ou system
      @mode = :terrain
      
      # Initialisation du bitmap contents
      self.contents = Bitmap.new(width - 32, height-32)
      self.contents.font.name = FONTFACE
      self.contents.font.size = FS_BIG
      
      # Sprite du tileset
      @tileset_sprite = Sprite.new
      @tileset_sprite.x = 221
      @tileset_sprite.y = 40
      @tileset_sprite.z = 20
      # Chargement du tileset
      load_tileset(1)
      
      # Barre de progression
      @progress_bar = Sprite.new
      @progress_bar.bitmap = Bitmap.new(8,416)
      @progress_bar.x = 221 + 256
      @progress_bar.y = 40
      @progress_bar.z = self.z + 10
      
      # Sprite de la grille
      @grid = Sprite.new
      @grid.x = 221
      @grid.y = 40
      @grid.z = self.z + 5
      @grid.bitmap = RPG::Cache.picture(DATA_TAG_EDITOR[:grid])

      # Sprite du curseur
      @cursor_sprite = Sprite.new
      @cursor_sprite.bitmap = RPG::Cache.picture(DATA_TAG_EDITOR[:tile_cursor])
      @cursor_sprite.ox = @cursor_sprite.bitmap.width / 2
      @cursor_sprite.oy = @cursor_sprite.bitmap.height / 2
      @cursor_sprite.x = 221 + @cursor_sprite.ox
      @cursor_sprite.y = 40 + @cursor_sprite.oy
      @cursor_sprite.z = self.z+10
      
      # Infos pour index
      @item_max = (@tileset_sprite.bitmap.height / LH)*COLUMNS
      @index = 0
      @top_index = 0
      @bottom_index = min(@top_index + LINES*COLUMNS-1, @item_max - 1)
      
      # Pour garder en mémoire les valeurs affichées par le texte
      @tag_drawn = Array.new(LINES * COLUMNS)
      
      # Rafraichissement
      update
      refresh
    end
   
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      super
      @tileset_sprite.bitmap.dispose
      @tileset_sprite.dispose
      @cursor_sprite.dispose
      @grid.dispose
      @progress_bar.bitmap.dispose
      @progress_bar.dispose
      @tileset_sprite = nil
      @cursor_sprite = nil
      @grid = nil
      @progress_bar = nil
    end
    
    #----------------------------------------------------
    # Mise à jour
    #----------------------------------------------------
    def update
      
      # Si la fenêtre est active
      if self.active and @item_max > 0
        if Input.repeat?(Input::RIGHT)
          if @index < @item_max - 1 and @index % COLUMNS != 7
            $game_system.se_play($data_system.cursor_se)
            @index = @index + 1
            cursor_refresh
            return
          end
        end
        
        if Input.repeat?(Input::LEFT)
          if @index > 0 and @index % COLUMNS != 0
            $game_system.se_play($data_system.cursor_se)
            @index = @index - 1
            cursor_refresh
            return
          end
        end
        
        if Input.repeat?(Input::DOWN)
          if @index + COLUMNS < @item_max
            $game_system.se_play($data_system.cursor_se)
            # Augmentation de l'index
            increase_index(COLUMNS)
            return
          end
        end
        
        if Input.repeat?(Input::UP)
          if @index >= COLUMNS
            $game_system.se_play($data_system.cursor_se)
            # Diminution de l'index
            decrease_index(COLUMNS)
            return
          end
        end
    
        if Input.repeat?(Input::R)
          if @index + COLUMNS < @item_max
            $game_system.se_play($data_system.cursor_se)
            # Augmentation de l'index
            increase_index(LINES * COLUMNS)
            return
          end
        end
        
        if Input.repeat?(Input::L)
          if @index >= COLUMNS
            $game_system.se_play($data_system.cursor_se)
            # Diminution de l'index
            decrease_index(LINES * COLUMNS)
            return
          end
        end
        
      end
    end
    
    #----------------------------------------------------
    # Gestion index, top_index, bottom_index
    #----------------------------------------------------
    def index
      return @index
    end
    
    def top_index
      return @top_index
    end
    
    def bottom_index
      return @bottom_index
    end
    
    # Placer l'index au niveau de top_index
    def index_ltop
      @index = @top_index
      cursor_refresh
    end
    
    # Placer l'index au niveau de bottom_index
    def index_rtop
      @index = @top_index + COLUMNS - 1
      cursor_refresh
    end
    
    # Réinitialiser l'index et les infos sur l'index
    def reset_index
      @item_max = (@tileset_sprite.bitmap.height / LH) * COLUMNS
      @index = 0
      @top_index = 0
      @bottom_index = min(@top_index+LINES*COLUMNS-1, @item_max-1)
    end
    
    # MAJ de @top_index et @bottom_index
    def update_top_bottom_index
      value = @index - @index % COLUMNS
      if value < @top_index
        @top_index = value
        @bottom_index = @top_index + LINES * COLUMNS - 1
      elsif value > @bottom_index
        @bottom_index = value + 7
        @top_index = @bottom_index - LINES * COLUMNS + 1
      end
    end
    
    def increase_index(val)
      # Augmentation de l'index
      @index += min(val, @item_max-1-@index)
      # Enregistrement de l'ancien bottom_index
      old_bottom = @bottom_index
      # MAJ de top_index et bottom_index
      update_top_bottom_index
      # Rafraichissement du curseur
      cursor_refresh
      # Si bottom_index a été modifié, on rafrachit le texte
      if old_bottom != @bottom_index
        text_refresh_all
        tileset_refresh
        progress_bar_refresh
      end
    end
    
    def decrease_index(val)
      # Diminution de l'index
      @index -= min(val, @index)
      # Enregistrement de l'ancien top_index
      old_top = @top_index
      # MAJ de top_index et bottom_index
      update_top_bottom_index
      # Rafraichissement le curseur
      cursor_refresh
      # Si top_index a été modifié, on rafraichit le texte
      if old_top != @top_index
        text_refresh_all
        tileset_refresh
        progress_bar_refresh
      end
    end
    
    #----------------------------------------------------
    # Gestion curseur
    #----------------------------------------------------
    def set_cursor_visible
      @cursor_sprite.visible = true
    end
    
    def set_cursor_invisible
      @cursor_sprite.visible = false
    end
    
    # Disparition/apparition suivant l'activation de fenêtre
    def active=(bool)
      super(bool)
      if bool then set_cursor_visible else set_cursor_invisible end
    end
    
    #----------------------------------------------------
    # Rafraichissement de la position du curseur
    #----------------------------------------------------
    def cursor_refresh
      @cursor_sprite.x = ((@index-@top_index)%COLUMNS)*CW + 221 + @cursor_sprite.ox
      @cursor_sprite.y = ((@index-@top_index)/COLUMNS)*LH + 40 + @cursor_sprite.oy
    end
    
    #----------------------------------------------------
    # Rafraichissement total
    #----------------------------------------------------
    def refresh
      cursor_refresh
      text_refresh_all
      tileset_refresh
      progress_bar_refresh
    end
    
    #----------------------------------------------------
    # Chargement du tileset
    #----------------------------------------------------
    def load_tileset(tileset_id)
      # Libération du bitmap de tileset_sprite
      tsbmp = @tileset_sprite.bitmap
      tsbmp.dispose if tsbmp
      
      # Chargement du tileset sans les autotiles
      unless $data_tilesets[tileset_id].tileset_name.empty?
        bitmap = RPG::Cache.tileset($data_tilesets[tileset_id].tileset_name)
        tsbmp = Bitmap.new(bitmap.width, bitmap.height + 32)
        src_rect = Rect.new(0, 0, bitmap.width, bitmap.height)
        tsbmp.blt(0, 32, bitmap, src_rect)
      else
        tsbmp = Bitmap.new(256, 32)
      end
      
      # Maj de la taille de terrain_tags et system_tags
      # Au cas où le tileset a été redimensionné
      new_tb_size = 384 + (tsbmp.height/LH-1) * (COLUMNS)
      @data_tags[tileset_id].terrain_tags.resize(new_tb_size)
      @data_tags[tileset_id].system_tags.resize(new_tb_size)

      # Chargement des autotiles
      $data_tilesets[tileset_id].autotile_names.each_with_index do |autotile_name, i|
        if autotile_name and !autotile_name.empty?
          bitmap = RPG::Cache.autotile(autotile_name)
          src_rect = Rect.new(0, 0, 32, 32)
          tsbmp.blt(32+32*i, 0, bitmap, src_rect)
        end
      end
      
      # Chargement du bitmap du sprite @tileset_sprite
      @tileset_sprite.bitmap = tsbmp
      @tileset_sprite.src_rect.set(0, 0, 256, LINES*LH)
    end
    
    #----------------------------------------------------
    # Rafraichissement tileset
    #----------------------------------------------------
    def tileset_refresh
      @tileset_sprite.src_rect.set(0, @top_index/COLUMNS*LH, 256, LINES*LH)
    end
    
    #----------------------------------------------------
    # Changement de tileset
    #----------------------------------------------------
    def change(tileset_id)
      @tileset_id = tileset_id
      load_tileset(tileset_id)
      reset_index
      cursor_refresh
      text_refresh_all
      progress_bar_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement de la barre de progression
    #----------------------------------------------------
    def progress_bar_refresh
      if @item_max > 0
        rect = Rect.new(0, 0, 8, 416)
        @progress_bar.bitmap.fill_rect(rect, Color.new(240,240,240,255))
        # taille curseur
        tail = max(416*LINES*COLUMNS/@item_max, 20)
        # Placement curseur
        rect = Rect.new(0, (416-tail)*@top_index/max(1,@item_max-COLUMNS*LINES), 8, tail)
        @progress_bar.bitmap.fill_rect(rect, Color.new(205,205,205,255))
      end
    end
    
    #----------------------------------------------------
    # Changement du mode (terrain ou system)
    #----------------------------------------------------
    def change_mode(mode)
      @mode = mode
    end
    
    #----------------------------------------------------
    # Chargement de la valeur du tag du tile sélectionné
    #----------------------------------------------------
    def load_tag(index)
      case @mode
      when :terrain
        if index < COLUMNS
          value = @data_tags[@tileset_id].terrain_tags[index*48]
        else
          value = @data_tags[@tileset_id].terrain_tags[384+index-COLUMNS]
        end
        return value
      when :system
        if index < COLUMNS
          value = @data_tags[@tileset_id].system_tags[index*48]
        else
          value = @data_tags[@tileset_id].system_tags[384+index-COLUMNS]
        end
        return value
      end
      return 0
    end
    
    #----------------------------------------------------
    # Modification du tag du tile sélectionné
    #----------------------------------------------------
    def change_tag(val = 1)
      case @mode
      when :terrain
        if @index < COLUMNS
          tag = @data_tags[@tileset_id].terrain_tags[@index*48]
          48.times do |i|
            @data_tags[@tileset_id].terrain_tags[@index*48+i] = (tag+val)%TAG_SYS::T_SIZE
          end
        else
          tag = @data_tags[@tileset_id].terrain_tags[384+@index-COLUMNS]
          @data_tags[@tileset_id].terrain_tags[384+@index-COLUMNS] = (tag+val)%TAG_SYS::T_SIZE
        end
      when :system
        if @index < COLUMNS
          tag = @data_tags[@tileset_id].system_tags[@index*48]
          48.times do |i|
            @data_tags[@tileset_id].system_tags[@index*48+i] = (tag+val)%TAG_SYS::T_SIZE
          end
        else
          tag = @data_tags[@tileset_id].system_tags[384+@index-COLUMNS]
          @data_tags[@tileset_id].system_tags[384+@index-COLUMNS] = (tag+val)%TAG_SYS::T_SIZE
        end
      end
      text_refresh_selected
    end
    
    #----------------------------------------------------
    # Rafraichissement total du texte
    #----------------------------------------------------
    def text_refresh_all
      @top_index.upto(@bottom_index) do |ind|
        draw_info(ind)
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement du texte associé à l'index
    #----------------------------------------------------
    def text_refresh_selected
      self.contents.font.color = white
      draw_info(@index)
    end
    
    #----------------------------------------------------
    # Effaçage du texte associé à l'index
    #----------------------------------------------------
    def clear_text(index)
      x = ((index - @top_index)%COLUMNS)*CW
      y = ((index - @top_index)/COLUMNS)*LH
      self.contents.fill_rect(x, y, CW, LH, Color.new(0, 0, 0, 0))
    end
    
    #----------------------------------------------------
    # Rafraichissement de la dernière ligne du text
    #----------------------------------------------------
    def text_refresh_last_line
      self.contents.font.color = white
      @bottom_index.downto(@bottom_index-7) do |ind|
        draw_info(ind)
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement de la première ligne du text
    #----------------------------------------------------
    def text_refresh_first_line
      self.contents.font.color = white
      @top_index.upto(@top_index+7) do |ind|
        draw_info(ind)
      end
    end
    
    #----------------------------------------------------
    # Décaler le texte d'une ligne vers le haut
    #----------------------------------------------------
    def text_move_up
      # On copie le text sauf la première ligne
      bitmap = Bitmap.new(self.contents.width, self.contents.height-32)
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
      bitmap = Bitmap.new(self.contents.width, self.contents.height-32)
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
    # Affichage de l'info associé à l'index
    #----------------------------------------------------
    def draw_info(index)
      # Position x
      x = ((index - @top_index)%COLUMNS)*CW
      # Position y
      y = ((index - @top_index)/COLUMNS)*LH
      
      # Valeur du Tag sélectionné
      value = load_tag(index)
      
      # Si la valeur affichée n'a pas besoin d'être changée
      return if value == @tag_drawn[index - @top_index]
      
      # Rafraichissement l'info affichée
      clear_text(index)
      self.contents.font.color = normal_color
      self.contents.draw_text(x+1, y+1, CW, LH, value.to_s,1)
      self.contents.font.color = white
      self.contents.draw_text(x, y, CW, LH, value.to_s,1)
      
      # MAJ @tag_drawn
      @tag_drawn[index - @top_index] = value
    end
    
    #----------------------------------------------------
    # Enregistrement des modifications dans $data_tilesets
    #----------------------------------------------------
    def save
      # Modification de $data_tilesets
      1.upto($data_tilesets.size - 1) do |i|
        $data_tilesets[i].terrain_tags = @data_tags[i].terrain_tags
        $data_tilesets[i].system_tags = @data_tags[i].system_tags
      end
    end
    
  end
  
end