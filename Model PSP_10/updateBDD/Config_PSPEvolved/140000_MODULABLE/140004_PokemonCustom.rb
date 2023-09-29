#==============================================================================
# ■ Pokemon_Custom
# Pokemon Script Project - Krosk 
# 05/09/08
#-----------------------------------------------------------------------------
# Méthodes spéciales pour Pokémons et capacités spécifiques
#-----------------------------------------------------------------------------
# Ce script sert à placer les modifications de méthodes propres à certains 
# Pokémons ou capacités spéciales, pour éviter de modifier les scripts clés
#-----------------------------------------------------------------------------
# La méthode à suivre doit être comprise avant d'essayer d'ajouter des règles...
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon
    # -----------------------------------------------------------------
    #  Stat spéciale Munja
    # -----------------------------------------------------------------
    alias temp_maxhp_basis maxhp_basis
    def maxhp_basis
      if name == "Munja"
        return 1
      end
      temp_maxhp_basis
    end
    
    # -----------------------------------------------------------------
    #  Zarbi et Vivaldaim à l'état sauvage
    # -----------------------------------------------------------------
    alias temp_initialize initialize
    def initialize(id_data = 1, level = 1, shiny = false, no_shiny = false, trainer = Player)
      temp_initialize(id_data, level, shiny, no_shiny, trainer)
      if name == "Zarbi"
        @form = rand(27) + 1
      end
      if name == "Vivaldaim"
        @form = rand(4)
      end
      if name == "Haydaim"
        @form = rand(4)
      end
      alt_movepool(true)
    end  
    


    
    # -----------------------------------------------------------------
    #  Objet tenu, changement de forme
    # -----------------------------------------------------------------
    def item_hold=(item_id)
      @item_hold = item_id
      if ability_symbol == :multi_type
        # 324 est la marge entre le numéro de la forme et l'ID de l'item
        @form = item_id - 324
        @form = 0 if @form < 2 or @form > 18
      else
        case name
        when "Deoxys"
          @form = 5 if item_id == 1
          @form = 0 if item_id != 1
        when "Giratina"
          @form = item_id == 343 ? 1 : 0 
          @ability = @form == 0 ? 46 : 26
        end
      end
    end
    
    
    #type formes
    def type1
      if ability_symbol == :multi_type or ability_symbol == :meteo
        type = @form > 1 ? @form : 0
      else
        type = @type1
      end
      return type
    end
    
    def type2
      case name
      when "Motisma"
        list = [14, 2, 3, 6, 10, 5]
        type = list[@form]
      when "Necrozma"
        list = [11, 2, 3, 11]
        type = list[@form]
      else
        type = @type2
      end
       #---------- Forme Alola -------------
      if @form == 1
        case name
        when "Noadkoko"
          type = 15
        when "Ossatueur"
          type = 14
        when "Racaillou", "Gravalanch", "Grolem"
          type = 4
        when "Raichu"
          type = 11
        end
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Nanméouïe", "Altaria"
          type = 18
        when "Leviator"
          type = 17
        when "Scarabrute"
          type = 10
        when "Galeking"
          type = 0
        end
      end
      return type
    end
      
    # -----------------------------------------------------------------
    #  Stat spéciale Deoxys
    # -----------------------------------------------------------------
    # 1 : Attaque
    # 2 : Defense
    # 3 : Normal
    # 4 : Vitesse
    alias temp_base_atk base_atk
    def base_atk
      @form ||= 0
      atk_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 180, 70, 95]
        atk_tmp = list[@form] if @form < list.size
      when "Giratina"
        atk_tmp = 120 if @form == 1
      when "Exagide"
        atk_tmp = 150 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          atk_tmp = 75
        when "Gardevoir"
          atk_tmp = 85
        when "Gallame"
          atk_tmp = 165
        when "Ectoplasma"
          atk_tmp = 65
        when "Scarhino"
          atk_tmp = 185
        when "Lucario", "Métalosse", "Drattak"
          atk_tmp = 145
        when "Tyranocif"
          atk_tmp = 164
        when "Altaria"
          atk_tmp = 110
        when "Blizzaroi"
          atk_tmp = 132
        when "Cizayox"
          atk_tmp = 150
        when "Camérupt", "Oniglali"
          atk_tmp = 120
        when "Galeking",  "Sharpedo"
          atk_tmp = 140
        when "Léviator", "Scarabrute"
          atk_tmp = 155
        when "Carchacrok"
          atk_tmp = 170
        when "Charmina"
          atk_tmp = 100
        when "Démolosse"
          atk_tmp = 90
        when "Steelix"
          atk_tmp = 125
        when "Mysdibule"
          atk_tmp = 105
        when "Nanméouie"
          atk_tmp = 60
        end
      end
      return atk_tmp if atk_tmp != nil
      temp_base_atk
    end
    
    alias temp_base_dfe base_dfe
    def base_dfe
      @form ||= 0
      dfe_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 20, 160, 90]
        dfe_tmp = list[@form] if @form < list.size
      when "Giratina"
        dfe_tmp = 100 if @form == 1
      when "Exagide"
        dfe_tmp = 50 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          dfe_tmp = 80
        when "Gardevoir"
          dfe_tmp = 65
        when "Gallame"
          dfe_tmp = 95
        when "Ectoplasma"
          dfe_tmp = 80
        when "Scarhino"
          dfe_tmp = 115
        when "Lucario"
          dfe_tmp = 88
        when "Tyranocif"
          dfe_tmp = 150
        when "Altaria"
          dfe_tmp = 110
        when "Blizzaroi"
          dfe_tmp = 105
        when "Cizayox"
          dfe_tmp = 140
        when "Métalosse"
          dfe_tmp = 150
        when "Camérupt"
          dfe_tmp = 100
        when "Galeking", "Steelix"
          dfe_tmp = 230
        when "Léviator"
          dfe_tmp = 109
        when "Carchacrok"
          dfe_tmp = 115
        when "Sharpedo"
          dfe_tmp = 70
        when "Oniglali"
          dfe_tmp = 80
        when "Drattak"
          dfe_tmp = 130
        when "Charmina"
          dfe_tmp = 85
        when "Scarabrute"
          dfe_tmp = 120
        when "Démolosse"
          dfe_tmp = 90
        when "Mysdibule"
          dfe_tmp = 125
        when "Nanméouie"
          dfe_tmp = 126
        end
      end
      return dfe_tmp if dfe_tmp != nil
      temp_base_dfe
    end
    
    alias temp_base_spd base_spd
    def base_spd
      @form ||= 0
      spd_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 150, 90, 180]
        spd_tmp = list[@form] if @form < list.size
      when "Exagide"
        spd_tmp = 60 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          spd_tmp = 135
        when "Gardevoir", "Oniglali", "Charmina"
          spd_tmp = 100
        when "Gallame", "Métalosse"
          spd_tmp = 110
        when "Ectoplasma"
          spd_tmp = 130
        when "Scarhino", "Cizayox"
          spd_tmp = 75
        when "Lucario"
          spd_tmp = 112
        when "Tyranocif"
          spd_tmp = 71
        when "Altaria"
          spd_tmp = 80
        when "Blizzaroi", "Steelix"
          spd_tmp = 30
        when "Camérupt"
          spd_tmp = 20
        when "Galeking", "Mysdibule", "Nanméouie"
          spd_tmp = 50
        when "Léviator"
          spd_tmp = 81
        when "Carchacrok"
          spd_tmp = 92
        when "Sharpedo"
          spd_tmp = 105
        when "Drattak"
          spd_tmp = 120
        when "Scarabrute" 
          spd_tmp = 105
        when "Démolosse"
          spd_tmp = 115
        end
      end
      return spd_tmp if spd_tmp != nil
      temp_base_spd
    end
    
    alias temp_base_ats base_ats
    def base_ats
      @form ||= 0
      ats_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 180, 70, 95]
        ats_tmp = list[@form] if @form < list.size
      when "Giratina"
        ats_tmp = 120 if @form == 1
      when "Exagide"
        ats_tmp = 150 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint"
          ats_tmp = 135
        when "Gardevoir"
          ats_tmp = 165
        when "Gallame", "Cizayox"
          ats_tmp = 65
        when "Ectoplasma"
          ats_tmp = 170
        when "Scarhino"
          ats_tmp = 40
        when "Lucario", "Démolosse"
          ats_tmp = 140
        when "Tura,pcof"
          ats_tmp = 95
        when "Altaria", "Sharpedo"
          ats_tmp = 110
        when "Blizzaroi"
          ats_tmp = 132
        when "Métalosse"
          ats_tmp = 105
        when "Camérupt"
          ats_tmp = 145
        when "Galeking"
          ats_tmp = 60
        when "Léviator"
          ats_tmp = 70
        when "Carchacrok", "Oniglali", "Drattak"
          ats_tmp = 120
        when "Charmina"
          ats_tmp = 80
        when "Scarabrute"
          ats_tmp = 65
        when "Steelix"
          ats_tmp = 55
        when "Nanméouie"
          ats_tmp = 80
        end
      end
      return ats_tmp if ats_tmp != nil
      temp_base_ats
    end
    
    alias temp_base_dfs base_dfs
    def base_dfs
      @form ||= 0
      dfs_tmp = nil
      case name
      when "Deoxys"
        list = [nil, 20, 160, 90]
        dfs_tmp = list[@form] if @form < list.size
      when "Giratina"
        dfs_tmp = 100 if @form == 1
      when "Exagide"
        dfs_tmp = 50 if @form == 1
      end
      #---------- Méga-Pokémon -------------
      if @mega == 1
        case name
        when "Élecsprint", "Galeking", "Oniglali", "Charmina"
          dfs_tmp = 80
        when "Gardevoir"
          dfs_tmp = 135
        when "Gallame"
          dfs_tmp = 115
        when "Ectoplasma", "Carchacrok"
          dfs_tmp = 95
        when "Scarhino", "Camérupt"
          dfs_tmp = 105
        when "Lucario"
          dfs_tmp = 70
        when "Tyranocif"
          dfs_tmp = 120
        when "Altaria", "Blizzaroi"
          dfs_tmp = 105
        when "Cizayox"
          dfs_tmp = 100
        when "Métalosse"
          dfs_tmp = 110
        when "Léviator"
          dfs_tmp = 130
        when "Sharpedo", "Scarabrute"
          dfs_tmp = 65
        when "Drattak"
          dfs_tmp = 90
        when "Démolosse"
          dfs_tmp = 140
        when "Steelix", "Mysdibule"
          dfs_tmp = 55
        when "Nanméouie"
          dfs_tmp = 126
        end
      end
      return dfs_tmp if dfs_tmp != nil
      temp_base_dfs
    end
    
    
    # -----------------------------------------------------------------
    #  Effect
    # -----------------------------------------------------------------
    #  La suite n'est à modifier que si vous savez ce que vous faites
    # -----------------------------------------------------------------
    alias temp_skill_effect_reset skill_effect_reset
    def skill_effect_reset
      # Transform / Morphing cleaning
      if effect_list.include?(:morphing)
        index = effect_list.index(:morphing)
        transform_effect(@effect[index][2], true)
        @effect.delete_at(index)
      end
      # Copie / Mimic cleaning
      if effect_list.include?(:copie)
        index = effect_list.index(:copie)
        skill_index = @skills_set.index(@effect[index][2][1])
        @skills_set[skill_index] = @effect[index][2][0]
        @effect.delete(effect)
      end
      temp_skill_effect_reset
    end
    
    # --------- ----------
    # Morphing / Transform
    # --------- ----------
    def transform_effect(target, recover = false)
      if not recover
        @save_transform = {
          :type1 => @type1,
          :type2 => @type2,
          :atk => @atk,
          :dfe => @dfe,
          :ats => @ats,
          :dfs => @dfs,
          :spd => @spd,
          :base_atk => @base_atk,
          :base_ats => @base_ats,
          :base_dfe => @base_dfe,
          :base_dfs => @base_dfs,
          :base_spd => @base_spd,
          :dv_atk => @dv_atk,
          :dv_ats => @dv_ats,
          :dv_dfe => @dv_dfe,
          :dv_dfs => @dv_dfs,
          :dv_spd => @dv_spd,
          :battle_stage => @battle_stage,
          :atk_plus => @atk_plus,
          :dfe_plus => @dfe_plus,
          :ats_plus => @ats_plus,
          :dfs_plus => @dfs_plus,
          :spd_plus => @spd_plus,
          :ability => @ability,
          :battler_id => @battler_id,
          :skills_set => @skills_set
        }
      else
        @save_transform = nil
      end
      @type1 = target.type1
      @type2 = target.type2
      @atk = target.atk
      @dfe = target.dfe
      @ats = target.ats
      @dfs = target.dfs
      @spd = target.spd
      @base_atk = target.base_atk
      @base_ats = target.base_ats
      @base_dfe = target.base_dfe
      @base_dfs = target.base_dfs
      @base_spd = target.base_spd
      @dv_atk = target.dv_atk
      @dv_ats = target.dv_ats
      @dv_dfe = target.dv_dfe
      @dv_dfs = target.dv_dfs
      @dv_spd = target.dv_spd
      @battle_stage = target.battle_stage
      @bonus = target.bonus
      @atk_plus = target.atk_plus
      @dfe_plus = target.dfe_plus
      @ats_plus = target.ats_plus
      @dfs_plus = target.dfs_plus
      @spd_plus = target.spd_plus
      @ability = target.ability
      @battler_id = target.id
      if recover
        @skills_set = target.skills_set
      end
      statistic_refresh
    end
    
    def re_etablish_transform_effect
        @type1 = @save_transform[:type1]
        @type2 = @save_transform[:type2]
        @atk = @save_transform[:atk]
        @dfe = @save_transform[:dfe]
        @ats = @save_transform[:ats]
        @dfs = @save_transform[:dfs]
        @spd = @save_transform[:spd]
        @base_atk = @save_transform[:base_atk]
        @base_ats = @save_transform[:base_ats]
        @base_dfe = @save_transform[:base_dfe]
        @base_dfs = @save_transform[:base_dfs]
        @base_spd = @save_transform[:base_spd]
        @dv_atk = @save_transform[:dv_atk]
        @dv_ats = @save_transform[:dv_ats]
        @dv_dfe = @save_transform[:dv_dfe]
        @dv_dfs = @save_transform[:dv_dfs]
        @dv_spd = @save_transform[:dv_spd]
        @battle_stage = @save_transform[:battle_stage]
        @atk_plus = @save_transform[:atk_plus]
        @dfe_plus = @save_transform[:dfe_plus]
        @ats_plus = @save_transform[:ats_plus]
        @dfs_plus = @save_transform[:dfs_plus]
        @spd_plus = @save_transform[:spd_plus]
        @ability = @save_transform[:ability]
        @battler_id = @save_transform[:battler_id]
        @skills_set = @save_transform[:skills_set]
    end
    
    # -----------------------------------------------------------------
    #  Capacités spéciales
    # -----------------------------------------------------------------
    #  La suite n'est à modifier que si vous savez ce que vous faites
    # -----------------------------------------------------------------
    
    alias temp_change_stat change_stat
    def change_stat(stat_id, amount = 0, actor_change = self)
      # Corps sain / Clear Body (ab) // Mist / Brume
      if amount < 0 and (effect_list.include?(:brume) and 
                         actor_change.ability_symbol != :infiltration or 
                         ability_symbol == :corps_sain or 
                         effect_list.include?(:defense_spec))
        return 0 
      end
      # Regard Vif / Keen Eye (ab)
      if amount < 0 and stat_id == 6 and ability_symbol == :regard_vif
        return 0
      end
      # Hyper Cutter (ab)
      if amount < 0 and stat_id == 0 and ability_symbol == :hyper_cutter
        return 0
      end
      temp_change_stat(stat_id, amount, actor_change)
    end
    
    alias temp_spd_modifier spd_modifier
    def spd_modifier
      n = 1
      # Swift Swim / Glissade (ab)
      if ability_symbol == :glissade and $battle_var.rain?
        n *= 2
      end
      # Chlorophyle (ab)
      if ability_symbol == :chlorophyle and $battle_var.sunny?
        n *= 2
      end
      return n*temp_spd_modifier
    end
    
    alias temp_sleep_check sleep_check
    def sleep_check
      if ability_symbol == :matinal
        @status_count -= 1
      end
      temp_sleep_check
    end
  end
