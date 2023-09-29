#==============================================================================
# ■ TRADE
# Pokemon Script Project - Krosk 
# 24/01/08
# 29/08/08 - Script complété
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Gestion d'échange
#-----------------------------------------------------------------------------

TABLE = [
"0","1","2","3","4","5","6","7","8","9",
"a","b","c","d","e","f","g","h","i","j",
"k","l","m","n","o","p","q","r","s","t",
"u","v","w","x","y","z","A","B","C","D",
"E","F","G","H","I","J","K","L","M","N",
"O","P","Q","R","S","T","U","V","W","X",
"Y","Z","?","!"] # base 64

module POKEMON_S
  class Player
    def self.trainer_trade_code
      if POKEMON_S::TRADEGROUP == nil
        trade_group = 0
      else
        trade_group = POKEMON_S::TRADEGROUP
      end
      
      trade_bit_code = ""
      trade_bit_code += sprintf("%010d", trade_group.to_s(2))
      trade_bit_code += sprintf("%032d", Player.code.to_s(2))
      
      trade_string_code = ""
      for i in 1..7
        trade_string_code += TABLE[ trade_bit_code[(i-1)*6..(i*6-1)].to_i(2) ]
      end
      
      file = File.open("Echange/Mon_code.txt", "w")
      file.write(trade_string_code)
      file.close
      
      return trade_string_code
    end
  end
end
  
