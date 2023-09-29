#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# 20/07/07
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
# Système de Combat - Squelette général
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# $battle_var.action_id
#   0 : Phase de Sélection
#   1 : Sélection Item
#   2 : Switch Pokémon
#   4 : Switch Fin de Tour
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Core
  #   noyau possédant les fonctions communes aux combats sauvages/dresseurs
  #------------------------------------------------------------  
  class Pokemon_Battle_Core
    attr_accessor :z_level
    attr_accessor :actor_status
    attr_accessor :actor
    attr_accessor :actor_sprite
    
    #------------------------------------------------------------  
    # ------------------- Squelette Général ---------------------
    #------------------------------------------------------------
    
    #------------------------------------------------------------  
    # main
    #------------------------------------------------------------
    def main
      @user_group = []
      # Si la variable est définie, alors force le niveau définit dans la
      # variable à l'acteur et à l'ennemi
      if $game_variables[LEVEL_TOUR_COMBAT] > 0
        refresh_level
      end
      initialisation_interface
      
      @actor_party_status.visible = false
      @enemy_party_status.visible = false
      # note: .active = true activera les animations liées à ces fenêtres
      @actor_party_status.active = false
      @enemy_party_status.active = false
      
      # Création fenêtre de statut
      # CAS DE LA CAPACITE SPECIALE : Illusion
      if @actor.ability_symbol == :illusion
        @actor.illusion=(@party.actors[@party.size - 1])
        if @actor.get_illusion.id != @actor.id
          @actor.last_name=(@actor.given_name)
          @actor.last_gender=(@actor.gender)
          @actor.change_name(@actor.get_illusion.given_name)
          @actor.gender=(@actor.get_illusion.gender)
        end
      end
      if @enemy.ability_symbol == :illusion
        party_enemy = $battle_var.enemy_party
        @enemy.illusion=($battle_var.enemy_party.actors[party_enemy.size - 1])
        if @enemy.get_illusion.id != @enemy.id
          @enemy.last_name=(@enemy.name)
          @enemy.last_gender=(@enemy.gender)
          @enemy.name_enemy=(@enemy.get_illusion.name)
          @enemy.gender=(@enemy.get_illusion.gender)
          type_name = @enemy.male? ? "ennemi" : "ennemie"
          name = @enemy.name + " " + type_name
          @enemy.change_name(name)
        end
      end
      @actor_status = Pokemon_Battle_Status.new(@actor, false, @z_level + 15)
      @enemy_status = Pokemon_Battle_Status.new(@enemy, true, @z_level + 15)
      @actor_status.visible = false
      @enemy_status.visible = false
      @enemy_caught = false

      # Lancement des animations
      pre_battle_transition
      pre_battle_animation
      
      # Effets pré-premier round
      pre_post_round_effect
      
      # CAS DE LA CAPACITE SPECIALE : Imposteur
      if @actor.ability_symbol == :imposteur
        morphing(@actor, @enemy)
        stage_animation(@actor_sprite, $data_animations[144])
        draw_text("imposteur de #{@actor.given_name}", 
                  "le transforme en  #{@enemy.given_name}")
        wait(40)
      end
      if @enemy.ability_symbol == :imposteur
        morphing(@enemy, @actor)
        stage_animation(@enemy_sprite, $data_animations[144])
        draw_text("imposteur de #{@enemy.given_name}", 
                  "le transforme en  #{@actor.given_name}")
        wait(40)
      end
      
      Graphics.transition
      loop do
        $scene.battler_anim ; Graphics.update
        Input.update
        update
        if $scene != self
          break
        end
      end
      
      end_scene
    end
    
    #------------------------------------------------------------  
    # Déroulement
    #------------------------------------------------------------
    def update
      # Animation test : séquence de test d'une animation
      if false
        if $temp == nil
          $temp = false
          @actor_sprite.register_position
          @enemy_sprite.register_position
        end
        animation = $data_animations[15] # tappez le numéro de l'anim à tester
        if not @enemy_sprite.effect? and not @actor_sprite.effect?
          if $temp
            @enemy_sprite.reset_position
            @actor_sprite.register_position
            @actor_sprite.animation(animation, true, true)
            $temp = !$temp
          else
            @actor_sprite.reset_position
            @enemy_sprite.register_position
            @enemy_sprite.animation(animation, true)
            $temp = !$temp
          end
        end
        @actor_sprite.update
        @enemy_sprite.update
        return
      end
      
      case @phase
      when 0 # Phase d'initialisation
        @phase = 1
        
        # Création fenêtre de skill
        list = []
        for skill in @actor.skills_set
          list.push(skill.name)
        end
        while list.size < 4
          list.push("  ---")
        end
        
        types = [0,0,0,0]
        pp = [0,0,0,0]
        ppmax = [0,0,0,0]
        0.upto(4) do |i|
          skill = @actor.skills_set[i]
           if skill != nil
            
            types[i] = skill.type
            pp[i] = skill.pp
            ppmax[i] = skill.ppmax
           else

            types[i] = 0
           end
        end  
        @curseur2.visible = false
        initialisation_interface_skill(types, list)
        @skills_window.visible = false
        @skills_window.active = false
        
        # Compétences bloquées
        0.upto(@actor.skills_set.length - 1) do |i|
          skill = @actor.skills_set[i]
          if not(skill.usable?)
            @skills_window.disable_item(i)
          end
        end
        
        # Curseur sur le dernier choix
        if $battle_var.last_index == nil
          $battle_var.last_index = 0
          @skills_window.index = 0
        else
          @skills_window.index = $battle_var.last_index
        end
        case @skills_window.index
        when 0
          @curseur2.x = 36
          @curseur2.y = 355
        when 1
          @curseur2.x = 262
          @curseur2.y = 355
        when 2
          @curseur2.x = 36
          @curseur2.y = 410
        when 3
          @curseur2.x = 262
          @curseur2.y = 410
        else           
          @curseur2.visible = false
        end
        
        # Création fenêtre description de skill
        @skill_descr = Window_Base.new(497, 336, 128, 144)
        @skill_descr.contents = Bitmap.new(96, 144)
        @skill_descr.contents.font.name = $fontface
        @skill_descr.contents.font.size = $fontsizebig
        @skill_descr.visible = false
        @skill_descr.opacity = 0
        skill_descr_refresh
        
        # Activation fenêtre
        @actor_status.visible = true
        @enemy_status.visible = true
                
        # ------- ---------- --------- --------
        #    Saut de phase de sélection actor
        # ------- ---------- --------- --------
        jumped = phase_jump
        
        # Activations fenêtres
        if not(jumped)
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:phase_joueur]}")
          draw_text("Que doit faire ", @actor.given_name + "?")
          @action = true
          @fond.visible = true
          @choix.visible = true
          @curseur.visible = true
          $battle_var.action_id = 0
          bouton_mega #mega
        end
        
      when 1 # Phase d'attente d'action
        @skills_window.update
        @skills_window.cursor_rect.empty
        if @skills_window.active and input
          skill_descr_refresh
          if @skills_window.index == 0
            @curseur2.x = 36
            @curseur2.y = 355
          elsif
            @skills_window.index == 1 
            @curseur2.x = 262
            @curseur2.y = 355
          elsif
            @skills_window.index == 2
            @curseur2.x = 36
            @curseur2.y = 410
          elsif
            @skills_window.index == 3
            @curseur2.x = 262
            @curseur2.y = 410
          else           
            @curseur2.visible = false
          end         
        end
        
        if @action
          bouton_mega2 if Input.trigger?(Input::A) #mega
          case @index
          when 0 # Selection ATTAQUE
            @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_attaque])
            @curseur.x = 331
            @curseur.y = 353
            if Input.trigger?(Input::RIGHT)
              $game_system.se_play($data_system.cursor_se)
              @index = 2
            end
            if Input.trigger?(Input::DOWN)
              $game_system.se_play($data_system.cursor_se)
              @index = 1
            end
            if Input.trigger?(Input::C)
              Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:validation_combat]}")
              @action = false           
              @choix.visible = false
              @curseur.visible = false
              @skills_window.opacity = 0
              @text_window.contents.clear
                
              # ------- ---------- --------- --------
              #   Reset compteur de fuite
              # ------- ---------- --------- --------
              $battle_var.run_count = 0
                
              # ------- ---------- --------- --------
              #    Saut de phase de sélection attaque
              # ------- ---------- --------- --------
              if attack_selection_jump
                @actor_action = 1
                @phase = 2
                return
              end
                
              # ------- ---------- --------- --------
              #      Vérification PP // Lutte
              # ------- ---------- --------- --------
              total = 0
              for skill in @actor.skills_set
                if skill.usable?
                  total += skill.pp
                end
              end
              if total == 0
                @actor_action = 1
                @phase = 2
                @actor_skill = Skill.new(165) # Lutte
                return
              end
              @skills_window.active = true
              @skills_window.visible = true
              @att1.visible = true
              @att2.visible = true
              @att3.visible = true
              @att4.visible = true
              @skill_descr.visible = true
              @curseur2.visible = true
            end
            return
          when 2 # Selection ITEM
            @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_sac])
            @curseur.x = 488
            @curseur.y = 353
            if Input.trigger?(Input::DOWN)
              $game_system.se_play($data_system.cursor_se)
              @index = 3
            end
            if Input.trigger?(Input::LEFT)
              $game_system.se_play($data_system.cursor_se)
              @index = 0
            end
            if Input.trigger?(Input::C)
              if @actor.effect_list.include?(0xE8)
                $game_system.se_play($data_system.buzzer_se)
                @choix.visible = false
                draw_text("Embargo empêche l'utilisation","des objets!")
                wait(40)
                draw_text("Que doit faire ", "#{@actor.given_name} ?")
                @choix.visible = true
              else
                Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:validation_combat]}")
                scene = Pokemon_Item_Bag.new($pokemon_party.bag_index, @z_level + 100, "battle")
                scene.main
                return_data = scene.return_data
                @phase = 0
                if $battle_var.action_id == 1
                  @phase = 2
                  @actor_action = 3
                  @item_id = return_data
                end
              end
            end
            return
          when 1 # Selection PKMNn
            @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_pokemon])
            @curseur.x = 331
            @curseur.y = 409
            if Input.trigger?(Input::UP)
              $game_system.se_play($data_system.cursor_se)
              @index = 0
            end
            if Input.trigger?(Input::RIGHT)
              $game_system.se_play($data_system.cursor_se)
              @index = 3
            end
            if Input.trigger?(Input::C)
              # ------- ---------- --------- --------
              #    Vérification switch permis
              # ------- ---------- --------- --------
              @curseur.visible = false              
              @choix.visible = false
              @fond.visible = false
              if not(switch_able(@actor, @enemy))
                $game_system.se_play($data_system.buzzer_se)
                draw_text("Que doit faire", "#{@actor.given_name} ?")
                @curseur.visible = true              
                @choix.visible = true
                @fond.visible = true
                return
              end
              @curseur.visible = true              
              @choix.visible = true
              @fond.visible = true
              Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:validation_combat]}")
              $battle_var.window_index = @index
              scene = Pokemon_Party_Menu.new(0, @z_level + 100)
              scene.main
              return_data = scene.return_data
              @phase = 0
              # Enregistrement données Switch de Pokémon
              if $battle_var.action_id == 2
                @phase = 2
                @actor_action = 2
                @switch_id = return_data
              end
            end
            return
          when 3 # sélection FUITE
            @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_fuite])
            @curseur.x = 488
            @curseur.y = 409
            if Input.trigger?(Input::UP)
              $game_system.se_play($data_system.cursor_se)
              @index = 2
            end
            if Input.trigger?(Input::LEFT)
              $game_system.se_play($data_system.cursor_se)
              @index = 1
            end
            if Input.trigger?(Input::C)
              # ------- ---------- --------- --------
              #    Vérification fuite permise
              # ------- ---------- --------- --------
              @fond.visible = false
              @choix.visible = false
              @curseur.visible = false
              if not(flee_able(@actor, @enemy))
                $game_system.se_play($data_system.buzzer_se)
                @fond.visible = false
                @choix.visible = false
                draw_text("Que doit faire", "#{@actor.given_name} ?")
                @curseur.visible = true              
                @choix.visible = true
                @fond.visible = true
                return
              end
              @action = false            
              @choix.visible = false            
              @curseur.visible = false
              run
            end
            return
          end
        end
      
        bouton_mega2 if Input.trigger?(Input::A) #mega
        if Input.trigger?(Input::C) and @skills_window.active
          index = @skills_window.index
          skill = @actor.skills_set[index]
          if skill != nil and skill.usable?
            @actor_action = 1
            @phase = 2
            Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:validation_combat]}")
            @skills_window.active = false
            @skills_window.visible = false
            @att1.visible = false
            @att2.visible = false
            @att3.visible = false
            @att4.visible = false
            @skill_descr.visible = false
            @action = false            
            @choix.visible = false
            @curseur.visible = false
            @curseur2.visible = false
            @fond.visible = false
            @actor_skill = @actor.skills_set[index]
            $battle_var.last_index = @skills_window.index
          else
            $game_system.se_play($data_system.buzzer_se)
          end
        end
        
        if Input.trigger?(Input::B) and @skills_window.active
          $game_system.se_play($data_system.decision_se)
          @skills_window.active = false
          @skills_window.visible = false
          @att1.visible = false
          @att2.visible = false
          @att3.visible = false
          @att4.visible = false
          @skill_descr.visible = false
          @action = true
          @fond.visible = true
          @choix.visible = true
          @curseur.visible = true
          @curseur2.visible = false
          @phase = 0
        end
        
        when 2 # Phase d'action automatisée        
        @action = false
        @choix.visible = false
        @fond.visible = false
        @curseur.visible = false

        
        @object_use = item_use?
        
        # ------- ---------- --------- --------
        #    Saut de phase de sélection (ennemi)
        #   action = false  : saut
        #   action = true   : pas de saut
        # ------- ---------- --------- --------
        action = phase_jump(true)
        
        # Vérifie si un objet est utilisé et qu'il peut être utilisé (cas où
        # le pokémon ennemi à des attaques à multi-tours sans phase de décision,
        # se concentre ou se recharge
        if @object_use != nil and @object_use[:objet] != nil and action 
          @enemy_action = 3
        else
          enemy_skill_decision(action)
        end
        
        statistic_refresh_modif
        turn_order
        @phase3DejaActif = 0
        # Vérifie que l'acteur est est bien présent dans la liste de
        # ceux qui ont combattu => pour gain d'exp
        if not($battle_var.have_fought.include?(@actor.party_index))
          $battle_var.have_fought.push(@actor.party_index)
        end
        phase2
        # Si la phase 3 n'est pas enclenché avant un switch en phase 2
        if @phase3DejaActif == 0
          phase3
        end
        
        # CAS DE LA CAPACITE SPECIALE : Impudence
        if @enemy.dead? and @actor.ability_symbol == :impudence and 
           not @actor.dead?
          n = @actor.change_atk(+1)
          if n != 0
            draw_text("Impudence augmente l'attaque", 
                      "de #{@actor.given_name} !")
            stage_animation(@actor_sprite, $data_animations[478]) if $anim != 0
          end
        elsif @actor.dead? and @enemy.ability_symbol == :impudence and 
              not @enemy.dead?
          n = @enemy.change_atk(+1)
          if n != 0
            draw_text("Impudence augmente l'attaque", 
                      "de #{@enemy.given_name} !")
            stage_animation(@enemy_sprite, $data_animations[478]) if $anim != 0
          end
        end
        
        
        # Phase de switch de fin de tour
        $battle_var.action_id = 4
        
        # Fin de tour / Post_Round effects
        pre_post_round_effect
        @actor_status.refresh
        @enemy_status.refresh
        
        if $battle_var.battle_end?
          return
        end
        
        # Phase de switch post_round
        $battle_var.action_id = 6
        end_battle_check
        @phase = 0
        
        if $battle_var.battle_end?
          return
        end
      end
      return
    end
  end
end    