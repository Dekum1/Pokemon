#==============================================================================
# ■ Pokemon_Pokedex
# Pokemon Script Project - Krosk
# 18/07/07
# 07/09/08 - révision v0.7, Pokédex de Shaolan (PSP4G) simplifié et optimisé
#             (crédits : Shaolan, Slash)
# 03/01/09 - révision
#-----------------------------------------------------------------------------
# Révision - G!n0 
# 15/08/2020
#    - Optimisation (réduction du temps d'attente lors du lancement du pokedex)
#    - Tri du pokedex (alphabétique, par taille, par poids)
# Damien Linux - 12/09/2020 => Correction tri par poids
#-----------------------------------------------------------------------------
# Scène modifiable
#-----------------------------------------------------------------------------

module POKEMON_S
  
  class Pokemon_List < Window_Base

    #----------------------------------------------------
    # Les Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FONTSIZE = 24
    LH = 50 # Hauteur d'une ligne
    LINES = 7 # Nombre de lignes visibles
    
    #----------------------------------------------------
    # Initialisation
    # id_list liste des pokémons vu/attrapés
    #----------------------------------------------------
    def initialize(id_list = [], menu_index = 0)
      super(329-16, 65-16, 310+32, LH*LINES+32)
      self.opacity = 0
      
      # Liste triée des Pokémon
      @id_list = id_list

      # Dernier vu de la liste
      @last = id_list[-1]
      value = id_list.size
      unless value
        value = 1
        @last = 1
      end
      
      # Infos pour index
      @item_max = value
      @index = menu_index
      
      # Effet de mouvement
      @cpt_cursor = 0
      
      # Initialisation du bitmap contents
      self.contents = Bitmap.new(width - 32, (height + 2 * LH)-32)
      self.oy = LH
      self.contents.font.name = FONTFACE
      self.contents.font.size = FONTSIZE
      
      # Barre de progression de la liste
      @progress_bar = Sprite.new
      @progress_bar.bitmap = Bitmap.new(4,332)
      @progress_bar.x = 628
      @progress_bar.y = 74
      @progress_bar.z = 4
      
      # Sprite Barre selection
      @selection_sprite = Sprite.new
      @selection_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:selection])
      @selection_sprite.x = 331
      @selection_sprite.y = 219
      @selection_sprite.z = 2
      
      # Sprite curseur
      @cursor_sprite = Sprite.new
      @cursor_sprite.bitmap = RPG::Cache.picture(DATA_PKDX[:intro_curseur])
      @cursor_sprite.x = 310 #331-21
      @cursor_sprite.y = 219+8
      @cursor_sprite.z = 4
      
      # Sprite du Pokémon sélectionné
      @sprite_pokemon = Sprite.new
      @sprite_pokemon.z = 4
      @sprite_pokemon.x = 77
      @sprite_pokemon.y = 160
      
      # Rafraichissement
      update
      refresh
    end
   
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      super
      @progress_bar.bitmap.dispose
      @progress_bar.dispose
      @selection_sprite.dispose
      @cursor_sprite.dispose
      @sprite_pokemon.dispose
    end
    
    #----------------------------------------------------
    # Mise à jour
    #----------------------------------------------------
    def update
      # Animation du curseur
      cursor_animation
      
      # Si la fenêtre est active
      if self.active and @item_max > 0 and @index >= 0
        
        # Un déplacement vers le bas
        if Input.repeat?(Input::DOWN)
          if Input.trigger?(Input::DOWN) or @index < @item_max - 1
            $game_system.se_play($data_system.cursor_se)
            index_move_down
            return
          end
        end
        
        # Un déplacement vers le haut
        if Input.repeat?(Input::UP)
          if Input.trigger?(Input::UP) or @index >= 1
            $game_system.se_play($data_system.cursor_se)
            index_move_up
            return
          end
        end
        
        # Saut vers le bas
        if Input.repeat?(Input::RIGHT)
          if @index < @item_max - LINES
            $game_system.se_play($data_system.cursor_se)
            @index = (@index + LINES) % @item_max
            refresh
          elsif @index < @item_max-1
            $game_system.se_play($data_system.cursor_se)
            @index = @item_max - 1
            refresh
          end
          return
        end
        
        # Saut vers le haut
        if Input.repeat?(Input::LEFT)
          if @index >= LINES
            $game_system.se_play($data_system.cursor_se)
            @index = (@index - LINES) % @item_max
            refresh
          elsif @index > 0
            $game_system.se_play($data_system.cursor_se)
            @index = 0
            refresh
          end
          return
        end
      end
      
    end
    
    #----------------------------------------------------
    # Effets de Défilement
    #----------------------------------------------------
    # Vers le bas
    def flag_down
      self.oy += LH / 2
      Graphics.update
      self.oy = LH
    end
    
    # Vers le haut
    def flag_up
      self.oy -= LH / 2
      Graphics.update
      self.oy = LH
    end
    
    #----------------------------------------------------
    # Infos position index
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
        return min(LINES-1,@item_max - 1)
      end
      return min(@index + mid, @item_max - 1)
    end
    
    #----------------------------------------------------
    # Augmenter une fois l'index
    #----------------------------------------------------
    def index_move_down
      # Enregistrement de l'ancien top_index
      old_top = top_index
      # Augmentation de l'index et rafraichissement du curseur
      @index = (@index + 1) % @item_max
      new_top = top_index
      # Rafraichissement texte, sprites et progress_bar si top_index a changé
      if new_top != old_top
        # Rafraichissement total si retour au début de la liste
        return refresh if new_top == 0
        # Rafraichissement partiel pour déplacement vers le bas
        return move_down_refresh
      end
      # Rafraichissement lorsque top index est inchangé
      static_down_refresh
    end
    
    #----------------------------------------------------
    # Diminuer une fois l'index
    #----------------------------------------------------
    def index_move_up
      # Enregistrement de l'ancien bottom_index
      old_bottom = bottom_index
      # Diminution de l'index et rafraichissement du curseur
      @index = (@index - 1) % @item_max
      new_bottom = bottom_index
      # Rafraichissement texte, sprites et progress_bar si top_index a changé
      if new_bottom != old_bottom
        # Rafraichissement total si on se retrouve en fin de la liste
        return refresh if new_bottom == @item_max - 1
        # Rafraichissement partiel pour déplacement vers le bas
        return move_up_refresh
      end
      # Rafraichissement lorsque top index est inchangé
      static_up_refresh
    end
    
    #----------------------------------------------------
    # Animation du curseur
    #----------------------------------------------------
    def cursor_animation
      if @cursor_sprite.visible
        val = 0.10471976 #pi/30
        @cpt_cursor = (@cpt_cursor+1)%30
        @cursor_sprite.x = 310 + Integer(10*Math.sin(val*(@cpt_cursor)))
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
      if bool then set_cursor_visible else set_cursor_invisible end
    end
    
    #----------------------------------------------------
    # Rafraichissement total des sprites et du texte
    #----------------------------------------------------
    def refresh
      text_refresh
      sprite_pokemon_refresh
      selection_refresh
      progress_bar_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement partiel pour les déplacements
    # vers le bas avec effet de défilement
    #----------------------------------------------------
    def move_down_refresh
      # Effet de défilement vers le bas
      flag_down
      # Déplacement du text vers le haut
      text_move_up
      # Rafraichissements sprites
      sprite_pokemon_refresh
      selection_refresh
      progress_bar_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement partiel pour les déplacements
    # vers le haut avec effet de défilement
    #----------------------------------------------------
    def move_up_refresh
      # Effet de défilement vers le bas
      flag_up
      # Déplacement du text vers le bas
      text_move_down
      # Rafraichissements sprites
      sprite_pokemon_refresh
      selection_refresh
      progress_bar_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement quand l'index augmente sans
    # qu'il y ait un mouvement du texte
    #----------------------------------------------------
    def static_down_refresh
      draw_line(@index-1) if (@index-1) >= 0
      draw_line(@index)
      selection_refresh
      sprite_pokemon_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement quand l'index diminue sans
    # qu'il y ait un mouvement du texte
    #----------------------------------------------------
    def static_up_refresh
      draw_line(@index)
      draw_line(@index+1) if @id_list.size > (@index+1)
      selection_refresh
      sprite_pokemon_refresh
    end
    
    #----------------------------------------------------
    # Rafraichissement du curseur de sélection
    #----------------------------------------------------
    def selection_refresh
      @selection_sprite.y = ((@index - self.top_index))*LH + 69
      @cursor_sprite.y = ((@index - self.top_index))*LH + 69 + 8
    end
    
    #----------------------------------------------------
    # Rafraichissement du Sprite du Pokémon
    #----------------------------------------------------
    def sprite_pokemon_refresh
      #si pkmn vu
      if @id_list.length != 0
        if $pokedex.seen?(@id_list[@index % @id_list.length])
          @sprite_pokemon.bitmap = RPG::Cache.battler("Front_Male/#{sprintf('%03d', @id_list[@index%@id_list.length])}.png", 0)
        else
          @sprite_pokemon.bitmap = RPG::Cache.battler("Front_Male/000.png", 0)
        end
      else
        $game_system.se_play($data_system.buzzer_se)
      end
    end
   
    #----------------------------------------------------
    # Rafraichissement de la barre de progression de la liste
    #----------------------------------------------------
    def progress_bar_refresh
      if @item_max > 0
        @progress_bar.bitmap.fill_rect(0, 0, 4, 332, Color.new(145, 2, 2,235))
        # taille curseur
        tail = max(332*LINES/@item_max, 20)
        # Placement curseur
        rect = Rect.new(0, (332-tail)*top_index/max(1,@item_max-LINES), 4, tail)
        @progress_bar.bitmap.fill_rect(rect, Color.new(240, 80, 30,210))
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement total du text
    #----------------------------------------------------
    def text_refresh
      self.contents.font.color = normal_color
      top = top_index
      bottom = bottom_index
      if @item_max > LINES
        draw_line((top-1)%@item_max)
        draw_line((bottom+1)%@item_max)
      end
      (top).upto(bottom) do |ind|
      draw_line(ind)
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement de la première ligne du text
    #----------------------------------------------------
    def text_refresh_first_line
      top = top_index
      self.contents.font.color = normal_color
      draw_line(top-1) if top > 0
    end
    
    #----------------------------------------------------
    # Rafraichissement de la dernière ligne du text
    #----------------------------------------------------
    def text_refresh_last_line
      bottom = bottom_index
      self.contents.font.color = normal_color
      draw_line(bottom+1) if bottom < @item_max - 1
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
      # Correction du coloriage de sélection
      draw_line(@index-1)
      draw_line(@index)
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
      # Correction du coloriage de sélection
      draw_line(@index)
      draw_line(@index+1)
      # Rafraichissement de la première ligne
      text_refresh_first_line
    end
    
    #----------------------------------------------------
    # Effaçage d'une ligne
    #----------------------------------------------------
    def clear_line(ind)
      y = LH * (ind - top_index) + self.oy
      self.contents.fill_rect(0, y, self.width, LH, Color.new(0,0,0,0))
    end
    
    #----------------------------------------------------
    # Affichage d'une ligne
    #----------------------------------------------------
    def draw_line(ind)
      # Effaçage de la ligne
      clear_line(ind)
      # Déterminer si ind correspond à la ligne sélectionnée
      select = 0
      if ind == @index
        self.contents.font.color = white
        select = 1
      end
      # Id du Pokémon
      value = @id_list[ind]
      # Position y dans self.contents
      y = LH * (ind - top_index) + self.oy
      # Numéro suivant le mode national ou régional
      draw_number(y, value)
      # Nom et infos de caputre
      draw_info(y, value, select)
      # Retour à la couleur normale du texte
      if ind == @index
        self.contents.font.color = normal_color
        select = 1
      end
    end
    
    #----------------------------------------------------
    # Tracer le numéro du Pokémon
    #----------------------------------------------------
    def draw_number(y, value)
      if $pokedex.regional
        string = "  N°#{sprintf('%03d',Pokemon_Info.id_bis(value))}"
      else
        string = "  N°#{sprintf('%03d',value)}"
      end
      self.contents.draw_text(10+32, y, 480, LH, string)
    end
    
    #----------------------------------------------------
    # Tracer le nom et les infos de capture d'un Pokémon
    #----------------------------------------------------
    def draw_info(y, value, select)
      if $pokedex.seen?(value)
        # Icône du Pokémon
        src_rect = Rect.new(0, 0, 64, 64)
        bitmap = RPG::Cache.battler("#{sprintf("Icon/%03d",value)}", 0) 
        dest_rect = Rect.new(10, y + 9, bitmap.width / 2, bitmap.height / 2)
        self.contents.stretch_blt(dest_rect, bitmap, src_rect, 255)
        # Nom du Pokémon
        self.contents.draw_text(90+32, y, 300, LH, Pokemon_Info.name(value))
        # Apparence ball suivant les cas attrapé/vu
        bitmap = RPG::Cache.picture(DATA_PKDX[:pokemon_capture])
        if $pokedex.captured?(value)
          self.contents.blt(230+32, y + 15, bitmap, Rect.new(0, 20*select, 20, 20))
        else
          self.contents.blt(230+32, y + 15, bitmap, Rect.new(0, 40+20*select, 20, 20))
        end
      # Si le Pokémon n'a pas été vu
      else
        self.contents.draw_text(90+32, y, 300, LH, "-------")
      end
    end
    
  end
end