#==============================================================================
# Traces de Pas - G!n0
# 22/12/20
#==============================================================================

#-------------------------------------------------------------------------------
# Le system_tag des traces de pas est enregistré dans TRACE_TAG.
# Il est pour l'instant égal à 1.

# Il y a deux types de traces : les traces de pas et les traces de vélo.
# Pour que les traces de vélo s'affichent, il faut que le nom du character concerné
# finisse par : _bike

# Il y a possibilté d'interdire les traces de pas pour un character donné :
# Dans la liste des commandes de l'événement, mettre en première ligne la
# commande "Commentaire" et écrire dans le commentaire le mot ":nt"
#-------------------------------------------------------------------------------

TRACE_TAG = 1

#-------------------------------------------------------------------------------
# Classe Trace de Pas
#-------------------------------------------------------------------------------
class Trace_Pas < RPG::Sprite

  #----------------------------------------------------
  # Initialisation
  #----------------------------------------------------
  def initialize(viewport=nil, character=nil)
    super(viewport)
    @character = character
    # Gestion générale du sprite "trace de pas"
    self.x = 0
    self.y = 0
    self.z = @character.is_a?(Game_Player) ? 9 :  5
    self.opacity = 0
    # Gestion de la vie de la trace de pas
    @trace = false
    @destruction = false
    # Gestion position/direction de la trace de pas
    @real_x = 0
    @real_y = 0
    @direction = @character.direction
    #chargement bitmap
    load_bitmap
    # Mise à jour du sprite
    update
  end

  #----------------------------------------------------
  # Mise à jour du sprite
  #----------------------------------------------------
  def update
    super
    #Si la trace est active
    if @trace
      # on corrige la position du sprite "Trace de pas"
      self.x = (@real_x - $game_map.display_x + 3)/4 + 16 
      self.y = (@real_y - $game_map.display_y + 3)/4 + 32
      
      # Si le processus de destruction n'est pas enclenché
      unless @destruction
        # On enclenche le processus de destruction si character est en mouvement
        if moving
          load_bitmap
          sx = ((@character.direction - @direction )/2) % 4 * @cw
          sy = (@direction - 2) / 2 * @ch
          self.src_rect.set(sx, sy, @cw, @ch)
          self.opacity = 255
          @destruction = true
        end
        
      # Si le processus de destruction est activé
      else
        self.opacity -= 15
        # Disparition de la trace de pas
        if self.opacity <= 0
          @trace = false
          self.x = 0
          self.y = 0
        end
      end
    end
    
  end
  
  #----------------------------------------------------
  #Chargement du bon bitmap
  #----------------------------------------------------
  def load_bitmap
    name = :trace_pas
    if @character.character_name.end_with?("_bike")
      name = :trace_velo
    end
    if @trace_name != name
      @trace_name = name
      self.bitmap = RPG::Cache.picture(DATA_TRACES[name])
      @cw = bitmap.width / 4
      @ch = bitmap.height / 4
      self.ox = @cw / 2
      self.oy = @ch
      self.src_rect.set(0, 0, @cw, @ch)
    end
  end
  
  #----------------------------------------------------
  # Détecteur de mouvement
  #----------------------------------------------------
  def moving
    return ( @character.real_x % 128 != 0 or @character.real_y % 128 != 0 )
  end
  
  #----------------------------------------------------
  # MAJ de la direction lorsque le sprite trace de pas est en attente de placement
  #----------------------------------------------------
  def update_dir
    if !@trace and moving
      @direction = @character.direction
    end
  end
  
  #----------------------------------------------------
  # MAJ du detecteur de positon
  #----------------------------------------------------
  def update_pos
    if !@trace and !moving
      @real_x = @character.real_x
      @real_y = @character.real_y
    end
  end
  
  #----------------------------------------------------
  # Détecter le sable
  #----------------------------------------------------
  def sand?
    return ($game_map.system_tag(@character.real_x / 128, 
            @character.real_y / 128) == TRACE_TAG)
  end
  
  #----------------------------------------------------
  #Placer la trace de pas sous le character quand c'est son tour
  #----------------------------------------------------
  def place
    # Detection sable et chagement de position du character
    if sand? and (@real_x != @character.real_x or
        @real_y != @character.real_y)
      # Conditions pour placer et activer la trace
      if !@trace and !moving
        # Gestion de la vie de la trace de pas
        @trace = true
        @destruction = false
        # Gestion position/direction de la trace de pas
        @real_x = @character.real_x
        @real_y = @character.real_y
        return true
      end
    end
    return false
  end
  
end


#-------------------------------------------------------------------------------
# Gestion des traces de pas
#-------------------------------------------------------------------------------
class Traces
  #----------------------------------------------------
  # Initialisation : 12 pas par character
  #----------------------------------------------------
  def initialize(viewport, character = nil)
    @character = character
    # Liste des pas
    @list = Array.new(12){Trace_Pas.new(viewport,@character)}
    # Pour selectionner le pas en attente
    @turn = 0
  end
  
  #----------------------------------------------------
  # Mise à jour du groupe de pas
  #----------------------------------------------------
  def update
    # MAJ direction du pas en attente
    @list[@turn].update_dir
    #Si le placement aboutit, on passe à un autre pas de la liste
    if @list[@turn].place
      @turn = (@turn + 1) % 12
    end
    # MAJ du detecteur de position du pas en attente
    @list[@turn].update_pos
    # MAJ principale de tous les pas
    for pas in @list
      pas.update
    end
  end
  
  #----------------------------------------------------
  # Libération de la mémoire
  #----------------------------------------------------
  def dispose
    for pas in @list
      pas.dispose
    end
  end
  
end


#-------------------------------------------------------------------------------
# Ré-édition de la classe Sprite_character
#-------------------------------------------------------------------------------
class Sprite_Character < RPG::Sprite
  #----------------------------------------------------
  # Déterminer si le character est invisible
  #----------------------------------------------------
  def character_invisible
    @character.character_name == "" or @character.transparent or
    @character.opacity <= 0
  end
          
  #----------------------------------------------------
  # Vérifier si les traces de pas sont interdites
  #----------------------------------------------------
  def no_traces
    character_invisible or
    ( @character.is_a?(Game_Event) and @character.list != nil and 
      @character.list[0].code == 108 and 
      @character.list[0].parameters[0].include?(":nt") )
  end

  #----------------------------------------------------
  # Vérifier la nécessité de créer des traces
  #----------------------------------------------------
  def check_traces
    if @character.system_tag == TRACE_TAG
      # Si les traces ne sont pas interdites
      unless no_traces
        @traces ||= Traces.new(viewport, @character)
        return
      end
      # Si les traces sont interdites et si les traces existent
      if @traces
        @traces.dispose
        @traces = nil
      end
    end
  end
  
  #----------------------------------------------------
  # Mise à jour
  #----------------------------------------------------
  alias trace_update update
  def update
    trace_update
    # Création des traces quand c'est nécessaire
    check_traces
    # Mise à jour des traces si elles existent
    @traces.update if @traces
  end
  
  #----------------------------------------------------
  # Libération de la mémoire
  #----------------------------------------------------
  def dispose
    # On libère les sprites de tous les pas si les traces existent
    @traces.dispose if @traces
    super
  end
  
end