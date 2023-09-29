#==============================================================================
# ■ Pokemon Script Project Window_Message
#    Script Communauté CSP - Youspin
#------------------------------------------------------------------------------
# Petit script servant à redéfinir l'apparence des messages par défauts et
# de permettre l'utilisation d'un plus grand nombre de choix. Testé PSP 0.9.
#------------------------------------------------------------------------------
module POKEMON_S
#------------------------------------------------------------------------------
# Taille de l'écran. 640 représente la largeur du jeu et 480 sa hauteur.
  DIMENSIONS = [640,480]
# Vitesse de l'effet de glissement vers le haut du texte. S'active avec \up
  DEFIL_SPEED = 2
# Entendre le petit bruit de confirmation à la fin d'un message ?
# Mettre true pour oui, false pour non.
  MSG_CONFIRM = false
# Coordonnées Y à partir du HAUT de l'écran de la boite de dialogue selon 
# la commande évenement « Options des messages... » ou pendant un combat.
  MSG_Y = [     0,     # Haut
    160,     # Milieu
    336,     # Bas
    336   ]  # En combat
# Nombre de lignes de texte maximum sur un dialogue. Le message sera coupé si
# il fait plus de lignes que ce nombre. 
  NB_LIGNES = 3
# Coordonnée X sur l'écran où le texte commence à apparaitre.
  DEBUT_MSG = 25
# Coordonnée X sur l'écran où le texte doit dépasser pour changer de ligne.
  FIN_MSG = 597
# Coordonnée Y à partir du Haut de la boite de dialogue où la première
# ligne de texte apparait.
  TXT_Y = 6
#------------------------------------------------------------------------------  
class MULTICHOIX < Window_Command
def initialize(choix); @choix, @cancel, @align = choix[0], choix[1], choix[2]
#------------------------------------------------------------------------------  
# Largeur de la fenêtre des choix. Mettre à adaptable pour une largeur 
# proportionnelle à la largeur du plus grand texte.
  @LARGEUR = adaptable # Je recommande aussi : DIMENSIONS[0]/4
# Coordonnée X de la fenêtre des choix en partant du point Gauche de l'écran.
  @X = [                         0,    # 0 Gauche
        (DIMENSIONS[0]-@LARGEUR)/2,    # 1 Milieu
        DIMENSIONS[0]-(@LARGEUR+6)  ]  # 2 Droite (par défaut)
# Coordonnées Y de la fenêtre des choix en partant du point Bas de l'écran.
  @Y = 150
#------------------------------------------------------------------------------
# ▼ La partie suivante est le code *important* du script.
#   Éditez la partie ci-dessous seulement si vous savez ce que vous faites.
#==============================================================================
      make_choices
      super(@LARGEUR, @choix, $fontsize)
      self.x = @X[(@align>=3) ? 2 : @align]
      self.y = DIMENSIONS[1]-(@Y+self.height)
      self.z = 5000
      Graphics.transition
    end
    # Remplacer des commandes par des variables, pour les choix
    def make_choices
      for i in 0..@choix.size-1
        # Utilisation de \V[ID] pour afficher Variable[ID]
        @choix[i].gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
        # Utilisation de \P[ID] pour afficher $string[ID]
        @choix[i].gsub!(/\\[Pp]\[([0-9]+)\]/) { $string[$1.to_i] }
        # Utilisation de \N[ID] pour afficher NomDuHéro[ID]
        @choix[i].gsub!(/\\[Nn]\[([0-9]+)\]/) do
          $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
        end
      end
    end
    # Ajuster la taille de la fenêtre des choix
    def adaptable
      make_choices
      textSize=Bitmap.new(DIMENSIONS[0],DIMENSIONS[1]) 
      textSize.font.name = $fontface
      textSize.font.size = $fontsize
      size = (textSize.text_size(@choix.max{|a,b|a.length <=> b.length}).width)+50
      textSize.dispose
      textSize = nil
      return (size<=120) ? 120 : size
    end
  end#MULTICHOIX
