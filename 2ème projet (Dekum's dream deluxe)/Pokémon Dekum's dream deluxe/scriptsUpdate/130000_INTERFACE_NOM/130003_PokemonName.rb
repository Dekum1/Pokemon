#==============================================================================
# ■ Pokemon_Name
# Pokemon Script Project - Krosk 
# 17/08/07
# Amélioré par Damien Linux - 02/02/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier
#-----------------------------------------------------------------------------
# Renommage de Pokémon uniquement
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Name
    def initialize(pokemon, z_level = 10000)
      @pokemon = pokemon
      @z_level = z_level
    end
    
    def main
      Graphics.freeze
      @background = Sprite.new
      @background.bitmap = RPG::Cache.picture(DATA_SCENE_NAME[:interface_name])
      @background.z = @z_level
      @max_char = 10
      @edit_window = POKEMON_S::Pokemon_NameEdit.new(@pokemon, 
                                                     "Surnom de #{@pokemon.name} ?")
      @edit_window.z = @z_level + 1
      
      @input_window = POKEMON_S::Pokemon_NameInput.new
      @input_window.z = @z_level + 2
      
      @done = false
      Input_Scene.set_keysset(:full)
      Graphics.transition
      loop do
        Graphics.update
        Input_Scene.update
        update
        if @done
          break
        end
      end
      Input_Scene.set_keysset(:partial)
      Graphics.freeze
      @edit_window.dispose
      @input_window.dispose
      @background.dispose
      @background = nil
      @edit_window = nil
      @input_window = nil
    end
    #--------------------------------------------------------------------------
    # ● Mise à jour du cadre
    #--------------------------------------------------------------------------
    def update
      @edit_window.update
      @input_window.update
      # Saisie d'une lettre au clavier
      if Input_Scene.key_triggered?
        if @edit_window.max_char > @max_char
          $game_system.se_play($data_system.buzzer_se)
        else
          l = Input_Scene.get_char
          if not @input_window.char_authorize?(l[0])
            $game_system.se_play($data_system.buzzer_se)
          elsif l[0] != ''
            @edit_window.add(l[0], l[1])
          end
        end
      end
      # Effacement
      if Input_Scene.repeat?(Keys::BACK)
        if @edit_window.index == 0
          return
        end
        $game_system.se_play($data_system.cancel_se)
        @edit_window.back
        return
      end
      # Confirmer
      if Input_Scene.trigger?(Keys::ENTER)
        # Bouton sur Confirmer
        if @input_window.character == nil
          # Pas de nom entrée => Par défaut
          if @edit_window.name == ""
            @edit_window.restore_default
            if @edit_window.name == ""
              $game_system.se_play($data_system.buzzer_se)
              return
            end
            $game_system.se_play($data_system.decision_se)
            return
          end
          
          @pokemon.given_name = @edit_window.name
          $string[0] = @pokemon.name
          $string[1] = @pokemon.given_name
          $game_system.se_play($data_system.decision_se)
          @done = true
          return
        end
        
        # Entrée d'un caractère de trop
        if @edit_window.index == 10
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        
        # Entrée d'un mauvais caractère
        if @input_window.character == ""
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        @edit_window.add(@input_window.character, 1)
        return
      end
    end
  end
end