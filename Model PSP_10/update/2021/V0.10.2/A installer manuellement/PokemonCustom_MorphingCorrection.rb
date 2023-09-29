Dans Pokemon_Custom :
l.438 :
Remplacez :
# --------- ----------
    # Morphing / Transform
    # --------- ----------
    def transform_effect(target, recover = false)
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
Par :
# --------- ----------
    # Morphing / Transform
    # --------- ----------
    def transform_effect(target, recover = false)
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