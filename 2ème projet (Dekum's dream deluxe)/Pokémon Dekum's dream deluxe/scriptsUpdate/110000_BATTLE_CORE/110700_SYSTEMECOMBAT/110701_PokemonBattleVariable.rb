#==============================================================================
# ■ Pokemon_Battle_Variable
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
  class Pokemon_Battle_Variable
    attr_accessor :weather
    attr_accessor :last_used
    attr_accessor :actor_last_used
    attr_accessor :enemy_last_used
    attr_accessor :battle_order
    attr_accessor :enemy_battle_order
    attr_accessor :in_battle
    attr_accessor :actor_last_taken_damage
    attr_accessor :enemy_last_taken_damage
    attr_accessor :have_fought #liste des pokémons ayant participé par leur index
    attr_accessor :enemy_party
    attr_accessor :action_id
    attr_accessor :window_index
    attr_accessor :result_flee
    attr_accessor :result_win
    attr_accessor :result_defeat
    attr_accessor :last_index
    attr_accessor :round
    attr_accessor :run_count
    attr_accessor :money
    attr_accessor :money_payday
    
    # Weather: [ catégorie, nombre de tours ]
    # catégorie: 0: Normal, 1: Pluie, 2: Ensoleillé, 
    #            3: Tempête de Sable, 4: Grêle
    
    def initialize
      @weather = [0, 0]
      @last_used = nil
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
      @result_flee = false
      @result_win = false
      @result_defeat = false
      @last_index = 0
      @round = 0
      @run_count = 0
      @money = 0
      @money_payday = 0
    end
    
    def reset
      @weather = [0, 0]
      @last_used = nil
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
      @money_payday = 0
    end
    
    def reset_weather
      @weather = [0, 0]
    end
    
    def set_rain(duration = -1)
      @weather = [1, duration]
    end
    
    def rain?
      if @weather[0] == 1
        return true
      else
        return false
      end
    end
    
    def set_sunny(duration = -1)
      @weather = [2, duration]
    end
    
    def sunny?
      if @weather[0] == 2
        return true
      else
        return false
      end
    end
    
    def sandstorm?
      if @weather[0] == 3
        return true
      else
        return false
      end
    end
    
    def set_sandstorm(duration = -1)
      @weather = [3, duration]
    end
    
    def hail?
      if @weather[0] == 4
        return true
      else
        return false
      end
    end
    
    def set_hail(duration = -1)
      @weather = [4, duration]
    end
    
    def battle_end?
      if @result_flee or @result_win or @result_defeat
        return true
      else
        return false
      end
    end
    
    def add_money(amount)
      if @money == nil
        @money = 0
      end
      @money += amount
    end
  end
end