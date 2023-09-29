#============================================================================== 
# ■ Sprite_Shadow - Damien Linux
# 22/12/2020
# Ajoute une ombre intégrée au Sprite Character
#============================================================================== 
class Sprite_Shadow < RPG::Sprite
  attr_accessor :master # Le Sprite_Character auquel l'ombre appartient
  
  def initialize(viewport, character = nil)
    super(viewport)
    @master = character
    self.bitmap = RPG::Cache.picture(SHADOW)
    self.visible = false
    self.opacity = 75
    update
  end
  
  def update
    super
    if not $game_switches[OMBRE_NON_ACTIF]
      self.opacity = 75
      # Joueur
      if @master.character.is_a?(Game_Player) and $game_map.map_id != POKEMON_S::_WMAPID
        self.x = @master.x - 16
        self.y = @master.y + 15
        self.ox = @master.ox 
        self.oy = @master.oy
        self.visible = true
      # Pokémon Suiveur
      elsif @master.character.is_a?(Follower_Pkm) and
              $game_party.follower_pkm.character_name.length > 0
        self.x = @master.x - 10
        self.y = @master.y + 15
        self.ox = @master.ox 
        self.oy = @master.oy
        self.visible = $game_switches[PKM_TRANSPARENT_SWITCHES]
      # Events ayant un commentaire "o" en tout début
      elsif @master.character.is_a?(Game_Event)  and 
              @master.character.list != nil and @master.character.list[0].parameters != nil and
              @master.character.list[0].parameters == ["o"]
        self.x = @master.x - 9
        self.y = @master.y + 14
        self.ox = @master.ox 
        self.oy = @master.oy
        self.visible = true
      end
    else
      self.opacity = 0
    end
  end
end

class Sprite_Character < RPG::Sprite
  attr_accessor :shadow
  
  alias sp_initialize initialize 
  def initialize(viewport, character = nil)
    @shadow = Sprite_Shadow.new(viewport, self)
    sp_initialize(viewport, character)
  end
  
  alias sp_update update 
  def update
    sp_update
    @shadow.update
  end
end