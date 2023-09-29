#=================================
# Audio +
# Script créé par Zeus81
#=================================
# Manuel d'utilisation :
#
# Les commandes suivantes doivent être écrites dans un script.
#
#
# OUVERTURE D'UN NOUVEAU FICHIER AUDIO :
#             Advanced_Audio.new("identifiant", "nom du fichier")
#
# identifiant = Nom quelconque dont on se servira ensuite pour modifier notre son.
#
# nom du fichier = Nom du fichier à lire (avec le chemin et l'extension).
#
# Exemple :   Advanced_Audio.new("BGS 01", "Audio/BGS/020-People02.ogg")
#
# Note : Si un autre fichier audio porte le même identifiant il sera remplacé.
#
#
# DEMARRER LA LECTURE :
#             Advanced_Audio["identifiant"].play(répétition, départ, fin)
#
# identifiant = Identifiant précédemment indiqué.
#               Attention si l'identifiant ne correspond à aucun fichier ouvert, 
#               ça plantera.
#
# répétition = Précise si le fichier doit être lu en boucle ou pas.
#              Pour lire en boucle mettez true, sinon false.
#
# départ = Temps à partir d'où débute la lecture en millisecondes.
#          Si vous mettez -1 ce sera à partir de la dernière position de 
#          lecture.
#
# fin = Temps où s'arrêtera la lecture en ms.
#       Si vous mettez -1 ça ira jusqu'à la fin du fichier.
#
# Exemple :   Advanced_Audio["BGS 01"].play(true, 0, -1)
#
# Note : Les répétitions redémarrent non pas à la position de départ indiqué
# mais au début du fichier.
#
#
# METTRE EN PAUSE :
#             Advanced_Audio["identifiant"].pause
#
#
# SORTIR DE PAUSE :
#             Advanced_Audio["identifiant"].resume
#
#
# ARRETER LA LECTURE :
#             Advanced_Audio["identifiant"].stop
#
# Note : Contrairement à la pause si vous voulez redémarrer la lecture il
# faudra passer par play.
# Ce qui signifie qu'il faudra remettre les options (répétition, départ, fin).
#
#
# FERMER LE FICHIER :
#             Advanced_Audio["identifiant"].close
#
# Note : Ferme le fichier et libère la mémoire (en théorie).
#
#
# MODIFICATION DU VOLUME :
#             Advanced_Audio["identifiant"].volume_change(volume, temps)
#
# volume = Nouveau volume du fichier entre 0 et 100
#
# temps = Durée de transition en nombre de frames.
#
# Exemple :   Advanced_Audio["BGS 01"].volume_change(50, 40)
#
# Note : Par défaut le volume est à 100%
#
#
# MODIFICATION DE LA BALANCE (GAUCHE DROITE) :
#             Advanced_Audio["identifiant"].balance_change(balance, temps)
#
# balance = Nouvelle balance du fichier entre -100 et 100
#           A -100 le son est à gauche, à 0 au centre, à 100 à droite.
#
# Exemple :   Advanced_Audio["BGS 01"].balance_change(-75, 200)
#
# Note : Par défaut la balance est à 0
#
#
# MODIFICATION DE LA VITESSE (TEMPO) :
#             Advanced_Audio["identifiant"].pitch(vitesse)
#
# vitesse = Nouvelle vitesse de lecture en pourcentage.
#           200 = 2x, 100 = 1x, 50 = 0.5x
#
# Exemple :   Advanced_Audio["BGS 01"].pitch(120)
#
# Note : Par défaut la vitesse est à 100%
#
#
# AUTRES FONCTIONS :
#
# Advanced_Audio["identifiant"].position : retourne la position de lecture
# actuelle
# Advanced_Audio["identifiant"].length : retourne la durée totale du fichier
# Advanced_Audio["identifiant"].mode : retourne l'état actuel 
# (playing, paused, stopped)
#
# Advanced_Audio.reset : Ferme tous les fichiers audio
if defined?(Advanced_Audio)
  Advanced_Audio.reset
