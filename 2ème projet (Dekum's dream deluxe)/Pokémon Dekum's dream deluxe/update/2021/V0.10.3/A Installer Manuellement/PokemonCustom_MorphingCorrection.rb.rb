dépendance : aucune

Dans Pokemon_Custom :
l.441 :
Remplacez :
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
Par :
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