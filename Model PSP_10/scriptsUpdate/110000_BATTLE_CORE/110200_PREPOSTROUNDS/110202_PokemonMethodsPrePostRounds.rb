#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# 26/07/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 02/11/19 et 04/01/2020
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#----------------------------------------------------------------------------- 
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Core
  # - Actions périodiques : Météo et voeux
  # - Actions des status
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Actions périodiques : Météo et voeux
    #------------------------------------------------------------ 
    # Programmation de l'attaque souvenirs
    # list : Liste des acteurs
    def souvenirs(list)
      list.each do |array|
        target = array[0]
        target_sprite = array[1]
        target_status = array[2]
        if target.effect_list.include?(:voeu)
          bonus = target.hp / 2
          draw_text("Un souhait est réalisé.")
          heal(target, target_sprite, target_status, bonus)
          wait(40)
        end
      end
    end
    
    # Suite du déroulement de la pluie
    # list : Liste des acteurs
    def pluie(list, count)
      if $battle_var.rain? and count != 0
        draw_text("La pluie continue de", "tomber.")
        animation = $data_animations[493]
        @actor_sprite.animation(animation, true) if $anim != 0
        loop do
          @actor_sprite.update
          $scene.battler_anim ; Graphics.update
          Input.update
          if not(@actor_sprite.effect?)
            break
          end
        end
        wait(20)
      elsif $battle_var.rain? and count == 0
        draw_text("La pluie s'est arrêtée.")
        wait(40)
        $battle_var.reset_weather
      end
    end
    
    # Suite du déroulement de l'ensoleillement
    # list : Liste des acteurs
    def soleil(list, count)
      if $battle_var.sunny? and count != 0
        draw_text("Les rayons du soleil","tapent fort.")
        animation = $data_animations[492]
        @actor_sprite.animation(animation, true) if $anim != 0
        loop do
          @actor_sprite.update
          $scene.battler_anim ; Graphics.update
          Input.update
          if not(@actor_sprite.effect?) #and Input.trigger?(Input::C)
            break
          end
        end
        wait(20)
      elsif $battle_var.sunny? and count == 0
        draw_text("Le soleil est parti.")
        wait(40)
        $battle_var.reset_weather
      end
    end
    
    # Suite du déroulement de la tempête de sable
    # list : Liste des acteurs
    def tempete_sable(list, count)
      if $battle_var.sandstorm? and count != 0
        draw_text("La tempête de sable souffle.")
        animation = $data_animations[494]
        @actor_sprite.animation(animation, true) if $anim != 0
        loop do
          @actor_sprite.update
          $scene.battler_anim ; Graphics.update
          Input.update
          if not(@actor_sprite.effect?) #and Input.trigger?(Input::C)
            break
          end
        end
        
        # Dégats
        list.each do |array|
          target = array[0]
          target_sprite = array[1]
          target_status = array[2]
          if target.type_ground? or target.type_rock? or target.type_steel? or
             target.effect_list.include?(:tunnel) or 
             target.effect_list.include?(:plongee) or
             target.ability_symbol == :baigne_sable or 
             target.ability_symbol == :envelocape or
            (target.ability_symbol == :voile_sable and 
            (not target.effect_list.include?(:suc_digestif) or 
             not target.effect_list.include?(:soucigraine)))
            next
          end
          # Capacite speciale : Garde Magik
          if target.ability_symbol != :garde_magik 
            damage = target.max_hp / 16
            heal(target, target_sprite, target_status, -damage)
          end
        end
      elsif $battle_var.sandstorm? and count == 0
        draw_text("La tempête de sable s'est arretée.")
        wait(40)
        $battle_var.reset_weather
      end
    end
    
    # Suite du déroulement de la grêle
    # list : Liste des acteurs
    def grele(list, count)
      if $battle_var.hail? and count > 0
        draw_text("Il grêle...")
        animation = $data_animations[495]
        @actor_sprite.animation(animation, true) if $anim != 0
        loop do
          @actor_sprite.update
          $scene.battler_anim ; Graphics.update
          Input.update
          if not(@actor_sprite.effect?)
            break
          end
        end
        
        # Dégâts
        list.each do |array|
          target = array[0]
          target_sprite = array[1]
          target_status = array[2]
          if target.type_ice? or
              target.effect_list.include?(:tunnel) or 
              target.effect_list.include?(:plongee) or 
              target.ability_symbol == :envelocape
            next
          end
          # Capacite speciale : Garde Magik
          if target.ability_symbol != :garde_magik
            damage = target.max_hp / 16
            heal(target, target_sprite, target_status, -damage)
          end
        end
      elsif $battle_var.hail? and count == 0
        draw_text("La grêle s'est arrêtée.")
        wait(40)
        $battle_var.reset_weather
      end
    end
    
    #------------------------------------------------------------  
    # Actions des status
    #------------------------------------------------------------ 
    def empoisonnement(actor)
      if actor == @actor
        actor_sprite = @actor_sprite
        actor_status = @actor_status
      else
        actor_sprite = @enemy_sprite
        actor_status = @enemy_status
      end
      damage = actor.poison_effect
      draw_text(actor.given_name + " souffre", "du poison.")
      status_animation(actor_sprite, actor.status)
      heal(actor, actor_sprite, actor_status, -damage)
      wait(20)
    end
    
    def empoisonnement_fort(actor)
      if actor == @actor
        actor_sprite = @actor_sprite
        actor_status = @actor_status
      else
        actor_sprite = @enemy_sprite
        actor_status = @enemy_status
      end
      damage = actor.toxic_effect
      draw_text(actor.given_name + " souffre", "gravement du poison.")
      status_animation(actor_sprite, actor.status)
      heal(actor, actor_sprite, actor_status, -damage)
      wait(20)
    end
    
    def brulure(actor)
      if actor == @actor
        actor_sprite = @actor_sprite
        actor_status = @actor_status
      else
        actor_sprite = @enemy_sprite
        actor_status = @enemy_status
      end
      damage = actor.burn_effect
      draw_text(actor.given_name + " souffre", "de ses brûlures.")
      status_animation(actor_sprite, actor.status)
      heal(actor, actor_sprite, actor_status, -damage)
      wait(20)
    end
  end
end