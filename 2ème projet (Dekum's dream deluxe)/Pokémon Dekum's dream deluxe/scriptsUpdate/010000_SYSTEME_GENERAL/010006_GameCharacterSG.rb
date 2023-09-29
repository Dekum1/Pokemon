#==============================================================================
# ■ Game_Character
# Pokemon Script Project - Krosk 
# 10/11/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
class Game_Character
  def passable?(x, y, d)
    # Trouver de nouvelles coordonnées
    new_x = x + (d == 6 ? 1 : d == 4 ? -1 : 0)
    new_y = y + (d == 2 ? 1 : d == 8 ? -1 : 0)
    # Si les coordonnées sont en dehors de la carte
    unless $game_map.valid?(new_x, new_y)
      # Impraticable
      return false
    end
    # Lorsque le glissement est activé
    if @through
      # Autorisé
      return true
    end
    # Si vous ne pouvez pas vous déplacer dans la direction spécifiée à 
    # partir de la tuile source
    unless $game_map.passable?(x, y, d, self)
      # Impraticable
      return false
    end
    # Si vous ne pouvez pas saisir la vignette de destination à partir de 
    # la direction spécifiée
    unless $game_map.passable?(new_x, new_y, 10 - d, self)
      # Impraticable
      return false
    end
    # Boucle de tous les événements
    $game_map.events.values.each do |event|
      # Lorsque les coordonnées de l'événement correspondent à la destination
      if event.x == new_x and event.y == new_y
        # Si le glissement est désactivé
        unless event.through
          # Si vous êtes un événement
          if self != $game_player
            # Impraticable
            return false
          end
          # Si vous êtes un joueur et que le graphique de votre adversaire est 
          # un personnage
          if event.character_name != ""
            # Impraticable
            return false
          end
        end
      end
    end
    # Lorsque les coordonnées du joueur correspondent à la destination
    if $game_player.x == new_x and $game_player.y == new_y
      # Si le glissement est désactivé
      unless $game_player.through
        # Si votre graphique est un personnage
        if @character_name != ""
          # Impraticable
          return false
        end
      end
    end
    # Autorisé
    return true
  end
end
# Implémentation Surf