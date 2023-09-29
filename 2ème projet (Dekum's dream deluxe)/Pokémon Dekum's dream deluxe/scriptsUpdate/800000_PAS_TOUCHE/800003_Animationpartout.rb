#=================================
# Animation Partout v1.1
# Script créé par Zeus81
#=================================
#
#
# Manuel d'utilisation :
#
# Faire insérer un script et écrire :
#             $game_temp.animations.push([id, hit, x, y])
#
# id      =   Id de l'animation.
#
# hit     =   Animation Touché ou Manqué (Voir les réglages des animations).
#             Pour Touché -> hit = true
#             Pour Manqué -> hit = false
#
# x et y  =   Position ou sera affichée l'animation.
#             On peux mettre des nombres décimaux pour plus de précision.
#
# Exemple d'utilisation :
#             id  = 1
#             hit = true
#             x   = 14
#             y   = 7
#             $game_temp.animations.push([id, hit, x, y])
#
# Note :
#             Dans les animations seuls les "Flash" sur l'écran seront visible, pas ceux sur la cible.
#             (Forcement vu qu'il n'y a pas de cible)
#             La portée de l'animation ("Haut", "Milieu", "Bas") ne changera rien à sa position.
#             Par contre si c'est "Ecran", ce sera comme si l'animation était faite sur n'importe quel évènement.
#             Les animations s'affichent uniquement quand on est sur la map (c-à-d pas pendant les combats ou les menus).
 
class Game_Temp
  
  attr_accessor :animations
  
  alias zeus81_animation_partout_game_temp_initialize initialize
  def initialize
    zeus81_animation_partout_game_temp_initialize
    @animations = []
  end
  
end
 
 
class Spriteset_Map
  
  alias zeus81_animation_partout_spriteset_map_initialize initialize
  def initialize
    @animations_sprites = []
    zeus81_animation_partout_spriteset_map_initialize
  end
  
  alias zeus81_animation_partout_spriteset_map_dispose dispose
  def dispose
    @animations_sprites.each {|sprite| sprite.dispose}
    zeus81_animation_partout_spriteset_map_dispose
  end
  
  alias zeus81_animation_partout_spriteset_map_update update
  def update
    if @animations_sprites != nil
      $game_temp.animations.each {|data| @animations_sprites.push(Sprite_Animation.new(@viewport1, data))}
      $game_temp.animations.clear
      need_compact = false
      for i in 0...@animations_sprites.size
        @animations_sprites[i].update
        if @animations_sprites[i].disposed?
          @animations_sprites[i] = nil
          need_compact = true
        end
      end
      @animations_sprites.compact! if need_compact
    end
    zeus81_animation_partout_spriteset_map_update
  end
  
end
 
 
class Sprite_Animation < RPG::Sprite
  
  def initialize(viewport, data)
    super(viewport)
    animation($data_animations[data[0]], data[1])
    @real_x = data[2] * 128
    @real_y = data[3] * 128
  end
  
  def update
    super
    self.x = (@real_x - $game_map.display_x + 3) / 4 + 16
    self.y = (@real_y - $game_map.display_y + 3) / 4
    self.dispose if @_animation_duration == 0
  end
  
end