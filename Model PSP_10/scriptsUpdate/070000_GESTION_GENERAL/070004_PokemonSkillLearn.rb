#==============================================================================
# ■ Pokemon_Skill_Learn
# Pokemon Script Project - Krosk 
# 01/08/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Scène parallèle appelée en cas de level_up
#-----------------------------------------------------------------------------

module POKEMON_S
  class Pokemon_Skill_Learn
    attr_accessor :return_data
    
    def initialize(pokemon, skill_id, backscene = nil)
      if backscene == nil
        @z_level = 500
        @scene = nil
      else
        @z_level = backscene.z_level + 100
        @scene = backscene
      end
      @pokemon = pokemon
      @skill = Skill.new(skill_id)
      @text_window = Pokemon_Window_Help.new
      @phase = 0
      @done = false
    end
    
    def main
      if @pokemon.skills_set.length < 4
        draw_text(@pokemon.given_name + " a appris", @skill.name+"!")
        @pokemon.learn_skill(@skill.id)
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:level_plus]}")
        wait(30)
        wait_hit
        @done = true
        @return_data = true
      else
        loop do
          Graphics.update
          Input.update
          if @done
            break
          end
          if [0,1,3].include?(@phase)
            update
          end
          if @phase == 2
            update_skill
          end
        end
      end
      @text_window.dispose
      @text_window = nil
    end
    
    def update
      name = @pokemon.given_name
      skill = @skill.name
      case @phase
      when 0
        draw_text(name + " tente", "d'apprendre " + skill+".")
        wait_hit
        draw_text("Mais "+name+" ne peut pas","avoir plus de 4 capacités.")
        wait_hit
        draw_text("Effacer une ancienne","capacité ...")
        wait_hit
        draw_text("... pour apprendre",skill+"?")
        decision = draw_choice
        if decision #Oui
          draw_text("","")
          initialize_skill_window
          @phase = 2
          return
        else #Non
          @phase = 1
          return
        end
      when 1
        draw_text("Arrêter d'apprendre", skill +"?")
        decisionbis = draw_choice
        if decisionbis #Oui
          draw_text(name + " n'a pas appris",skill+".")
          wait_hit
          @done = true
          @return_data = false
          return
        else
          @phase = 0
          return
        end
      when 3
        draw_text("1...")
        wait(10)
        draw_text("1... 2... ")
        wait(10)
        draw_text("1... 2... et Tadaa!")
        wait_hit
        draw_text(name + " oublie", @pokemon.skills_set[@skill_index].name+".")
        wait_hit
        draw_text("Et...")
        wait_hit
        draw_text(name + " apprend", skill+"!")
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:level_plus]}")
        wait(40)
        @pokemon.replace_skill_index(@skill_index, @skill.id)
        @done = true
        @return_data = true
      end
    end
    
    # -------------------------------------------------------
    # Fonctions de la fenêtre des Skills
    # -------------------------------------------------------
    
    def initialize_skill_window
      Graphics.freeze
      # Fond
      @background = Sprite.new
      @background.z = @z_level + 10
      @background.bitmap = RPG::Cache.picture(MENU_SKILL)
      # Statut des skills
      @status = Window_Base.new(0 - 16, 54 - 16, 640 + 32, 426 + 32)
      @status.opacity = 0
      @status.z = @z_level + 12
      @status.contents = Bitmap.new(640, 426)
      @status.contents.font.name = $fontface
      @status.contents.font.size = $fontsizebig
      # Icone
      @pokemon_sprite = Sprite.new
      @pokemon_sprite.x = 12
      @pokemon_sprite.y = 80
      @pokemon_sprite.z = @z_level + 12
      @pokemon_sprite.bitmap = RPG::Cache.battler(@pokemon.icon, 0)
      # Informations
      @pokemon_window = Window_Base.new(11-16, 60-16, 292+32, 39+32)
      @pokemon_window.opacity = 0
      @pokemon_window.z = @z_level + 12
      @pokemon_window.contents = Bitmap.new(292, 39)
      @pokemon_window.contents.font.name = $fontface
      @pokemon_window.contents.font.size = $fontsizebig
      @pokemon_window.draw_text(9, -6, 87, 39, "N."+ @pokemon.level.to_s)
      @pokemon_window.draw_text(90, -6, 180, 39, @pokemon.given_name)
      @skill_index = 0
      draw_gender(273, 0, @pokemon.gender)
      refresh
      Graphics.transition(5)
    end
    
    def update_skill
      if Input.trigger?(Input::UP)
        if @skill_index != 0
          $game_system.se_play($data_system.cursor_se)
        end
        @skill_index -= @skill_index == 0 ? 0 : 1
        refresh
      end
      
      if Input.trigger?(Input::DOWN)
        if @skill_index != @pokemon.skills_set.length
          $game_system.se_play($data_system.cursor_se)
        end
        @skill_index += @skill_index == @pokemon.skills_set.length ? 0 : 1
        refresh
      end
      
      if Input.trigger?(Input::B) or (Input.trigger?(Input::C) and @skill_index == @pokemon.skills_set.length)
        @phase = 1
        $game_system.se_play($data_system.decision_se)
        dispose_window_skill
        return
      end
      
      if Input.trigger?(Input::C) and @skill_index != @pokemon.skills_set.length
        @phase = 3
        $game_system.se_play($data_system.decision_se)
        dispose_window_skill
        return
      end
        
    end
    
    def refresh
      @status.contents.clear
      i = 0
      draw_type(88, 45, @pokemon.type1)
      draw_type(187, 45, @pokemon.type2)
      # Skills appris
      for skill in @pokemon.skills_set
        if @skill_index == i
          if @skill_selected != @skill_index
            rect = Rect.new(0, 0, 303, 72)
            bitmap = RPG::Cache.picture(SKILL_SELECTION)
            @status.contents.blt(335 ,9+i*84, bitmap, rect)
          end
          if skill.power == 0 or skill.power == 1
            string = "---"
          else
            string = skill.power.to_s
          end
          @status.draw_text(159, 114, 74, $fhb, string, 1, @status.normal_color)
          if skill.accuracy == 0
            string = "---"
          else
            string = skill.accuracy.to_s
          end
          @status.draw_text(159, 156, 74, $fhb, string, 1, @status.normal_color)
          list = string_builder(skill.description, 16)
          for k in 0..3
            @status.draw_text(20, 240 + 42*k, 276, $fhb, list[k], 0, @status.normal_color)
          end
          # Type d'attaque
          rect = Rect.new(0, 0, 100, 100) 
          if @pokemon.skills_set[@skill_index].physical # Physique
            bitmap = RPG::Cache.picture(DATA_MENU[:icon_physique]) 
          elsif @pokemon.skills_set[@skill_index].special # Spéciale
            bitmap = RPG::Cache.picture(DATA_MENU[:icon_speciale])
          elsif @pokemon.skills_set[@skill_index].status # Status
            bitmap = RPG::Cache.picture(DATA_MENU[:icon_status])
          end
          @status.contents.blt(195, 208, bitmap, rect, 255)
        end
        if @skill_selected == i
          rect = Rect.new(0, 0, 303, 72)
          bitmap = RPG::Cache.picture(SKILL_SELECTIONNE)
          @status.contents.blt(335 ,9+i*84, bitmap, rect)
        end
        draw_type(323, 6 + 84*i, skill.type)
        @status.draw_text(422, 3 + 84 * i, 216, $fhb, skill.name, 0, @status.normal_color)
        @status.draw_text(422, 3 + 84 * i + 36, 213, $fhb, "PP " + skill.pp.to_s + "/" + skill.ppmax.to_s, 2, @status.normal_color)
        i += 1
      end
      
      # Skill en apprentissage
      if @skill_index == @pokemon.skills_set.length
        if @skill.power == 0 or @skill.power == 1
          string = "---"
        else
          string = @skill.power.to_s
        end
        @status.draw_text(159, 114, 74, $fhb, string, 1, @status.normal_color)
        if @skill.accuracy == 0
          string = "---"
        else
          string = @skill.accuracy.to_s
        end
        @status.draw_text(159, 156, 74, $fhb, string, 1, @status.normal_color)
        list = string_builder(@skill.description, 16)
        for k in 0..3
          @status.draw_text(20, 240 + 42*k, 276, $fhb, list[k], 0, @status.normal_color)
        end
        # Type d'attaque
        rect = Rect.new(0, 0, 100, 100) 
        if @skill.physical # Physique
          bitmap = RPG::Cache.picture(DATA_MENU[:icon_physique]) 
        elsif @skill.special # Spéciale
          bitmap = RPG::Cache.picture(DATA_MENU[:icon_speciale])
        elsif @skill.status # Status
          bitmap = RPG::Cache.picture(DATA_MENU[:icon_status])
        end
        @status.contents.blt(195, 208, bitmap, rect, 255)
      end
      draw_type(323, 6 + 84*4, @skill.type)
      @status.draw_text(422, 3 + 84 * 4, 216, $fhb, @skill.name, 0, @status.normal_color)
      @status.draw_text(422, 3 + 84 * 4 + 36, 213, $fhb, "PP " + @skill.pp.to_s + "/" + @skill.ppmax.to_s, 2, @status.normal_color)
    end
    
    def dispose_window_skill
      Graphics.freeze
      @background.dispose
      @pokemon_sprite.dispose
      @pokemon_window.dispose
      @status.dispose
      @background = nil
      @pokemon_sprite = nil
      @pokemon_window = nil
      @status = nil
      Graphics.transition
    end
    
    # -----------------------------------------------------------
    # Fonctions Annexes
    # -----------------------------------------------------------
    
    def draw_choice
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsizebig)
      @command.x = 517
      @command.y = 215
      @command.z = @z_level
      loop do
        Graphics.update
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          @command.dispose
          @command = nil
          Input.update
          return true
        end
        if Input.trigger?(Input::C) and @command.index == 1
          @command.dispose
          @command = nil
          Input.update
          return false
        end
      end
    end
    
    def draw_type(x, y, type)
      src_rect = Rect.new(0, 0, 96, 42)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @status.contents.blt(x, y, bitmap, src_rect, 255)
    end
    
    def draw_text(line1 = "", line2 = "")
      if @scene == nil
        Graphics.freeze
        @text_window.contents.clear
        #@text_window.draw_text(12, 0, 460, 50, line1)
        #@text_window.draw_text(12, 55, 460, 50, line2)
        @text_window.draw_text(line1, line2)
        Graphics.transition(5)
      else
        @scene.draw_text(line1, line2)
      end
    end
    
    def wait_hit
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
    end
      
    def wait(frame)
      i = 0
      loop do
        i += 1
        Graphics.update
        if i >= frame
          break
        end
      end
    end
    
    def draw_gender(x, y, gender)
      if gender == 1
        rect = Rect.new(0, 0, 18, 33)
        bitmap = RPG::Cache.picture(MALE)
        @pokemon_window.contents.blt(x, y, bitmap, rect, 255)
      end
      if gender == 2
        rect = Rect.new(0, 0, 18, 33)
        bitmap = RPG::Cache.picture(FEMELLE)
        @pokemon_window.contents.blt(x, y, bitmap, rect, 255)        
      end
    end
    
    def string_builder(text, limit)
      length = text.length
      full1 = false
      full2 = false
      full3 = false
      full4 = false
      string1 = ""
      string2 = ""
      string3 = ""
      string4 = ""
      word = ""
      for i in 0..length
        letter = text[i..i]
        if letter != " " and i != length
          word += letter.to_s
        else
          word = word + " "
          if (string1 + word).length < limit and not(full1)
            string1 += word
            word = ""
          else
            full1 = true
          end
          
          if (string2 + word).length < limit and not(full2)
            string2 += word
            word = ""
          else
            full2 = true
          end
          
          if (string3 + word).length < limit and not(full3)
            string3 += word
            word = ""
          else
            full3 = true
          end
          
          #if (string4 + word).length < limit and not(full4)
            string4 += word
            word = ""
          #else
          #  full4 = true
          #end
        end
      end
      if string4.length > 1
        string4 = string4[0..string4.length-2]
      end
      return [string1, string2, string3, string4]
    end
    
  end
end