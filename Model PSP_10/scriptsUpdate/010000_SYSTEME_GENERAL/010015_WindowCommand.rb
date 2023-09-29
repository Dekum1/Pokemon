#==============================================================================  
# ■ Window_Message  
# Pokemon Script Project - Krosk   
# 18/07/07  
#-----------------------------------------------------------------------------  
# Scène à ne pas modifier de préférence  
#-----------------------------------------------------------------------------  
# Modifications portant sur la gestion de la fenêtre commande  
#   pour qu'elle supporte des colonnes, et des changements de taille  
#   de police.  
# Nécessaire au combat (fenêtre skill et menu)  
#  
# Introduit:  
#   @height : hauteur (largeur) d'une ligne  
#   @heightsize : hauteur du texte  
#   @column_max  
#-----------------------------------------------------------------------------        
class Window_Command < Window_Selectable  
  attr_reader :item_max  
  attr_reader :commands  
  
  def initialize(width, commands, size = $fontsize, column = 1, height = nil)
    # Calculez la hauteur de la fenêtre à partir du nombre de commandes
    if size == $fontsize
      @heightsize = 32
    elsif size == $fontsizebig
      @heightsize = 43
    else
      @heightsize = 32
    end
    if height != nil
      @height = height
    else
      @height = @heightsize
    end
    
    csize = commands.size / column + min(1, commands.size % column)
    super(0, 0, width, csize * @height + 32, @height)
    
    @item_max = commands.size
    @commands = commands
    @column_max = column
    
    self.contents = Bitmap.new(width, @item_max * @height)
    self.contents.font.name = $fontface
    self.contents.font.size = size
    self.contents.font.color = normal_color
    
    refresh
    
    self.index = 0
  end
  
  def refresh
    self.contents.clear
    for i in 0...@item_max
      draw_item(i, self.contents.font.color)
    end
  end
  
  def draw_item(index, color = normal_color)
    list_cs = ["COUPE","VOL","SURF","FORCE","FLASH","ECLATE-ROC","CASCADE","PLONGEE", "ESCALADE"]
    if index >= 0 and not list_cs.include?(@commands[(index - 1)])
      self.contents.font.color = color
    else
      self.contents.font.color = normal_color
    end
    
    # Modification pour le tracé du texte
    rect = Rect.new(4 + 8 + (index % @column_max) * (width/@column_max), 
                    @height * (index/@column_max) + (@height-@heightsize)/2, 
                    self.contents.width/@column_max, 
                    @heightsize)
    self.contents.fill_rect(rect, Color.new(0, 0, 0, 0))
    self.contents.draw_text(rect, @commands[index])
    
    if list_cs.include?(@commands[index])
      self.contents.font.color = Color.new(64,144,208,255)  
      self.contents.draw_text(rect, @commands[index])  
    end
  end
  
  def enable_item(index)
    # Nouvelle fonction
    draw_item(index, normal_color)
  end
end