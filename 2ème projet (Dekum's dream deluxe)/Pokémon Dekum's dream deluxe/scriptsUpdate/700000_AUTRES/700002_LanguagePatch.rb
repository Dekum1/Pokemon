#==============================================================================
# ■ Language Patch
# Pokemon Script Project - Krosk 
# 17/01/09
#-----------------------------------------------------------------------------
# N'y touchez pas
#-----------------------------------------------------------------------------
if FileTest.exist?("Language")
  def skill_conversion
    # Conversion
    for id in 1..$data_skills_pokemon.length-1
      skill = POKEMON_S::Skill.new(id)
      
      if $data_skills[id] == nil
        $data_skills[id] = RPG::Skill.new
      end
      
      $data_skills[id].name = skill.name.upcase
      $data_skills[id].element_set = [skill.type]
      if skill.power > 200
        $data_skills[id].atk_f = 200
        $data_skills[id].eva_f = skill.power - 200
      else
        $data_skills[id].atk_f = skill.power
        $data_skills[id].eva_f = 0
      end
      $data_skills[id].hit = skill.accuracy
      $data_skills[id].power = skill.effect
      $data_skills[id].pdef_f = skill.effect_chance
      $data_skills[id].sp_cost = skill.ppmax
      case skill.target
      when 1
        $data_skills[id].scope = 0
      when 0
        $data_skills[id].scope = 1
      when 8
        $data_skills[id].scope = 2
      when 4
        $data_skills[id].scope = 3
      when 20
        $data_skills[id].scope = 4
      when 40
        $data_skills[id].scope = 5
      when 10
        $data_skills[id].scope = 7
      end
      $data_skills[id].animation1_id = skill.user_anim_id
      $data_skills[id].animation2_id = skill.target_anim_id
      $data_skills[id].description = skill.description
      $data_skills[id].variance = skill.direct? ? 1 : 0
      $data_skills[id].mdef_f = skill.priority
      if skill.map_use != 0
        $data_skills[id].occasion = 0
        $data_skills[id].common_event_id = skill.map_use
      else
        $data_skills[id].occasion = 1
        $data_skills[id].common_event_id = 0
      end
      
      # Effacement
      $data_skills[id].plus_state_set = []
      $data_skills[id].minus_state_set = []
      $data_skills[id].agi_f = 0
      $data_skills[id].str_f = 0
      $data_skills[id].dex_f = 0
      $data_skills[id].agi_f = 0
      $data_skills[id].int_f = 0
    end
    
    file = File.open("Data/Skills.rxdata", "wb")
    Marshal.dump($data_skills, file)
    file.close
  end
  
  begin
    # data_pokemon[id][0]
    i = 0
    if FileTest.exist?("Language/noms.txt")
      file = File.open("Language/noms.txt", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| 
        i += 1
        $data_pokemon[i][0] = line.sub("\r\n", "")
        }
      file.close
    end
    
    # data_pokemon[id][5][1+]
    i = 0
    if FileTest.exist?("Language/evolve.txt")
      file = File.open("Language/evolve.txt", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| 
        i += 1
        clean_line = line.sub('\r\n', "")
        array = clean_line.split(';')
        $data_pokemon[i][5] = $data_pokemon[i][5][0..0]
        for evo in array
          $data_pokemon[i][5].push(eval("[#{evo}]"))
        end
        }
      file.close
    end
    
    # data_pokemon[id][9][jd]
    if FileTest.exist?("Language/description.txt")
      j = 0
      for filename in ["description.txt", "espece.txt"]
        i = 0
        file = File.open("Language/#{filename}", "rb")
        file.readchar
        file.readchar
        file.readchar
        file.each {|line| 
          i += 1
          if j == 2 or j == 3
            clean_line = line.sub("\r\n", "")
            $data_pokemon[i][9][j] = clean_line.sub(/ \(.*\)/, "")
          else
            $data_pokemon[i][9][j] = line.sub("\r\n", "")
          end
          }
        file.close
        j += 1
      end
    end
    
    # data_skills[id][0]
    i = 0
    if FileTest.exist?("Language/skill_noms.txt")
      file = File.open("Language/skill_noms.txt", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| 
        i += 1
        $data_skills_pokemon[i][0] = line.sub("\r\n", "")
        }
      file.close
    end
    
    $game_system = Game_System.new
    $data_system        = load_data("Data/System.rxdata")
    $fontface = ["Pokemon FRLG", "Trebuchet MS"]
    $fontsize = 38  # // hauteur min 26
    
    splash.dispose
    Graphics.transition(5)
    Graphics.update
    
    print "Quand la mise à jour sera terminée, supprimez le répertoire Language."
    
    skill_conversion
    temp = Scene_Debug.new
    temp.pokemon_conversion
    
    
  rescue Exception => exception
    EXC::error_handler(exception, file)
  end
end