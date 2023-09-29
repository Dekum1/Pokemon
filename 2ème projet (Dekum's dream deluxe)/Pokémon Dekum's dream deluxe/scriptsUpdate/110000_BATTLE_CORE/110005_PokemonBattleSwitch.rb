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
  # Switch de Pokémon :
  # - Méthodes générales pour le switch
  # - Switch acteur
  # - Switch ennemie
  # - Supression des effets lors d'un switch
  # - Switch forcé (côté ennemie)
  # - Rappel du Pokémon
  # - Lancement du Pokémon
  # - Vérifie si le switch est autorisé
  #------------------------------------------------------------
	class Pokemon_Battle_Core
  
    #------------------------------------------------------------  
    # Méthodes générales pour le switch
    #------------------------------------------------------------     
    def switch(list, id1, id2)
      if id1 <= id2
        list.insert(id1, list[id2])
        list.delete_at(id2+1)
        list.insert(id2 + 1, list[id1+1])
        list.delete_at(id1+1)
        return list
      else
        switch(list, id2, id1)
      end
    end
    
    #------------------------------------------------------------  
    # Switch acteur
    #------------------------------------------------------------         
    def actor_pokemon_switch
      @actor.round = 0
      if @switch_id != -1
        if not(@actor.dead?)
          @actor_status.visible = true
        else
          @actor_status.visible = false
        end
        
        switch_effect(@actor, @enemy)
        
        if not(@actor.dead?)
          recall_pokemon
        end
        
        @battle_order = switch(@battle_order, 0, @switch_id)
        @actor = @party.actors[@battle_order[0]]
        if @actor.ability_symbol != :illusion or @party.size <= 1
           @actor_sprite.bitmap = RPG::Cache.battler(@actor.battler_back, 0)
        else
          # CAS DE LA CAPACITE SPECIALE : Illusion
          @actor.illusion=(@party.actors[@party.size - 1])
          # Récupère les détails de l'illusion
          actor_illusion = @actor.get_illusion
          if actor_illusion.id != @actor.id
            @actor.last_name=(@actor.given_name)
            @actor.last_gender=(@actor.gender)
            @actor_sprite.bitmap = RPG::Cache.battler(actor_illusion.battler_back, 
                                                      0)
            @actor.change_name(actor_illusion.given_name)
            @actor.gender=(actor_illusion.gender)
          else
            @actor_sprite.bitmap = RPG::Cache.battler(@actor.battler_back, 0)
            # Reset des effets d'illusion
            @actor.illusion=(nil)
          end
        end
        @actor_status = Pokemon_Battle_Status.new(@actor, false)
        @actor_status.visible = false
        if not($battle_var.have_fought.include?(@actor.party_index))
          $battle_var.have_fought.push(@actor.party_index)
        end
        
        if actor_illusion != nil
          launch_pokemon(actor_illusion)
        else
          launch_pokemon(@actor)
        end
        
        @actor_status.visible = true
        @switch_id = -1
        
        # Cas de Voeu Soin / Danse Lune
        if @actor.effect_list.include?(:vent_arriere)
          heal(@actor, @actor_sprite, @actor_status, @actor.max_hp)
          draw_text("#{@actor.given_name} a été","soigné par VOEU SOIN !")
          @actor.effect.delete(:vent_arriere)
          wait(40)
        end
        
        # Picots et Pics Toxic
        if @picot != nil and @picot[1] > 0
          damage = 1
          case @picot[1]
          when 1
            damage = 0.125
          when 2
            damage = 0.1875
          when 3
            damage = 0.25
          end
          damage *= @actor.max_hp
          condition = (((not @actor.type_fly?) and 
                         @actor.ability_symbol != :levitation or 
                        @actor.type_fly? and @actor.item_hold == 403) and
                       @actor.ability_symbol != :garde_magik)
          if condition
            self_damage(@actor, @actor_sprite, @actor_status, Integer(damage))
            draw_text("Les picots blessent","#{@actor.given_name} !")
            wait(40)
          else
            draw_text(@actor.given_name, "n'est pas affecté par les picots !")
            wait(40)
          end
        end
        if @picot_toxik != nil and @picot_toxik[1] > 0
          effect_temp = 0
          case @picot_toxik[1]
          when 1
            effect_temp = 1
          when 2
            effect_temp = 8
          end
          status_check(@actor, effect_temp, true)
          if not @actor.type_poison? and not @actor.type_steel? and
             @actor.ability_symbol != :garde_magik
            draw_text("Les picots empoisonnent","#{@actor.given_name} !")
            wait(40)
          elsif @actor.type_poison?
            @picot_toxik[1] = 0
            draw_text("Les picots empoisonnés","disparaissent.")
            wait(40)
          end
        end
        
        # Piège de Roc
        if @piege_de_roc_actif != nil and @piege_de_roc_actif[1] > 0
          perte = 0
          efficiency = element_rate(@actor.type1, @actor.type2, 13, 0, 
                                    @actor.effect_list)
          case efficiency
          when 25.0 # double type pas très efficace
            perte = 0.03125
          when 50.0 # un type pas très efficace
            perte = 0.0625
          when 100.0 # normal
            perte = 0.125
          when 200.0 # un type très efficace
            perte = 0.25
          when 400.0 # double type très efficace
            perte = 0.5
          end
          if @actor.ability_symbol != :garde_magik
            damage = Integer(@actor.max_hp * perte)
            self_damage(@actor, @actor_sprite, @actor_status, damage)
            draw_text("Des rochers transpercent","#{@actor.given_name} !")
            wait(40)
            if actor.dead?
              @actor.down
            end
          end
        end
      end
    end
    
    #------------------------------------------------------------  
    # Switch ennemie
    #------------------------------------------------------------ 
    def enemy_pokemon_switch
      @enemy.round = 0
      if @enemy_switch_id != -1
        @enemy_status.visible = false
        
        switch_effect(@enemy, @actor)
        
        @enemy_battle_order = switch($battle_var.enemy_battle_order, 0, 
                                     @enemy_switch_id)
        @enemy = $battle_var.enemy_party.actors[@enemy_switch_id]
        party_enemy = $battle_var.enemy_party
        if @enemy.ability_symbol != :illusion or party_enemy.size <= 1
          @enemy_sprite.bitmap = RPG::Cache.battler(@enemy.battler_face, 0)
        else
          # CAS DE LA CAPACITE SPECIALE : Illusion
          @enemy.illusion=(party_enemy.actors[party_enemy.size - 1])
          # Récupère les détails de l'illusion
          enemy_illusion = @enemy.get_illusion
          if enemy_illusion.id != @enemy.id
            @enemy.last_name=(@enemy.name)
            @enemy.last_gender=(@enemy.gender)
            @enemy_sprite.bitmap = RPG::Cache.battler(enemy_illusion.battler_face, 
                                                      0)
            @enemy.name_enemy=(enemy_illusion.name)
            @enemy.gender=(enemy_illusion.gender)
            type_name = @enemy.male? ? "ennemi" : "ennemie"
            name = @enemy.name + " " + type_name
            @enemy.change_name(name)
          else
            @enemy_sprite.bitmap = RPG::Cache.battler(@enemy.battler_face, 0)
            # Reset des effets d'illusion
            @enemy.illusion=(nil)
          end
        end
        
        $pokedex.add(@enemy, false) #on ajoute pokemon vu dans pokedex
        @enemy_status = Pokemon_Battle_Status.new(@enemy, true)
        @enemy_status.visible = false
        
        if enemy_illusion != nil
          launch_enemy_pokemon(enemy_illusion)
        else
          launch_enemy_pokemon(@enemy)
        end
        @enemy_status.visible = true
        @enemy_switch_id = -1
        
        # Cas de Voeu Soin
        if @enemy.effect_list.include?(:vent_arriere)
          heal(@enemy, @enemy_sprite, @enemy_status, @enemy.max_hp)
          draw_text("#{@enemy.given_name} a été","soigné par VOEU SOIN !")
          @enemy.effect.delete(:vent_arriere)
          wait(40)
        end
        
        # Picots et Pics Toxic
        if @picot != nil and @picot[0] > 0
          damage = 1
          case @picot[0]
          when 1
            damage = 0.125
          when 2
            damage = 0.1875
          when 3
            damage = 0.25
          end
          damage *= @enemy.max_hp
          condition = (((not @enemy.type_fly?) and 
                         @enemy.ability_symbol != :levitation or 
                        @enemy.type_fly? and @enemy.item_hold == 403) and
                       @enemy.ability_symbol != :garde_magik)
          if condition
            self_damage(@enemy, @enemy_sprite, @enemy_status, Integer(damage))
            draw_text("Les picots blessent","#{@enemy.given_name} !")
            wait(40)
          else
            draw_text(@actor.given_name, "n'est pas affecté par les picots !")
            wait(40)
          end
        end
        if @picot_toxik != nil and @picot_toxik[0] > 0
          effect_temp = 0
          case @picot_toxik[0]
          when 1
            effect_temp = 1
          when 2
            effect_temp = 8
          end
          status_check(@enemy, effect_temp, true)
          if not @enemy.type_poison? and not @enemy.type_steel? and
             @enemy.ability_symbol != :garde_magik
            draw_text("Les picots empoisonnent","#{@enemy.given_name} !")
            wait(40)
          elsif @enemy.type_poison?
            @picot_toxik[0] = 0
            draw_text("Les picots empoisonnés","disparaissent.")
            wait(40)
          end
        end
        
        # Piège de Roc
        if @piege_de_roc_actif != nil and @piege_de_roc_actif[0] > 0
          perte = 0
          efficiency = element_rate(@enemy.type1, @enemy.type2, 13, 0, 
                                    @enemy.effect_list)
          case efficiency
          when 25.0 # double type pas très efficace
            perte = 0.03125
          when 50.0 # un type pas très efficace
            perte = 0.0625
          when 100.0 # normal
            perte = 0.125
          when 200.0 # un type très efficace
            perte = 0.25
          when 400.0 # double type très efficace
            perte = 0.5
          end
          if @enemy.ability_symbol != :garde_magik
            damage = Integer(@enemy.max_hp * perte)
            self_damage(@enemy, @enemy_sprite, @enemy_status, damage)
            draw_text("Des rochers transpercent","#{@enemy.given_name} !")
            wait(40)
            if @enemy.dead?
              enemy.down
            end
          end
        end
      end
    end
    
    #------------------------------------------------------------    
    #    Supression des effets lors d'un switch
    #------------------------------------------------------------    
    def switch_effect(actor, enemy)
      # Reset de statut : Toxic
      actor.reset_toxic_count if actor.toxic? 
      # Reset de status : Confuse
      actor.cure_state if actor.confused?
      # Reset capacité spéciale
      actor.ability_active = false
      actor.ability_token = nil
      unless actor.effect_list.include?(:suc_digestif) or 
             actor.effect_list.include?(:soucigraine)
        case actor.ability_symbol
        when :medic_nature # Natural cure / Medic Nature (ab)
          actor.cure
        end
      end
      # CAS DE LA CAPACITE SPECIALE ILLUSION (Rétablis le nom et le sexe)
      reset_illusion(actor)
      # Réinitialisation des stats
      actor.reset_stat_stage(true)
      if @stockage != nil
        # Reset de stockage
        index = actor == @actor ? 0 : 1
        @stockage[index] = 0
      end
      if @clone!= nil
        # Reset de clonage
        index = actor == @actor ? 0 : 1
        @clone[index] = 0 
      end
      
      # Effets supprimés lors du switch
      actor.effect.each do |effect|
        case effect[0]
        when :patience, :multi_tour_confus, :adaptation, :ligotement, 
             :puissance, :vampigraine, :encore, :requiem, 
             :lilliput, :malediction, :attraction, :boul_armure, 
             :brouhaha, :chargeur, :lance_boue, :tourniquet, 
             :gravite, :oeil_miracle, :embargo, :anti_soin, 
             :astuce_force, :suc_digestif, :soucigraine, :anneau_hydro, 
             :vol_magnetik, :mitra_poing
          actor.effect.delete(effect)
        when :morphing # Morphing / Transform
          index = actor.effect_list.index(:morphing)
          actor.transform_effect( actor.effect[index][2] , true )
          actor.effect.delete(effect)
        when :frenesie # Rage / Frénésie
          actor.change_atk(-effect[2])
          actor.effect.delete(effect)
        when :copie # Copie / Mimic
          skill_index = actor.skills_set.index(effect[2][1])
          actor.skills_set[skill_index] = effect[2][0]
          actor.effect.delete(effect)
        when :entrave # Entrave / Disable
          index = effect[2]
          actor.skills_set[index].enable
          actor.effect.delete(effect)
        when :tourmente # Torment / Tourment
          index = actor.effect_list.index(:tourmente)
          skill_index = actor.effect[index][2]
          actor.skills_set[skill_index].enable
          actor.effect.delete(effect)
        when :provoc # Provoc / Taunt
          actor.skills_set.each do |skill|
            if skill.power == 0 and not(skill.enabled?)
              skill.enable
            end
          end
          actor.effect.delete(effect)
        when :corps_maudit # CAPACITE SPECIALE : Corps Maudit
          index = effect[2]
          actor.skills_set[index].enable
          actor.effect.delete(effect)
        when :defaitiste # CAPACITE SPECIALE : Défaitiste
          actor.effect.delete(effect)
          actor.set_bonus_atk(0, '*', true)
          actor.set_bonus_ats(0, '*', true)
          actor.statistic_refresh_modif
        end
      end
      enemy.effect.each do |effect|
        case effect[0]
        when :empeche_fuite, :empeche_esquive, :attraction
          enemy.effect.delete(effect)
        end
      end
    end
    
    #------------------------------------------------------------    
    #    Switch forcé (côté ennemie)
    #------------------------------------------------------------ 
    def force_switch(n)
      @force_switch = true
      if (@enemy.given_name.include?("sauvage"))
        if n == @enemy
          end_battle_flee_enemy(true)
        elsif n == @actor
          end_battle_flee(true)
        end
      else
        if n == @enemy
          try = 1
          loop do
            @enemy_switch_id = rand($battle_var.enemy_party.size)
            if $battle_var.enemy_party.actors[@enemy_switch_id].hp > 0 and
               not $battle_var.enemy_party.actors[@enemy_switch_id].egg
              try += 1
              if $battle_var.enemy_party.actors[@enemy_switch_id] != @enemy
                @enemy = $battle_var.enemy_party.actors[@enemy_switch_id]
                enemy_pokemon_switch
                break
              elsif try == 20
                if $battle_var.enemy_party.size > 0 and
                   $battle_var.enemy_party.actors[0].hp > 0
                  @enemy = $battle_var.enemy_party.actors[0]
                  enemy_pokemon_switch
                elsif $battle_var.enemy_party.size > 1 and
                      $battle_var.enemy_party.actors[1].hp > 0
                  @enemy = $battle_var.enemy_party.actors[1]
                  enemy_pokemon_switch
                elsif $battle_var.enemy_party.size > 2 and
                      $battle_var.enemy_party.actors[2].hp > 0
                  @enemy = $battle_var.enemy_party.actors[0]
                  enemy_pokemon_switch
                elsif $battle_var.enemy_party.size > 3 and
                      $battle_var.enemy_party.actors[3].hp > 0
                  @enemy = $battle_var.enemy_party.actors[0]
                  enemy_pokemon_switch
                elsif $battle_var.enemy_party.size > 4 and
                      $battle_var.enemy_party.actors[4].hp > 0
                  @enemy = $battle_var.enemy_party.actors[0]
                  enemy_pokemon_switch
                elsif $battle_var.enemy_party.size > 5 and
                      $battle_var.enemy_party.actors[5].hp > 0
                  @enemy = $battle_var.enemy_party.actors[0]
                  enemy_pokemon_switch
                end
                break
              end
            end
          end
        else
          string = 1
          loop do
            @switch_id = rand($pokemon_party.size)
            if $pokemon_party.actors[@switch_id].hp > 0 and 
               not @party.actors[@switch_id].egg
              string += 1
              if $pokemon_party.actors[@switch_id] != @actor
                actor_pokemon_switch
                break
              elsif string == 20
                break
              end
            end
          end
        end
      end
    end
    
    #------------------------------------------------------------       
    # Rappel du Pokémon
    #------------------------------------------------------------           
    def recall_pokemon
      if @actor.ability_symbol != :illusion or @actor.get_name == nil or
         @actor.get_name == @actor.given_name
        draw_text("Ca suffit, #{@actor.given_name} !", "Reviens !")
      else
        draw_text("Ca suffit, #{@actor.get_name} !", "Reviens !")
        # Reset l'ancien nom
        @actor.last_name=(nil)
      end
      
      @actor_sprite.ox = @actor_sprite.bitmap.width / 2
      height = @actor_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @actor_sprite.oy = height - height / coef_position
      @actor_sprite.y = 301
      @actor_sprite.x = 153
      @actor_sprite.color = @actor.ball_color
      @actor_sprite.color.alpha = 0
      
      until @actor_sprite.color.alpha >= 255
        @flash_sprite.opacity += 25
        @actor_sprite.color.alpha += 25
        $scene.battler_anim ; Graphics.update
      end
      
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:recall_pokemon]}")
      loop do
        @actor_status.x += 20
        @actor_sprite.opacity -= 25
        @actor_sprite.color.alpha += 25
        @actor_sprite.zoom_x -= 0.1
        @actor_sprite.zoom_y -= 0.1
        @flash_sprite.opacity -= 25
        $scene.battler_anim ; Graphics.update
        if @actor_status.x >= 711
          @actor_status.visible = false
          @actor_status.x = 711
          @actor_sprite.color.alpha = 0
          @actor_sprite.opacity = 0
          $scene.battler_anim ; Graphics.update
          break
        end
      end
    end
    
    #------------------------------------------------------------    
    #    Lancement du Pokémon
    #------------------------------------------------------------ 
    def launch_pokemon(actor)
      @actor_sprite.x = 153
      @actor_sprite.y = 301
      @actor_sprite.ox = @actor_sprite.bitmap.width / 2
      height = @actor_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @actor_sprite.oy = height - height / coef_position
      @actor_sprite.zoom_x = 0
      @actor_sprite.zoom_y = 0

      name = actor.given_name
      text = ["#{name} ! Go !", "#{name} ! A toi !", "#{name} ! A l'attaque !", 
              "#{name} ! Fonce !"][rand(4)]
      draw_text(text)
      
      @ball_sprite = Sprite.new
      @ball_sprite.bitmap = RPG::Cache.picture(actor.ball_sprite)
      @ball_sprite.ox = @ball_sprite.bitmap.width / 2
      @ball_sprite.oy = @ball_sprite.bitmap.height / 2
      @ball_sprite.x = -44
      @ball_sprite.y = 324
      @ball_sprite.z = @z_level + 14
      
      t = 0
      pi = 3.14
      
      loop do
        t += 1
        @ball_sprite.x += 5
        @ball_sprite.y = 336 - 130 * Math.sin(t/40.0*pi)
        @ball_sprite.angle = - t*63
        $scene.battler_anim ; Graphics.update
        if t == 40
          @ball_sprite.bitmap = RPG::Cache.picture(actor.ball_open_sprite)
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:recall_pokemon]}")
          break
        end
      end
      
      if FileTest.exist?(actor.cry)
        Audio.se_play(actor.cry)
      end
      
      @actor_sprite.opacity = 0
      @actor_sprite.color = actor.ball_color
      until @actor_sprite.zoom_x >= 0.9
        @flash_sprite.opacity += 25
        @ball_sprite.opacity -= 25
        @actor_sprite.zoom_x += 0.1
        @actor_sprite.zoom_y += 0.1
        @actor_sprite.opacity += 25
        $scene.battler_anim ; Graphics.update
      end
      
      if not @actor.is_anime
        @actor_sprite.zoom_x = 1.5
        @actor_sprite.zoom_y = 1.5
      else
        @actor_sprite.zoom_x = 1
        @actor_sprite.zoom_y = 1
      end
      @actor_sprite.opacity = 255
      
      @actor_status.x = 711
      @actor_status.visible = true
      
      if actor.shiny
        animation = $data_animations[496]
        @actor_sprite.animation(animation, true) if $anim != 0
      end
      
      until @actor_status.x == 311
        @background.update
        @actor_ground.update
        @enemy_ground.update
        @actor_status.x -= 20
        @actor_sprite.color.alpha -= 25
        @flash_sprite.opacity -= 25
        @actor_sprite.update
        $scene.battler_anim ; Graphics.update
      end
      
      until not(@actor_sprite.effect?)
        @actor_sprite.update
        $scene.battler_anim ; Graphics.update
      end
      
      @actor_status.x = 311
      @actor_sprite.color.alpha = 0
      @flash_sprite.opacity = 0
      @ball_sprite.dispose
      $scene.battler_anim ; Graphics.update
    end
    
    def launch_enemy_pokemon(enemy)
      if not @enemy.is_anime
        @enemy_sprite.x = 464
        @enemy_sprite.y = 175
      else
        @enemy_sprite.x = 464
        @enemy_sprite.y = 135
      end
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      height = @enemy_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @enemy_sprite.oy = height - height / coef_position
      @enemy_sprite.zoom_x = 0
      @enemy_sprite.zoom_y = -1000
      
      string = "#{Trainer_Info.type(@trainer_id)} #{Trainer_Info.name(@trainer_id)}"
      draw_text("#{enemy.name} est envoyé", "par #{string} !")
      
      @ball_sprite = Sprite.new
      @ball_sprite.bitmap = RPG::Cache.picture(enemy.ball_sprite)
      @ball_sprite.ox = @ball_sprite.bitmap.width / 2
      @ball_sprite.oy = @ball_sprite.bitmap.height / 2
      @ball_sprite.x = 663
      @ball_sprite.y = 104
      @ball_sprite.z = @z_level + 14
      @ball_sprite.mirror = true
      
      t = 0
      pi = 3.14
      
      loop do
        t += 1
        @ball_sprite.x -= 5
        @ball_sprite.y = 128 - 80 * Math.sin(t/40.0*pi)
        @ball_sprite.angle = - t*63
        $scene.battler_anim ; Graphics.update
        if t == 40
          @ball_sprite.bitmap = RPG::Cache.picture(enemy.ball_open_sprite)
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:recall_pokemon]}")
          break
        end
      end
      @enemy_sprite.opacity = 0
      @enemy_sprite.color = enemy.ball_color
      
      until @enemy_sprite.zoom_x >= 0.9
        @flash_sprite.opacity += 25
        @ball_sprite.opacity -= 25
        @enemy_sprite.zoom_x += 0.08
        @enemy_sprite.zoom_y += 0.08
        @enemy_sprite.opacity += 25
        $scene.battler_anim ; Graphics.update
      end
      
      if FileTest.exist?(enemy.cry)
        Audio.se_play(enemy.cry)
      end
      
      @enemy_sprite.zoom_x = 1
      @enemy_sprite.zoom_y = 1
      @enemy_sprite.opacity = 255
      
      @enemy_status.x = -377
      @enemy_status.visible = true
      
      if enemy.shiny
        animation = $data_animations[496]
        @enemy_sprite.animation(animation, true) if $anim != 0
      end
      
      until @enemy_status.x == 23
        @background.update
        @actor_ground.update
        @enemy_ground.update
        @enemy_status.x += 20
        @enemy_sprite.color.alpha -= 25
        @flash_sprite.opacity -= 25
        @enemy_sprite.update
        $scene.battler_anim ; Graphics.update
      end
      
      until not(@enemy_sprite.effect?)
        @enemy_sprite.update
        $scene.battler_anim ; Graphics.update
      end
      
      @enemy_sprite.x = 464
      @enemy_status.x = 23
      @enemy_sprite.color.alpha = 0
      @flash_sprite.opacity = 0
      @ball_sprite.dispose
      $scene.battler_anim ; Graphics.update
    end
    
    #------------------------------------------------------------    
    # Vérifie si le switch est autorisé
    #------------------------------------------------------------        
    def switch_able(actor, enemy)
      # Arena Trap / Piege (ab)
      if enemy.ability_symbol == :piege_sable and 
        not (enemy.effect_list.include?(:suc_digestif) or 
             enemy.effect_list.include?(:soucigraine))
        draw_text("#{enemy.ability_name} de #{enemy.given_name}", "empêche #{actor.given_name} de fuir !")
        wait(40)
        return false
      end
      # Effets appliqués au user empêchant la fuite
      list = [:patience, :multi_tour_confus, :empeche_fuite, :brouhaha, 
              :racines]
      actor.effect_list.each do |effect|
        if list.include?(effect)
          return false
        end
      end
      # Effets appliqués à l'ennemi empêchant la fuite
      list = [:ligotement]
      enemy.effect_list.each do |effect|
        if list.include?(effect)
          return false
        end
      end
      # Shadow Tag / Marque Ombre (ab) // Magnepiece / Magnet Pull (ab)
      if ((enemy.ability_symbol == :marque_ombre or 
           enemy.ability_symbol == :magnepiege) and not 
          (enemy.effect_list.include?(:suc_digestif) or 
           enemy.effect_list.include?(:soucigraine))) and
          enemy.type_steel?
        draw_text("#{enemy.ability_name} de #{enemy.given_name}", 
                  "empêche le changement!")
        wait(40)
        return false
      end
      return true
    end
  end
end