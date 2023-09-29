#==============================================================================
# ■ Pokemon_Window_Help
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Window_Help modifié
#-----------------------------------------------------------------------------

module POKEMON_S
  
  class Pokemon_Window_Help < Window_Base
    
    attr_reader :z_level
    attr_accessor :scroll
    
    #----------------------------------------------------
    # Initialisation
    #----------------------------------------------------
    def initialize
      # Propriétés générales
      super(21, 342, 597, 126)
      self.contents = Bitmap.new(width - 32, height - 32)
      self.contents.font.name = $fontface
      self.contents.font.size = $fontsize
      self.opacity = 0
      self.z = 9998
      @z_level = 9998
      
      # Cadre de la fenêtre
      @dummy = Sprite.new
      unless $message_dummy
        @dummy.bitmap = RPG::Cache.picture(MSG)
      else
        @dummy.bitmap = RPG::Cache.picture($message_dummy)
      end
      @dummy.visible = false
      @dummy.y = 336
      @dummy.z = 9997
      
      # Activation du défilement du texte
      @scroll = false
    end
    
    #----------------------------------------------------
    # Afficher un texte
    #----------------------------------------------------
    def draw_text(text, text_or_align = 0, is_align = 0)
      # Infos sur l'alignement
      if text_or_align.is_a?(Integer)
        align = text_or_align
      else
        align = is_align
      end
      
      # Si les paramètres sont inchangés
      if text == @text and text_or_align == @text_or_align and align == @align
        return
      end
      
      # MAJ paramètres
      @text = text
      @text_or_align = text_or_align
      @align = align
      
      # Si le texte est vide : fenêtre invisible
      if text == "" and text_or_align == ""
        self.contents.clear
        @dummy.visible = false
        self.visible = false
        return
      end
      
      # Affichage du cadre avant le texte
      @dummy.visible = true
      self.visible = true
      
      # Réinitialisation de self.contents
      self.contents.clear
      self.contents.font.color = normal_color
      
      # Affichage du texte
      unless text_or_align.is_a?(String)
        string = str_builder(text, 3, self.width - 40)
        return scrolling(string) if @scroll
        self.contents.draw_text(0, 0, self.width - 40, 32, string[0], align)
        self.contents.draw_text(0, 32, self.width - 40, 32, string[1], align)
        self.contents.draw_text(0, 64, self.width - 40, 32, string[2], align)
      else
        return scrolling([text, text_or_align, ""]) if @scroll
        self.contents.draw_text(0, 0, self.width - 40, 32, text, align)
        self.contents.draw_text(0, 32, self.width - 40, 32, text_or_align, align)
      end
      
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      @dummy.dispose
      @dummy = nil
      super
    end
    
    #----------------------------------------------------
    # Défilement du texte
    #----------------------------------------------------
    def scrolling(text)
      # Vitesse de défilement du texte
      speed_scrolling = $vit_txt
      speed_scrolling ||= SPEED_MSG
      
      # Indiquer si le défilement est en cours
      is_scrolling = true
      
      # Défilement
      3.times do |i|
        # Position du caractère à imprimer
        x = 0
        # Compteur pour vitesse défilement
        cpt = 0
        
        string = text[i].gsub(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      
        while (c = string.slice!(/./m))
          # Changement de couleur
          if c == "\001"
            string.sub!(/\[([0-9]+)\]/, "")
            color = $1.to_i
            if color >= 0 and color <= 7
              self.contents.font.color = self.text_color(color)
            end
            next
          end
          
          # Affichage progressif du texte : Forcément de gauche à droite
          self.contents.draw_text(x, 32*i, 40, 32, c, 0)
          
          # Gestion de l'affichage du défilement
          if is_scrolling
            Graphics.update if cpt % speed_scrolling == 0
            Input.update
            if Input.trigger?(Input::C) or Input.trigger?(Input::B)
              is_scrolling = false
            end
          end
          
          # MAj des indicateurs
          x += self.contents.text_size(c).width
          cpt += 1
        end
      end
    
    Graphics.update
    end
    
  end
end
