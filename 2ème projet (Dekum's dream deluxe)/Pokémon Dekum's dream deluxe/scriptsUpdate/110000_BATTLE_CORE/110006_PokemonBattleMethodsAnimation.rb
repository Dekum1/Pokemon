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
# 02/11/19
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
  # Méthodes d'animation sur les pokémon / des attaques :
  # - Attaques
  # - Statut (animation de stats gérés dans Pokemon_Battle_Status_Stats)
  # - Acteur et ennemie K.O. 
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------       
    # Attaques
    #------------------------------------------------------------
    def attack_animation(info, hit, miss, user, user_skill, user_sprite, 
                         target_sprite)
      if miss
        wait(40)
        draw_text("Mais cela échoue !")
        wait(40)
        return
      end
      
      if user == @enemy
        reverse = true
      else
        reverse = false
      end
      
      efficiency = info[2]  
      if hit and efficiency != -2
        # Animation utilisateur
        
        animation_user = $data_animations[user_skill.user_anim_id]
        user_sprite.register_position
        
        if animation_user != nil and $anim != 0
          user_sprite.animation(animation_user, true, reverse)
          until not(user_sprite.effect?)
            user_sprite.update
            $scene.battler_anim ; Graphics.update
          end
        end
        
        user_sprite.reset_position
        
        user_sprite.update
        $scene.battler_anim ; Graphics.update
        
        # Animation Cible
        animation_target = $data_animations[user_skill.target_anim_id]
        target_sprite.register_position
        
        if animation_target != nil and $anim != 0
          target_sprite.animation(animation_target, true, reverse)
          until not(target_sprite.effect?)
            target_sprite.update
            $scene.battler_anim ; Graphics.update
          end
        end
        
        target_sprite.reset_position
        
        target_sprite.update
        $scene.battler_anim ; Graphics.update
      elsif not(hit)
        wait(40)
        draw_text(user.given_name, "rate son attaque !")
        wait(40)
      end
      if hit and user.ability_symbol == :pickpocket and 
         user_skill.direct? and damage > 0 and user.item_hold == 0 and 
         @target.item_hold != 0
        draw_text("#{@actor.given_name} vole l'objet",
                  "de #{@target.given_name} !")
        user.item_hold = @target.item_hold
        @target.item_hold = 0
        wait(40)
      end
    end
    
    # Ecran illuminé 
    def blink(sprite, frame = 4, number = 3)
      0.upto(number) do |i|
        wait(frame)
        sprite.opacity = 0
        $scene.battler_anim ; Graphics.update
        wait(frame)
        sprite.opacity = 255
        $scene.battler_anim ; Graphics.update
      end
    end
    
    def post_attack(info, damage, power)
      efficiency = info[2]
      if damage == 0 and (efficiency != -2 or power == 0)
        return
      end
      critical = info[1]
      if critical  and efficiency != -2 #critical_hit
        draw_text("Coup critique !")
        wait(40)
      end
      case efficiency
      when 1
        draw_text("C'est super efficace !")
        wait(40)
      when -1
        draw_text("Ce n'est pas très efficace...")
        wait(40)
      when -2
        draw_text("Ca ne l'affecte pas...")
        wait(40)
      end
    end

    #------------------------------------------------------------       
    # Statut (animation de stats gérés dans Pokemon_Battle_Status_Stats)
    #------------------------------------------------------------    
    def status_animation(sprite, status)
      animation = $data_animations[469 + status]
      sprite.animation(animation, true) if $anim != 0
      loop do
        sprite.update
        $scene.battler_anim ; Graphics.update
        Input.update
        if not(sprite.effect?)
          break
        end
      end
    end
    
    def stage_animation(sprite, animation)
      sprite.animation(animation, true) if $anim != 0
      loop do
        sprite.update
        $scene.battler_anim ; Graphics.update
        Input.update
        if not(sprite.effect?)
          wait(20)
          break
        end
      end
    end

    # 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 
    # 9 Sol 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 
    # 17 Tenebres
    def type_string(type)
      case type
      when 0
        return "???"
      when 1
        return "NORMAL"
      when 2
        return "FEU"
      when 3
        return "EAU"
      when 4
        return "ELECTRIK"
      when 5
        return "PLANTE"
      when 6
        return "GLACE"
      when 7
        return "COMBAT"
      when 8
        return "POISON"
      when 9
        return "SOL"
      when 10
        return "VOL"
      when 11
        return "PSY"
      when 12
        return "INSECTE"
      when 13
        return "ROCHE"
      when 14
        return "SPECTRE"
      when 15
        return "DRAGON"
      when 16
        return "ACIER"
      when 17
        return "TENEBRES"
      when 18
        return "FEE"
      end
    end
    
    
    # Changement (ou pas) de statut
    def status_string(actor, status)
      string = actor.given_name
      case status
      when -1
        draw_text("#{string} est", "déjà empoisonné !")
        wait(40)
      when -2
        draw_text("#{string} est", "déjà paralysé !")
        wait(40)
      when -3
        draw_text(string, "brûle déjà !")
        wait(40)
      when -4
        draw_text(string, "dort déjà !")
        wait(40)
      when -5
        draw_text(string, "est déjà gelé !")
        wait(40)
      when -6
        draw_text(string, "est déjà confus !")
        wait(40)
      when -8
        draw_text("#{string} est", "déjà gravement empoisonné !")
        wait(40)
      when 1
        draw_text(string, "est empoisonné !")
        wait(40)
      when 2
        draw_text(string, "est paralysé !")
        wait(40)
      when 3
        draw_text(string, "brûle !")
        wait(40)
      when 4
        draw_text(string, "s'endort !")
        wait(40)
      when 5
        draw_text(string, "gèle !")
        wait(40)
      when 6
        draw_text("Cela rend #{string}", "confus !")
        wait(40)
      when 7
        draw_text(string, "est apeuré !")
        wait(40)
      when 8
        draw_text("#{string} est", "gravement empoisonné !")
        wait(40)
      end
    end
    
    #------------------------------------------------------------  
    # Acteur et ennemie K.O. 
    #------------------------------------------------------------         
    def enemy_down
      @enemy.round = 0
      # Si déjà vaincu
      if @enemy_sprite.zoom_y == 0
        return
      end #else
      if FileTest.exist?(@enemy.cry)
        # Récupère les détails de l'illusion
        enemy_illusion = @enemy.get_illusion
        if enemy_illusion != nil
          Audio.se_play(enemy_illusion.cry, 100, 85)
        else
          Audio.se_play(@enemy.cry, 100, 85)
        end
      end
      
      wait(50)
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:ko]}")
      
      loop do
        @enemy_status.x -= 20
        @enemy_sprite.y += 8
        @enemy_sprite.opacity -= 20
        $scene.battler_anim ; Graphics.update
        if @enemy_sprite.y >= 348
          @enemy_sprite.zoom_y = 0
          break
        end
      end
      draw_text(@enemy.given_name, "est K.O.!")
      wait(40)
    end
    
    def actor_down
      @actor.round = 0
      # Si déjà vaincu
      if @actor_sprite.y >= 576
        return
      end #else
      if FileTest.exist?(@actor.cry)
        # Récupère les détails de l'illusion
        actor_illusion = @actor.get_illusion
        if actor_illusion != nil
          Audio.se_play(actor_illusion.cry, 100, 85)
        else
          Audio.se_play(@actor.cry, 100, 85)
        end
      end
      wait(50)
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:ko]}")
      loop do
        @actor_status.x += 20
        @actor_sprite.y += 12
        @actor_sprite.opacity -= 20
        $scene.battler_anim ; Graphics.update
        if @actor_sprite.y >= 576
          break
        end
      end
      draw_text(@actor.given_name, "est K.O. !")
      wait(40)
    end
  end
end