end#POKEMON_S
# Gestion des messages
class Window_Message
  include POKEMON_S #
  #----------------------------------------------------------------------------
  # ● Initialize
  #----------------------------------------------------------------------------
  def initialize
    super(DEBUT_MSG, MSG_Y[2]+TXT_Y, FIN_MSG, 126)
    self.contents = Bitmap.new(DIMENSIONS[0] - 32, DIMENSIONS[1] - 32)
    self.visible = false
    self.z = 9998
    self.opacity = 0
    @dummy = Sprite.new
    unless $message_dummy
      @dummy.bitmap = RPG::Cache.picture(MSG)
    else
      @dummy.bitmap = RPG::Cache.picture($message_dummy)
    end
    @dummy.visible = false
    @dummy.z = 9997
    @fade_in = false
    @fade_out = false
    @contents_showing = false
    @cursor_width = 0
    unless $vit_txt
      @speed_defilement = SPEED_MSG
    else
      @speed_defilement = $vit_txt
    end
    $start_transition = 0
    $end_transition = 0
    @wait_for_input = true
    self.active = false
    self.index = -1
  end
  #----------------------------------------------------------------------------
  # ● Reset_window :Redéfinir la position de la fenêtre
  #----------------------------------------------------------------------------
  def reset_window
    @dummy.y = ($game_temp.in_battle) ? MSG_Y[4] : MSG_Y[$game_system.message_position]
    self.y = @dummy.y + TXT_Y
    @dummy.opacity = ($game_system.message_frame == 0) ? 255 : 0
    self.back_opacity = 255
  end
  #----------------------------------------------------------------------------
  # ● Update :Cette méthode est appelée via Scene_Map
  #---------------------------------------------------------------------------- 
  def update
    super
    # Méthode suivante après le @fade_out. S'éxécute plusieurs fois.
    if @fade_in
      self.contents_opacity += 24
      if @input_number_window != nil
        @input_number_window.contents_opacity += 24
      end
      if self.contents_opacity == 255
        @fade_in = false
        if @speed_defilement != 0
          refresh
        end
      end
      return
    end
    # Création de la fenêtre pour entrer un nombre
    if $game_temp.num_input_variable_id > 0 and @input_number_window == nil
      if @contents_showing or $game_temp.message_text == nil
        Graphics.update
        @input_number_window = Window_InputNumber.new($game_temp.num_input_digits_max)
        @input_number_window.number = $game_variables[$game_temp.num_input_variable_id]
        @input_number_window.x = DIMENSIONS[0]/2 - @input_number_window.width/2
        @input_number_window.y = DIMENSIONS[1]/2 - @input_number_window.height/2
      end
    end
    # Fermer la fenêtre pour entrer un nombre
    if @input_number_window != nil
      @input_number_window.update
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_variables[$game_temp.num_input_variable_id] = @input_number_window.number
        $game_map.need_refresh = true
        @input_number_window.dispose
        @input_number_window = nil
        terminate_message
      end
      return
    end
    # Création de la fenêtre des choix 
    if $game_temp.choice_list != nil and @choice_window == nil
      if @contents_showing or $game_temp.message_text == nil
        Graphics.update
        @choice_window = MULTICHOIX.new([$game_temp.choice_list, 
            $game_temp.choice_cancel_type, 
            $game_temp.choice_align])
      end
    end
    # Fermer la fenêtre des choix
    if @choice_window != nil
      @choice_window.update
      if Input.trigger?(Input::C)  # Si validation
        $game_system.se_play($data_system.decision_se)
        index = @choice_window.index 
      end
      if Input.trigger?(Input::B) and $game_temp.choice_cancel_type > 0 # Si annulation
        $game_system.se_play($data_system.cancel_se)
        index = $game_temp.choice_cancel_type-1
      end
      return if index == nil
      @choice_window.dispose
      @choice_window = nil
      $game_variables[$game_temp.choice_max] = index+1 if $game_temp.choice_max > 0
      $game_temp.choice_proc.call(index) if $game_temp.choice_proc != nil
      terminate_message
      return
    end
    # Méthode appelée à chaque caractère d'affiché.
    if @contents_showing
      # Si on affiche déjà des choix
      if $game_temp.choice_max == 0
        # Afficher le curseur
        self.pause = true if (@speed_defilement != 0 and $end_transition > -1)
        if Input.trigger?(Input::C) or not @wait_for_input
          # Bruit de confirmation
          $game_system.se_play($data_system.decision_se) if MSG_CONFIRM
          # Effet de glissement vers le haut
          if @defil
            self.pause = @defil = false
            n = DEFIL_SPEED
            while self.y >= @dummy.y - 32 * @y do
              self.contents.fill_rect(0, n, self.contents.width, DEFIL_SPEED, Color.new(0, 0, 0, 0))
              self.y -= DEFIL_SPEED
              Graphics.update
              n += DEFIL_SPEED
            end end
          if ($scene.class.name != "Scene_Map" or $end_transition != 0)
            Graphics.freeze
            self.contents_opacity = 0
            @dummy.opacity = 0
            Graphics.transition($end_transition) if $end_transition > 0
          end
          terminate_message
        end
      end                             # Appui possible seulement à la fin
      return
    end
    # Au début d'un message. S'éxécute une seule fois.
    if not @fade_out and $game_temp.message_text != nil
      Audio.se_play("Audio/SE/#{SOUND_CHOICE}")
      @contents_showing = true
      $game_temp.message_window_showing = true
      reset_window
      Graphics.freeze if $start_transition > 0
      if @speed_defilement == 0
        refresh
      end
      self.visible = true
      @dummy.visible = true
      Graphics.transition($start_transition) if $start_transition > 0
      Graphics.frame_reset
      if @input_number_window != nil
        @input_number_window.contents_opacity = 0
      end
      @fade_in = true
      return
    end
    # À la fin de tout les messages.
    if self.visible
      @fade_out = true
      @dummy.opacity = 0
      if @dummy.opacity == 0
        self.visible = false
        @dummy.visible = false
        @fade_out = false
        $game_temp.message_window_showing = false
      end
      $start_transition = 0
      $end_transition = 0
      unless $vit_txt
        @speed_defilement = SPEED_MSG
      else
        @speed_defilement = $vit_txt
      end
      return
    end
  end
  #----------------------------------------------------------------------------
  # ● Refresh :Méthode consistant à afficher le texte lettre par lettre
  #----------------------------------------------------------------------------
  def refresh
    self.contents.clear
    self.contents.font.color = normal_color
    self.contents.font.name = $fontface
    self.contents.font.size = $fontsize
    text_count, x, @y = 0, 0, 0
    skip = true
    push = false
    @cursor_width = 0
    @wait_for_input = true
    # Affichage lettre par lettre
    if $game_temp.message_text != nil and NB_LIGNES > 0
      text = $game_temp.message_text
      # Remplacer les mots dans le texte
      begin
        last_text = text.clone
        # Utilisation de \V[ID] pour afficher $game_variables[ID]
        text.gsub!(/\\[Vv]\[([0-9]+)\]/) { $game_variables[$1.to_i] }
        # Utilisation de \P[ID] pour afficher $string[ID]
        text.gsub!(/\\[Pp]\[([0-9]+)\]/) { $string[$1.to_i] }
      end until text == last_text
      # Utilisation de \N[ID] pour afficher NomDuHéro[ID]
      text.gsub!(/\\[Nn]\[([0-9]+)\]/) do
        $game_actors[$1.to_i] != nil ? $game_actors[$1.to_i].name : ""
      end
      # Remplacer \\ par "\000"
      text.gsub!(/\\\\/) { "\000" }
      # Remplacer \C[ID] par "\001[ID]"
      text.gsub!(/\\[Cc]\[([0-9]+)\]/) { "\001[#{$1}]" }
      # Remplacer \G par "\002"
      text.gsub!(/\\[Gg]/) { "\002" }
      # Remplacer \S[Vitesse] par "\003[Vitesse]"
      text.gsub!(/\\[Ss]\[([0-9]+)\]/) { "\003[#{$1}]" }
      # Remplacer \W[TempsEnFrames] par "\004[TempsEnFrames]"
      text.gsub!(/\\[Ww]\[([0-9]+)\]/) { "\004[#{$1}]" }
      # Remplacer \NS par "\005"
      text.gsub!(/\\NS/i) { "\005" }
      # Remplacer \NI par "\006"
      text.gsub!(/\\NI/i) { "\006" }
      # Remplacer \Up par "\d"
      text.gsub!(/\\UP/i) { "\007" }
      # Remplacer \CX par "\010"
      text.gsub!(/\\CX/i) { "\010" }
      # Remplacer \Poke[id] par "\020[id]"
      text.gsub!(/\\POKE\[([0-9]+)\]/i) { "\020[#{$1}]" }
      # Remplacer \Cry[id] par "\030[id]"
      text.gsub!(/\\CRY\[([0-9]+)\]/i) { "\030[#{$1}]" }
      # Analyser tout les caractères \suitedecaractère = un caractère
      while ((c = text.slice!(/./m)) != nil)
        # Afficher "\\" lorsqu'on écrit \\
        if c == "\000"
          c = "\\"
        end
        # Changer la couleur du texte
        if c == "\001"
          text.sub!(/\[([0-9]+)\]/, "")
          color = $1.to_i
          if color >= 0 and color <= 7
            self.contents.font.color = text_color(color)
          end
          next
        end
        # Afficher la fenêtre d'argent
        if c == "\002"
          if @gold_window == nil
            @gold_window = Window_Gold.new
            @gold_window.x = 560 - @gold_window.width
            if $game_temp.in_battle
              @gold_window.y = 192
            else
              @gold_window.y = self.y >= 128 ? 32 : 384
            end
            @gold_window.opacity = 255
            @gold_window.back_opacity = 255
          end
          next
        end
        # Changer la vitesse d'écriture
        if c == "\003"
          text.sub!(/\[([0-9]+)\]/, "")
          @speed_defilement = $1.to_i
          next
        end
        # Attendre X frames
        if c == "\004"
          text.sub!(/\[([0-9]+)\]/, "")
          ($1.to_i).times { Graphics.update }
          next
        end
        # Empêcher de skipper l'affichage du texte
        if c == "\005"
          skip = false
          next
        end
        # Ne pas attendre l'appui de la touche ::C pour terminer le message 
        if c == "\006"
          @wait_for_input = false
          next
        end
        # Activer l'effet de défilement
        if c == "\007"
          @defil = true
          next
        end
        # Exécuter tout de suite la prochaine commande
        if c == "\010"
          if $game_system.map_interpreter.child_interpreter
            $game_system.map_interpreter.child_interpreter.verif_next_command(true)
          else
            $game_system.map_interpreter.verif_next_command(true)
          end
          next
        end
        # Afficher un Pokémon
        if c == "\020"
          text.sub!(/\[([0-9]+)\]/, "")
          pokemon = Pokemon.new($1.to_i)
          @poke = Sprite.new
          @poke.bitmap = RPG::Cache.battler(pokemon.battler_face(false),0)
          @poke.x = DIMENSIONS[0]/2 - @poke.bitmap.width/2 # Centrer
          @poke.y = DIMENSIONS[1]/2 - @poke.bitmap.height/2
          @poke.z = 999999
          next
        end
        # Entendre le cri d'un Pokémon
        if c == "\030"
          text.sub!(/\[([0-9]+)\]/, "")
          pokemon = Pokemon.new($1.to_i)
          Audio.se_play(pokemon.cry) if FileTest.exist?(pokemon.cry)
          next
        end
        # Changer de ligne
        if c == "\n"
          @y += 1
          break if @y > NB_LIGNES-1
          x = 0
          next
        end
        # Afficher le caractère
        self.contents.draw_text(x, 32 * @y, 40, 32, c)
        text_count += 1
        Input.update
        # Permettre de skipper l'affichage du texte en empêchant le Graphics.update
        if Input.trigger?(Input::C) and skip
          push = true
        end
        # Faire une pause avant de voir l'autre caractère selon la vitesse 
        if text_count == @speed_defilement and @speed_defilement != 0 and not push
          Graphics.update
          text_count = 0
        end
        x += self.contents.text_size(c).width
      end
    end
  end#refresh
  #----------------------------------------------------------------------------
  # ● Terminate_message :Réinitialiser les variables
  #----------------------------------------------------------------------------
  alias old terminate_message
  def terminate_message
    old
    if @poke != nil
      @poke.dispose
      @poke = nil
    end
    unless $vit_txt
      @speed_defilement = SPEED_MSG
    else
      @speed_defilement = $vit_txt
    end
    $start_transition = 0
    $end_transition = 0
    $game_temp.choice_list = nil
    $game_temp.choice_cancel_type = 0
    $game_temp.choice_max = 0
    $game_temp.choice_align = 2
  end
