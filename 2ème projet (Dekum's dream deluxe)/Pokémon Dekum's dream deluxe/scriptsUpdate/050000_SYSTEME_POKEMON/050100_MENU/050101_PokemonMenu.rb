#==============================================================================  
# ■ Pokemon_Menu  
# Pokemon Script Project - Krosk   
# 18/07/07  
# Modifier par Slash le 15/07/09  
# Restructuré par Damien Linux
# 29/12/2019
#-----------------------------------------------------------------------------  
# Scène modifiable  
#-----------------------------------------------------------------------------  
# Menu principal accessible par échap  
#-----------------------------------------------------------------------------  
module POKEMON_S  
  class Pokemon_Menu  
    def initialize(menu_index = 0)  
      @menu_index = menu_index  
    end  

    def main  
      Graphics.freeze  
      @z_level = 10000  
      @background = Sprite.new
      if $game_switches[FILLE]      
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_fille])
      elsif $game_switches[GARCON]
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_garcon])       
      else        
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_garcon])          
      end
      @background.x = 0  
      @background.y = 0  
      @background.z = @z_level  
      @location = Window_Location.new  
      @location.x = 0  
      @location.y = 394  
      @location.z = @z_level + 2  
      @location.opacity = 0  
      @argent = Window_Argent.new  
      @argent.x = 480  
      @argent.y = 424  
      @argent.z = @z_level + 2  
      @argent.opacity = 0  
      @pokemon = Window_Pokemon.new  
      @pokemon.x = -2  
      @pokemon.y = 0  
      @pokemon.z = @z_level + 2  
      @pokemon.opacity = 0  
      @spriteset = Spriteset_Map.new  
      s1 = "      Journal"  
      s2 = "      Pokédex"  
      s3 = "      Pokémon"  
      s4 = "      Sac"  
      s5 = "      Options"
      s6 = "      " + Player.name
      s7 = "      Sauver"
      s8 = "      Retour"  
      @command_window = Window_Command.new(180, [s1, s2, s3, s4, s5, s6, s7, s8])  
      @command_window.index = @menu_index  
      @command_window.x = 457 - 3 
      @command_window.y = 72  
      @command_window.z = @z_level + 2  
      @command_window.opacity = 0  
      
      if not $game_switches[ACCES_JOURNAL]  
        # Enlève accès Journal
        @command_window.disable_item(0)
      end
      if $pokemon_party.size == 0  
        # Enlève accès Equipe  
        @command_window.disable_item(2)  
      end  
      unless $pokedex.enabled?
        # Enlève accès Pokédex si non possédé  
        @command_window.disable_item(1)  
      end  
      if $game_system.save_disabled  
        @command_window.disable_item(6)  
      end  
  
      Graphics.transition  
      loop do  
        Graphics.update  
        Input.update  
        update  
        if $scene != self  
          break  
        end  
      end  
      Graphics.freeze  
      @pokemon.dispose  
      @location.dispose  
      @argent.dispose  
      @command_window.dispose  
      @background.dispose  
      @spriteset.dispose  
    end  

    def update  
      # Fenêtre de mise à jour 
      @command_window.update  
      @spriteset.update  
      # Si la fenêtre de commande est active : appelez update_command
      if @command_window.active  
        update_command  
        return  
      end  
    end  
    #--------------------------------------------------------------------------  
    # ● Mettre à jour le cadre (lorsque la fenêtre de commande est active)
    #--------------------------------------------------------------------------  
    def update_command  
      # Lorsque le bouton B est enfoncé 
      if Input.trigger?(Input::B)  
        # Lecture Annuler SE
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:fermeture_menu]}")
        # Passer à l'écran de la carte
        $scene = Scene_Map.new  
        return  
      end  
      # Lorsque le bouton C est enfoncé
      if Input.trigger?(Input::C)  
        # Lorsque le nombre de parties est 0 et les commandes autres que la 
        # sauvegarde et la fin de la partie
        if $game_party.actors.size == 0 and @command_window.index < 4  
          # Buzzer SE
          $game_system.se_play($data_system.buzzer_se)  
          return  
        end  
        # Branche à la position du curseur dans la fenêtre de commande
        case @command_window.index 
        when 0 # Quêtes
          if not $game_switches[ACCES_JOURNAL]  
            $game_system.se_play($data_system.buzzer_se)  
          else
            $game_system.se_play($data_system.decision_se) 
            $scene = Scene_Quete.new
          end
        when 1 # Pokédex  
          unless $pokedex.enabled?
            $game_system.se_play($data_system.buzzer_se)  
            return  
          end  
          $game_system.se_play($data_system.decision_se)  
          $scene = POKEMON_S::Intro_Pokedex.new 
        when 2 # Menu  
          if $pokemon_party.size == 0  
          $game_system.se_play($data_system.buzzer_se)  
            return  
          end  
          $game_system.se_play($data_system.decision_se)  
          $scene = POKEMON_S::Pokemon_Party_Menu.new  
        when 3 # Sac  
          $game_system.se_play($data_system.decision_se)  
          $scene = Pokemon_Item_Bag.new  
        when 4 #Options
          $game_system.se_play($data_system.decision_se)
          $scene = Scene_Settings.new
        when 5 # Carte de Dresseur  
          $game_system.se_play($data_system.decision_se)            
          $scene = Scene_T_Card.new 
        when 6 # Sauvegarde  
          if $game_system.save_disabled  
          $game_system.se_play($data_system.buzzer_se)  
            return  
          end  
          $game_system.se_play($data_system.decision_se)  
          $scene = POKEMON_S::Pokemon_Save.new  
        when 7 # Quitter le menu  
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:fermeture_menu]}") 
          $scene = Scene_Map.new  
        end  
        return  
      end  
    end  
  end  
end  