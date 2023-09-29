# Fixe les images -- XHTMLBoy (http://funkywork.blogspot.com) Adapté par Grim
# Pour permettre à une image de rester fixée sur la carte, il faut que son
# nom commence par FIX- ou alors utiliser la fonction "fixed_pictures(id1, id2, id3 etc.)"
# qui permet de fixer une (ou plusieurs) images sur la carte.
# Par défaut, les images sont supprimée a chaque téléportation sauf si vous utilisez
# la commande "add_stayed_pictures(id1, id2 etc.)" qui permet au images de rester
# malgré la téléportation. (il existe aussi remove_stayed_pictures qui annule l'effet stay des images)
 
#==============================================================================
# ** Game_Map
#------------------------------------------------------------------------------
#  This class handles maps. It includes scrolling and passage determination
# functions. The instance of this class is referenced by $game_map.
#==============================================================================

# Mettre à false si vous installez ceci sur un jeu FixPictures qui n'utilisait pas FixPictures
# PAR DEFAUT A TRUE :
# Toutes les images sont effacées en changeant de map sauf celles dans @stay_pictures (ajoutées via add_stayed_pictures)
# Si à FALSE :
# Toutes les images sont gardées en changeant de map sauf celles dans @stay_pictures qui sont supprimées (ajoutées via add_stayed_pictures)
COMPATIBLE_FIX_PICTURES = true

class Game_Map
  #--------------------------------------------------------------------------
  # * Alias
  #--------------------------------------------------------------------------
  alias fix_setup setup
  alias fix_initialize initialize
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :fix_pictures
  attr_accessor :stay_picture
 
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    fix_initialize
    @stay_pictures = []
    @screen = $game_screen
  end
  
  #--------------------------------------------------------------------------
  # * Setup
  #--------------------------------------------------------------------------
  def setup(map_id, reload_map = false)
    fix_setup(map_id, reload_map)
    (1..20).each do |id|
      if @screen.pictures[id]
        if COMPATIBLE_FIX_PICTURES
          @screen.pictures[id].erase unless stayed?(id)
        else
          @screen.pictures[id].erase if stayed?(id)
        end
      end
    end
    @fix_pictures = []
  end

  #--------------------------------------------------------------------------
  # * Set fixed pictures
  #--------------------------------------------------------------------------
  def set_fixed_pictures(ids)
    @fix_pictures = ids
  end
 
  #--------------------------------------------------------------------------
  # * add stay pictures
  #--------------------------------------------------------------------------
  def add_stay_pictures(ids)
    @stay_pictures += ids
    @stay_pictures.uniq!
  end
 
  #--------------------------------------------------------------------------
  # * remove stay pictures
  #--------------------------------------------------------------------------
  def remove_stay_pictures(ids)
    ids.each do |id|
      @stay_pictures.delete(id)
    end
  end
 
  #--------------------------------------------------------------------------
  # * 's fixed
  #--------------------------------------------------------------------------
  def fixed?(id)
    @fix_pictures.include?(id)
  end
 
  #--------------------------------------------------------------------------
  # * 's stayed
  #--------------------------------------------------------------------------
  def stayed?(id)
    @stay_pictures.include?(id)
  end
end
 
#==============================================================================
# ** Sprite_Picture
#------------------------------------------------------------------------------
#  This sprite is used to display pictures. It observes an instance of the
# Game_Picture class and automatically changes sprite states.
#==============================================================================
class Sprite_Picture
  #--------------------------------------------------------------------------
  # * alias
  #--------------------------------------------------------------------------
  alias fix_initialize initialize
  alias fix_update_position update

  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :anchor
  
  #--------------------------------------------------------------------------
  # * Object Initialization
  #    picture : Game_Picture
  #--------------------------------------------------------------------------
  def initialize(viewport, picture)
    fix_initialize(viewport, picture)
    @anchor = (@picture.name =~ /^Fix\_/) != nil
  end
 
  #--------------------------------------------------------------------------
  # * Update Position
  #--------------------------------------------------------------------------
  def update
    fix_update_position
    @anchor = (@picture.name =~ /^FIX-/) != nil || $game_map.fixed?(@picture.number)
    if @anchor
      new_x =  @picture.x - ($game_map.display_x / 4)
      new_y =  @picture.y - ($game_map.display_y / 4)
      self.x, self.y = new_x, new_y
    else
      self.x = @picture.x
      self.y = @picture.y
      self.z = @picture.number
    end
  end
end
 
#==============================================================================
# ** Game_Interpreter
#------------------------------------------------------------------------------
#  An interpreter for executing event commands. This class is used within the
# Game_Map, Game_Troop, and Game_Event classes.
#==============================================================================
class Interpreter
  #--------------------------------------------------------------------------
  # * define fixed pictures
  #--------------------------------------------------------------------------
  def fixed_pictures(*ids)
    $game_map.set_fixed_pictures(ids)
  end

  #--------------------------------------------------------------------------
  # * define stayed pictures
  #--------------------------------------------------------------------------
  def add_stayed_pictures(*ids)
    $game_map.add_stay_pictures(ids)
  end
 
  #--------------------------------------------------------------------------
  # * remove stayed pictures
  #--------------------------------------------------------------------------
  def remove_stayed_pictures(*ids)
    $game_map.remove_stay_pictures(ids)
  end
end