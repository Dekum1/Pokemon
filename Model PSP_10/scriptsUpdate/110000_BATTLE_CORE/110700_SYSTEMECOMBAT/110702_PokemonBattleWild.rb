#==============================================================================
# ■ Pokemon_Battle_Wild
# Pokemon Script Project - Krosk 
# 20/07/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Pokémon Sauvage
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
  # Pokemon_Battle_Wild
  # - Fonction d'initialisation
  # - Déroulement
  # - Rounds
  # - Items
  # - Lancer de pokéball
  # - Fin de combat
  #------------------------------------------------------------  
  class Pokemon_Battle_Wild < Pokemon_Battle_Core
    attr_accessor :z_level
    attr_accessor :actor_status
    attr_accessor :actor
    #------------------------------------------------------------  
    # Fonction d'initialisation
    # Appel: $scene = POKEMON_S::Pokemon_Battle_Wild.new(
    #           party, pokemon, ia)
    #     party: $pokemon_party (classe Pokemon_Party)
    #     pokemon: class Pokemon
    #     ia: Fausse AI
    #------------------------------------------------------------
    def initialize(party, pokemon, ia = false, lose_able = false)
      @z_level = 0
      @ia = ia
      @lose = lose_able
      $sauvage = true
      
      $battle_var.reset
      
      # Assignations données des Pokémons
      @enemy = pokemon
      if not(@enemy.given_name.include?("sauvage"))
        @enemy.given_name += " sauvage"
      end
      $battle_var.enemy_party.actors[0] = @enemy
      @party = party
      
      # Mise à jour Pokedex: Pokémon vu
      $pokedex.add(@enemy, false) #on ajoute pokemon vu dans pokedex
      
      # Génération ordre de combat
      @battle_order = Array.new(@party.size)
      @battle_order.fill {|i| i}
      
      # Désignation 1er Pokémon au combat
      # @actor désigne le (class) Pokémon
      actor_index = 0
      @actor = @party.actors[actor_index]
      if @actor == nil
        print("Attention, vous n'avez pas de Pokémon dans votre équipe! Réglez ce bug.")
      end
      while @actor.dead?
        actor_index += 1
        @actor = @party.actors[actor_index]
      end
    
      
      # Correction ordre combat (Pokémon vivant en premier)
      @battle_order = switch(@battle_order, 0, actor_index)
      
      # Remise à zéro résultat
      $battle_var.result_flee = false
      $battle_var.result_win = false
      $battle_var.result_defeat = false
      
      # Initialisation des variables de combat
      @phase = 0
      # 0 Non décidé, 1 Attaque, 2 Switch, 3 Item, 4 Fuite
      @actor_action = 0
      @enemy_action = 0
      
      @start_actor_battler = Player.battler # $trainer_battler
      @start_enemy_battler = @enemy.battler_face
      
      $battle_var.have_fought.push(@actor.party_index)
      $battle_var.battle_order = @battle_order
      $battle_var.in_battle = true
      
      @actor.reset_stat_stage
      @enemy.reset_stat_stage
      @actor.skill_effect_reset
      @enemy.skill_effect_reset
      @actor_skill = nil
      @enemy_skill = nil
      @actor.ability_active = false
      @enemy.ability_active = false
      @item_id = 0   # item utilisé
    end
    
    #------------------------------------------------------------  
    # Déroulement
    #------------------------------------------------------------
    # Choix du skill ennemi
    # Action : si true sauf de phase sinon pas de saut
    def enemy_skill_decision(action)
      @enemy_action = 1
      
      # Décision skill ennemi
      if not(@actor.dead?) and action
        list = []
        0.upto(@enemy.skills_set.size - 1) { |i| list.push(i) }
        list.shuffle!
        # Skill sans PP // Lutte
        @enemy_skill = Skill.new(165)
        # ----------
        list.each do |i|
          if @enemy.skills_set[i].usable?
            @enemy_skill = @enemy.skills_set[i]
          end
        end
      end
      
      if @ia and not(@actor.dead?) and action
        # Skill sans PP // Lutte
        @enemy_skill = Skill.new(165)
        
        rate_list = {}
        i = 0
        @enemy.skills_set.each do |skill|
          if skill.usable?
            rate_list[i] = ia_rate_calculation(skill, @enemy, @actor)
          else
            rate_list[i] = 0
          end
          i += 1
        end
        
        # Tri dans l'ordre decroissant de valeur
        sorted_list = rate_list.sort {|a,b| b[1]<=>a[1]}
        
        # Decision prioritaire: max dégat ou soin
        # Valeur seuil: 200
        # si une attaque/défense dépasse ce seuil, il est choisi
        if sorted_list[0][1] > 200 
          @enemy_skill = @enemy.skills_set[sorted_list[0][0]]
        else
          # Decision par pallier
          i = rand(100)
          # Taux de decision
          taux = [100, 25, 5, 0]
          0.upto(3) do |a|
            if i <= taux[a] and sorted_list[a] != nil and sorted_list[a][1] != 0
              @enemy_skill = @enemy.skills_set[sorted_list[a][0]]
            end
          end
        end
      end
      
      if not(action) # Reprise du skill précédent
        @enemy_skill = $battle_var.enemy_last_used
      end
    end
    
    #------------------------------------------------------------  
    # Rounds
    #------------------------------------------------------------                
    def end_battle_check
      @actor_status.refresh
      @enemy_status.refresh
      if @enemy.dead? and not(@party.dead?)
        end_battle_victory
      elsif @actor.dead?
        if @party.dead?
          end_battle_defeat
        elsif not $game_switches[SWITCH_POKEMON_BLOQUE]
          draw_text("Voulez-vous utiliser", "un autre Pokémon?")
          if draw_choice
            $battle_var.window_index = @index
            scene = POKEMON_S::Pokemon_Party_Menu.new(0)
            scene.main
            return_data = scene.return_data
            # Switch de Pokémon
            if $battle_var.action_id == 4 or $battle_var.action_id == 6
              @switch_id = return_data
              actor_pokemon_switch
            end
          elsif run_able?(@actor, @enemy)
            run
          else
            fail_flee
            $battle_var.window_index = @index
            scene = POKEMON_S::Pokemon_Party_Menu.new(0)
            scene.main
            return_data = scene.return_data
            # Switch de Pokémon
            if $battle_var.action_id == 4 or $battle_var.action_id == 6
              @switch_id = return_data
              actor_pokemon_switch
            end
          end
        end
      end
    end
    
    #------------------------------------------------------------  
    # Items
    #------------------------------------------------------------     
    def actor_item_use # items à utiliser
      # Item déjà utilisé ie remplacé par 0
      if @item_id == 0
        return
      end
      if POKEMON_S::Item.data(@item_id)["flee"] != nil
        end_battle_flee
        return
      end
      if POKEMON_S::Item.data(@item_id)["ball"] and HASH_BALL[@item_id]
        if catch_pokemon
          @enemy.skill_effect_reset
          @enemy.given_name = @enemy.name
          @enemy.id_ball = @item_id
          # Changement de surnom
          draw_text("Voulez-vous donner un", "surnom à #{@enemy.given_name} ?")
          if draw_choice
            draw_text("")
            scene = POKEMON_S::Pokemon_Name.new(@enemy, @z_level + 50)
            scene.main
          end
          # Intégration au PC
          if $pokemon_party.size < 6
            $pokemon_party.add(@enemy)
          else
            $pokemon_party.store_captured(@enemy)
            string1 = @enemy.given_name
            string2 = "est envoyé au PC."
            draw_text(string1, string2)
            wait(40)
          end
          $battle_var.result_win = true
          end_battle
        end
      end
    end

    #------------------------------------------------------------  
    # Lancer de pokéball
    #------------------------------------------------------------         
    def catch_pokemon
      # Rejet
      if $game_switches[INTERDICTION_CAPTURE]
        draw_text("Capture impossible !")
        wait(40)
        $pokemon_party.add_item(@item_id)
        return false
      elsif [:rebond, :tunnel, :plongee, :vol].include?(@enemy_skill.effect_symbol) and
              @enemy.effect_list.include?(@enemy_skill.effect_symbol)
        draw_text("#{@enemy.given_name} n'est pas visible !", "Impossible de le capturer !")
        wait(40)
        $pokemon_party.add_item(@item_id)
        return false
      end
      # Initialisation des données
      ball = Pokemon_Object_Ball.new
      ball_name = Pokemon_Object_Ball.name(@item_id)
      ball_sprite = Pokemon_Object_Ball.sprite_name(@item_id)
      ball_open_sprite = Pokemon_Object_Ball.open_sprite_name(@item_id)
      ball_color = Pokemon_Object_Ball.color(@item_id)      
      
      oscillation_number = ball.catch_pokemon(@item_id, @actor, @enemy)
      
      # Procédure / Animation
      # Lancer
      draw_text(Player.name + " utilise une", ball_name + " !")
      @ball_sprite = Sprite.new
      @ball_sprite.bitmap = RPG::Cache.picture(ball_sprite)
      @ball_sprite.x = -25
      @ball_sprite.y = 270
      @ball_sprite.z = @z_level + 16
      @ball_sprite.mirror = true
      t = 0.0
      pi = Math::PI
      loop do
        t += 16
        calcul = Math.sin(2 * pi / 3.0 * t / 445.0)
        @ball_sprite.y = (270.0 - 230.0 * calcul).to_i
        @ball_sprite.x = -15 + t
        $scene.battler_anim ; Graphics.update
        if @ball_sprite.x >= 445
          @ball_sprite.bitmap = RPG::Cache.picture(ball_open_sprite)
          break
        end
      end
      
      count = oscillation_number
      $scene.battler_anim ; Graphics.update
      
      # "Aspiration"
      @enemy_sprite.color = ball_color
      @enemy_sprite.color.alpha = 0
      @ball_sprite.z -= 2
      until @enemy_sprite.color.alpha >= 255
        @flash_sprite.opacity += 50
        @enemy_sprite.color.alpha += 50
        $scene.battler_anim ; Graphics.update
      end
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:recall_pokemon]}")
      loop do
        @enemy_sprite.zoom_x -= 0.1
        @enemy_sprite.zoom_y -= 0.1
        @enemy_sprite.opacity -= 25
        @flash_sprite.opacity -= 25
        $scene.battler_anim ; Graphics.update
        if @enemy_sprite.zoom_x <= 0.1
          @flash_sprite.opacity = 0
          @enemy_sprite.opacity = 0
          break
        end
      end
      @ball_sprite.bitmap = RPG::Cache.picture(ball_sprite)
      
      # Descente de la ball + rebond
      t = 0
      r = 0
      loop do
        t += 1
        calcul = 1-Math.exp(-t/20.0)*(Math.cos(t*2*pi/30.0)).abs
        @ball_sprite.y = 81 + 75*calcul
        if @ball_sprite.y >= 81+45 and r < 6
          r += 1
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:pokeball_capture]}")
        end
        $scene.battler_anim ; Graphics.update
        if t >= 60
          break
        end
      end

      # Oscillement
      width = @ball_sprite.bitmap.width
      height = @ball_sprite.bitmap.height
      @ball_sprite.x += width / 2
      @ball_sprite.y += height / 2
      @ball_sprite.ox = width / 2
      @ball_sprite.oy = height / 2
      while count > 0
        count -= 1
        t = 0
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:pokeball_move]}")
        loop do
          t += 4
          @ball_sprite.angle = 30*Math.sin(2*pi*t/100.0)          
          $scene.battler_anim ; Graphics.update          
          if t == 100
            wait(15)
            @ball_sprite.angle = 0
            break
          end
        end
      end
      
      if oscillation_number != 4
        # Echappé
        @ball_sprite.bitmap = RPG::Cache.picture(ball_open_sprite)
        @ball_sprite.y -= 16
        @ball_sprite.z -= 1
        Audio.se_stop
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:open_break]}")
        @enemy_sprite.oy = @enemy_sprite.bitmap.height
        @enemy_sprite.y += @enemy_sprite.bitmap.height / 2
        loop do
          @enemy_sprite.opacity += 25
          @enemy_sprite.zoom_x += 1
          @enemy_sprite.zoom_y += 1
          @ball_sprite.opacity -= 25
          @flash_sprite.opacity += 25
          $scene.battler_anim ; Graphics.update
          if @enemy_sprite.zoom_x >= 0
            height = @enemy_sprite.bitmap.height
            coef_position = height / (height * 0.16 + 14)
            @enemy_sprite.oy = height - height / coef_position
            @enemy_sprite.y -= @enemy_sprite.bitmap.height / 2
            $scene.battler_anim ; Graphics.update
            @ball_sprite.dispose
            break
          end
        end
        until @enemy_sprite.color.alpha <= 0
          @enemy_sprite.color.alpha -= 25
          @flash_sprite.opacity -= 25
          $scene.battler_anim ; Graphics.update
        end
        @enemy_sprite.color.alpha = 0
        @enemy_sprite.opacity = 255
        @flash_sprite.opacity = 0
        $scene.battler_anim ; Graphics.update
        
        string1 = oscillation_number == 3 ? "Mince !" : oscillation_number == 2 ? "Aaaah !" : 
          oscillation_number == 1 ? "Raah !" : "Oh non !"
        string2 = oscillation_number == 3 ? "Ca y était presque !" : 
          oscillation_number == 2 ? "Presque !" : oscillation_number == 1 ? "Ca y était presque !" : "Le Pokémon s'est libéré !"
        draw_text(string1, string2)
        wait(40)
      else
        # Attrapé
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:capturer_pokemon]}")
        @enemy = ball.effect_ball(@item_id, @enemy)
        @enemy.ability = @enemy.save_ability if @enemy.save_ability != nil
        @enemy_caught = true
        draw_text("Et hop ! " + @enemy.given_name , "est attrapé !")
        wait(90)
        wait_hit
        unless $pokedex.captured?(@enemy.id)
          draw_text("#{@enemy.name} est ajouté", "au Pokédex.")
          wait(20)
          wait_hit
          $pokedex.add(@enemy)
          scene = POKEMON_S::Pokemon_Detail.new(@enemy.id, 0, :combat , 9999)
          scene.main          
          wait(40) 
          wait_hit
          Graphics.transition 
          wait(10)          
        end
        until @ball_sprite.opacity <= 0
          @ball_sprite.opacity -= 25
          $scene.battler_anim ; Graphics.update
        end
      end
      if oscillation_number != 4
        return false
      elsif oscillation_number == 4
        return true
      end
    end

    #------------------------------------------------------------  
    # Fin de combat
    #------------------------------------------------------------      
    def end_battle_victory
      $battle_var.result_win = true
      @actor_status.z = @z_level + 15
      if DEFAULT_CONFIGURATION
        index = $game_variables[CONFIGURATION_BATTLE_WILD]
        if DATA_WILD[index] != nil
          audio = DATA_WILD[index][:victoire_audio]
          volume = DATA_WILD[index][:victoire_volume]
          pitch = DATA_WILD[index][:victoire_pitch]
        else
          audio = DATA_WILD[-1][:victoire_audio]
          volume = DATA_WILD[-1][:victoire_volume]
          pitch = DATA_WILD[-1][:victoire_pitch]
        end
        volume = 100 unless volume
        pitch = 100 unless pitch
        Audio.bgm_play("Audio/BGM/#{audio}", volume, pitch)
      else
        Audio.bgm_play("Audio/BGM/#{DATA_AUDIO_BGM[:victoire_wild_default]}")
      end
      
      
      # Réduction du nombre de participants
      $battle_var.have_fought.uniq!
      $battle_var.have_fought.each do |index|
        actor = $pokemon_party.actors[index]
        if actor.dead?
          $battle_var.have_fought.delete(index)
        end
      end
      number = $battle_var.have_fought.length
      @enemy.skill_effect_reset
      @enemy.reset_stat_stage
      evolve_checklist = []
      type = 1
      
      # PIECE RUNE/AMULET COIN
      money_rate = 1
      # EXP SHARE/MULTI EXP
      exp_share_number = 0
      $pokemon_party.actors.each do |pokemon|
        if not(pokemon.dead?) and POKEMON_S::Item.data(pokemon.item_hold)["expshare"]
          exp_share_number += 1
        end
      end
      
      # Exp de bataille
      $pokemon_party.actors.each do |actor|
        if actor.dead?
          next
        end
        
        amount = nil
        if $battle_var.have_fought.include?(actor.party_index)
          amount = Integer(actor.exp_calculation(@enemy.battle_list, @enemy.level, 
                                         number, type, exp_share_number))
          # Tag objet
          if POKEMON_S::Item.data(actor.item_hold)["amuletcoin"]
            money_rate = 2
          end
        end
        if POKEMON_S::Item.data(actor.item_hold)["expshare"] and 
            not($battle_var.have_fought.include?(actor.party_index)) and 
            not(actor.dead?)
          amount = actor.exp_calculation(@enemy.battle_list, @enemy.level, 
                                         number, type, exp_share_number, 0)
        end
        if amount != nil
          actor.add_bonus(@enemy.battle_list)
          draw_text("#{actor.given_name} a gagné", 
                    "#{amount} points d'expérience !")
          $scene.battler_anim ; Graphics.update
          wait_hit
        
          if not $game_switches[EXP_BLOQUE]
            Advanced_Audio.new(:exp, "Audio/SE/#{DATA_AUDIO_SE[:exp]}")
            Advanced_Audio[:exp].play(false)
            1.upto(amount) do |i|
              actor.add_exp_battle(1)
              if actor.level_check
                Advanced_Audio[:exp].stop
                actor.level_up(self)
                Advanced_Audio[:exp].play(false)
                evolve_checklist.push(actor)
              end
              if actor == @actor
                if @actor.exp_list[@actor.level+1] != nil and 
                   @actor.level < MAX_LEVEL
                  difference = @actor.exp_list[@actor.level]
                  divide = (@actor.exp_list[@actor.level+1]-difference)/192
                  if divide == 0
                    divide = 1
                  end
                  if (@actor.exp - @actor.exp_list[@actor.level])%divide == 0
                    @actor_status.exp_refresh
                    $scene.battler_anim ; Graphics.update
                  end
                end
              end
            end
            Advanced_Audio[:exp].stop
          end
        end
      end

      @actor_status.refresh
      $scene.battler_anim ; Graphics.update
      if $battle_var.money_payday > 0
        draw_text("#{Player.name} gagne #{$battle_var.money_payday}$",  
                  "grâce à Jackpot !")
        $pokemon_party.add_money($battle_var.money_payday)
        wait(40)
      end

      wait(30)
      $game_system.bgm_play($game_temp.map_bgm)
      evolve_checklist.each do |actor|
        info = actor.evolve_check
        if info != false and  actor.item_hold != 110
          scene = POKEMON_S::Pokemon_Evolve.new(actor, info, @z_level + 200)
          scene.main
        end
      end
      end_battle
    end
  end
end