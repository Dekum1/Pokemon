#===
#RGSS Linker (Kernel)
#  Fonction permettant de charger des extensions utilisant le RGSS Linker
#---
#© 2015 - Nuri Yuri (塗 ゆり)
#===
module Kernel
  unless @RGSS_Linker #>Pour éviter le problème du RGSS Reset avec les projets sans loader
    
  @RGSS_Linker = {:core => Win32API.new("RGSS Linker.dll","RGSSLinker_Initialize","p","i")}
  Win32API.new("kernel32","GetPrivateProfileString","ppppip","i").call("Game","Library",0,lib_name = "\x00"*32,32,".//Game.ini")
  raise LoadError, "Failed to load RGSS Linker." unless(@RGSS_Linker[:core].call(lib_name)==1)
  lib_name = nil
  module_function
  #===
  #>Kernel.load_module
  #  Permet de charger une extension RGSS
  #---
  #E : module_filename : String : nom de fichier qui contient l'extension
  #    module_function : String : nom de la fonction qui va charger l'extension
  #===
  def load_module(module_filename, module_function)
    return if @RGSS_Linker[module_filename]
    mod = @RGSS_Linker[module_filename] = Win32API.new(module_filename, module_function, "", "")
    mod.call
  end
  
  end #>unless @RGSS_Linker
end