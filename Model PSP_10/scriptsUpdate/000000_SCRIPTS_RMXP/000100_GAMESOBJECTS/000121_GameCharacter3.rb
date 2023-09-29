#==============================================================================
# ■ Game_Character (Définition fractionnée 3)
#------------------------------------------------------------------------------
# 　Cette classe traite des personnages. Cette classe est la classe Game_Player 
#  et Game_Event. Utilisé comme super-classe de la classe.
#==============================================================================

class Game_Character
  #--------------------------------------------------------------------------
  # ● Descendre
  #     turn_enabled : Drapeau pour permettre le changement d'orientation à la volée
  #--------------------------------------------------------------------------
  def move_down(turn_enabled = true)
     # Regarde en bas
    if turn_enabled
      turn_down
    end
    # Quand tu peux passer
    if passable?(@x, @y, 2)
      # Regarde en bas
      turn_down
      # Mettre à jour les coordonnées
      @y += 1
      # Augmentation des étapes
      increase_steps
    # Quand le passage est impossible
    else
    # Jugement d'activation de l'événement de contact
      check_event_trigger_touch(@x, @y+1)
    end
  end
  
  #--------------------------------------------------------------------------
  # ● Déplacer vers la gauche
  #     turn_enabled : Drapeau pour permettre le changement d'orientation à la volée
  #--------------------------------------------------------------------------
  def move_left(turn_enabled = true)
    # Tourner à gauche
    if turn_enabled
      turn_left
    end
    # Quand tu peux passer
    if passable?(@x, @y, 4)
      # 左を向く
      turn_left
      # Mettre à jour les coordonnées
      @x -= 1
      # Augmentation des étapes
      increase_steps
    # Quand le passage est impossible
    else
      # Jugement d'activation de l'événement de contact
      check_event_trigger_touch(@x-1, @y)
    end
  end
  #--------------------------------------------------------------------------
  # ● Déplacer vers la droite
  #     turn_enabled : Drapeau pour permettre le changement d'orientation à la volée
  #--------------------------------------------------------------------------
  def move_right(turn_enabled = true)
    # Tourner à droite
    if turn_enabled
      turn_right
    end
    # Quand tu peux passer
    if passable?(@x, @y, 6)
      # 右を向く
      turn_right
      # Mettre à jour les coordonnées
      @x += 1
      # Augmentation des étapes
      increase_steps
    # Quand le passage est impossible
    else
      # Jugement d'activation de l'événement de contact
      check_event_trigger_touch(@x+1, @y)
    end
  end
  #--------------------------------------------------------------------------
  # ● Monter
  #     turn_enabled : Drapeau pour permettre le changement d'orientation à la volée
  #--------------------------------------------------------------------------
  def move_up(turn_enabled = true)
    # Montez
    if turn_enabled
      turn_up
    end
    # Quand tu peux passer
    if passable?(@x, @y, 8)
      # Montez
      turn_up
      # Mettre à jour les coordonnées
      @y -= 1
      # Augmentation des étapes
      increase_steps
    # Quand le passage est impossible
    else
      # Jugement d'activation de l'événement de contact
      check_event_trigger_touch(@x, @y-1)
    end
  end
  #--------------------------------------------------------------------------
  # ● Déplacer en bas à gauche
  #--------------------------------------------------------------------------
  def move_lower_left
    # Lorsque l'orientation n'est pas fixe
    unless @direction_fix
      # Si vous êtes face à droite, tournez à gauche; 
      # si vous pointez vers le haut, tournez vers le bas
      @direction = (@direction == 6 ? 4 : @direction == 8 ? 2 : @direction)
    end
    # Si le parcours est soit vers le bas → gauche ou gauche → bas
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 2))
      # Mettre à jour les coordonnées
      @x -= 1
      @y += 1
      # Augmentation des étapes
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● Descendre à droite
  #--------------------------------------------------------------------------
  def move_lower_right
    # Lorsque l'orientation n'est pas fixe
    unless @direction_fix
      # Si vous faites face à gauche, tournez à droite, 
      # si vous tournez vers le haut, tournez vers le bas
      @direction = (@direction == 4 ? 6 : @direction == 8 ? 2 : @direction)
    end
    # Si vous pouvez passer soit en bas → à droite ou à droite → en bas
    if (passable?(@x, @y, 2) and passable?(@x, @y + 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 2))
      # Mettre à jour les coordonnées
      @x += 1
      @y += 1
      # Augmentation des étapes
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● Déplacer vers le haut à gauche
  #--------------------------------------------------------------------------
  def move_upper_left
    # Lorsque l'orientation n'est pas fixe
    unless @direction_fix
      # Tournez à gauche si vous faites face à droite ou 
      # vers le haut si vous êtes face à vous
      @direction = (@direction == 6 ? 4 : @direction == 2 ? 8 : @direction)
    end
    # Si vous pouvez passer le cap supérieur → gauche ou gauche → supérieur
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 4)) or
       (passable?(@x, @y, 4) and passable?(@x - 1, @y, 8))
      # Mettre à jour les coordonnées
      @x -= 1
      @y -= 1
      # Augmentation des étapes
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● Déplacer vers le haut à droite
  #--------------------------------------------------------------------------
  def move_upper_right
    # Lorsque l'orientation n'est pas fixe
    unless @direction_fix
      # Si vous faites face à gauche, tournez à droite, 
      # si vous tournez vers le bas, montez
      @direction = (@direction == 4 ? 6 : @direction == 2 ? 8 : @direction)
    end
    # Si vous pouvez passer le cap supérieur → droit ou droit → supérieur
    if (passable?(@x, @y, 8) and passable?(@x, @y - 1, 6)) or
       (passable?(@x, @y, 6) and passable?(@x + 1, @y, 8))
      # Mettre à jour les coordonnées
      @x += 1
      @y -= 1
      # Augmentation des étapes
      increase_steps
    end
  end
  #--------------------------------------------------------------------------
  # ● Déplacer au hasard
  #--------------------------------------------------------------------------
  def move_random
    case rand(4)
    when 0  # Descendre
      move_down(false)
    when 1  # Déplacer vers la gauche
      move_left(false)
    when 2  # Déplacer vers la droite
      move_right(false)
    when 3  # Monter
      move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● Rapprochez-vous des joueurs
  #--------------------------------------------------------------------------
  def move_toward_player
    # Trouvez les différences à partir des coordonnées du joueur
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Si les coordonnées sont égales
    if sx == 0 and sy == 0
      return
    end
    # Trouver la valeur absolue de la différence
    abs_sx = sx.abs
    abs_sy = sy.abs
    # Lorsque la distance horizontale est égale à la distance verticale
    if abs_sx == abs_sy
      # Incrémenter l'un au hasard
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # Lorsque la distance horizontale est plus longue
    if abs_sx > abs_sy
      # Déplacez-vous dans la direction où se trouve le joueur, 
      # en donnant la priorité aux directions gauche et droite
      sx > 0 ? move_left : move_right
      if not moving? and sy != 0
        sy > 0 ? move_up : move_down
      end
    # Lorsque la distance verticale est plus longue
    else
      # Priorisez de haut en bas, déplacez-vous là où se trouve le joueur
      sy > 0 ? move_up : move_down
      if not moving? and sx != 0
        sx > 0 ? move_left : move_right
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Restez à l'écart des joueurs
  #--------------------------------------------------------------------------
  def move_away_from_player
    # Trouvez les différences à partir des coordonnées du joueur
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Si les coordonnées sont égales
    if sx == 0 and sy == 0
      return
    end
    # Trouver la valeur absolue de la différence
    abs_sx = sx.abs
    abs_sy = sy.abs
    # Lorsque la distance horizontale est égale à la distance verticale
    if abs_sx == abs_sy
      # Incrémenter l'un au hasard
      rand(2) == 0 ? abs_sx += 1 : abs_sy += 1
    end
    # Lorsque la distance horizontale est plus longue
    if abs_sx > abs_sy
      # Déplacez-vous sur le côté sans le joueur, 
      # en donnant la priorité aux directions gauche et droite
      sx > 0 ? move_right : move_left
      if not moving? and sy != 0
        sy > 0 ? move_down : move_up
      end
    # Lorsque la distance verticale est plus longue
    else
      # Priorisez de haut en bas, déplacez-vous sur le côté sans le joueur
      sy > 0 ? move_down : move_up
      if not moving? and sx != 0
        sx > 0 ? move_right : move_left
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Un pas en avant
  #--------------------------------------------------------------------------
  def move_forward
    case @direction
    when 2
      move_down(false)
    when 4
      move_left(false)
    when 6
      move_right(false)
    when 8
      move_up(false)
    end
  end
  #--------------------------------------------------------------------------
  # ● Prendre du recul
  #--------------------------------------------------------------------------
  def move_backward
    # Se souvient de l'orientation fixe
    last_direction_fix = @direction_fix
    # Fixation de force
    @direction_fix = true
    # Direction par direction
    case @direction
    when 2  # Bas
      move_up(false)
    when 4  # Gauche
      move_right(false)
    when 6  # À droite
      move_left(false)
    when 8  # Ci-dessus
      move_down(false)
    end
    # Restaurer l'orientation fixe
    @direction_fix = last_direction_fix
  end
  #--------------------------------------------------------------------------
  # ● Sauter
  #     x_plus : X Coordonner la valeur calculée
  #     y_plus : Y Coordonner la valeur calculée
  #--------------------------------------------------------------------------
  def jump(x_plus, y_plus)
    # Si la somme n'est pas (0,0)
    if x_plus != 0 or y_plus != 0
      # Lorsque la distance horizontale est plus longue
      if x_plus.abs > y_plus.abs
        # Changer de direction vers la gauche ou la droite
        x_plus < 0 ? turn_left : turn_right
      # Lorsque la distance verticale est plus longue ou égale
      else
        # Changer l'orientation vers le haut ou vers le bas
        y_plus < 0 ? turn_up : turn_down
      end
    end
    # Calculer de nouvelles coordonnées
    new_x = @x + x_plus
    new_y = @y + y_plus
    # Lorsque la valeur ajoutée est (0,0) ou lorsque la destination de saut 
    # est passable
    if (x_plus == 0 and y_plus == 0) or passable?(new_x, new_y, 0)
      # Posture correcte
      straighten
      # Mettre à jour les coordonnées
      @x = new_x
      @y = new_y
      # Calculer la distance
      distance = Math.sqrt(x_plus * x_plus + y_plus * y_plus).round
      # Définir le nombre de sauts
      @jump_peak = 10 + distance - @move_speed
      @jump_count = @jump_peak * 2
      # Effacer le nombre d'arrêts
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Regarde en bas
  #--------------------------------------------------------------------------
  def turn_down
    unless @direction_fix
      @direction = 2
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Tourner à gauche
  #--------------------------------------------------------------------------
  def turn_left
    unless @direction_fix
      @direction = 4
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Tourner à droite
  #--------------------------------------------------------------------------
  def turn_right
    unless @direction_fix
      @direction = 6
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Montez
  #--------------------------------------------------------------------------
  def turn_up
    unless @direction_fix
      @direction = 8
      @stop_count = 0
    end
  end
  #--------------------------------------------------------------------------
  # ● Rotation de 90 degrés vers la droite
  #--------------------------------------------------------------------------
  def turn_right_90
    case @direction
    when 2
      turn_left
    when 4
      turn_up
    when 6
      turn_down
    when 8
      turn_right
    end
  end
  #--------------------------------------------------------------------------
  # ● Rotation de 90 degrés vers la gauche
  #--------------------------------------------------------------------------
  def turn_left_90
    case @direction
    when 2
      turn_right
    when 4
      turn_down
    when 6
      turn_up
    when 8
      turn_left
    end
  end
  #--------------------------------------------------------------------------
  # ● Rotation à 180 degrés
  #--------------------------------------------------------------------------
  def turn_180
    case @direction
    when 2
      turn_up
    when 4
      turn_right
    when 6
      turn_left
    when 8
      turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● Rotation à droite ou à gauche de 90 degrés
  #--------------------------------------------------------------------------
  def turn_right_or_left_90
    if rand(2) == 0
      turn_right_90
    else
      turn_left_90
    end
  end
  #--------------------------------------------------------------------------
  # ● Changer de direction au hasard
  #--------------------------------------------------------------------------
  def turn_random
    case rand(4)
    when 0
      turn_up
    when 1
      turn_right
    when 2
      turn_left
    when 3
      turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● Tournez-vous vers le joueur
  #--------------------------------------------------------------------------
  def turn_toward_player
    # Trouvez les différences à partir des coordonnées du joueur
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Si les coordonnées sont égales
    if sx == 0 and sy == 0
      return
    end
    # Lorsque la distance horizontale est plus longue
    if sx.abs > sy.abs
      # Faites face au joueur dans la direction gauche et droite
      sx > 0 ? turn_left : turn_right
    # Lorsque la distance verticale est plus longue
    else
      # Faites face au joueur de haut en bas
      sy > 0 ? turn_up : turn_down
    end
  end
  #--------------------------------------------------------------------------
  # ● Face à l'opposé du joueur
  #--------------------------------------------------------------------------
  def turn_away_from_player
    # Trouvez les différences à partir des coordonnées du joueur
    sx = @x - $game_player.x
    sy = @y - $game_player.y
    # Si les coordonnées sont égales
    if sx == 0 and sy == 0
      return
    end
    # Lorsque la distance horizontale est plus longue
    if sx.abs > sy.abs
      # Tournez à gauche ou à droite sans joueur
      sx > 0 ? turn_right : turn_left
    # Lorsque la distance verticale est plus longue
    else
      # Faites face de haut en bas sans joueur
      sy > 0 ? turn_down : turn_up
    end
  end
end
