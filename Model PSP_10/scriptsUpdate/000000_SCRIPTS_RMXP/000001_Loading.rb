#==============================================================================
# ■ Loading
# Pokemon Script Project - Krosk 
# 28/08/08
#-----------------------------------------------------------------------------
# Ecran de chargement
#-----------------------------------------------------------------------------
# Ne pas y toucher... ou avec modération, ce sont mes crédits
#-----------------------------------------------------------------------------
begin
  Graphics.freeze
  $splash = Sprite.new
  $splash.bitmap = RPG::Cache.title("pkssplash.png")
  Graphics.transition(5)
  Graphics.freeze
end

#==============================================================================
# ■ Cimetière
# Pokemon Script Project - Krosk 
# 07/08/08
#-----------------------------------------------------------------------------
# N'y touchez pas
#-----------------------------------------------------------------------------
if false
  data_pokemon = Array.new(494)
  
  for i in 1..493
    data_pokemon[i] = []
    data_pokemon[i][1] = i
    data_pokemon[i][2] = []
    data_pokemon[i][4] = []
    data_pokemon[i][5] = []
    data_pokemon[i][7] = []
    data_pokemon[i][9] = []
    data_pokemon[i][9][4] = []
  end
  
  begin
    # data_pokemon[id][0]
    i = 0
    file = File.open("database/noms.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      data_pokemon[i][0] = line.sub("\r\n", "")
      }
    file.close
    
    # data_pokemon[id][2][jd]
    j = 0
    for filename in ["base_hp.txt", "base_atk.txt", "base_dfe.txt", "base_spd.txt", "base_ats.txt", "base_dfs.txt"]
      i = 0
      file = File.open("database/#{filename}", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| 
        i += 1
        data_pokemon[i][2][j] = line.sub("\r\n", "").to_i
        }
      file.close
      j += 1
    end
    
    # data_pokemon[id][3]
    i = 0
    file = File.open("database/skill_list.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub('\r\n', "")
      data_pokemon[i][3] = eval("[#{clean_line}]")
      }
    file.close
    
    # data_pokemon[id][4]
    i = 0
    file = File.open("database/tech_list.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub('\r\n', "")
      for j in 0..clean_line.length/2-1
        tech = clean_line[2*j..2*j+1]
        if tech.include?("H")
          tech.sub!("H", "")
          data_pokemon[i][4].push( eval("[#{tech.to_i}]") )
        else
          data_pokemon[i][4].push( tech.to_i ) if tech.to_i != 0
        end
      end
      }
    file.close
    
    # data_pokemon[id][5][0]
    i = 0
    file = File.open("database/exp.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub('\r\n', "")
      data_pokemon[i][5][0] = clean_line.to_i
      }
    file.close
    
    # data_pokemon[id][5][1+]
    i = 0
    file = File.open("database/evolve.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub('\r\n', "")
      array = clean_line.split(';')
      for evo in array
        data_pokemon[i][5].push(eval("[#{evo}]"))
      end
      }
    file.close
    
    # data_pokemon[id][6]
    i = 0
    file = File.open("database/type.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub('\r\n', "")
      data_pokemon[i][6] = eval("[#{clean_line}]")
      }
    file.close
    
    # data_pokemon[id][7][jd]
    j = 0
    for filename in ["rarete.txt", "taux_femelle.txt", "loyaute.txt", 
        "capa_spe.txt", "breed_group.txt", "breed_move.txt", "hatch_step.txt"]
      i = 0
      file = File.open("database/#{filename}", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| 
        i += 1
        clean_line = line.sub("\r\n", "")
        next if i >= 494
        clean_line.upcase! if j == 3
        if j == 3
          data_pokemon[i][7][3] = clean_line.split(',')
        elsif j == 4 or j == 5
          data_pokemon[i][7][j] = eval("[#{clean_line}].uniq")
        else
          data_pokemon[i][7][j] = clean_line.to_i
        end
        }
      file.close
      j += 1
    end
    
    # data_pokemon[id][8]
    i = 0
    file = File.open("database/battle_list.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub("\r\n", "")
      data_pokemon[i][8] = eval("[#{clean_line}]")
      }
    file.close
    
    # data_pokemon[id][8][6]
    i = 0
    file = File.open("database/base_exp.txt", "rb")
    file.readchar
    file.readchar
    file.readchar
    file.each {|line| 
      i += 1
      clean_line = line.sub("\r\n", "")
      data_pokemon[i][8].push(clean_line.to_i)
      }
    file.close
    
    # data_pokemon[id][9][jd]
    j = 0
    for filename in ["description.txt", "espece.txt", "taille.txt", "poids.txt"]
      i = 0
      file = File.open("database/#{filename}", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| 
        i += 1
        if j == 2 or j == 3
          clean_line = line.sub("\r\n", "")
          data_pokemon[i][9][j] = clean_line.sub(/ \(.*\)/, "")
        else
          data_pokemon[i][9][j] = line.sub("\r\n", "")
        end
        }
      file.close
      j += 1
    end
      
    $data_pokemon = data_pokemon
  rescue Exception => exception
    EXC::error_handler(exception, file)
  end
    
  file = File.open("data.txt", "w")
  for i in 1..493
    file.write("$data_pokemon[#{i}] = #{$data_pokemon[i].inspect}\n")
  end
  file.close
  
  Dir.rmdir("database")
end