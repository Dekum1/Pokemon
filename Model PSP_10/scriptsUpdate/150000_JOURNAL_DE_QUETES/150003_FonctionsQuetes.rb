class Game_Event
  alias qu_start start
  def start
    if $pokemon_party != nil
      if @event.name != "FALSE"
        $pokemon_party.quete_parler(@event.name)
      end
    end
    qu_start
  end
end

class Interpreter
  alias qu_command_126 command_126
  def command_126
    value = operate_value(@parameters[1], @parameters[2], @parameters[3])
    $pokemon_party.quete_tr_obj(@parameters[0],value)
    qu_command_126
  end
end

module POKEMON_S
  class Pokemon_Battle_Trainer < Pokemon_Battle_Core
    alias qu_initialize initialize
    def initialize(party, trainer_id, ia = false, run_able = false, lose_able = false)
      qu_initialize(party, trainer_id, ia, run_able, lose_able)
      $pokemon_party.quete_voir_pokemon(@enemy.id)
    end
    
    alias qu_catch_pokemon catch_pokemon
    def catch_pokemon
      $pokemon_party.quete_capturer_pokemon(@enemy.id)
      qu_catch_pokemon
    end
  end
  
  class Pokemon_Battle_Wild < Pokemon_Battle_Core
    alias qu_initialize initialize
    def initialize(party, pokemon, ia = false, lose_able = false)
      qu_initialize(party, pokemon, ia, lose_able)
      $pokemon_party.quete_voir_pokemon(@enemy.id)
    end
    
    alias qu_catch_pokemon catch_pokemon
    def catch_pokemon
      $pokemon_party.quete_capturer_pokemon(@enemy.id)
      qu_catch_pokemon
    end
  end
  
  class Pokemon_Battle_Core
    alias qu_enemy_down enemy_down
    def enemy_down
      $pokemon_party.quete_vaincre_pokemon(@enemy.id)
      qu_enemy_down
    end
  end
end