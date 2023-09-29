#==============================================================================
# ■ Pokemon
# Pokemon Script Project - Krosk 
# 20/07/07
# 26/08/08 - révision, support des oeufs
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 04/11/19
#-----------------------------------------------------------------------------
# Gestion individuelle
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon : génère l'information sur un Pokémon.
  # Méthodes sur les niveaux du Pokémon et l'évolution :
  # - Gestion d'expérience - EV
  # - Vérification du niveau / Augmente le niveau
  # - Modification/Evolution du Pokémon
  # - Expérience à acquérir pour le prochain niveau
  #------------------------------------------------------------
  class Pokemon
    def evolve_list
      if @egg
        return []
      end
      return Pokemon_Info.evolve_table(id)
    end
    
    #------------------------------------------------------------
    # Gestion d'expérience - EV
    #------------------------------------------------------------    
    #------------------------------------------------------------    
    # Génère l'expérience.
    #   battle_list : battle_list de l'adversaire vaincu battle_list[6]: base_exp
    #   level : niveau du vaincu
    #   number : nombre de participants
    #   type : de combat: sauvage ou dresseur, et autres multiplicateurs
    #   exp_share : multi_exp
    #------------------------------------------------------------   
    def exp_calculation(battle_list, level, number = 1, type = 1, exp_share_number = 0, out_battle = 1)
      # Formule de base
      number = 1 if number == 0
      exp_sup = Integer(battle_list[6] * level * type / 7) / number
      if POKEMON_S::Item.data(item_hold)["expgiven"]
        exp_sup += Integer(0.5 * exp_sup)
      end
      # Formule multi_exp
      if exp_share_number > 0
        exp_share_hold = POKEMON_S::Item.data(item_hold)["expshare"] ? 1 : 0
        value = level*battle_list[6]/14
        exp_sup = (Integer(value/number)*out_battle + Integer(value/exp_share_number)*exp_share_hold)*type
      end
      return exp_sup
    end
    
    def add_exp_battle(amount)
      @exp = (@exp + amount > exp_list[MAX_LEVEL])? exp_list[MAX_LEVEL] : @exp + amount
    end
    
    # Bonus EV pour celui qui a mis KO le pokémon adverse
    def add_bonus(battle_list)
      points = 0
      battle_list.each do |i|
        points += i
      end
      if total_ev + points <= 510
        if @hp_plus + battle_list[0] <= 255
          @hp_plus += battle_list[0]
        end
        if @atk_plus + battle_list[1] <= 255
          @atk_plus += battle_list[1]
        end
        if @dfe_plus + battle_list[2] <= 255
          @dfe_plus += battle_list[2]
        end
        if @spd_plus + battle_list[3] <= 255
          @spd_plus += battle_list[3]
        end
        if @ats_plus + battle_list[4] <= 255
          @ats_plus += battle_list[4]
        end
        if @dfs_plus + battle_list[5] <= 255
          @dfs_plus += battle_list[5]
        end
        statistic_refresh
        return true
      else
        return false
      end
    end
    
    def total_ev
      return @hp_plus + @atk_plus + @dfe_plus + @spd_plus + @ats_plus + @dfs_plus
    end
    
    def drop_loyalty(amount = 1)
      @loyalty -= amount
      if @loyalty < 0
        @loyalty = 0
      end
    end
    
    def raise_loyalty(amount = 0)
      if amount == 0
        if @loyalty < 100
          @loyalty += 5
        elsif @loyalty < 200
          @loyalty += 3
        elsif @loyalty < 255
          @loyalty += 2
        end
        if @loyalty > 255
          @loyalty = 255
        end
      else
        @loyalty += amount
      end
    end
    
    #------------------------------------------------------------    
    # Vérification du niveau / Augmente le niveau
    #------------------------------------------------------------    
    def level_check
      if @level >= MAX_LEVEL
        return false
      end
      return @exp >= exp_list[@level+1]
    end
    
    def level_up(scene = nil)
      list = level_up_stat_refresh
      list0 = list[0]
      list1 = list[1]
      
      # Loyauté
      raise_loyalty
      
      Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:level_plus]}")
      if scene != nil
        if $battle_var.in_battle 
          if self == scene.actor
            scene.actor_status.refresh
            scene.actor_sprite.animation($data_animations[497], true)
          end
        elsif not($battle_var.in_battle)
          scene.item_refresh
        end
        scene.draw_text(@given_name + " monte au", "niveau " + @level.to_s + "!")
        Graphics.update
        Input.update
        if $battle_var.in_battle 
          until Input.trigger?(Input::C) and not(scene.actor_sprite.effect?)
            scene.actor_sprite.update
            Graphics.update
            Input.update
          end
        end
        level_up_window_call(list0, list1, scene.z_level + 100)
        scene.draw_text("", "")
        refresh_skill(scene)
      else
        new_scene = Pokemon_Window_Help.new
        new_scene.draw_text(@given_name + " monte au", "niveau " + @level.to_s + "!")
        new_scene.update
        Input.update
        until Input.trigger?(Input::C)
          Graphics.update
          Input.update
        end
        new_scene.dispose
        Graphics.update
        level_up_window_call(list0, list1, new_scene.z_level + 1000)
        refresh_skill
      end
      if level_check
        level_up(scene)
      end
    end
    
    def level_up_stat_refresh
      if @exp < exp_list[@level+1]
        @exp = exp_list[@level+1]
      end
      hp_minus = maxhp_basis - @hp
      list0 = [maxhp_basis, atk_basis, dfe_basis, ats_basis, dfs_basis, spd_basis]
      @level += 1
      statistic_refresh
      list1 = [maxhp_basis, atk_basis, dfe_basis, ats_basis, dfs_basis, spd_basis]
      @hp = maxhp_basis - hp_minus
      return [list0, list1]
    end
    
    def silent_level_up
      # Calculs
      level_up_stat_refresh
      # Skills
      @skills_table.each do |skill|
        if skill[1] == @level and not(skill_learnt?(skill[0]))
          @skills_set.push(Skill.new(skill[0]))
          if @skills_set.length  > 4
            @skills_set = @skills_set[-4..-1]
          end
        end
      end
    end
    
    #------------------------------------------------------------    
    # Modification/Evolution du Pokémon
    #------------------------------------------------------------    
    def evolve(id = 0)
      if @egg
        @egg = false
        @trainer_id = Player.id
        @trainer_name = Player.name
        @given_name = name
        scenebis = Pokemon_Name.new(self)
        scenebis.main
        Graphics.transition
        return
      end
      if evolve_list[1] == [] or evolve_list[1] == nil or evolve_list[1][0] == ""
        return
      end
      hp_lost = max_hp - @hp
      if id == 0
        id = evolve_check
        if not id
          return
        end
        if @given_name == name
          @id = id
          @given_name = name
        else
          @id = id
        end
        archetype(@id)
        @hp = max_hp - hp_lost
        refresh_skill
      else # Force l'évolution (par l'usage de pierres ou de transfert)
        if @given_name == name
          @id = id
          @given_name = name
        else
          @id = id
        end
        @id = id
        archetype(@id)
        @hp = max_hp - hp_lost
        refresh_skill
      end
    end
    
    def evolve_check(mode = "", param = "")
      # Pas d'évolution
      if evolve_list[1] == [] or evolve_list[1] == nil or evolve_list[1][0] == ""
        return false
      end
      
      # [1, ["ONIGLALI", 42], ["MOMARTIK", ["stone", "PIERRE AUBE"], ["genre", "femelle"]]]
      1.upto(evolve_list.size - 1) do |i|
        check = true
        
        1.upto(evolve_list[i].size - 1) do |j|
          # V0.7 : PSP teste chaque critère.
          #   Si le critère est bon, il passe au critère suivant (next), sinon, 
          #   si aucun des critères na été respecté, l'évolution est rendue
          #   invalide (check = false) 
          #   et on inspecte l'évolution possible suivante (break). 
          #     A la fin, l'évolution est lancée car tous 
          #     les critères ont été validés.
          
          # Evolution par niveau  
          if evolve_list[i][j].type == Fixnum and 
             @level >= evolve_list[i][j] and mode != "stone"              
            next  
          end  
          
          # Evolution par loyauté
          if evolve_list[i][j] == "loyal" and @loyalty > 220 and mode != "stone"   
            next
          end
        
          # Evolution par lieu
          if evolve_list[i][j].is_a?(Array) and 
              evolve_list[i][j][0] == "place" and 
              evolve_list[i][j][1].include?($game_map.map_id)
            next
          end
          
          # Evolution par apprentissage d'attaques
          if evolve_list[i][j].is_a?(Array) and 
              evolve_list[i][j][0] == "attaque" and
              skills.include?(Skill_Info.id(evolve_list[i][j][1]))
            next
          end
          
          # Evolution par objet tenu
          if evolve_list[i][j].is_a?(Array) and 
              evolve_list[i][j][0] == "item" and
              @item_hold == POKEMON_S::Item.id(evolve_list[i][j][1])
            next
          end
          
          # Evolution par genre
          if evolve_list[i][j].is_a?(Array) and evolve_list[i][j][0] == "genre"
            if male? and evolve_list[i][j][1] == "male"
              next
            end
            if female? and evolve_list[i][j][1] == "femelle"
              next
            end
          end
          
          # Evolution par periode
          if evolve_list[i][j].is_a?(Array) and evolve_list[i][j][0] == "periode"
            if POKEMON_S.jour? and evolve_list[i][j][1] == "jour"
              next
            end
            if POKEMON_S.nuit? and evolve_list[i][j][1] == "nuit"
              next
            end
          end
          
          # Evolution par saison
          if evolve_list[i][1] == "saison"
            if Time.now.month > 5 and Time.now.month < 9 # si le jeu se déroule en été
              saisonloc = "ete"
              end
            if Time.now.month > 8 and Time.now.month < 12 # si le jeu se déroule en automne
                saisonloc = "automne"
                   end
            if Time.now.month > 0 and Time.now.month < 3 # si le jeu se déroule en hiver
                saisonloc = "hiver"
                   end
            if Time.now.month > 2 and Time.now.month < 6 # si le jeu se déroule au printemps
                saisonloc = "printemps"
            end
            if @level == evolve_list[i][2][0] and saisonloc == evolve_list[i][2][1]
              name = evolve_list[i][0]
              id = id_conversion(name)
              return id
            end
          end
          
          # Evolution aléatoire
          if evolve_list[i][j].is_a?(Array) and evolve_list[i][j][0] == "aleatoire"
            if rate == nil
              rate = rand(100)
            end
            if chance == nil
              chance = 0
            end
            if rate <= evolve_list[i][j][1] + chance
              next
            else
              chance += evolve_list[i][j][1]
            end
          end
          
          # Echange
          if evolve_list[i][j] == "trade" and mode == "trade"
            next
          end
          
          # Par pierre
          if evolve_list[i][j].is_a?(Array) and 
              evolve_list[i][j][0] == "stone" and
              mode == "stone" and
              evolve_list[i][j][1] == param
            next
          end
          
          check = false
          break
        end
        
        if check
          name = evolve_list[i][0]
          id = id_conversion(name)
          return id
        end
        
      end
      
      return false
    end
    
    # Modification forcée du niveau
    # level : Level attribué
    def refresh_level(new_level)
      @level_save = @level
      @level = new_level
      @hp = maxhp_basis
      @atk = atk_basis
      @dfe = dfe_basis
      @spd = spd_basis
      @ats = ats_basis
      @dfs = dfs_basis
    end
    
    #------------------------------------------------------------    
    # Expérience à acquérir pour le prochain niveau
    #------------------------------------------------------------ 
    def next_exp
      if @level >= MAX_LEVEL
        return 0
      end
      return (exp_list[@level+1]-@exp)
    end
  end
end