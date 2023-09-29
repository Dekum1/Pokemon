#==============================================================================
# Module TIMESYS - G!n0
# 19/08/20
# Gestion Basique du temps et de l'effet Jour/Nuit
# Basé sur le script TempsJourNuit
#-----------------------------------------------------------------------------


module TIMESYS
  #-----------------------------------------------------------------
  # Les constantes
  #-----------------------------------------------------------------
  
  # Ton neutre
  NEUTRAL_TONE = Tone.new(0,0,0,0)
  
  # Ton J/N de l'écran
  TONE = {
    :morning => Tone.new(20, -20, -35, 0),
    :day => NEUTRAL_TONE,
    :sunset => Tone.new(-20, -50, -35, 0),
    :night => Tone.new(-70, -70, -10, 0),
    :default => NEUTRAL_TONE
  }
  
  # Heures des phases suivant la saison. dans chaque taleau :
  # index 0 : début matin, index 1 : début midi, 2 : début crépuscule, 3 : début nuit
  TIME = {
   :winter => [9, 12, 16, 17],
   :spring => spring = [8, 11, 19, 20],
   :summer => [7, 11, 20, 22],
   :fall => spring,
   :default => spring
  }
  
  #-----------------------------------------------------------------
  # Les méthodes
  #-----------------------------------------------------------------
  
  #-------------------------------------------
  # Mise à jour du système J/N
  #-------------------------------------------
  def self.update
    clock = Time.now
    # Changement de minute
    if $game_variables[TS_MIN] != clock.min
      self.update_variables(clock)
      if $game_switches[SWITCH_EXTERIEUR]
        self.update_phases(clock)
      end
      return
    end
    # En extérieur sans changement de min
    if $game_switches[SWITCH_EXTERIEUR]
      # S'il la phase est en défaut, on la MAJ
      if $game_variables[TS_NIGHTDAY] == :default
        self.update_phases(clock)
      end
      return
    end
    # Si pas extérieur, mettre phase en défaut
    if $game_variables[TS_NIGHTDAY] != :default
      $game_screen.start_tone_change(TONE[:default],5)
      $game_variables[TS_NIGHTDAY] = :default
    end
  end
    
  #-------------------------------------------
  # Mise à jour des phases de la journée
  #-------------------------------------------
  def self.update_phases(clock = Time.now)
    season = $game_variables[TS_SEASON]
    # Maj des phases et du ton
    # Matin
    if clock.hour >= TIME[season][0] and clock.hour < TIME[season][1]
      if $game_variables[TS_NIGHTDAY] != :morning
        $game_screen.start_tone_change(TONE[:morning],5)
        $game_variables[TS_NIGHTDAY] = :morning
      end
      return
    end
    # Jour
    if clock.hour >= TIME[season][1] and clock.hour < TIME[season][2]
      if $game_variables[TS_NIGHTDAY] != :day
        $game_screen.start_tone_change(TONE[:day],5)
        $game_variables[TS_NIGHTDAY] = :day
      end
      return
    end
    # Crépuscule
    if clock.hour >= TIME[season][2] and clock.hour < TIME[season][3]
      if $game_variables[TS_NIGHTDAY] != :sunset
        $game_screen.start_tone_change(TONE[:sunset],5)
        $game_variables[TS_NIGHTDAY] = :sunset
      end
      return
    end
    # Nuit
    if clock.hour >= TIME[season][3] or clock.hour < TIME[season][0]
      if $game_variables[TS_NIGHTDAY] != :night
        $game_screen.start_tone_change(TONE[:night],5)
        $game_variables[TS_NIGHTDAY] = :night
        #Audio.bgm_play("Audio/BGM/" + NIGHt_MUSIC, 100, 100)
      end
      return
    end
  end
  
  #-------------------------------------------
  # Mise à jour des variables de temps
  # Ne prend pas en compte TS_NAMEDAY
  #-------------------------------------------
  def self.update_variables(clock = Time.now)
    $game_variables[TS_NIGHTDAY] = :default
    $game_variables[TS_MIN] = clock.min
    $game_variables[TS_HOUR] = clock.hour
    $game_variables[TS_MDAY] = clock.mday
    if $game_variables[TS_MONTH] != clock.mon
      $game_variables[TS_MONTH] = clock.mon
      if clock.mon >= 1 and clock.mon <= 3
        $game_variables[TS_SEASON] = :winter
      elsif clock.mon >= 4 and clock.mon <= 6
        $game_variables[TS_SEASON] = :spring
      elsif clock.mon >= 7 and clock.mon <= 9
        $game_variables[TS_SEASON] = :summer
      else
        $game_variables[TS_SEASON] = :fall
      end
    end
  end
  
  def self.get_min
    $game_variables[TS_MIN] = Time.new.min
    return $game_variables[TS_MIN]
  end
  
  def self.get_hour
    $game_variables[TS_HOUR] = Time.new.hour
    return $game_variables[TS_HOUR]
  end
  
  def self.get_month
    $game_variables[TS_MONTH] = Time.new.mon
    return $game_variables[TS_MONTH]
  end
  
  def self.get_name_day
    case clock.strftime("%A")
    when "Monday"
      jour = "Lundi"
    when "Tuesday"
      jour = "Mardi"
    when "Wednesday"
      jour = "Mercredi"
    when "Thursday"
      jour = "Jeudi"
    when "Friday"
      jour = "Vendredi"
    when "Saturday"
      jour = "Samedi"
    when "Sunday"
      jour = "Dimanche"
    end
    $game_variables[TS_NAMEDAY] = jour
    return jour
  end
  
  def self.get_season(mon)
    if $game_variables[TS_MONTH] != mon
      if mon >= 1 and mon <= 3
        $game_variables[TS_SEASON] = :winter
      elsif mon >= 4 and mon <= 6
        $game_variables[TS_SEASON] = :spring
      elsif mon >= 7 and mon <= 9
        $game_variables[TS_SEASON] = :summer
      else
        $game_variables[TS_SEASON] = :fall
      end
    end
    return $game_variables[TS_SEASON]
  end
  
  #-------------------------------------------
  # Forcer l'application d'un ton d'une phase
  #-------------------------------------------
  def self.set_tone(phase, frame = 1)
    $game_screen.start_tone_change(TONE[phase],frame)
  end
  
  #-------------------------------------------
  # remettre le ton associé à l'effet J/N en cours
  #-------------------------------------------
  def self.reset_tone(frame = 1)
    case $game_variables[TS_NIGHTDAY]
    when :night #"Nuit"
      $game_screen.start_tone_change(TONE[:night],frame)
    when :morning #"Matin"
      $game_screen.start_tone_change(TONE[:morning],frame)
    when :day #"Jour"
      $game_screen.start_tone_change(TONE[:day],frame)
    when :twilight #"Crépuscule"
      $game_screen.start_tone_change(TONE[sunset],frame)
    else
      $game_screen.start_tone_change(TONE[:default],frame)
    end
  end
  
  #-------------------------------------------
  # Appliquer une musique de nuit
  #-------------------------------------------
  def self.nightmusic(new_music)
    if $game_variables[TS_NIGHTDAY] == :night
      Audio.bgm_play("Audio/BGM/" + new_music, 100, 100)
    end
  end
  
end


#-------------------------------------------------------------------------------
# ● Application des tons sur la map
#-------------------------------------------------------------------------------

class Scene_Map
  
  # MAJ des var de temps au lancement d'une Scene_Map
  alias ts_main main
  def main
    TIMESYS::update_variables
    ts_main
  end
  
  # MAJ temps et effet J/N
  alias ts_update update
  def update
    TIMESYS::update
    ts_update
  end

end