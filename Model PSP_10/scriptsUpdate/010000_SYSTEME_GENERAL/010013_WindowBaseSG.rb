#==============================================================================
# ■ Window_Base
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène modifiable
#-----------------------------------------------------------------------------
class Window_Base < Window
  
  def normal_color
    return Color.new(60, 60, 60, 255)
  end
  
  def disabled_color
    return Color.new(60, 60, 60, 128)
  end
  
  def white
    return Color.new(255, 255, 255, 255)
  end
  
  def draw_text(x, y, w, h, string, align = 0, color = white)
    self.contents.font.color = Color.new(96,96,96,175)
    self.contents.draw_text(x, y, w, h, string, align)
    self.contents.font.color = color
    self.contents.draw_text(x, y, w, h, string, align)
  end
  
  def text_color(n)
    case n
    when 0
      return normal_color
    when 1
      return Color.new(128, 128, 255, 255)
    when 2
      return Color.new(255, 128, 128, 255)
    when 3
      return Color.new(128, 255, 128, 255)
    when 4
      return Color.new(128, 255, 255, 255)
    when 5
      return Color.new(255, 128, 255, 255)
    when 6
      return Color.new(255, 255, 128, 255)
    when 7
      return Color.new(192, 192, 192, 255)
    else
      normal_color
    end
  end
  
  #---------------------------------------------------
  # Remplissage optimisé des lignes d'un text
  # lines : nb de lignes, lim : nb max de pixel
  #---------------------------------------------------
  # ATTENTION : le bitmap contents doit être construit!
  #---------------------------------------------------
  def str_builder(txt, lines, lim = self.contents.width)
    # liste des mots constituant le texte
    words = txt.split
    # Liste des listes de mots constituant les lignes
    words_by_line = Array.new(lines){[""]}
    # taille de l'espace en pixels
    space_size =  self.contents.text_size(" ").width
    # indicateurs de taille et d'index
    s, i = 0, 0
    # Distribution des mots par lignes
    words.each do |w|
      s_plus = space_size + self.contents.text_size(w).width
      if s + s_plus > lim and i < lines - 1
        i += 1
        s = 0
      end
      s += s_plus
      words_by_line[i].push(w)
    end
    # Conversion des listes de mots en phrases
    return Array.new(lines){|i| words_by_line[i].join(" ")}
  end
  
end