end#Window_Message
#Ajout de la propriété :choice_list et :choice_align pour Game_Event
class Game_Temp
  attr_accessor :choice_list
  attr_accessor :choice_align
  alias new initialize
  def initialize
    new
    @choice_list = nil
    @choice_align = 2 
  end
end
# Voir l'arrière-plan de la fenêtre pour entrer un nombre
class Window_InputNumber
  alias my initialize
  def initialize(digits_max)
    my(digits_max)
    self.opacity = 255
  end
end
# Gestion des commandes évennement
class Interpreter
  attr_reader :child_interpreter #Assurer la compatibilé avec un event commun
  #----------------------------------------------------------------------------
  # ● Setup_choices :Appelé lors de cx ou d'affichage de choix
  #----------------------------------------------------------------------------
  def setup_choices(parameters, var = 0, align = 2, from_script = false)
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.choice_list = parameters[0]
    $game_temp.choice_cancel_type = parameters[1]
    $game_temp.choice_max = var
    $game_temp.choice_align = 2
    if !from_script
      current_indent = @list[@index].indent
      $game_temp.choice_proc = Proc.new { |n| @branch[current_indent] = n }
    end
  end
  #----------------------------------------------------------------------------
  # ● Setup_input_number :Appelé lors de command_103
  #----------------------------------------------------------------------------
  def setup_input_number(parameters)
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.num_input_start = 0
    $game_temp.num_input_variable_id = parameters[0]
    $game_temp.num_input_digits_max = parameters[1]
  end
  #----------------------------------------------------------------------------
  # ● Command_101 :Afficher message
  #----------------------------------------------------------------------------
  def command_101
    @message_waiting = true
    $game_temp.message_proc = Proc.new { @message_waiting = false }
    $game_temp.message_text = @list[@index].parameters[0] + "\n"
    while @list[@index+1].code == 401
      $game_temp.message_text += @list[@index+1].parameters[0] + "\n"
      @index += 1
    end
    verif_next_command(false)
    return true
  end
  #----------------------------------------------------------------------------
  # ● Command_102 :Afficher choix
  #----------------------------------------------------------------------------
  def command_102
    setup_choices(@parameters, 0, 2, false)
    return true
  end
  #----------------------------------------------------------------------------
  # ● Command_103 :Entrer un nombre
  #----------------------------------------------------------------------------
  def command_103
    setup_input_number(@parameters)
    return true
  end
  #----------------------------------------------------------------------------
  # ● Verif_next_command :Démarrer la prochaine commande évennement
  #----------------------------------------------------------------------------
  def verif_next_command(check_script)
    if $scene.class.name == "Scene_Map"
      a=(check_script) ? 0 : 1
      case @list[@index+a].code
      when 102
        setup_choices(@list[@index+a].parameters, 0, 2, false)
        @index += 1
      when 103
        setup_input_number(@list[@index+a].parameters)
        @index += 1
      when 355
        if check_script
          script = @list[@index+a].parameters[0] + "\n"
          loop do
            if @list[@index+a+1].code == 655
              script += @list[@index+a+1].parameters[0] + "\n"
            else
              break
            end
            @index += 1
          end
          @index += 1
          $running_script = "MAP #{@map_id} EVENT #{@event_id}\nSCRIPT\n#{script}"
          eval(script)
        end
      end#When
    end#if
  end#def
