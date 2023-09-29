#==============================================================================
# ■ Scene_Name
# Amélioré par Damien Linux - 02/02/2020
#------------------------------------------------------------------------------
# Il s'agit d'une classe qui traite l'écran de saisie du nom.
#==============================================================================
class Scene_Name
  def initialize(code_exchange = nil)
    @code_exchange = code_exchange
  end
  #--------------------------------------------------------------------------
  # ● Traitement principal
  #--------------------------------------------------------------------------
  def main
    Graphics.freeze
    @z_level = 10000
    @background = Sprite.new
    @background.bitmap = RPG::Cache.picture(DATA_SCENE_NAME[:interface_name])
    @background.z = @z_level
    @actor = $game_actors[$game_temp.name_actor_id]
    if @code_exchange != nil
      @max_char = 7
      @edit_window = POKEMON_S::Pokemon_NameEdit.new(@code_exchange, 
                                                     "CODE ECHANGE ?", false, 
                                                     @max_char)
      @input_window = POKEMON_S::Pokemon_NameInput.new(true)
    else
      @max_char = $game_temp.name_max_char
      @edit_window = POKEMON_S::Pokemon_NameEdit.new(@actor, "Quel nom ?", false, 
                                                     @max_char)
      @input_window = POKEMON_S::Pokemon_NameInput.new
    end
    
    @edit_window.z = @z_level + 1
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
        
        if @code_exchange != nil and @edit_window.name.length < 7
          $game_system.se_play($data_system.buzzer_se)
          return
        end
        $game_system.se_play($data_system.decision_se)
        
        if @code_exchange == nil
          @actor.name = @edit_window.name
          $scene = Scene_Map.new
        else
          $string[0] = @edit_window.name
        end
        
        @done = true
        return
      end
      
      # Entrée d'un caractère de trop
      if @code_exchange == nil and @edit_window.index == $game_temp.name_max_char
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      if @code_exchange != nil and @edit_window.index == 7
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