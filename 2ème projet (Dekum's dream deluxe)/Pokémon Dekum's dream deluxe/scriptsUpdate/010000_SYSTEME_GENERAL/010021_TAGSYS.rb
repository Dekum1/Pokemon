#===============================================================================
# Module TAG_SYS - G!n0
#-------------------------------------------------------------------------------
# Gestion des tags (terrain_tags et system_tags)
#===============================================================================

module TAG_SYS
 
  #------------------------------------------------------------------
  # Constantes
  #------------------------------------------------------------------
  # Taille de la liste des terrain_tags
  T_SIZE = 32
  # Taille de la liste des system_tags
  S_SIZE = 32
  
  
  #------------------------------------------------------------------
  # Classes
  #------------------------------------------------------------------
  #----------------------------------------------------
  # classe stockant les terrain_tags et les system_tags
  # d'un tileset
  #----------------------------------------------------
  class Tileset_Tags
    attr_accessor :terrain_tags
    attr_accessor  :system_tags
    
    def initialize(tileset)
      @terrain_tags = tileset.terrain_tags.dup
      @system_tags = tileset.system_tags.dup
    end
  end
  
  
  #------------------------------------------------------------------
  # Méthodes
  #------------------------------------------------------------------
  #----------------------------------------------------
  # Création des system_tags s'ils n'existent pas
  #----------------------------------------------------
  def self.system_tags_check
    1.upto($data_tilesets.size-1) do |tileset_id|
      unless $data_tilesets[tileset_id].system_tags
        size = $data_tilesets[tileset_id].terrain_tags.xsize
        $data_tilesets[tileset_id].system_tags = Table.new(size)
      end
    end
  end

  #----------------------------------------------------
  # Ouverture de l'éditeur
  #----------------------------------------------------
  def self.call_tag_editor
    $game_system.se_play($data_system.decision_se)
    $game_player.straighten
    $scene = Tag_Menu.new
  end
  
  #----------------------------------------------------
  # Compilation
  #----------------------------------------------------
  def self.compilation
    # Vérification de l'existence des system_tags
    self.system_tags_check
    # injection $data_tilesets => Tilesets.rxdata
    file = File.open("Data/Tilesets.rxdata", "wb")
    Marshal.dump($data_tilesets, file)
    file.close
    print "Modifications sauvegardées. Veuillez fermer et rouvrir votre projet
              sans enregistrer votre projet."
    exit
  end
end

#-------------------------------------------------------------------------------
# Rééditions nécessaires pour le support des system_tags
#-------------------------------------------------------------------------------
module RPG
  class Tileset
    attr_accessor :system_tags 
  end
end

class Game_Map
  attr_accessor :system_tags
  
  alias tag_setup setup
  def setup(map_id, reload_map = false)
    tag_setup(map_id, reload_map)
    tileset = $data_tilesets[@map.tileset_id]
    @system_tags = tileset.system_tags
  end
  
  def system_tag(x, y)
    if @map_id != 0
      for i in [2, 1, 0]
        tile_id = data[x, y, i]
        if tile_id == nil or @system_tags[tile_id] == nil
          return 0
        elsif @system_tags[tile_id] != nil and @system_tags[tile_id] > 0
          return @system_tags[tile_id]
        end
      end
    end
    return 0
  end
end

class Game_Character
  def system_tag
    return $game_map.system_tag(@x, @y)
  end
end
