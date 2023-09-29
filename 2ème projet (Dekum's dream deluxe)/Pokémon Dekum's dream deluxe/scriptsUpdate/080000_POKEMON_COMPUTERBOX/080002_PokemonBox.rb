#============================================================================== 
# ■ Pokemon_Box 
# Pokemon Script Project - Krosk  
# 20/07/07
# Restructuré par Damien Linux
# 11/11/19
# 24/12/2019 - Ajustement par Lizen
#----------------------------------------------------------------------------- 
# Scène à ne pas modifier de préférence 
#----------------------------------------------------------------------------- 
# Interface Menu de stockage 
#----------------------------------------------------------------------------- 
# $data_storage[0] : informations générales et noms 
#    id = 1..xx 
# $data_storage[0][id] = [ nom, attribut ] 
# $data_storage[id] = boite 
#----------------------------------------------------------------------------- 
module POKEMON_S
  class Pokemon_Box
    def initialize(mode = 0, index = 0) 
      #mode: 1 Party , 2 Box 
      @z_level = 0 
       
      # 2 images de background: gauche, et fond 
      @background = Plane.new(Viewport.new(0,0,640,480)) 
      @background_left = Sprite.new 
      @background_left.z = @z_level + 1 
       
      # Box status: boite d'affichage info Pokémon 
      @box_status = POKEMON_S::Pokemon_Box_Status.new 
      # Box party: boite affichage contenu équipe 
      @box_party = POKEMON_S::Pokemon_Box_Party.new(0) 
      # Box viewer: contenu boite 
      @box_viewer = POKEMON_S::Pokemon_Box_Viewer.new(1, -1) 
      # Box_name: boite nom 
      @box_name = Window_Base.new(332-16, 14-16, 304+32, 66+32) 
      @box_name.opacity = 0 
      @box_name.contents = Bitmap.new(304, 66) 
      @box_name.contents.font.color = Color.new(0,0,0) 
      @box_name.contents.font.size = $fontsizebis+5 
      @box_name.contents.font.name = $fontfacebis 
      @box_name.active = false 
      
      @box_name.z = @z_level + 6 
       
      @box_arrow = Sprite.new 
      @box_arrow.bitmap = RPG::Cache.picture(DATA_PC[:fleche_navigation]) 
      @box_arrow.opacity = 0 
      @box_arrow.x = 332 
      @box_arrow.y = 80 
      @box_arrow.z = @z_level + 6 
       
      s1 = "TRANSFERER" 
      s2 = "RESUME" 
      s3 = "DEPLACER" 
      s4 = "RELACHER" 
      s5 = "ANNULER" 
      @command_window = Window_Command.new(220, [s1,s2,s3,s4,s5]) 
      @command_window.x = 640 - 220 - 3 
      @command_window.y = 280 
      @command_window.z = @z_level + 10 
      @command_window.visible = false 
      @command_window.active = false 
      
      s1 = "CONFIRMER"
      s2 = "ANNULER"
      window = Window_Command.new(1, [s1, s2], $fontsize)
      width = [window.contents.text_size(s1).width, window.contents.text_size(s2).width].max + 16
      window.dispose
      @validation = Window_Command.new(width + 32, [s1, s2], $fontsize)
      @validation.x = 605 - width
      @validation.y = 375
      @validation.z = @z_level + 10 
      @validation.visible = false
      
      @text_window = create_text()
      @text_window.visible = false
       
      @temp_index = index 
      @mode = mode # 1: Party 2: Box 
      @selected = nil #selected = [box, index] 
    end 
     
    def main 
      @background.bitmap = RPG::Cache.picture(ARRIERE_PLAN) 
      Graphics.transition 
      Graphics.freeze 
      @background.bitmap = RPG::Cache.picture(DATA_PC[:arriere_plan_boite]) 
      @background_left.bitmap = RPG::Cache.picture(DATA_PC[:arriere_plan_equipe]) 
       
      @box_party.active = true 
      @box_viewer.active = false 
      @box_viewer.refresh 
      @box_party.refresh 
      refresh_box_name 
       
      Graphics.transition(20, "Graphics/Transitions/#{DATA_PC[:computer_open]}") 
      loop do 
        background_move 
        Graphics.update 
        Input.update 
        update 
        if $scene != self 
          break 
        end 
      end 
      Graphics.freeze 
      @command_window.dispose 
      @validation.dispose
      @text_window.dispose
      @background.dispose 
      @background_left.dispose 
      @box_status.dispose 
      @box_party.dispose 
      @box_viewer.dispose 
      @box_name.dispose 
      @box_arrow.dispose 
      Graphics.transition(20, "Graphics/Transitions/#{DATA_PC[:computer_close]}") 
      Graphics.freeze 
    end 
     
    def background_move 
      @background.ox += 1 
      @background.oy -= 1 
    end 
     
    def update 
      # Box viewer -> Box Party 
      if @box_viewer.active and Input.repeat?(Input::LEFT) and (@box_viewer.index)%4 == 0 
        $game_system.se_play($data_system.cursor_se) 
        @box_viewer.active = false 
        @box_party.active = true 
        @box_party.index = @box_viewer.index/4 
        until $pokemon_party.actors[@box_party.index] != nil 
          @box_party.index -= 1 
        end 
        # Refresh obligatoire? 
        @box_viewer.refresh 
        @box_party.refresh 
        return 
      end 
       
      # Box party -> Box viewer 
      if @box_party.active and Input.repeat?(Input::RIGHT) 
        $game_system.se_play($data_system.cursor_se) 
        @box_party.active = false 
        @box_viewer.active = true 
        @box_viewer.index = @box_party.index * 4 
        @box_party.refresh 
        @box_viewer.refresh 
        return 
      end 
       
      # Box viewer -> Box name 
      if @box_viewer.active and Input.repeat?(Input::UP) and @box_viewer.index < 4 
        $game_system.se_play($data_system.cursor_se) 
        @box_viewer.active = false 
        @box_name.active = true 
        @box_viewer.index = -1 
        @box_viewer.refresh 
        refresh_box_name 
        return 
      end 
       
      # En sélection 
      if Input.repeat?(Input::DOWN) and @box_party.active and @selected != nil and @box_party.index >= $pokemon_party.size-1 and $pokemon_party.size != 6
        if @selected[0] != 0 
          $game_system.se_play($data_system.cursor_se) 
          @box_party.index = $pokemon_party.size 
          @box_party.refresh 
        end 
        return 
      end 
       
      # Rafraichissement boite de statut 
      if @box_party.active 
        @box_party.update 
        @box_status.refresh(@box_party.pokemon_pointed) 
      end 
      if @box_viewer.active 
        @box_viewer.update 
        @box_status.refresh(@box_viewer.pokemon_pointed) 
      end 
       
      # Update @box_name 
      if @box_name.active 
        @box_arrow.opacity = 255 
        # box_name -> bow_viewer 
        if Input.repeat?(Input::DOWN) 
          $game_system.se_play($data_system.cursor_se) 
          @box_name.active = false 
          @box_viewer.index = 0 
          @box_viewer.active = true 
          @box_viewer.refresh 
          refresh_box_name 
          return 
        end 
         
        # Navigation entre boites 
        $game_variables[NAVIGATION_BOITE] = @box_viewer.box
        if $game_variables[NAVIGATION_BOITE] == 0
          @box_viewer.box = 1
        end
        if Input.repeat?(Input::RIGHT) 
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:open_break]}") 
          @box = @box_viewer.box 
          if $data_storage[0][@box+1] != nil
            @box_viewer.box += 1 
          else 
            @box_viewer.box = 1 
          end 
          refresh_box_name 
          @box_viewer.refresh 
        end 
        if Input.repeat?(Input::LEFT) 
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:open_break]}") 
          @box = @box_viewer.box 
          if @box == 1 
            @box_viewer.box = $data_storage[0].length - 1
          else# 
            @box_viewer.box -= 1 
          end# 
          refresh_box_name 
          @box_viewer.refresh 
        end 
      else 
        @box_arrow.opacity = 0 
      end 
       
      # Selection pokemon dans équipe -> mode = 1 
      if @box_party.active and Input.trigger?(Input::C) 
        if @selected == nil 
          @box_party.active = false 
          @mode = 1 
          @command_window.index = 0 
          @command_window.active = true 
          @command_window.visible = true 
          return 
        else 
          if @selected[0] == 0 
            $pokemon_party.switch_party(@box_party.index, @selected[1]) 
          else 
            $pokemon_party.switch_storage_party(@box_party.index, @selected[1], @selected[0]) 
          end 
          @selected = nil 
          @box_party.selected(@selected) 
          @box_viewer.selected(@selected) 
          @box_party.refresh 
          @box_viewer.refresh 
          return 
        end 
      end 
       
      # Selection pokemon dans boite -> mode = 2  
      if @box_viewer.active and Input.trigger?(Input::C) 
        if @selected == nil 
          @box_viewer.active = false 
          @mode = 2 
          @command_window.index = 0 
          @command_window.active = true 
          @command_window.visible = true 
          return 
        else 
          if @selected[0] == 0 
            $pokemon_party.switch_storage_party(@selected[1], @box_viewer.index, @box) 
          else 
            $pokemon_party.switch_storage(@box_viewer.index, @selected[1], @box, @selected[0]) 
          end 
          @selected = nil 
          @box_party.selected(@selected) 
          @box_viewer.selected(@selected) 
          @box_viewer.refresh 
          @box_party.refresh 
          return           
        end 
      end 
       
      # Selection boite options 
      if @box_name.active and Input.trigger?(Input::C) 
        return 
      end 
       
      # Update commande 
      if @command_window.active 
        update_command_window 
      end 
       
      # Annulation 
      if Input.trigger?(Input::B) 
        $game_system.se_play($data_system.decision_se) 
        @command_window.active = false 
        @command_window.visible = false 
        if @selected != nil 
          if @selected[0] == 0 
            @box_party.index = @selected[1] 
            @box_party.active = true 
            @box_viewer.active = false 
          elsif @selected[0] != 0 
            @box_viewer.index = @selected[1] 
            @box_viewer.box = @selected[0] 
            @box_party.active = false 
            @box_viewer.active = true 
          end 
          @selected = nil 
          @box_viewer.selected(@selected) 
          @box_party.selected(@selected) 
          @box_viewer.refresh 
          @box_party.refresh 
          refresh_box_name 
          return 
        end 
        case @mode 
        when 0 # Quitter le PC 
          $game_system.se_play($data_system.decision_se) 
          $scene = POKEMON_S::Pokemon_Computer.new(1, 1) 
        when 1 # Retour 
          @mode = 0 
          @box_party.active = true 
          @box_party.visible = true 
        when 2 # Retour 
          @mode = 0 
          @box_viewer.active = true 
          @box_viewer.visible = true 
        end 
        return 
      end 
    end 
     
    # Refresh du nom de la boite 
    def refresh_box_name 
      touche = nil
      @box = @box_viewer.box 
      @box_name.contents.clear 
      @box_name.contents.font.color = Color.new(0,0,0) 
      @box_name.contents.font.bold = true 
      if Input.press?(Input::LEFT) and touche == nil
        touche = 1
      end
      if Input.press?(Input::RIGHT) and touche == nil
        touche = 1
      end
      boite = touche
      if boite == 0
        @box_name.contents.draw_text(4,4, 304, 66, "Boite 1", 1)
      end
      if boite != 0
        num = @box_viewer.box
        @box_name.contents.draw_text(4,4, 304, 66, "Boite " + num.to_s, 1)
      end
   
      @box_name.contents.font.color = Color.new(0,0,0) 
    end 
     
     
    def update_command_window 
      @command_window.update 
      @box = @box_viewer.box 
      if @box_viewer.pokemon_pointed == nil and @mode == 2 
        @command_window.disable_item(1) 
      else 
        @command_window.enable_item(1) 
      end 
      if ($pokemon_party.size == 1 and @mode == 1) or (@mode == 2 and @box_viewer.pokemon_pointed == nil) 
        @command_window.disable_item(0) 
        @command_window.disable_item(2) 
        @command_window.disable_item(3) 
      elsif ($pokemon_party.size == 6 and @mode == 2) or ($pokemon_party.box_full?(@box) and @mode == 1) 
        @command_window.disable_item(0) 
        @command_window.enable_item(2) 
        @command_window.enable_item(3) 
      else 
        @command_window.enable_item(0) 
        @command_window.enable_item(2) 
        @command_window.enable_item(3) 
      end 
       
      # Mode pokémon sélectionné dans l'équipe 
      if Input.trigger?(Input::C) and @mode == 1 
        case @command_window.index 
        when 0 # Transférer 
          if $pokemon_party.size == 1 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
          if $pokemon_party.box_full?(@box) 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
          id = @box_party.index #indique la place du pokémon dans l'equipe 
          id_store = $pokemon_party.store(id, @box) 
          $game_system.se_play($data_system.decision_se) 
          @command_window.active = false 
          @command_window.visible = false 
          @box_viewer.active = true 
          @box_viewer.index = id_store 
          @mode = 0 
           
        when 1 # Résumé 
          $game_system.se_play($data_system.decision_se) 
          # Données [@mode, @box_party.index] 
          scene = POKEMON_S::Pokemon_Status.new(@box_party.pokemon_pointed, -1, @z_level + 100, [@mode, @box_party.index]) 
          scene.main 
          Graphics.transition 
          return 
        when 2 # Déplacer 
          if $pokemon_party.size == 1 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end           
          @selected = [0, @box_party.index] 
          @box_party.selected(@selected) 
          $game_system.se_play($data_system.decision_se) 
          @command_window.active = false 
          @command_window.visible = false 
          @box_party.active = true 
          @mode = 0 
          @box_party.refresh 
          return 
           
        when 3 # Relacher 
          if $pokemon_party.size == 1 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
                
          @command_window.active = false
          @command_window.visible = false 
          @validation.visible = true
          
          draw_text("Cette action est irréversible", "Souhaitez-vous relacher ce pokémon ?")
          loop do
            Graphics.update
            Input.update
            @validation.update
            if Input.trigger?(Input::C)
              case @validation.index
              when 0 # Relacher
                id = @box_party.index 
                $game_system.se_play($data_system.decision_se) 
                $pokemon_party.remove_id(id) 
                if $pokemon_party.actors[@box_party.index] == nil 
                  @box_party.index = $pokemon_party.size-1 
                end 
                @validation.visible = false
                @text_window.visible = false
                break
              when 1 # Annuler
                $game_system.se_play($data_system.decision_se)
                @validation.visible = false
                @text_window.visible = false
                break
              end
            end
          end
          @mode = 0  
          @box_party.active = true
        when 4 # Annuler 
          $game_system.se_play($data_system.decision_se) 
          @command_window.active = false 
          @command_window.visible = false 
          @mode = 0 
          @box_party.active = true 
        end 
         
        @box_party.refresh 
        @box_viewer.refresh 
        return 
      end 
       
      # Mode pokémon sélectionné dans la box 
      if Input.trigger?(Input::C) and @mode == 2 
        case @command_window.index 
        when 0 # Transférer 
          id = @box_viewer.index 
          if $data_storage[@box][id] == nil or $pokemon_party.size == 6 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
          $pokemon_party.retrieve(id, @box) 
          $game_system.se_play($data_system.decision_se) 
          @command_window.active = false 
          @command_window.visible = false 
          @box_party.active = true 
          @box_party.index = $pokemon_party.size - 1 
          @mode = 0 
           
        when 1 # Résumé 
          id = @box_viewer.index 
          if $data_storage[@box][id] == nil 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
          $game_system.se_play($data_system.decision_se) 
          scene = POKEMON_S::Pokemon_Status.new(@box_viewer.pokemon_pointed, -1, @z_level + 100, [@mode, @box_viewer.index]) 
          scene.main 
          Graphics.transition 
          return 
        when 2 # Deplacer 
          id = @box_viewer.index 
          if $data_storage[@box][id] == nil 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
          @selected = [@box, @box_viewer.index] 
          @box_viewer.selected(@selected) 
          $game_system.se_play($data_system.decision_se) 
          @command_window.active = false 
          @command_window.visible = false 
          @mode = 0 
          @box_viewer.active = true 
          @box_viewer.refresh 
          return 
           
        when 3 # Relacher 
          id = @box_viewer.index 
          if $data_storage[@box][id] == nil 
            $game_system.se_play($data_system.buzzer_se) 
            return 
          end 
                
          @command_window.active = false
          @command_window.visible = false 
          @validation.visible = true
          
          draw_text("Cette action est irréversible", "Souhaitez-vous relacher ce pokémon ?")
          loop do
            Graphics.update
            Input.update
            @validation.update
            if Input.trigger?(Input::C)
              case @validation.index
              when 0 # Relacher
                $game_system.se_play($data_system.decision_se) 
                $data_storage[@box][id] = nil 
                @validation.visible = false
                @text_window.visible = false
                break
              when 1 # Annuler
                $game_system.se_play($data_system.decision_se)
                @validation.visible = false
                @text_window.visible = false
                break
              end
            end
          end
          @mode = 0  
          @box_party.active = true
        when 4 # Annuler 
          $game_system.se_play($data_system.decision_se) 
          @command_window.active = false 
          @command_window.visible = false 
          @mode = 0 
          @box_viewer.active = true 
        end 
        @box_party.refresh 
        @box_viewer.refresh 
        return 
      end 
    end
    
    # Création d'une fenêtre de texte
    # Renvoie les détails de la fenêtre
    def create_text()
      text_window = Window_Base.new(0, 375, 632, $fontsize * 2 + 34)
      text_window.z = @z_level + 9
      text_window.contents = Bitmap.new(600, 104)
      text_window.contents.font.name = $fontface
      text_window.contents.font.size = $fontsize

      return text_window
    end
    
    # Ecriture sur la fenêtre de texte d'une taille de 2 lignes
    # line1 : La première ligne du block de texte
    # line2 : La deuxième ligne du block de texte
    def draw_text(line1 = "", line2 = "")
      @text_window.visible = true
      @text_window.contents.clear
      @text_window.draw_text(0, -8, 460, 50, line1, 0, @text_window.normal_color)
      @text_window.draw_text(0, 22, 460, 50, line2, 0, @text_window.normal_color)
    end
  end 
end