#==============================================================================
# ■ Scene_Title
#------------------------------------------------------------------------------
# 　Il s'agit d'une classe qui effectue le traitement de l'écran titre.
#==============================================================================

class Scene_Title
  #--------------------------------------------------------------------------
  # ● Traitement principal
  #--------------------------------------------------------------------------
  def main
    # Pour les tests de combat
    if $BTEST
      battle_test
      return
    end
    # Créer un graphique de titre
    @sprite = Sprite.new
    @sprite.bitmap = RPG::Cache.title($data_system.title_name)
    # Créer une fenêtre de commande
    s1 = "Nouvelle partie"
    s2 = "Charger une partie"
    s3 = "Quitter"
    @command_window = Window_Command.new(192, [s1, s2, s3])
    @command_window.back_opacity = 160
    @command_window.x = 320 - @command_window.width / 2
    @command_window.y = 288
    # Poursuivre le jugement de validité
    # Vérifiez s'il existe des fichiers de sauvegarde
    # Définissez @continue_enabled sur true si activé, false si désactivé
    @continue_enabled = false
    1.upto(MAX_SAUVEGARDES) do |i|
      if FileTest.exist?("Save#{i}.rxdata")
        @continue_enabled = true
      end
    end
    # Déplacer le curseur pour continuer si continuer est activé
    # Si désactivé, continuer le texte est grisé
    if @continue_enabled
      @command_window.index = 1
    else
      @command_window.disable_item(1)
    end
    # Jouer le titre BGM
    $game_system.bgm_play($data_system.title_bgm)
    # Arrêtez de jouer ME et BGS
    Audio.me_stop
    Audio.bgs_stop
    # Exécuter la transition
    Graphics.transition
    # Boucle principale
    loop do
      # Écran de mise à jour du jeu
      Graphics.update
      # Mettre à jour les informations d'entrée
      Input.update
      # Mise à jour du cadre
      update
      # Briser la boucle lorsque l'écran change
      if $scene != self
        break
      end
    end
    # Préparation à la transition
    Graphics.freeze
    # Fenêtre de commande de libération
    @command_window.dispose
    # Graphique du titre de la version
    @sprite.bitmap.dispose
    @sprite.dispose
  end
  #--------------------------------------------------------------------------
  # ● Mise à jour du cadre
  #--------------------------------------------------------------------------
  def update
    # Fenêtre de commande de mise à jour
    @command_window.update
    # Lorsque le bouton C est enfoncé
    if Input.trigger?(Input::C)
      # Branche à la position du curseur dans la fenêtre de commande
      case @command_window.index
      when 0  # Nouveau jeu
        command_new_game
      when 1  # Continuez
        command_continue
      when 2  # Arrêtez
        command_shutdown
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Commande: nouveau jeu
  #--------------------------------------------------------------------------
  def command_new_game
    # Play Decision SE
    $game_system.se_play($data_system.decision_se)
    # Arrêter le BGM
    Audio.bgm_stop
    # Réinitialiser le nombre d'images pour la mesure du temps de lecture
    Graphics.frame_count = 0
    # Créer divers objets de jeu
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_self_variables = Game_SelfVariables.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # Mettre en place une première fête
    $game_party.setup_starting_members
    # Configurer la carte pour l'emplacement initial
    $game_map.setup($data_system.start_map_id)
    # Déplacer le joueur à sa position initiale
    $game_player.moveto($data_system.start_x, $data_system.start_y)
    # Actualiser le lecteur
    $game_player.refresh
    # Effectue une commutation automatique entre BGM et BGS définie sur la carte
    $game_map.autoplay
    # Mettre à jour la carte (exécution d'événement parallèle)
    $game_map.update
    # Passer à l'écran de la carte
    $scene = Scene_Map.new
  end
  #--------------------------------------------------------------------------
  # ● コマンド : コンティニュー
  #--------------------------------------------------------------------------
  def command_continue
    # Lorsque continuer n'est pas valide
    unless @continue_enabled
      # Play Buzzer SE
      $game_system.se_play($data_system.buzzer_se)
      return
    end
    # Play Decision SE
    $game_system.se_play($data_system.decision_se)
    # Passer à l'écran de chargement
    $scene = Scene_Load.new
  end
  #--------------------------------------------------------------------------
  # ● Commande : arrêt
  #--------------------------------------------------------------------------
  def command_shutdown
    # Play Decision SE
    $game_system.se_play($data_system.decision_se)
    # Fade out BGM, BGS, ME
    Audio.bgm_fade(800)
    Audio.bgs_fade(800)
    Audio.me_fade(800)
    # Arrêtez
    $scene = nil
  end
  #--------------------------------------------------------------------------
  # ● Test de bataille
  #--------------------------------------------------------------------------
  def battle_test
    # Charger la base de données (pour le test de bataille)
    $data_actors        = load_data("Data/BT_Actors.rxdata")
    $data_classes       = load_data("Data/BT_Classes.rxdata")
    $data_skills        = load_data("Data/BT_Skills.rxdata")
    $data_items         = load_data("Data/BT_Items.rxdata")
    $data_weapons       = load_data("Data/BT_Weapons.rxdata")
    $data_armors        = load_data("Data/BT_Armors.rxdata")
    $data_enemies       = load_data("Data/BT_Enemies.rxdata")
    $data_troops        = load_data("Data/BT_Troops.rxdata")
    $data_states        = load_data("Data/BT_States.rxdata")
    $data_animations    = load_data("Data/BT_Animations.rxdata")
    $data_tilesets      = load_data("Data/BT_Tilesets.rxdata")
    $data_common_events = load_data("Data/BT_CommonEvents.rxdata")
    $data_system        = load_data("Data/BT_System.rxdata")
    # Réinitialiser le nombre d'images pour la mesure du temps de lecture
    Graphics.frame_count = 0
    # Créer divers objets de jeu
    $game_temp          = Game_Temp.new
    $game_system        = Game_System.new
    $game_switches      = Game_Switches.new
    $game_variables     = Game_Variables.new
    $game_self_switches = Game_SelfSwitches.new
    $game_screen        = Game_Screen.new
    $game_actors        = Game_Actors.new
    $game_party         = Game_Party.new
    $game_troop         = Game_Troop.new
    $game_map           = Game_Map.new
    $game_player        = Game_Player.new
    # Mettre en place une fête pour les tests de combat
    $game_party.setup_battle_test_members
    # Définir l'ID de la troupe, le drapeau d'échappement et le combat
    $game_temp.battle_troop_id = $data_system.test_troop_id
    $game_temp.battle_can_escape = true
    $game_map.battleback_name = $data_system.battleback_name
    # Play Battle Start SE
    $game_system.se_play($data_system.battle_start_se)
    # Play Battle BGM
    $game_system.bgm_play($game_system.battle_bgm)
    # Passer à l'écran de combat
    $scene = Scene_Battle.new
  end
end