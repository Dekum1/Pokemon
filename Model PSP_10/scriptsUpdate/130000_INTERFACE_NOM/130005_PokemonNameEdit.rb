#==============================================================================
# ■ Pokemon_NameEdit
# Pokemon Script Project - Krosk 
# 17/08/07
# Amélioré par Damien Linux - 02/02/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_NameEdit < Window_Base

    attr_reader   :name                     # Nom
    attr_reader   :index                    # Position du curseur
    attr_reader   :max_char

    def initialize(actor, string, pokemon = true, max_char = 10)
      super(99, 27, 442, 114)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = $fontface
      self.contents.font.size = $fontsizebig
      self.contents.font.color = normal_color
      self.opacity = 0
      @string = string
      if actor.is_a?(String)
        @actor = nil
        @name = actor
      elsif pokemon
        @pokemon = actor
        @name = actor.given_name
      else
        @actor = actor
        @name = actor.name
      end
      @max_char = max_char # Nombre de caractères maximal à saisir
      name_array = @name.split(//)[0...@max_char]
      
      @name = ""
      
      for i in 0...name_array.size
        @name += name_array[i]
      end
      
      if pokemon
        if @pokemon.given_name.size >= 10
          @name = @pokemon.given_name[0..10]
        else
          @name = @pokemon.given_name[0...@pokemon.given_name.size]
        end
      
        if @pokemon.name.size >= 10
          @default_name = @pokemon.name[0..10]
        else
          @default_name = @pokemon.name[0...@pokemon.name.size]
        end
      else
        @default_name = @name
      end
      
      @index = name_array.size
      
      refresh
      update_cursor_rect
    end

    def restore_default
      @name = @default_name
      @index = @name.split(//).size
      refresh
      update_cursor_rect
    end
    #--------------------------------------------------------------------------
    # ● Ajout de caractères
    #     character : La chaîne à ajouter
    #     size : La taille de la chaîne (1 ou 2 si : ^w par exemple)
    #--------------------------------------------------------------------------
    def add(character, size)
      length = @index + character.size - character.size
      if length < @max_char and character != ""
        @name += character
        size = 1 if size > 1
        @index += size
        $game_system.se_play($data_system.decision_se)
        refresh
        update_cursor_rect
      elsif length >= @max_char
        $game_system.se_play($data_system.buzzer_se)
      end
    end
    #--------------------------------------------------------------------------
    # ● Supprimer des caractères
    #--------------------------------------------------------------------------
    def back
      if @index > 0
        # Supprimer un caractère
        name_array = @name.split(//)
        @name = ""
        for i in 0...name_array.size-1
          @name += name_array[i]
        end
        @index -= 1
        refresh
        update_cursor_rect
      end
    end
    #--------------------------------------------------------------------------
    # ● Rafraîchir
    #--------------------------------------------------------------------------
    def refresh
      self.contents.clear
      
      name_array = @name.split(//)
      for i in 0...@max_char
        c = name_array[i]
        if c == nil
          c = "_"
        end
        x = 203.5 - (@max_char * 10.5) + (i * 21)
        draw_text(x, 33, 24, 44, c, 1, normal_color)
      end
      
      self.contents.font.size = $fontsize
      self.contents.draw_text(0, 0, 410, $fontsizebig, @string, 1)
      self.contents.font.size = $fontsizebig
     
      src_rect = Rect.new(0, 0, 64, 64)
      if @pokemon != nil
        bitmap = RPG::Cache.battler(@pokemon.icon, 0)
        self.contents.blt(12, 3, bitmap, src_rect, 255)
      elsif @actor != nil
        bitmap = RPG::Cache.character(@actor.character_name, @actor.character_hue)
        cw = bitmap.width / 4
        ch = bitmap.height / 4
        src_rect = Rect.new(0, 0, cw, ch)
        self.contents.blt(20, 0, bitmap, src_rect, 255)
      end
    end
    #--------------------------------------------------------------------------
    # ● Mettre à jour la forme du curseur
    #--------------------------------------------------------------------------
    def update_cursor_rect
      x = 196.5 - (@max_char * 10.5) + (@index * 21)
      self.cursor_rect.set(x, 40, 32, 32)
    end
    #--------------------------------------------------------------------------
    # ● Mise à jour du cadre
    #--------------------------------------------------------------------------
    def update
      super
      update_cursor_rect
    end
  end
end