class Interpreter
  def pokemon_trade_code(pokemon, trade_string_code = nil)
    if trade_string_code == nil
      file = File.open("Echange/Son_code.txt", "r")
      trade_string_code = file.read(7)
      file.close
    end
    bit_code = ""
    bit_code += sprintf("%010d", pokemon.id.to_s(2))
    name_array = pokemon.trainer_name.unpack('c12')
    for value in name_array
      if value != nil
        bit_code += sprintf("%08d", value.to_s(2))
      else
        bit_code += sprintf("%08d", 0)
      end
    end
    bit_code += sprintf("%032d", Player.code.to_s(2))
    bit_code += sprintf("%032d", pokemon.code.to_s(2))
    shiny_code = pokemon.shiny ? 1 : 0
    bit_code += sprintf("%02d", shiny_code.to_s(2))
    bit_code += sprintf("%05d", pokemon.dv_hp.to_s(2))
    bit_code += sprintf("%05d", pokemon.dv_atk.to_s(2))
    bit_code += sprintf("%05d", pokemon.dv_dfe.to_s(2))
    bit_code += sprintf("%05d", pokemon.dv_spd.to_s(2))
    bit_code += sprintf("%05d", pokemon.dv_ats.to_s(2))
    bit_code += sprintf("%05d", pokemon.dv_dfs.to_s(2))
    bit_code += sprintf("%016d", pokemon.hp_plus.to_s(2))
    bit_code += sprintf("%016d", pokemon.atk_plus.to_s(2))
    bit_code += sprintf("%016d", pokemon.dfe_plus.to_s(2))
    bit_code += sprintf("%016d", pokemon.spd_plus.to_s(2))
    bit_code += sprintf("%016d", pokemon.ats_plus.to_s(2))
    bit_code += sprintf("%016d", pokemon.dfs_plus.to_s(2))
    name_array = pokemon.given_name.unpack('c10')
    for value in name_array
      if value != nil
        bit_code += sprintf("%08d", value.to_s(2))
      else
        bit_code += sprintf("%08d", 0)
      end
    end
    bit_code += sprintf("%024d", pokemon.exp.to_s(2))
    for i in 0..3
      if pokemon.skills_set[i] != nil
        skill = pokemon.skills_set[i]
        bit_code += sprintf("%010d", skill.id.to_s(2))
        bit_code += sprintf("%06d", skill.pp.to_s(2))
        bit_code += sprintf("%06d", skill.ppmax.to_s(2))
      else
        bit_code += sprintf("%022d", 0)
      end
    end
    bit_code += sprintf("%04d", pokemon.status.to_s(2))
    bit_code += sprintf("%010d", pokemon.item_hold.to_s(2))
    bit_code += sprintf("%08d", pokemon.loyalty.to_s(2))
    bit_code += sprintf("%010d", pokemon.hp.to_s(2))
    bit_code += sprintf("%06d", pokemon.id_ball.to_s(2))
    
    bit_code += sprintf("%016d", pokemon.step_remaining.to_s(2))
    egg_code = pokemon.egg ? 1 : 0
    bit_code += sprintf("%02d", egg_code.to_s(2))
    bit_code += sprintf("%06d", pokemon.form.to_s(2))
    
    trade_bit_code = ""
    for i in 1..7
      trade_bit_code += sprintf("%06d", TABLE.index(trade_string_code[i-1..i-1]).to_s(2))
    end
    
    srand(trade_bit_code.to_i(2)%(2**32))
    
    string_code = ""
    validation_key_high = 0
    validation_key_low = 0
    trigger = false
    for i in 1..92
      value = (bit_code[(i-1)*6..(i*6-1)].to_i(2)) ^ (rand(64))
      string_code += TABLE[value]
      if trigger
        validation_key_high ^= value
      else
        validation_key_low ^= value
      end
      trigger = (not trigger)
    end
    
    # ---------- Sequence de redondance
    
    bit_code += sprintf("%010d", POKEMON_S::TRADEGROUP.to_s(2))
    validation_key = validation_key_low + validation_key_high*(2**6)
    validation_key ^= POKEMON_S::TRADEGROUP
    
    bit_code += "00"
    bit_code += sprintf("%012d", validation_key.to_s(2))
    
    for i in 93..96
      value = (bit_code[(i-1)*6..(i*6-1)].to_i(2))^(rand(64))
      string_code += TABLE[value]
    end
    srand
    file = File.open("Echange/Envoi.txt", "w")
    file.write(string_code)
    #file.write("     ")
    #file.write(bit_code)
    file.close
    
    Player.erase_code(pokemon.code)
  end
  alias echange_transferer pokemon_trade_code
  
  
  def pokemon_trade_decode
    file = File.open("Echange/Boite.txt", "r")
    string_code = file.read(96)
    file.close
    
    trade_string_code = read_my_code
    trade_bit_code = ""
    for i in 1..7
      trade_bit_code += sprintf("%06d", TABLE.index(trade_string_code[i-1..i-1]).to_s(2))
    end
    srand(trade_bit_code.to_i(2)%(2**32))
    
    bit_code = ""
    validation_key_high = 0
    validation_key_low = 0
    trigger = false
    for i in 1..92
      index = TABLE.index(string_code[i-1..i-1])
      value = index ^ (rand(64))
      bit_code += sprintf("%06d", value.to_s(2))
      if trigger
        validation_key_high ^= index
      else
        validation_key_low ^= index
      end
      trigger = (not trigger)
    end
    
    for i in 93..96
      index = TABLE.index(string_code[i-1..i-1])
      value = index ^ (rand(64))
      bit_code += sprintf("%06d", value.to_s(2))
    end
    trade_groupe = bit_code[552..561].to_i(2)
    
    read_validation_key = bit_code[564..575].to_i(2)
    validation_key = validation_key_low + validation_key_high*(2**6)
    validation_key ^= trade_groupe
    
    if trade_groupe != POKEMON_S::TRADEGROUP and POKEMON_S::TRADEGROUP != 0
      return 1 # Erreur tradegroup
    end
    
    if read_validation_key != validation_key
      return 2 # Erreur de validation
    end
    
    pokemon = POKEMON_S::Pokemon.new(1,1)
    pokemon.bit_code_interpreter(bit_code)
    
    if existing_pokemon_check(pokemon)
      return 3
    end
    
    return pokemon
  end
  alias echange_lire pokemon_trade_decode
  
  def existing_pokemon_check(pokemon_to_check)
    return Player.trade_list.include?(pokemon_to_check.code)
  end
  
  def ajouter_pokemon_echange(pokemon)
    Player.register_code(pokemon.code)
    check = pokemon.evolve_check("trade")
    if check != false
      Graphics.freeze
      scene = POKEMON_S::Pokemon_Evolve.new(pokemon, check, 15000, true)
      scene.main
      Graphics.transition
    end
    ajouter_pokemon_cree(pokemon)
  end
  
  def read_my_code
    return Player.trainer_trade_code
  end
  
  def read_his_code
    if FileTest.exist?("Echange/Son_code.txt")
      file = File.open("Echange/Son_code.txt", "r")
      trade_string_code = file.read(7)
      file.close
    else
      trade_string_code = "0000000"
      write_his_code(trade_string_code)
    end
    return trade_string_code
  end
  
  def write_his_code(trade_string_code)
    file = File.open("Echange/Son_code.txt", "w")
    file.write(trade_string_code)
    file.close
  end
  
  def entrer_code_echange(code)
    Graphics.freeze
    Scene_Name.new(code).main
    Graphics.transition
    return true
  end
  
