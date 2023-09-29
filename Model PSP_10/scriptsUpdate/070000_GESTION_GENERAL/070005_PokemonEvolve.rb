#==============================================================================
# ■ Pokemon_Evolve
# Pokemon Script Project - Krosk 
# 01/08/07
# 27/08/08 - révision pour les oeufs
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Scène appelée en cas de evolve
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Evolve
    def initialize(pokemon, evolve_id, z_level = 400, forcing = false)
      Graphics.freeze
      @z_level = z_level
      @forcing = forcing
      @cancel = false
      
      $game_temp.map_bgm = $game_system.playing_bgm
      Audio.bgm_play("Audio/BGM/#{DATA_AUDIO_BGM[:evolution]}")
      
      @pokemon = pokemon
      @evolve_id = evolve_id
      @background = Sprite.new
      @background.bitmap = RPG::Cache.battleback("HatchBack.png")
      
      @background.z = @z_level
      @background.color = Color.new(0, 0, 0, 0)
      
      @text_window = Window_Base.new(4, 340, 632, 136)
      @text_window.opacity = 0
      @text_window.z = @z_level + 2
      @text_window.contents = Bitmap.new(600 + 32, 104 + 32)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = $fontsizebig
      
      @message_background = Sprite.new
      @message_background.y = 336
      @message_background.z = @z_level + 1
      @message_background.bitmap = RPG::Cache.battleback(INFO_MSG)
      
      @pokemon_sprite = Sprite.new
      @pokemon_sprite.bitmap = RPG::Cache.battler(@pokemon.battler_face(false), 0)
      @pokemon_sprite.ox = @pokemon_sprite.bitmap.width / 2
      @pokemon_sprite.oy = @pokemon_sprite.bitmap.height / 2
      @pokemon_sprite.x = 320
      @pokemon_sprite.y = 240
      @pokemon_sprite.z = @z_level + 5
      @pokemon_sprite.color = Color.new(255,255,255,0)
      
      if @pokemon.egg
        @egg_sprite = Sprite.new
        @egg_sprite.bitmap = RPG::Cache.battler("BreakEgg0", 0)
        @egg_sprite.ox = @egg_sprite.bitmap.width / 2
        @egg_sprite.oy = @egg_sprite.bitmap.height / 2
        @egg_sprite.x = 320
        @egg_sprite.y = 240
        @egg_sprite.z = @z_level + 10
        @egg_sprite.visible = false
      end
      
      @evolved_sprite = Sprite.new
      @evolved_sprite.x = 320
      @evolved_sprite.y = 240
      @evolved_sprite.bitmap = RPG::Cache.battler(evolved_sprite_generation, 0)
      @evolved_sprite.ox = @evolved_sprite.bitmap.width / 2
      @evolved_sprite.oy = @evolved_sprite.bitmap.height / 2
      @evolved_sprite.z = @z_level + 6
      @evolved_sprite.zoom_x = 0
      @evolved_sprite.zoom_y = 0
      @evolved_sprite.color = Color.new(255,255,255,255)
      Graphics.transition(20)
    end
    
    
    def main
      if not @pokemon.egg  
        draw_text("Quoi ?", @pokemon.given_name + " évolue !")
        wait(40)
      
        # Blanchissement
        until @pokemon_sprite.color.alpha >= 255
          @pokemon_sprite.color.alpha += 20
          @background.color.alpha += 10
          Graphics.update
        end
        
        # Oscillement
        t = 0
        loop do
          t += 1
          if t > 100
            t +=1
          end
          if t > 250
            t += 1
          end
          if t > 450
            t += 1
          end
          pi = 3.14159265
          @pokemon_sprite.zoom_x = (Math.cos(t*2*pi/50)+1)/2
          @pokemon_sprite.zoom_y = (Math.cos(t*2*pi/50)+1)/2
          @evolved_sprite.zoom_x = (Math.cos(t*2*pi/50+pi)+1)/2
          @evolved_sprite.zoom_y = (Math.cos(t*2*pi/50+pi)+1)/2
          Input.update
          Graphics.update
          if t >= 650
            break
          end
          if Input.trigger?(Input::B) and not @forcing
            @cancel = true
            break
          end
        end
      else
        #draw_text("Quoi?", "L'OEUF est entrain d'éclore!")
        wait(40)
        t = 0
        loop do
          t += 1
          if ( t >= 0 and t < 20 ) or ( t >= 60 and t < 80) or
            ( t >= 130 and t < 170 ) or ( t >= 220 and t < 260 )
            @pokemon_sprite.x += 3 * (2*(t%2) - 1)
            @egg_sprite.x += 3 * (2*(t%2) - 1)
          end
          Graphics.update
          if t == 20
            @egg_sprite.visible = true
            @egg_sprite.bitmap = RPG::Cache.battler("BreakEgg0", 0)
            @egg_sprite.update
          end
          if t == 80
            @egg_sprite.bitmap = RPG::Cache.battler("BreakEgg1", 0)
            @egg_sprite.update
          end
          if t == 170
            @egg_sprite.visible = true
            @egg_sprite.bitmap = RPG::Cache.battler("BreakEgg2", 0)
            @egg_sprite.update
          end
          if t > 260
            @evolved_sprite.zoom_x = 0.3
            @evolved_sprite.zoom_y = 0.3
            @egg_sprite.color = Color.new(255,255,255,0)
            break
          end
        end
      end
      
      if @cancel and not @forcing
        until @pokemon_sprite.zoom_x >= 1
          @evolved_sprite.zoom_x -= 0.05
          @evolved_sprite.zoom_y -= 0.05
          @pokemon_sprite.zoom_x += 0.05
          @pokemon_sprite.zoom_y += 0.05
          Graphics.update
        end
        @pokemon_sprite.zoom_y = 1
        @pokemon_sprite.zoom_x = 1
        @evolved_sprite.zoom_x = 0
        @evolved_sprite.zoom_y = 0
        Graphics.update
        until @pokemon_sprite.color.alpha <= 0
          @pokemon_sprite.color.alpha -= 20
          @background.color.alpha -= 10
          Graphics.update
        end
        Graphics.update
        draw_text("Que...! "+@pokemon.given_name, "n'a pas évolué !")
        wait(40)
        wait_hit
        draw_text("", "")
      else
        # Rétablissement
        until @evolved_sprite.zoom_x >= 1
          @evolved_sprite.zoom_x += 0.05
          @evolved_sprite.zoom_y += 0.05
          @pokemon_sprite.zoom_x -= 0.05
          @pokemon_sprite.zoom_y -= 0.05
          if @pokemon.egg
            @evolved_sprite.zoom_x += 0.05
            @evolved_sprite.zoom_y += 0.05
            @pokemon_sprite.zoom_x += 0.20
            @pokemon_sprite.zoom_y += 0.20
            @pokemon_sprite.color.alpha += 40
            @pokemon_sprite.opacity -= 40
            @egg_sprite.zoom_x += 0.15
            @egg_sprite.zoom_y += 0.15
            @egg_sprite.opacity -= 40
            @egg_sprite.color.alpha += 40
          end
          Graphics.update
        end
        
        @evolved_sprite.zoom_x = 1
        @evolved_sprite.zoom_y = 1
        @pokemon_sprite.zoom_x = 0
        @pokemon_sprite.zoom_y = 0
        Graphics.update
        
        # Colorisation
        until @evolved_sprite.color.alpha == 0
          @evolved_sprite.color.alpha -= 20
          @background.color.alpha -= 10
          Graphics.update
        end
        
        loop do
          if @pokemon_sprite.color.alpha == 255 and @pokemon_sprite.zoom_x > 0
            @pokemon_sprite.zoom_x -= 0.05
            @pokemon_sprite.zoom_y -= 0.05
            @evolved_sprite.zoom_x += 0.05
            @evolved_sprite.zoom_y += 0.05
          end
          if @evolved_sprite.zoom_x >= 1
            @evolved_sprite.color.alpha -= 20
            @background.color.alpha -= 10
          end
          Graphics.update
          if @evolved_sprite.color.alpha == 0
            break
          end
        end
        filename = "Audio/SE/Cries/" + sprintf("%03d", @evolve_id) + "Cry.wav"
          if FileTest.exist?(filename)
            Audio.se_play(filename)
          end
          wait(65)
        
        Audio.me_play("Audio/ME/#{DATA_AUDIO_ME[:capturer_pokemon]}")
        if not @pokemon.egg
          draw_text("Félicitations ! "+@pokemon.given_name, 
          "a évolué en "+Pokemon_Info.name(@evolve_id)+" !")
        else
          draw_text(Pokemon_Info.name(@evolve_id),"vient de sortir de l'oeuf !")
          end
        wait(115)
        wait_hit
        draw_text("", "")
        if @forcing
          @pokemon.evolve(@evolve_id)
        else
          @pokemon.evolve
        end
        $pokedex.add(@pokemon)
      end
      
      Graphics.freeze
      $game_system.bgm_play($game_temp.map_bgm)
      Audio.me_stop
      @text_window.dispose
      @message_background.dispose
      @background.dispose
      @pokemon_sprite.dispose
      @evolved_sprite.dispose
      if @pokemon.egg
        @egg_sprite.dispose
      end
      @text_window = nil
    end
    
    def evolved_sprite_generation
      ida = sprintf("%03d", @evolve_id)
      form = sprintf("_%02d", @pokemon.form)
      if @pokemon.gender == 1 or @pokemon.gender == 0
        string = "Front_Male/#{ida}#{form}.png"
        if not($picture_data["Graphics/Battlers/" + string])
          string.sub!(form, "")
        end
      elsif @pokemon.gender == 2
        string = "Front_Female/#{ida}#{form}.png"
        #if not(FileTest.exist?("Graphics/Battlers/" + string))
        if not($picture_data["Graphics/Battlers/" + string])
          string.sub!(form, "")
        end
        if not($picture_data["Graphics/Battlers/" + string])
          string = "Front_Male/#{ida}#{form}.png"
          if not($picture_data["Graphics/Battlers/" + string])
            string.sub!(form, "")
          end
        end
      end
       
      if @pokemon.shiny
        string2 = "Shiny_" + string
        #if FileTest.exist?("Graphics/Battlers/" + string2)
        if $picture_data["Graphics/Battlers/" + string2]
          string = string2
        end
      end
       
      return string
    end
    
    def draw_text(line1 = "", line2 = "")
      Graphics.freeze
      @text_window.contents.clear
      @text_window.draw_text(12, 0, 460, 50, line1)
      @text_window.draw_text(12, 55, 460, 50, line2)
      Graphics.transition(5)
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
  end
end