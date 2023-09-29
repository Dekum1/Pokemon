#==============================================================================
# ■ Pokemon
# Pokemon Script Project - Krosk 
# 20/07/07
# 26/08/08 - révision, support des oeufs
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 04/11/19
#-----------------------------------------------------------------------------
# Gestion individuelle
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon : génère l'information sur un Pokémon.
  # Méthodes sur l'interface de consultation des données du Pokémon :
  # - Icons / Sprites en combat
  # - Fenêtres externes
  #------------------------------------------------------------
  class Pokemon
    #------------------------------------------------------------
    # Icons / Sprites en combat
    #------------------------------------------------------------
    def icon
      if @egg
        return "Icon/Egg000.png"
      end
      ida = sprintf("%03d", id)
      string = "Icon/#{ida}#{battler_form}#{battler_mega}.png"
      if not( $picture_data["Graphics/Battlers/#{string}.png"] ) and
         not( $picture_data["Graphics/Battlers/#{string}.PNG"] )
        string.sub!(battler_form, "")
      end
      if not( $picture_data["Graphics/Battlers/" + string] )
        string.sub!(battler_mega, "")
      end
      return string
    end
    
    def icon_2
      if @egg
        return "Icon/Anime/iconEgg.png"
      end
      ida = sprintf("%03d", id)
      string = "Icon/Anime/icon#{ida}#{icon_form}"
      if not( $picture_data["Graphics/Battlers/#{string}.png"] ) and
         not( $picture_data["Graphics/Battlers/#{string}.PNG"] )
        string.sub!(icon_form, "")
      end
      if not FileTest.exist?("Graphics/Battlers/Icon/Anime/icon#{ida}#{icon_form}.png")
        return icon
      end
      return string
    end
    
    def icon_form
      resultat = ""
      if @form == nil
        @form = 0
      end
      if @form > 0
        resultat = sprintf("_%d", @form)
      end
      return resultat
    end
    
    def battler_form
      resultat = ""
      if @form == nil
        @form = 0
      end
      if @form > 0
        if @form < 10
          resultat = sprintf("_0%d", @form)
        else
          resultat = sprintf("_%d", @form)
        end
      end
      return resultat
    end
    
    def battler_mega
      if @mega
        return sprintf("_M%01d", @mega)
      else
        return ""
      end
    end
     
    def battler_face(anime = true)
      ida = sprintf("%03d", id)
      prefixe = ((anime and $game_switches[POKEMON_ANIME]) ? "Anime/" : "")
       
      if @egg
        string = "Eggs/#{ida}.png"
        if not( $picture_data["Eggs/#{string}"] )
          string = "Eggs/Egg000.png"
        end
        return string
      end
      
      if @gender == 1 or @gender == 0
        string = "#{prefixe}Front_Male/#{ida}#{battler_form}#{battler_mega}.png"
      elsif @gender == 2
        string = "#{prefixe}Front_Female/#{ida}#{battler_form}#{battler_mega}.png"
        if not($picture_data["Graphics/Battlers/#{string}"] )
          string = "#{prefixe}Front_Male/#{ida}#{battler_form}#{battler_mega}.png"
        end
      end
             
      if @shiny
        string2 = "Shiny_#{string}"
        if $picture_data["Graphics/Battlers/#{string2}"]
          string = string2
        end
      end
       
      if anime and $game_switches[POKEMON_ANIME]
        string2 = battler_face(false)
      else
        string2 = string
      end
      if not( $picture_data["Graphics/Battlers/#{string}"] ) and not( $picture_data["Graphics/Battlers/#{string2}"] )
        string.sub!(battler_form, "")
      elsif not( $picture_data["Graphics/Battlers/#{string}"] ) and $picture_data["Graphics/Battlers/#{string2}"]
        string = string2
      end
      if not( $picture_data["Graphics/Battlers/#{string}"] ) and not( $picture_data["Graphics/Battlers/#{string2}"] )
        string.sub!(battler_mega, "")
      elsif not( $picture_data["Graphics/Battlers/#{string}"] ) and $picture_data["Graphics/Battlers/#{string2}"]
        string = string2
      end
      
      if (not( $picture_data["Graphics/Battlers/#{string}"] ) and 
         $game_switches[POKEMON_ANIME] and anime) or string == string2
        @is_anime = false
      elsif $game_switches[POKEMON_ANIME] and anime
        @is_anime = true
      end
      return string
    end
     
    def battler_back(anime = true)
      prefixe = ((anime and $game_switches[POKEMON_ANIME]) ? "Anime/" : "")
      
      ida = sprintf("%03d", id)
      if @gender == 1 or @gender == 0
        string = "#{prefixe}Back_Male/#{ida}#{battler_form}#{battler_mega}.png"
      elsif @gender == 2
        string = "#{prefixe}Back_Female/#{ida}#{battler_form}#{battler_mega}.png"
        if not($picture_data["Graphics/Battlers/#{string}"])
          string = "#{prefixe}Back_Male/#{ida}#{battler_form}#{battler_mega}.png"
        end
      end
       
      if @shiny
        string2 = "Shiny_#{string}"
        if $picture_data["Graphics/Battlers/#{string2}"]
          string = string2
        end
      end
      
      if anime and $game_switches[POKEMON_ANIME]
        string2 = battler_back(false)
      else
        string2 = string
      end
      if not( $picture_data["Graphics/Battlers/#{string}"] ) and not( $picture_data["Graphics/Battlers/#{string2}"] )
        string.sub!(battler_form, "")
      elsif not( $picture_data["Graphics/Battlers/#{string}"] ) and $picture_data["Graphics/Battlers/#{string2}"]
        string = string2
      end
      if not( $picture_data["Graphics/Battlers/#{string}"] ) and not( $picture_data["Graphics/Battlers/#{string2}"] )
        string.sub!(battler_mega, "")
      elsif not( $picture_data["Graphics/Battlers/#{string}"] ) and $picture_data["Graphics/Battlers/#{string2}"]
        string = string2
      end
      
      if (not( $picture_data["Graphics/Battlers/#{string}"] ) and 
         $game_switches[POKEMON_ANIME] and anime) or string == string2
        @is_anime = false
      elsif $game_switches[POKEMON_ANIME] and anime
        @is_anime = true
      end
      return string
    end
    
    #------------------------------------------------------------
    # Fenêtres externes
    #------------------------------------------------------------
    def level_up_window_call(list0, list1, z_level)
      @window = Window_Base.new(355, 170, 282, 308)
      @window.z = z_level
      @window.contents = Bitmap.new(250, 276)
      @window.contents.font.name = $fontface
      @window.contents.font.size = $fontsizebig
      @window.contents.font.color = @window.normal_color
      @window.contents.draw_text(0,0,189,$fhb, "PV MAX.")
      @window.contents.draw_text(0,48,189,$fhb, "ATTAQUE")
      @window.contents.draw_text(0,96,189,$fhb, "DEFENSE")
      @window.contents.draw_text(0,144,189,$fhb, "ATT.SPE.")
      @window.contents.draw_text(0,192,189,$fhb, "DEF.SPE.")
      @window.contents.draw_text(0,240,189,$fhb, "VITESSE")
      0.upto(5) do |i|
        string = (list1[i] - list0[i]).to_s
        if string.length == 1
          string = "+ " + string
        elsif string.length == 2
          string = "+" + string
        end
        @window.contents.draw_text(0, 48*i, 250, $fhb, string, 2)
      end
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
      @window.contents.clear
      @window.contents.draw_text(0,0,189,$fhb, "PV MAX.")
      @window.contents.draw_text(0,48,189,$fhb, "ATTAQUE")
      @window.contents.draw_text(0,96,189,$fhb, "DEFENSE")
      @window.contents.draw_text(0,144,189,$fhb, "ATT.SPE.")
      @window.contents.draw_text(0,192,189,$fhb, "DEF.SPE.")
      @window.contents.draw_text(0,240,189,$fhb, "VITESSE")
      0.upto(5) do |i|
        string = (list1[i]).to_s
        @window.contents.draw_text(0, 48*i, 250, $fhb, string, 2)
      end
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
      @window.dispose
      @window = nil
    end

    # -----------------------------------------------------------
    # G!n0 : Gestion Formes
    #------------------------------------------------------------
    
    # Changer la forme du Pkmn et l'enregistrer dans le Pokédex
    def change_form(form)
      @form = form
      # Vu dans le Pok�dex
      $pokedex.add(self, false)
    end
    
    # Retourner un entier associé à l'apparence du pokemon disponible dans ressources
    # 0 : mâle, 1 : mâle shiny, 2 : femelle, 3 : femelle shiny
    # les multiples de 10 donnent la forme. ex 31 est la forme 3 shiny
    # ATTENTION : forme et femelle non compatibles
    def code_appearence
      # Oeuf
      if @egg
        return -1
      end
      id_form = 0
      ida = sprintf("%03d", id)
      string = "Front_Male/#{ida}#{battler_form}.png"
      #Si la forme existe
      if battler_form != "" and FileTest.exist?("Graphics/Battlers/" + string)
        id_form += (battler_form.to_i * 10)
      #mode femelle vérifiée seulement si pas de forme
      else
        string = "Front_Male/#{ida}.png"
        string2 = "Front_Female/#{ida}.png"
        if @gender == 2 and FileTest.exist?("Graphics/Battlers/" + string2)
          string = string2
          id_form += 2
        end
      end
      #vérification shiny
      if @shiny
        string2 = "Shiny_" + string
        if FileTest.exist?("Graphics/Battlers/" + string2)
          id_form += 1
        end
      end
      return id_form
    end
  end
end