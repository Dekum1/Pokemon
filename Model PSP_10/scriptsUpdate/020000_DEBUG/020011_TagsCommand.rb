#===============================================================================
# Menu d'édition des tags - G!n0
#-------------------------------------------------------------------------------
# Fenêtre des commandes
#===============================================================================

module TAG_SYS
  
  class Tags_Command < Window_Base
    
    #----------------------------------------------------
    # Les Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FS_BIG = 24
    
    #----------------------------------------------------
    # Initialisation
    #----------------------------------------------------
    def initialize
      super(490,80,148,384)
      
      self.contents = Bitmap.new(148-32,384-32)
      self.contents.font.name = FONTFACE
      self.contents.font.size = FS_BIG

      self.opacity = 0
      
      @index = 0
      @cpt_cursor = 0
      
      # Sprite curseur
      @cursor_sprite = Sprite.new
      @cursor_sprite.bitmap = RPG::Cache.picture(DATA_TAG_EDITOR[:cursor])
      @cursor_sprite.x = 491
      @cursor_sprite.y = 32 + 78
      @cursor_sprite.z = self.z + 10
      
      refresh
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      super
      @cursor_sprite.dispose
      @cursor_sprite = nil
    end
    
    #----------------------------------------------------
    # Misa à jour
    #----------------------------------------------------
    def update
      # Animation du curseur
      cursor_animation
      
      if self.active
        if Input.repeat?(Input::DOWN)
          @index = (@index+1)%4
          cursor_refresh
          return
        end
        if Input.repeat?(Input::UP)
          @index = (@index-1)%4
          cursor_refresh
          return
        end
      end
    end
    
    #----------------------------------------------------
    # Récupérer l'index
    #----------------------------------------------------
    def index
      return @index
    end
    
    #----------------------------------------------------
    # Rafraichissement du text
    #----------------------------------------------------
    def refresh
      self.contents.clear
      if @index == 0
        self.contents.font.color = Color.new(255, 64, 64, 255)
        self.contents.draw_text(0,0,146-32,46,"Terrains",1)
        self.contents.font.color = normal_color
        self.contents.draw_text(0,64,146-32,46,"Systèmes",1)
      elsif @index == 1
        self.contents.font.color = normal_color
        self.contents.draw_text(0,0,146-32,46,"Terrains",1)
        self.contents.font.color = Color.new(255, 64, 64, 255)
        self.contents.draw_text(0,64,146-32,46,"Systèmes",1)
        self.contents.font.color = normal_color
      end
      self.contents.draw_text(0,240,146-32,46,"OK",1)
      self.contents.draw_text(0,304,146-32,46,"Annuler",1)
    end
    
    #----------------------------------------------------
    # Rafraichissement du curseur
    #----------------------------------------------------
    def cursor_refresh
      if @index < 2
        @cursor_sprite.y = 78+@index*64 + 32
      else
        @cursor_sprite.y = 318+(@index-2)*64 + 32
      end
    end
    
    #----------------------------------------------------
    # Animation du curseur
    #----------------------------------------------------
    def cursor_animation
      if @cursor_sprite.visible
        val = 0.10471976 #pi/30
        @cpt_cursor = (@cpt_cursor+1)%30
        @cursor_sprite.x = 490 + Integer(5*Math.sin(val*(@cpt_cursor)))
      end
    end
    
    #----------------------------------------------------
    # Gestion de la visibilité du curseur
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
    
  end
end