end
#-----------------------------------------------------------------------------
# ● cx :Simple fonction permettant d'afficher un nombre illimité de choix.
# cx "choix1", "choix2", "choix etc", [Choix Annulation,  ID Var, Alignement]
#-----------------------------------------------------------------------------
def cx(*args) 
  return if $scene.class.name != "Scene_Map"
  args = args # Permettre la modification de args lors du args.delete_at
  size = args.size-1
  array = args[size] 
  cancel, var, align = 0, 0, 2
  if array.type == Array # Si le dernier argument est un tableau
    cancel = array[0].to_i # Choix d'annulation
    var = array[1].to_i if array[1] # ID variable qui prend la valeur du choix
    align = array[2].to_i if array[2] # Alignement des choix
    args.delete_at(size)
  end
  setup_choices([args,cancel], var, align, true)
  cancel = var = align = nil
  return nil
end
#-----------------------------------------------------------------------------
# ● m :Simple fonction permettant d'afficher un message
#-----------------------------------------------------------------------------
def m(*args)
  Graphics.update
  def set
    $start_transition = @start_t
    $end_transition = @end_t
  end
  args = args
  size = args.size-1
  @start_t, @end_t = 0, 0
  if args[size].type == Array
    array = args.delete_at(size)
    @start_t = array[0]
    @end_t   = array[1] if array[1] !=nil
  end
  @message_waiting = true
  $game_temp.message_proc = Proc.new { @message_waiting = false }
  $game_temp.message_text = args[0].to_s + "\n"
  for i in 1..args.size-1
    $game_temp.message_text += args[i].to_s + "\n" if args[i]
  end
  if $scene.class.name != "Scene_Map"
    @window = Window_Message.new
    set
    until $game_temp.message_text==nil
      Graphics.update
      Input.update
      @window.update
    end
    @window.dispose
    @window = nil
  else
    verif_next_command(false)
    set
  end
  return nil
end