else
  class << Graphics
    alias zeus81_advanced_audio_update update
    def update
      zeus81_advanced_audio_update
      Advanced_Audio.update
    end
  end

  class Advanced_Audio
    MciSendString = Win32API.new("winmm", "mciSendString", "ppll", "l")
    @@buffer = " "*256
    @@audio = {}
    
    class << self
      def [](aliasname)
        return @@audio[aliasname]
      end

      def call(command)
        return (MciSendString.call(command, @@buffer, @@buffer.size, 0) == 0)
      end

      def update
        @@audio.each_value {|audio| audio.update}
      end
      
      def reset
        @@audio.each_value {|audio| audio.volume(1000); audio.close}
      end
    end
    
    def initialize(aliasname, filename)
      @aliasname = aliasname
      @@audio[@aliasname].close if @@audio[@aliasname] != nil
      @@audio[@aliasname] = self
      Advanced_Audio.call("open \"#{filename}\" alias \"#@aliasname\" type MPEGVideo")
      Advanced_Audio.call("set \"#@aliasname\" time format ms")
      @volume = 1000.0
      @balance = 0.0
      @volume_duration = @balance_duration = 0
      update
    end

    def play(repeat=true, from=-1, to=-1)
      command = "play \"#@aliasname\""
      command.concat(" from #{from}") if from != -1
      command.concat(" to #{to}") if to != -1
      command.concat(" repeat") if repeat
      Advanced_Audio.call(command)
    end

    def pause
      Advanced_Audio.call("pause \"#@aliasname\"")
    end

    def resume
      Advanced_Audio.call("resume \"#@aliasname\"")
    end
    
    def stop
      Advanced_Audio.call("stop \"#@aliasname\"")
    end

    def close
      @@audio.delete(@aliasname)
      Advanced_Audio.call("close \"#@aliasname\"")
    end

    def position
      Advanced_Audio.call("status \"#@aliasname\" position")
      return @@buffer.to_i
    end

    def length
      Advanced_Audio.call("status \"#@aliasname\" length")
      return @@buffer.to_i
    end

    def mode
      Advanced_Audio.call("status \"#@aliasname\" mode")
      return @@buffer.gsub("\000", "").gsub(" ","")
    end

    def pitch(pitch)
      Advanced_Audio.call("set \"#@aliasname\" tempo #{pitch.to_i}")
      Advanced_Audio.call("set \"#@aliasname\" speed #{(pitch*10).to_i}")
    end

    def left_volume(volume)
      Advanced_Audio.call("setaudio \"#@aliasname\" left volume to #{volume.to_i}")
    end

    def right_volume(volume)
      Advanced_Audio.call("setaudio \"#@aliasname\" right volume to #{volume.to_i}")
    end

    def volume(volume)
      Advanced_Audio.call("setaudio \"#@aliasname\" volume to #{volume.to_i}")
    end

    def volume_change(volume, duration=0)
      @volume_target = [[volume*10, 0].max, 1000].min
      @volume_duration = [duration*2, 1].max
    end

    def balance_change(balance, duration=0)
      @balance_target = [[balance*10, -1000].max, 1000].min
      @balance_duration = [duration*2, 1].max
    end

    def update
      if @volume_duration > 0
        @volume = (@volume * (@volume_duration - 1) + @volume_target) / @volume_duration.to_f
        @volume_duration -= 1
      end

      if @balance_duration > 0
        @balance = (@balance * (@balance_duration - 1) + @balance_target) / @balance_duration.to_f
        @balance_duration -= 1
      end

      if @last_volume != @volume or @last_balance != @balance
        @last_balance = @balance
        if $se_master == nil
          @last_volume = @volume
          left_volume((1000 - @balance) * @volume / 1000)
          right_volume((1000 + @balance) * @volume / 1000)
        else
          @last_volume = @volume * $se_master/100
          left_volume((1000 - @balance) * @volume / 1000 * $se_master/100)
          right_volume((1000 + @balance) * @volume / 1000 * $se_master/100)
        end
      end
    end
  end
end