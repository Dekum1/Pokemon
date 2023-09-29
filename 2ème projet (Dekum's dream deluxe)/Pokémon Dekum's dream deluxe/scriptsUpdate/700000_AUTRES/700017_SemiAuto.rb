#===============================================================================
#Déplacements Semi-Auto
#-------------------------------------------------------------------------------
#Réalisé par Metaiko
#Version 1.1
#Le 15/06/2019
# semi_auto_180(X,Y,pas) -> Rotation à 180 degré par exemple
# semi_auto(X,Y,pas) -> déplacement classique
# Plage du nombre de pas en avant d'affilée
# Nombre de pas minimum que l'événement pourra enchainer
# pas (Optionnel) : pas entre chaque déplacements en avant (Si le nombre 
# minimum de pas est de 7 avec un pas est de 2, l'event de déplacera de 7 
# ou 9 ou 11 ou 13 etc. cases avant de changer de direction)
#===============================================================================
class Game_Character
  def semi_auto(ecart_pas,pas_min,pas=1)
    @ecart_pas = ecart_pas
    @pas_min = pas_min
    @pas = pas
    @liste_pas = []
    @pas_min.step(@pas_min + @ecart_pas-1, @pas) do |i|
      @liste_pas.push(i)
    end
    @nb_pas = rand(@liste_pas.length)
    turn_right_or_left_90
    1.upto(@nb_pas) { |i| move_forward }
  end
   
  def semi_auto_180(ecart_pas,pas_min,pas=1)
    @ecart_pas = ecart_pas
    @pas_min = pas_min
    @pas = pas
    @liste_pas = []
    @pas_min.step(@pas_min + @ecart_pas-1, @pas) do |i|
      @liste_pas.push(i)
    end
    @nb_pas = rand(@liste_pas.length)
    @turn_dir = rand(3)
    case @turn_dir
    when 0
      turn_left_90
    when 1
      turn_right_90
    when 2
      turn_180
    end
    1.upto(@liste_pas[@nb_pas]) { |i| move_forward }
  end
end