end


# Les modules suivants sont complémentaires et ne sont pas activés par défaut.
if false

module POKEMON_S
  # Météo automatique au combat
  class Pokemon_Battle_Variable
    def reset
      reset_weather
      @actor_last_used = nil
      @enemy_last_used = nil
      @battle_order = (0..5).to_a
      @enemy_battle_order = (0..5).to_a
      @in_battle = false
      @actor_last_taken_damage = 0
      @enemy_last_taken_damage = 0
      @have_fought = []
      @enemy_party = Pokemon_Party.new
      @action_id = 0
      @window_index = 0
      @last_index = 0
      @round = 0
      @run_count = 0
      @money = 0
    end
  end
end


module POKEMON_S
  # Capacités évolutives (idée de Mister-K)
  class Skill
    PAS_UTIL = 20
    PAS_PUIS = 10
   
    alias initialize_temp initialize
    def initialize(id)
      initialize_temp(id)
      @use_number = 0
    end
   
    def power
      @use_number = 0 if @use_number == nil # Protection indéfinition
      return Skill_Info.base_damage(id) + PAS_PUIS * @use_number / PAS_UTIL
    end
   
    alias use_temp use
    def use
      use_temp
      @use_number = 0 if @use_number == nil # Protection indéfinition
      @use_number += 1 if @usable
    end
  end
end
end
module POKEMON_S
  class Pokemon_Battle_Variable
    alias reset_temp reset
    def reset
      reset_temp
      reset_weather
    end
    
    def reset_weather
      @weather = [0, 0]
      case $game_screen.weather_type
      when 1
        set_rain
      when 2
        set_rain
      when 3
        set_hail
      end
    end
  end
end
    