end

module POKEMON_S
  class Pokemon
    def bit_code_interpreter(bit_code)
      @id = bit_code[0..9].to_i(2)
      @trainer_name = ""
      name_array = []
      for i in 1..12
        value = bit_code[10+(i-1)*8..10+(i*8-1)].to_i(2)
        name_array.push(value)
      end
      name_array.delete(0)
      @trainer_name = name_array.pack('c*')
      @trainer_code = bit_code[106..137].to_i(2)
      @code = bit_code[138..169].to_i(2)
      @trainer_id = sprintf("%05d", @trainer_code % (2**16))
      @shiny = bit_code[170..171].to_i(2)
      @shiny = @shiny == 1 ? true : false
      archetype(@id)
      @dv_hp = bit_code[172..176].to_i(2)
      @dv_atk = bit_code[177..181].to_i(2)
      @dv_dfe = bit_code[182..186].to_i(2)
      @dv_spd = bit_code[187..191].to_i(2)
      @dv_ats = bit_code[192..196].to_i(2)
      @dv_dfs = bit_code[197..201].to_i(2)
      @hp_plus = bit_code[202..217].to_i(2)
      @atk_plus = bit_code[218..233].to_i(2)
      @dfe_plus = bit_code[234..249].to_i(2)
      @spd_plus = bit_code[250..265].to_i(2)
      @ats_plus = bit_code[266..281].to_i(2)
      @dfs_plus = bit_code[282..297].to_i(2)
      given_name_array = []
      @given_name = ""
      for i in 1..10
        value = bit_code[298+(i-1)*8..298+(i*8-1)].to_i(2)
        given_name_array.push(value)
      end
      given_name_array.delete(0)
      @given_name = given_name_array.pack('c*')
      @exp = bit_code[378..401].to_i(2)
      while @exp >= exp_list[@level+1]
        @level += 1
      end
      statistic_refresh
      @skills_set = []
      for i in 1..4
        id_skill = bit_code[402+(i-1)*22..411+(i-1)*22].to_i(2)
        if id_skill != 0
          skill = Skill.new(id_skill)
          skill.pp = bit_code[412+(i-1)*22..417+(i-1)*22].to_i(2)
          skill.define_ppmax(bit_code[418+(i-1)*22..423+(i-1)*22].to_i(2))
          skills_set.push(skill)
        end
      end
      @status = bit_code[490..493].to_i(2)
      @item_hold = bit_code[494..503].to_i(2)
      @loyalty = bit_code[504..511].to_i(2)
      @hp = bit_code[512..521].to_i(2)
      @id_ball = bit_code[522..527].to_i(2)
      @nature = nature_generation
      @ability = ability_conversion
      @step_remaining = bit_code[528..543].to_i(2)
      @egg = bit_code[544..545].to_i(2)
      @egg = shiny == 1 ? true : false
      @form = bit_code[546..551].to_i(2)
    end
  end
  
end