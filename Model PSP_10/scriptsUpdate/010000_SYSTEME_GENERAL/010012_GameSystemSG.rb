#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　Cette classe gère les données autour du système. Il gère également 
#  la musique de fond. Cette classe
#  Les instances sont référencées dans $ game_system.
#==============================================================================

class Game_System
  def reset_interpreter
    @map_interpreter = Interpreter.new(0, true)
  end
  
  def battle_bgm
    if not $game_switches[MATIN_SWITCHES]
      if @battle_bgm1 == nil
        return $data_system.battle_bgm
      else
        return @battle_bgm1
      end
    else
      if @battle_bgm2 == nil
        return $data_system.battle_bgm
      else
        return @battle_bgm2
      end
    end
  end

  def battle_bgm=(battle_bgm)
    if not $game_switches[MATIN_SWITCHES]
      @battle_bgm1 = battle_bgm
    else
      @battle_bgm2 = battle_bgm
    end
  end

  def battle_end_me
    if @battle_end_me == nil
      return $data_system.battle_end_me
    else
      return @battle_end_me
    end
  end

  def battle_end_me=(battle_end_me)
    @battle_end_me = battle_end_me
  end
end
