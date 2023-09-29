#===
#Audio (FmodEx)
#  Réécriture du module Audio pour intégrer l'utilisation de FmodEx
#---
#© 2015 - Nuri Yuri (塗 ゆり)
#© 2015 - GiraPrimal : Concept LOOP_TABLE
#---
#Script réalisé par des membres de Community Script Project
#===
module Audio
  LOOP_TABLE = [
  # [ "Audio/xxx/Nom_de_fichier", debut, fin ]
  # Ajoutez ici
   
 
  # Note : Pensez à ajouter une virgule après chaque ] 
  #        (sauf pour la dernière ligne et le ] ci-dessous).
  ]
  #---
  #>Mise en minuscule des noms de fichier pour améliorer la recherche
  #---
  LOOP_TABLE.each do |i| i[0].downcase! end
  
  unless @bgm_play #>Pour éviter le problème du RGSSReset
  #===
  #>Chargement et initialisation de FmodEx
  #===
  Kernel.load_module("RGSS FmodEx.dll","Init_FmodEx")
  ::FmodEx.init(32)
  #---
  #>Indication de la lib' utilisée par défauts
  #---
  @library = ::FmodEx
  #---
  #>Sauvegarde des fonctions du RGSS
  #---
  @bgm_play = method(:bgm_play)
  @bgm_fade = method(:bgm_fade)
  @bgm_stop = method(:bgm_stop)
  @bgs_play = method(:bgs_play)
  @bgs_fade = method(:bgs_fade)
  @bgs_stop = method(:bgs_stop)
  @me_play = method(:me_play)
  @me_fade = method(:me_fade)
  @me_stop = method(:me_stop)
  @se_play = method(:se_play)
  @se_stop = method(:se_stop)
  #---
  #>Définition des volumes
  #---
  @master_volume = 100
  @sfx_volume = 100
  #===
  #>Définition des extensions supportés par FmodEx
  #===
  EXT = [".mp3", ".ogg", ".wav", ".mid", ".aac", ".wma", ".it", ".xm", ".mod", ".s3m", ".midi"]
  #===
  #>Création/définition des fonctions
  #===
  module_function
    def bgm_play(file_name, volume = 100, pitch = 100)
      unless $bgm_master
        volume = volume * @master_volume / 100
      else
        volume = volume * @master_volume / 100 * $bgm_master/100
      end
      return @bgm_play.call(file_name, volume, pitch) if(@library != ::FmodEx)
      filename = file_name
      filename = check_file(file_name)
      bgm = ::FmodEx.bgm_play(filename, volume, pitch)
      loop_audio(bgm, file_name)
    end
    
    def bgm_fade(time)
      return @bgm_fade.call(time) if(@library != ::FmodEx)
      ::FmodEx.bgm_fade(time)
    end
    
    def bgm_stop
      return @bgm_stop.call if(@library != ::FmodEx)
      ::FmodEx.bgm_stop
    end
    
    def bgs_play(file_name, volume = 100, pitch = 100)
      unless $bgs_master
        volume = volume * @sfx_volume / 100
      else
        volume = volume * @sfx_volume / 100 * $bgs_master/100
      end
      return @bgs_play.call(file_name, volume, pitch) if(@library != ::FmodEx)
      filename = check_file(file_name)
      bgs = ::FmodEx.bgs_play(filename, volume, pitch)
      loop_audio(bgs, file_name)
    end
    
    def bgs_fade(time)
      return @bgs_fade.call(time) if(@library != ::FmodEx)
      ::FmodEx.bgs_fade(time)
    end
    
    def bgs_stop
      return @bgs_stop.call if(@library != ::FmodEx)
      ::FmodEx.bgs_stop
    end
    
    def me_play(file_name, volume = 100, pitch = 100)
      unless $me_master
        volume = volume * @master_volume / 100
      else
        volume = volume * @master_volume / 100 * $me_master/100
      end
      return @me_play.call(file_name, volume, pitch) if(@library != ::FmodEx)
      file_name = check_file(file_name)
      ::FmodEx.me_play(file_name, volume, pitch)
    end
    
    def me_fade(time)
      return @me_fade.call(time) if(@library != ::FmodEx)
      ::FmodEx.me_fade(time)
    end
    
    def me_stop
      return @me_stop.call if(@library != ::FmodEx)
      ::FmodEx.me_stop
    end
    
    def se_play(file_name, volume = 100, pitch = 100)
      unless $se_master
        volume = volume * @sfx_volume / 100
      else
        volume = volume * @sfx_volume / 100 * $se_master/100
      end
      return @se_play.call(file_name, volume, pitch) if(@library != ::FmodEx)
      file_name = check_file(file_name)
      ::FmodEx.se_play(file_name, volume, pitch)
    end
    
    def se_stop
      return @se_stop.call if(@library != ::FmodEx)
      ::FmodEx.se_stop
    end
    
    #===
    #>check_file
    #  Vérifie la présence du fichier et retourne le nom du fichier existant
    #  /!\ Ne corrige pas la connerie
    #====
    def check_file(file_name)
      return file_name if File.exist?(file_name)
      ext = EXT.find { |ext| File.exist?(file_name + ext) } || ""
      return file_name + ext
    end

    #===
    #>loop_audio
    # Fonction permettant de réaliser automatiquement l'appel de set_loop_points
    #===
    def loop_audio(sound, file_name)
      filename = file_name.downcase
      LOOP_TABLE.each do |i|
        if(i[0] == filename)
          return sound.set_loop_points(i[1], i[2])
        end
      end
    end
  end
end