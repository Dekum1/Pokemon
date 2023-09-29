#==============================================================================
# ■ No_Crash_Ressource
#   Krosk
#------------------------------------------------------------------------------
# --------------------------------------------------------  
#  <b style="color:#D0D1D1">Anti</b>-"No such file"  
#  ou comment dédramatiser le manque d'une ressource  
#    par Krosk - merci à Wawower et berka  
# --------------------------------------------------------  
# Ce script permet de continuer le jeu malgré   
# l'absence d'une ressource graphique ou audio  
# que le projet soit crypté ou non.  
#  
# Il n'empêche pas le crash en cas   
# de manque d'une map ou d'un fichier data...  
#   
# L'image manquante est substituée par   
# une image vide, mais vous pouvez  
# à la place utiliser une image de substitution.  
#  
# Le son manquant n'est tout simplement pas joué.  
#   
# Par ailleurs, personnalisez vous même le message  
# NOSUCHTEXT pour signaler au joueur la conduite à adopter.  
#  (utilisez \n pour sauter une ligne)  
#  
# Vous pouvez aussi couper les messages d'avertissement  
# en commentant les lignes de print dans ce script.  
#  (en placant # en tete de ligne)  
# --------------------------------------------------------  
   
NOSUCHTEXT = "Veuillez contacter l'équipe de PSP pour prévenir\nque cette ressource est manquante." 
   
class << Bitmap  
  alias_method :alias_new, :new unless method_defined?(:alias_new)  
  def new(*args)  
    alias_new(*args)  
  rescue 
    if args.size == 1 
      print "La ressource #{args[0]} manque.\n" + NOSUCHTEXT 
    end 
    alias_new(32, 32)  
  end 
end 
   
module Audio  
  class << self 
    alias_method :temp_se_play, :se_play unless method_defined?(:temp_se_play)  
    alias_method :temp_me_play, :me_play unless method_defined?(:temp_me_play)  
    alias_method :temp_bgm_play, :bgm_play unless method_defined?(:temp_bgm_play)  
    alias_method :temp_bgs_play, :bgs_play unless method_defined?(:temp_bgs_play)  
  end 
   
  def self.se_play(filename, volume = 100, pitch = 100)  
    self.temp_se_play(filename, volume, pitch)  
  rescue 
    print "La ressource #{filename} manque.\n" + NOSUCHTEXT 
  end 
     
  def self.me_play(filename, volume = 100, pitch = 100)  
    self.temp_me_play(filename, volume, pitch)  
  rescue 
    print "La ressource #{filename} manque.\n" + NOSUCHTEXT 
  end 
     
  def self.bgm_play(filename, volume = 100, pitch = 100)  
    self.temp_bgm_play(filename, volume, pitch)  
  rescue 
    print "La ressource #{filename} manque.\n" + NOSUCHTEXT 
  end 
     
  def self.bgs_play(filename, volume = 100, pitch = 100)  
    self.temp_bgs_play(filename, volume, pitch)  
  rescue 
    print "La ressource #{filename} manque.\n" + NOSUCHTEXT 
  end 
end 