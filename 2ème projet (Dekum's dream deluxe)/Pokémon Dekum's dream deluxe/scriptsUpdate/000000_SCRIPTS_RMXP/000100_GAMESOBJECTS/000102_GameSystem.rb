#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# Cette classe gère les données autour du système. Il gère également 
# la musique de fond. Cette classe
# Les instances sont référencées dans $game_system.
#==============================================================================
class Game_System
  #--------------------------------------------------------------------------
  # ● Variables d'instance publique
  #--------------------------------------------------------------------------
  attr_reader   :map_interpreter          # Interprète pour les événements de carte
  attr_reader   :battle_interpreter       # nterprète pour les événements de bataille
  attr_accessor :timer                    # Minuterie
  attr_accessor :timer_working            # Drapeau de minuterie en cours d'exécution
  attr_accessor :save_disabled            # Pas de sauvegarde
  attr_accessor :menu_disabled            # Interdiction de menu
  attr_accessor :encounter_disabled       # Rencontre interdite
  attr_accessor :message_position         # Position d'affichage de l'option de texte
  attr_accessor :message_frame            # Cadre de fenêtre d'options de texte
  attr_accessor :save_count               # Nombre de sauvegardes
  attr_accessor :magic_number             # Numéro magique
  #--------------------------------------------------------------------------
  # ● Initialisation d'objet
  #--------------------------------------------------------------------------
  def initialize
    @map_interpreter = Interpreter.new(0, true)
    @battle_interpreter = Interpreter.new(0, false)
    @timer = 0
    @timer_working = false
    @save_disabled = false
    @menu_disabled = false
    @encounter_disabled = false
    @message_position = 2
    @message_frame = 0
    @save_count = 0
    @magic_number = 0
  end
  #--------------------------------------------------------------------------
  # ● Performances BGM
  #   bgm: BGM à jouer
  #--------------------------------------------------------------------------
  def bgm_play(bgm, volume = 100, pitch = 100)
    @playing_bgm = bgm
    if bgm != nil and bgm.name != ""
      unless $bgm_master
        Audio.bgm_play("Audio/BGM/#{bgm.name}", volume, pitch)
      else
        Audio.bgm_play("Audio/BGM/#{bgm.name}", volume * $bgm_master/100, pitch)
      end
    else
      Audio.bgm_stop
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● Arrêter le BGM
  #--------------------------------------------------------------------------
  def bgm_stop
    Audio.bgm_stop
  end
  #--------------------------------------------------------------------------
  # ● BGM s'estompe
  #   time: temps de fondu (seconde)
  #--------------------------------------------------------------------------
  def bgm_fade(time)
    @playing_bgm = nil
    Audio.bgm_fade(time * 1000)
  end
  #--------------------------------------------------------------------------
  # ● Mémoire BGM
  #--------------------------------------------------------------------------
  def bgm_memorize
    @memorized_bgm = @playing_bgm
  end
  #--------------------------------------------------------------------------
  # ● Retour BGM
  #--------------------------------------------------------------------------
  def bgm_restore
    bgm_play(@memorized_bgm)
  end
  #--------------------------------------------------------------------------
  # ● Performances BGS
  #   bgs: BGS à jouer
  #--------------------------------------------------------------------------
  def bgs_play(bgs)
    @playing_bgs = bgs
    if bgs != nil and bgs.name != ""
      unless $bgs_master
        Audio.bgs_play("Audio/BGS/#{bgs.name}", volume, pitch)
      else
        Audio.bgs_play("Audio/BGS/#{bgs.name}", volume * bgs_master/100, pitch)
      end
    else
      Audio.bgs_stop
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● BGS s'estompe
  #   time: temps de fondu (seconde)
  #--------------------------------------------------------------------------
  def bgs_fade(time)
    @playing_bgs = nil
    Audio.bgs_fade(time * 1000)
  end
  #--------------------------------------------------------------------------
  # ● Mémoire BGS
  #--------------------------------------------------------------------------
  def bgs_memorize
    @memorized_bgs = @playing_bgs
  end
  #--------------------------------------------------------------------------
  # ● Retour de BGS
  #--------------------------------------------------------------------------
  def bgs_restore
    bgs_play(@memorized_bgs)
  end
  #--------------------------------------------------------------------------
  # ● ME jouer
  #   me : ME pour jouer
  #--------------------------------------------------------------------------
  def me_play(me)
    if me != nil and me.name != ""
      unless $me_master
        Audio.me_play("Audio/ME/#{me.name}", me.volume, me.pitch)
      else
        Audio.me_play("Audio/ME/#{me.name}", me.volume * $me_master/100, me.pitch)
      end
    else
      Audio.me_stop
    end
    Graphics.frame_reset
  end
  #--------------------------------------------------------------------------
  # ● Performances SE
  #   se: SE pour jouer
  #--------------------------------------------------------------------------
  def se_play(se)
    if se != nil and se.name != ""
      unless $se_master
        Audio.se_play("Audio/SE/#{se.name}", se.volume, se.pitch)
      else
        Audio.se_play("Audio/SE/#{se.name}", se.volume * $se_master/100, se.pitch)
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● Arrêter SE
  #--------------------------------------------------------------------------
  def se_stop
    Audio.se_stop
  end
  #--------------------------------------------------------------------------
  # ● Acquérir de la musique de fond tout en jouant
  #--------------------------------------------------------------------------
  def playing_bgm
    return @playing_bgm
  end
  #--------------------------------------------------------------------------
  # ● Obtenez BGS tout en jouant
  #--------------------------------------------------------------------------
  def playing_bgs
    return @playing_bgs
  end
  #--------------------------------------------------------------------------
  # ● Obtenir le nom du fichier d'habillage de fenêtre
  #--------------------------------------------------------------------------
  def windowskin_name
    if @windowskin_name == nil
      return $data_system.windowskin_name
    else
      return @windowskin_name
    end
  end
  #--------------------------------------------------------------------------
  # ● Définition du nom du fichier d'habillage de fenêtre
  #   windowskin_name : nouveau nom de fichier d'habillage de fenêtre
  #--------------------------------------------------------------------------
  def windowskin_name=(windowskin_name)
    @windowskin_name = windowskin_name
  end
  #--------------------------------------------------------------------------
  # ● Obtenez Battle BGM
  #--------------------------------------------------------------------------
  def battle_bgm
    if @battle_bgm == nil
      return $data_system.battle_bgm
    else
      return @battle_bgm
    end
  end
  #--------------------------------------------------------------------------
  # ● Paramètres de BGM de combat
  #   battle_bgm : nouveau BGM de combat
  #--------------------------------------------------------------------------
  def battle_bgm=(battle_bgm)
    @battle_bgm = battle_bgm
  end
  #--------------------------------------------------------------------------
  # ● Obtenez Battle End BGM
  #--------------------------------------------------------------------------
  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end
  #--------------------------------------------------------------------------
  # ● Paramètre BGM de fin de bataille
  #   battle_end_me : nouveau BGM de fin de bataille
  #--------------------------------------------------------------------------
  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
  #--------------------------------------------------------------------------
  # ● Mise à jour du cadre
  #--------------------------------------------------------------------------
  def update
    # Diminuer la minuterie d'une unité
    if @timer_working and @timer > 0
      @timer -= 1
    end
  end
end