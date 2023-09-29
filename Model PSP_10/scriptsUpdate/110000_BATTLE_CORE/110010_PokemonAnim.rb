#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Anim - FL0RENT
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
module POKEMON_S
  CUT_ACTOR_SPRITE = true
  CUT_ENEMY_SPRITE = true
  class Pokemon_Battle_Core
    @@sprite_timer = 0
    def battler_anim
      if @enemy_sprite and CUT_ENEMY_SPRITE and @enemy_sprite.bitmap
        cut_sprite(@enemy_sprite)
      end
      if @actor_sprite and CUT_ACTOR_SPRITE
        cut_sprite(@actor_sprite)
      end

      @@sprite_timer += 1
      return if @@sprite_timer < 2
      @@sprite_timer = 0
      if @enemy_sprite and CUT_ENEMY_SPRITE and @enemy_sprite.bitmap
        move_rect @enemy_sprite
      end
      if @actor_sprite and CUT_ACTOR_SPRITE
        move_rect @actor_sprite
      end

    end

    def cut_sprite(sprite)
      sprite.set_base_zoom(1) if sprite.bitmap.width < 400
      return if sprite.bitmap.width < 400
      sprite.set_base_zoom(2)
      actor_sprite.set_base_zoom(3)
      sprite.src_rect.width = sprite.bitmap.height
      sprite.src_rect.height = sprite.bitmap.height
      sprite.ox = (sprite.bitmap.height/2)
    end

    def move_rect(sprite)
      return if sprite.bitmap.width < 400
      sprite.src_rect.x += sprite.bitmap.height
      if sprite.src_rect.x >= sprite.bitmap.width
        sprite.src_rect.x = 0
      end
    end
  end
end