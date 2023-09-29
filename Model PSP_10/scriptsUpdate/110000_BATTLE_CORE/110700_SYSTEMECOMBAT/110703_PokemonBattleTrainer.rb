#==============================================================================
# ■ Pokemon_Battle_Trainer
# Pokemon Script Project - Krosk 
# 29/09/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
# end_battle_text_audio_method : Nuri Yuri, ajout de l'audio par Damien Linux
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Pokémon Dresseur
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
#   4 : Switch Fin de Tour
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Trainer
  # - Fonction d'initialisation
  # - Déroulement
  # - Rounds
  # - Items
  # - Lancer de pokéball
  # - Fuite
  # - Exp en cours de combat
  # - Fin de combat
  #------------------------------------------------------------  
  class Pokemon_Battle_Trainer < Pokemon_Battle_Core
    attr_accessor :z_level
    attr_accessor :actor_status
    attr_accessor :actor
    #------------------------------------------------------------  
    # Fonction d'initialisation
    # Appel: $scene = Pokemon_Battle_Trainer.new(
    #           party, trainer_id, ia)
    #     party: $pokemon_party (classe Pokemon_Party)
    #     trainer_id: L'ID du dresseur dans $data_trainer (groupe de monstres)
    #     ia: Fausse AI
    #     run_able: possible de fuir
    #------------------------------------------------------------
    def initialize(party, trainer_id, ia = false, run_able = false, 
                   lose_able = false, capturable = false)
      @z_level = 0
      @ia = ia
      @trainer_id = trainer_id
      @run = run_able
      @lose = lose_able
      @capture = capturable
      
      $battle_var.reset
      
      # Création données des Pokémons adverses
      Trainer_Info.pokemon_list(@trainer_id).each do |pokemon_info|
        $battle_var.enemy_party.actors.push(pokemon_info.create_pokemon)
      end
      refill_party($battle_var.enemy_party)
      @enemy = $battle_var.enemy_party.actors[0]
      $battle_var.enemy_battle_order = [0,1,2,3,4,5]
      
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
      
      @start_actor_battler = Player.battler
      @start_enemy_battler = Trainer_Info.battler(@trainer_id)
      
      $battle_var.have_fought.push(@actor.party_index)
      $battle_var.battle_order = @battle_order
      $battle_var.in_battle = true
      
      @actor.reset_stat_stage
      @enemy.reset_stat_stage
      @actor_skill = nil
      @enemy_skill = nil
      @actor.ability_active = false
      @enemy.ability_active = false
      @item_id = 0   # item utilisé
      
      # Récupération des objets :
      @objects = Trainer_Info.objects(@trainer_id)
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
        # ----------
        total = 0
        list.each do |i|
          if @enemy.skills_set[i].usable?
            @enemy_skill = @enemy.skills_set[i]
            total += @enemy.skills_set[i].pp
          end
        end
        if total == 0
          # Skill sans PP // Lutte
          @enemy_skill = Skill.new(165)
        end
      end
      
      
      # Trainer IA
      if @ia and not(@actor.dead?) and action
        
        rate_list = {}
        i = 0
        total = 0
        @enemy.skills_set.each do |skill|
          if skill.usable?
            rate_list[i] = ia_rate_calculation(skill, @enemy, @actor)
            total += skill.pp
          else
            rate_list[i] = 0
          end
          i += 1
        end
        if total == 0
          # Skill sans PP // Lutte
          @enemy_skill = Skill.new(165)
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
    # Ajoutez : 
    # Pour le texte : $end_battle_text = ["Ligne de texte 1","Ligne de texte 2"]
    # Pour l'audio : $end_battle_audio = "Titre de l'audio.wav"
    # Dans le script pour ce genre de combat
    def end_battle_text_audio_method
      if $end_battle_audio != nil
        Audio.bgm_play("Audio/BGM/#{$end_battle_audio}")
      end
      if $end_battle_text != nil
        sp = Sprite.new(@enemy_sprite.viewport)
        sp.bitmap = RPG::Cache.battler(@start_enemy_battler, 0)
        sp.y = 155
        sp.ox = @enemy_sprite.bitmap.width / 2
        height = 160 
        coef_position = height / (height * 0.16)
        sp.oy = height - height / coef_position 
        sp.x = 640 + sp.ox
        sp.z = @enemy_sprite.z
        18.times do
          sp.x -= 14
          Graphics.update
        end
        draw_text($end_battle_text)
        wait_hit
        18.times do
          sp.x += 14
          Graphics.update
        end
        sp.dispose
      end
      $end_battle_text = nil
      $end_battle_audio = nil
    end
    
    def end_battle_check
      @actor_status.refresh
      @enemy_status.refresh
      if $battle_var.enemy_party.dead? and not(@party.dead?)
        end_battle_victory
      elsif @enemy.dead? and not($battle_var.enemy_party.dead?)
        exp_battle if not $game_switches[EXP_BLOQUE]
        dead_counter = 0
        $battle_var.enemy_party.actors.each do |e|
          dead_counter += 1 if e.dead?
        end
        if dead_counter == ($battle_var.enemy_party.actors.size - 1)
          end_battle_text_audio_method
        end
        
        index = $battle_var.enemy_party.actors.index(@enemy)
        # CHOIX DU SWITCH :
        # Variable IA_SWITCH_BATTLE :
        # 0 => type de switch classique (de manière séquentielle)
        # 1 => switch aléatoire
        # 2 => IA de switch activé (le pokémon est envoyé de façon intélligente)
        @enemy_switch_id = -1
        loop do #verif de l'équipe ennemie
          # RANDOM APPARITION (désactivé par défaut)
          if $game_variables[IA_SWITCH_BATTLE] == 1
            @enemy_switch_id = rand($battle_var.enemy_party.size)
          elsif $game_variables[IA_SWITCH_BATTLE] == 2
            @enemy_switch_id = ia_choice_switch($battle_var.enemy_party)
          else 
            @enemy_switch_id += 1
          end
          if $battle_var.enemy_party.actors[@enemy_switch_id].hp > 0
            break
          end
        end
        name = $battle_var.enemy_party.actors[@enemy_switch_id].name
        draw_text("#{name} va être envoyé", 
                  "par #{Trainer_Info.string(@trainer_id)}.")
        
        if @enemy_party_status.active
          @enemy_party_status.reset_position
          @enemy_party_status.visible = true
          @enemy_party_status.x -= 400
          until @enemy_party_status.x == -16
            @enemy_party_status.x += 20
            $scene.battler_anim ; Graphics.update
          end
        end
        
        alive = 0
        @party.actors.each do |pokemon|
          if not pokemon.dead?
            alive += 1
          end
        end
        
        wait_hit
        if alive > 1 and $battle_style != 1 and
           not $game_switches[SWITCH_POKEMON_BLOQUE]
          draw_text("Voulez-vous utiliser", "un autre Pokémon ?")
          decision = false
          if draw_choice
            $battle_var.window_index = @index
            scene = Pokemon_Party_Menu.new(0)
            scene.main
            return_data = scene.return_data
            decision = true
            Graphics.transition
            $battle_var.have_fought.delete(@actor.party_index)
          end
        
          # Switch de Pokémon
          if ($battle_var.action_id == 4 or $battle_var.action_id == 6) and 
             decision 
            @switch_id = return_data
            actor_pokemon_switch
          end
        end
        
        if @enemy_party_status.active
          until @enemy_party_status.x == -416
            @enemy_party_status.x -= 20
            $scene.battler_anim ; Graphics.update
          end
          @enemy_party_status.visible = false
          @enemy_party_status.reset_position
        end
        
        # Switch enemy
        enemy_pokemon_switch
      end
      if @actor.dead?
        if @party.dead?
          if $battle_var.enemy_party.dead? and 
             (@user_last_skill.effect_symbol != :auto_ko or @user == @enemy)
            end_battle_victory
          else
            end_battle_defeat
          end
        elsif not $battle_var.enemy_party.dead?
          # Switch forcé
          $battle_var.window_index = @index
          scene = Pokemon_Party_Menu.new(0)
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
        catch_pokemon
      end
    end
    
    #------------------------------------------------------------  
    # Lancer de pokéball
    #------------------------------------------------------------         
    def catch_pokemon
      # Initialisation des données
      ball = Pokemon_Object_Ball.new
      ball_name = Pokemon_Object_Ball.name(@item_id)
      ball_sprite = Pokemon_Object_Ball.sprite_name(@item_id)
      
      # Procédure / Animation
      # Lancer
      draw_text(Player.name + " utilise", ball_name + "!")
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
          break
        end
      end
      
      $scene.battler_anim ; Graphics.update
      # Rejet
      draw_text("#{Trainer_Info.string(@trainer_id)} dévie", 
                "la #{ball_name} !")
      Audio.se_stop
      Audio.se_play("Audio/SE/Pokeopenbreak.wav")
      
      t = 0
      loop do
        t += 1
        @ball_sprite.x -= -20
        @ball_sprite.y += t
        $scene.battler_anim ; Graphics.update
        if t == 10
          @ball_sprite.dispose
          break
        end
      end
      
      wait(40)
      
      return false
    end
    
    #------------------------------------------------------------  
    # Fuite
    #------------------------------------------------------------           
    def run_able?(runner, opponent)
      if @run
        return super
      end
      return false
    end
    
    def flee_able(actor, enemy)
      if @run
        return super
      end
      draw_text("Fuite impossible", "lors d'un combat de dresseur !")
      wait(40)
      Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:phase_joueur]}")
      return false
    end
    
    def end_battle_flee(expulsion = false)
      if @run
        return super
      end
      draw_text("On ne s'enfuit pas", "d'un combat de dresseurs !")
      wait_hit
    end
    
    def end_battle_flee_enemy(expulsion = false)
      if @run
        return super
      end
      draw_text("On ne s'enfuit pas", "d'un combat de dresseurs !")
      wait_hit
    end
    
    #------------------------------------------------------------  
    # Exp en cours de combat
    #------------------------------------------------------------      
    def exp_battle
      @actor_status.z = @z_level + 15
      
      # Réduction de liste
      $battle_var.have_fought.uniq!
      elimination = 0
      $battle_var.have_fought.each do |index|
        actor = $pokemon_party.actors[index]
        if actor.dead?
          elimination += 1
        end
      end
      number = $battle_var.have_fought.length - elimination
      
      @enemy.reset_stat_stage
      if @evolve_checklist == nil
        @evolve_checklist = []
      end
      if @money_rate == nil
        @money_rate = 1
      end
      
      # Recherche de paramètres
      type = 1.3
      exp_share_number = 0
      $pokemon_party.actors.each do |pokemon|
        if not(pokemon.dead?) and POKEMON_S::Item.data(pokemon.item_hold)["expshare"]
          exp_share_number += 1
        end
      end
      
      $pokemon_party.actors.each do |actor|
        next if actor.dead?
        amount = nil
        if $battle_var.have_fought.include?(actor.party_index)
          amount = Integer(actor.exp_calculation(@enemy.battle_list, @enemy.level, 
                                         number, type, exp_share_number))
          # Tag objet
          if POKEMON_S::Item.data(actor.item_hold)["amuletcoin"]
            @money_rate = 2
          end
        end
        
        if POKEMON_S::Item.data(actor.item_hold)["expshare"] and 
            not($battle_var.have_fought.include?(actor.party_index)) and 
            not(actor.dead?)
          amount = actor.exp_calculation(@enemy.battle_list, @enemy.level, 
                                         number, type, exp_share_number, 0)
        end
        
        if amount != nil
          amount = amount.to_i
          actor.add_bonus(@enemy.battle_list)
          draw_text("#{actor.given_name} a gagné", 
                    "#{amount} points d'expérience !")
          $scene.battler_anim ; Graphics.update
          wait_hit
        
          Advanced_Audio.new(:exp, "Audio/SE/#{DATA_AUDIO_SE[:exp]}")
          Advanced_Audio[:exp].play(false)
          1.upto(amount) do |i|
            actor.add_exp_battle(1)
            if actor.level_check
              Advanced_Audio[:exp].stop
              actor.level_up(self)
              Advanced_Audio[:exp].play(false)
              if not(@evolve_checklist.include?(actor))
                @evolve_checklist.push(actor)
              end
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
      
      @actor_status.refresh
      $scene.battler_anim ; Graphics.update
      
      # Reset have_fought
      $battle_var.have_fought = [@actor.party_index]
      
    end
    
    #------------------------------------------------------------  
    # Fin de combat
    #------------------------------------------------------------      
    def end_battle_victory
      exp_battle if not $game_switches[EXP_BLOQUE]
      
      $battle_var.result_win = true
      if DEFAULT_CONFIGURATION
        index = $game_variables[CONFIGURATION_BATTLE_TRAINER]
        if DATA_TRAINERS_AUDIO_GRAPHIC[index] != nil
          audio = DATA_TRAINERS_AUDIO_GRAPHIC[index][:victoire_audio]
          volume = DATA_TRAINERS_AUDIO_GRAPHIC[index][:victoire_volume]
          pitch = DATA_TRAINERS_AUDIO_GRAPHIC[index][:victoire_pitch]
        else
          audio = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:victoire_audio]
          volume = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:victoire_volume]
          pitch = DATA_TRAINERS_AUDIO_GRAPHIC[-1][:victoire_pitch]
        end
        volume = 100 unless volume
        pitch = 100 unless pitch
        Audio.bgm_play("Audio/BGM/#{audio}", volume, pitch)
      else
        Audio.bgm_play("Audio/BGM/#{DATA_AUDIO_BGM[:victoire_default]}")
      end
      draw_text("Vous avez battu", "#{Trainer_Info.string(@trainer_id)} !")
      
      @enemy_sprite.opacity = 255
      @enemy_sprite.zoom_x = 1
      @enemy_sprite.zoom_y = 1
      @enemy_sprite.visible = true
      @enemy_sprite.bitmap = RPG::Cache.battler(@start_enemy_battler, 0)
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      @enemy_sprite.y = 135
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      height = @enemy_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @enemy_sprite.oy = height - height / coef_position - 10
      @enemy_sprite.x = 723
      loop do
        @enemy_sprite.x -= 10
        $scene.battler_anim ; Graphics.update
        if @enemy_sprite.x <= 464
          break
        end
      end
      wait_hit
      
      
      list_string = Trainer_Info.string_victory(@trainer_id)
      i = 0
      # Exécution des textes de victoires
      loop do
        if i >= list_string.size
          break
        end #else
        if list_string[i+1] != nil
          draw_text(list_string[i], list_string[i+1])
        else
          draw_text(list_string[i])
        end
        wait_hit
        i += 2
      end
      
      
      $battle_var.money = Trainer_Info.money(@trainer_id)
      $battle_var.have_fought.each do |index|
        if $pokemon_party.actors[index].item_hold == 107 or 
           $pokemon_party.actors[index].item_hold == 348 
          $battle_var.money *= 2
        end
      end
      draw_text("#{Player.name} remporte #{$battle_var.money}$ !")
      $pokemon_party.add_money($battle_var.money)
      wait(40)
      
      if $battle_var.money_payday > 0
        draw_text("#{Player.name} gagne #{$battle_var.money_payday} $",  
                  "grâce à Jackpot !")
        $pokemon_party.add_money($battle_var.money_payday)
        wait(40)
      end
      
      wait(30)
      $game_system.bgm_play($game_temp.map_bgm)
      if @evolve_checklist != nil
        @evolve_checklist.each do |actor|
          info = actor.evolve_check
          if info != false and  actor.item_hold != 110
            scene = Pokemon_Evolve.new(actor, info, @z_level + 200)
            scene.main
          end
        end
      end
      
      # Si gagné mais que l'équipe est K.0., peut arriver avec des attaques
      # d'auto-destructions
      if @party.dead?
        if $game_variables[MAP_ID] == 0
          print("Réglez votre point de retour !")
        else
          $game_map.setup($game_variables[MAP_ID])
          $game_map.display_x = $game_variables[MAP_X]
          $game_map.display_y = $game_variables[MAP_Y]
          $game_player.moveto($game_variables[MAP_X], $game_variables[MAP_Y])
        end
        $game_temp.common_event_id = 2
        $game_temp.map_bgm = $game_map.bgm
        end_battle(2)
      else
        end_battle
      end
    end
    
    def end_battle_defeat
      $battle_var.result_defeat = true
      list_string = Trainer_Info.string_defeat(@trainer_id)
      i = 0
      # Exécution des textes de défaites
      loop do
        if i >= list_string.size
          break
        end #else
        if list_string[i+1] != nil
          draw_text(list_string[i], list_string[i+1])
        else
          draw_text(list_string[i])
        end
        wait_hit
        i += 2
      end
      
      wait(40)
      $pokemon_party.money /= 2
      if not(@lose)
        if $game_variables[MAP_ID] == 0
          print("Réglez votre point de retour !")
        else
          $game_map.setup($game_variables[MAP_ID])
          $game_map.display_x = $game_variables[MAP_X]
          $game_map.display_y = $game_variables[MAP_Y]
          $game_player.moveto($game_variables[MAP_X], $game_variables[MAP_Y])
        end
        $game_temp.common_event_id = 2
      end
      $game_temp.map_bgm = $game_map.bgm
      end_battle(2)
    end
  end
end