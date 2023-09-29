#==============================================================================
# ■ Window_Selectable
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Ajouts: 
#   thick/@height : défini la hauteur d'une ligne
#-----------------------------------------------------------------------------
class Window_Selectable < Window_Base
  def initialize(x, y, width, height, thick = 32)
    super(x, y, width, height)
    @item_max = 1
    @column_max = 1
    @index = -1
    @height = thick
  end
  
  def update_cursor_rect
    # Redéfinition
    if @index < 0
      self.cursor_rect.empty
      return
    end
    row = @index / @column_max
    if row < self.top_row
      self.top_row = row
    end
    if row > self.top_row + (self.page_row_max - 1)
      self.top_row = row - (self.page_row_max - 1)
    end
    # Modification pour la taille de la flèche:
    # cursor_width = self.width / @column_max - 32
    cursor_width = 32
    # Calculer les coordonnées du curseur
    x = - 12 + (@index % @column_max) * (self.width / @column_max)
    # Modification pour le déplacement de la flèche:
    y = @index / @column_max * @height + (@height - 32) / 2 - self.oy
    # Mettre à jour le rectangle du curseur
    self.cursor_rect.set(x, y, cursor_width, 32)
  end
  
  def page_row_max
    # Redéfinition
    # Nécessaire au Pokédex ?
    # Modification: return (self.height - 32) / 32
    return (self.height - 32) / @height
  end
  
  def top_row
    # Redéfinition
    # Nécessaire au Pokédex ?
    # Modification: return self.oy / 32    
    return self.oy / @height
  end
  
  def top_row=(row)
    # Redéfinition
    # Nécessaire au Pokédex ?
    # Si la ligne est inférieure à 0, fixez-la à 0
    if row < 0
      row = 0
    end
    # Si la ligne est supérieure à row_max-1, modifiez-la en row_max-1
    if row > row_max - 1
      row = row_max - 1
    end
    # Modification: self.oy = row * 32
    self.oy = row * @height
  end
end
