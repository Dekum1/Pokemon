#==============================================================================
# ■ Pokemon_Party_Menu
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène modifiable mais complexe
#-----------------------------------------------------------------------------
# Menu de gestion d'équipe
#-----------------------------------------------------------------------------
module POKEMON_S
  #-----------------------------------------------------------------------------
  # Pokemon_Party_Menu
  #-----------------------------------------------------------------------------
  # Scene
  #   mode: "map", "battle", "give_item"
  #-----------------------------------------------------------------------------
  class Pokemon_Party_Menu
    attr_accessor :z_level
    attr_accessor :mode
    def initialize(menu_index = 0, z_level = 100, mode = "map", data = nil, forced = false) #EDIT_4G
      @menu_index = menu_index
      @z_level = z_level
      @data = data
      @mode = mode # "map", "battle", "hold", "item_use", "item_able", "selection"
      @forced = forced #EDIT_4G
      # battle_data: informations diverses du combat en cours
      if $battle_var.in_battle
        @order = $battle_var.battle_order
      else
        @order = [0,1,2,3,4,5]
      end
    end

    
    #-----------------------------------------------------------------------------
    # Déroulement de la scène
    #-----------------------------------------------------------------------------
    def main
      Graphics.freeze
      # Background
      @background = Sprite.new
      @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_equipe])
      @background.z = @z_level
      
      # Ensemble de fenêtres individuelles pour chaque Pokémon
      @party_window = []
      0.upto($pokemon_party.size - 1) do |i|
        pokemon = $pokemon_party.actors[@order[i]]
        @party_window.push(Pokemon_Party_Window.new(pokemon, i, @z_level, @mode, @data))
      end
      
      # @on_switch: indicateur d'ordre de permutation
      #   -1: pas d'ordre
      #   sinon: désigne le pokémon à permuter
      @on_switch = -1
      
      @action_window = Window_Command.new(240, ["RETOUR"])
      @action_window.z = @z_level + 10
      @action_window.x = 3
      @action_window.visible = false
      @action_window.active = false
      
      @item_window = Window_Command.new(240, ["DONNER", "PRENDRE", "RETOUR"])
      @item_window.z = @z_level + 11
      @item_window.x = 3
      @item_window.y = 480 - 3 - @item_window.height
      @item_window.visible = false
      @item_window.active = false
      
      @text_window = Window_Base.new(246, 413, 391, 64)
      @text_window.contents = Bitmap.new(602, 64)
      @text_window.z = @z_level + 10
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = $fontsize
      @text_window.contents.font.color = @text_window.normal_color
      
      refresh
      
      Graphics.transition
      loop do
        Graphics.update
        Input.update
        if @action_window.active and @on_switch == -1
          if $battle_var.in_battle
            update_action_battle
          else
            update_action
          end
        elsif @item_window.active
          update_item
        else
          refresh
          update
        end
        if @done
          break
        end
      end
      Graphics.freeze
      @background.dispose
      @party_window.each do |window|
        window.dispose
      end
      if @action_window != nil
        @action_window.dispose
      end
      @text_window.dispose
      @item_window.dispose
      @party_window = nil
    end
    
    def update      
      if Input.trigger?(Input::B)
        if @mode == "selection"
          @done = true
          @return_data = -1
          return
        end
        
        if @mode == "hold"
          @done = true
          @return_data = [0, false, 0, false]
          return
        end
        
        if @mode == "item_use" or @mode == "item_able"
          @done = true
          @return_data = [0, false]
          return
        end
        
        if @on_switch == -1 and not($battle_var.in_battle)
          $game_system.se_play($data_system.cancel_se)
          $scene = Pokemon_Menu.new(2)
          @done = true
          return
        elsif @on_switch == -1 and $battle_var.in_battle
          if $pokemon_party.actors[@order[0]].dead? or @forced #EDIT_4G
            $game_system.se_play($data_system.buzzer_se)
            return
          else            
            $game_system.se_play($data_system.cancel_se)
            $battle_var.action_id = 0
            # Pas d'action
            @return_data = [0]
            @done = true
            return
          end
        else
          # Annulation de la commande en cours ie @on_switch =/ 1
          $game_system.se_play($data_system.cancel_se)
          @action_window.active = true
          @action_window.visible = true
          @on_switch = -1
          refresh
          return
        end
      end
      
      if Input.repeat?(Input::DOWN)
        $game_system.se_play($data_system.cursor_se)
        @menu_index += (@menu_index == @party_window.size-1) ? 0 : 1
        located_refresh
        return
      end
      if Input.repeat?(Input::UP)
        $game_system.se_play($data_system.cursor_se)
        @menu_index -= (@menu_index == 0) ? 0 : 1
        located_refresh
        return
      end
      if Input.trigger?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        @menu_index = 0
        refresh
        return
      end
      if Input.trigger?(Input::RIGHT) and @menu_index == 0 and $pokemon_party.size > 1
        $game_system.se_play($data_system.cursor_se)
        @menu_index = 1
        refresh
        return
      end
      
      if Input.trigger?(Input::C)
        if @mode == "selection"
          $game_system.se_play($data_system.decision_se)
          @done = true
          @return_data = @menu_index
          return
        end
        
        if @mode == "hold"
          $game_system.se_play($data_system.decision_se)
          pokemon = $pokemon_party.actors[@menu_index]
          # Ne porte pas d'item
          if pokemon.item_hold == 0
            pokemon.item_hold = @data
            @return_data = [@data, true, 0, false]
            refresh
            draw_text(pokemon.given_name + " est équipé de " + POKEMON_S::Item.name(@data) + ".")
            Input.update
            until Input.trigger?(Input::C)
              Input.update
              Graphics.update
            end
          # Porte un item  
          elsif pokemon.item_hold != 0
            replaced_item = pokemon.item_hold
            pokemon.item_hold = @data
            @return_data = [@data, true, replaced_item, true]
            refresh
            if @data == replaced_item
              draw_text(pokemon.given_name + " tient déjà " + POKEMON_S::Item.name(@data) + "!")
            else
              draw_text(POKEMON_S::Item.name(replaced_item) + " est remplacé par " + POKEMON_S::Item.name(@data) + ".")
            end
            Input.update
            until Input.trigger?(Input::C)
              Input.update
              Graphics.update
            end
          end
          @done = true
          return
        end
        
        if @mode == "item_use" or @mode == "item_able" 
          if $battle_var.in_battle
            pokemon = $pokemon_party.actors[$battle_var.battle_order[@menu_index]]
          else
            pokemon = $pokemon_party.actors[@menu_index]
          end
          if @mode == "item_able" and not(POKEMON_S::Item.able?(@data, pokemon))
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          $game_system.se_play($data_system.decision_se)
          result = POKEMON_S::Item.effect_on_pokemon(@data, pokemon, self)
          # result[0] = item utilisé ou non
          # result[1] text
          @return_data = [@data, result[0]]
          refresh
          if result[1] != ""
            draw_text(result[1])
            Input.update
            until Input.trigger?(Input::C)
              Input.update
              Graphics.update
            end
          end
          @done = true
          return
        end
        
        $game_system.se_play($data_system.decision_se)
        if @on_switch == -1
          # Selection d'un Pokémon
          if $battle_var.in_battle
            set_action_battle_window
          else
            set_action_window
          end
          refresh
        else
          # Permutation
          if not($battle_var.in_battle)
            $pokemon_party.switch_party(@on_switch, @menu_index)
          end
          @action_window.active = false
          @action_window.visible = false
          @on_switch = -1
          reset_party_window
          refresh
        end
        return
      end
    end
    
    def update_action
      @action_window.update
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @action_window.visible = false
        @action_window.active = false
        text_refresh
      end
      
      if Input.trigger?(Input::C)
        case @action_window.commands[@action_window.index]
        when "RESUME"
          pokemon = $pokemon_party.actors[@menu_index]
          scene = Pokemon_Status.new(pokemon, @menu_index, @z_level + 100)
          scene.main
          @menu_index = scene.return_data
          refresh
          Graphics.transition
        when "ORDRE"
          $game_system.se_play($data_system.decision_se)
          # Permutation active
          @on_switch = @menu_index
          @action_window.visible = false
          @action_window.active = false
          refresh
        when "OBJET"
          $game_system.se_play($data_system.decision_se)
          @action_window.visible = false
          @action_window.active = false
          @item_window.active = true
          @item_window.visible = true
          text_refresh
        when "RETOUR"
          $game_system.se_play($data_system.decision_se)
          @action_window.visible = false
          @action_window.active = false
          text_refresh
        else # Attaque
          $game_system.se_play($data_system.decision_se)
          @action_window.visible = false
          @action_window.active = false
          name = @action_window.commands[@action_window.index]
          $game_temp.common_event_id = Skill_Info.map_use(Skill_Info.id(name))
          $on_map_call = true
          $scene = Scene_Map.new
          @done = true
        end
        return
      end
    end
    
    def update_item
      @item_window.update
      if Input.trigger?(Input::C)
        case @item_window.index
        # Donner
        when 0
          pokemon = $pokemon_party.actors[@menu_index]
          $game_system.se_play($data_system.decision_se)
          scene = Pokemon_Item_Bag.new($pokemon_party.bag_index, @z_level + 100, "hold")
          scene.main
          return_data = scene.return_data
          item = return_data[0]
          hold = return_data[1]
          former_item = pokemon.item_hold
          @item_window.visible = false
          @item_window.active = false
          refresh
          if hold
            $pokemon_party.drop_item(item)
            if former_item == 0
              draw_text(pokemon.given_name + " est équipé de " + POKEMON_S::Item.name(item) + ".")
            else
              $pokemon_party.add_item(former_item)
              draw_text(POKEMON_S::Item.name(former_item) + " est remplacé par " + POKEMON_S::Item.name(item) + ".")
            end
            pokemon.item_hold = item
            Input.update
            Graphics.transition
            until Input.trigger?(Input::C)
              Input.update
              Graphics.update
            end
          else
            Graphics.transition
          end
          refresh
          return
        # Prendre
        when 1
          @item_window.visible = false
          @item_window.active = false
          pokemon = $pokemon_party.actors[@menu_index]
          # Pas d'item
          if pokemon.item_hold == 0
            $game_system.se_play($data_system.buzzer_se)
            draw_text(pokemon.given_name + " ne tient rien.")
          else
            $game_system.se_play($data_system.decision_se)
            $pokemon_party.add_item(pokemon.item_hold)
            former_item = pokemon.item_hold
            pokemon.item_hold = 0
            refresh
            draw_text(POKEMON_S::Item.name(former_item) + " récupéré de " + pokemon.given_name + ".")
          end
          Input.update
          until Input.trigger?(Input::C)
            Input.update
            Graphics.update
          end
          refresh
          $game_system.se_play($data_system.decision_se)
        # Retour
        when 2
          $game_system.se_play($data_system.decision_se)
          @item_window.active = false
          @item_window.visible = false
          @action_window.active = true
          @action_window.visible = true
          text_refresh
        end
      end
      
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @item_window.active = false
        @item_window.visible = false
        @action_window.active = true
        @action_window.visible = true
        text_refresh
      end
    end
    
    def skill_selection(pokemon)
      # Rafraihcisemment fenetre de texte
      @skill_selection = true
      text_refresh
      @skill_selection = false
      # Création liste skill
      list = []
      pokemon.skills_set.each do |skill|
        list.push(skill.name)
      end
      @skill_window = Window_Command.new(240, list)
      @skill_window.y = 480 - @skill_window.height - 3
      @skill_window.x = 3
      @skill_window.z = @z_level + 11
      # Selection
      loop do
        Input.update
        Graphics.update
        @skill_window.update
        if Input.trigger?(Input::C)
          @skill_index = @skill_window.index
          break
        end
        if Input.trigger?(Input::B)
          @skill_window.dispose
          return false
          break
        end
      end
      @skill_window.dispose
      return @skill_index
    end
    
    def refresh
      @party_window.each do |window|
        window.refresh_index(@menu_index)
        window.switch(@on_switch)
        window.refresh
      end
      text_refresh
    end
    
    def text_refresh
      @text_window.contents.clear
      @text_window.width = 391
      @text_window.height = 64
      @text_window.x = 246
      @text_window.y = 480 - @text_window.height - 3
      width = @text_window.width - 32
      height = @text_window.height - 32
      if @on_switch != -1
        @text_window.contents.draw_text(0,0,width,height, "Le mettre où ?")
      elsif @action_window.active
        @text_window.contents.draw_text(0,0,width,height, "Que faire avec ce POKéMON ?")
      elsif @item_window.active
        @text_window.contents.draw_text(0,0,width,height, "Que faire avec un objet ?")
      elsif @mode == "hold"
        @text_window.contents.draw_text(0,0,width,height, "Donner à quel POKéMON ?")
      elsif @skill_selection
        @text_window.contents.draw_text(0,0,width,height, "Laquelle restaurer ?")
      elsif @mode == "item_use" or @mode == "item_able"
        @text_window.contents.draw_text(0,0,width,height, "Utiliser sur quel POKéMON ?")
      else
        @text_window.contents.draw_text(0,0,width,height, "Choisir un POKéMON.")
      end
    end
    
    def draw_text(string = "", string2 = "")
      @text_window.width = 634
      @text_window.x = 3
      @text_window.contents.clear
      if string2 == ""
        @text_window.height = 64
        @text_window.y = 480 - @text_window.height - 3
        width = 602
        height = 32
        @text_window.contents.draw_text(0,0,width,height,string)
      else
        @text_window.height = 96
        @text_window.y = 480 - @text_window.height - 3
        width = 602
        height = 32
        @text_window.contents.draw_text(0,0,width,height,string)
        @text_window.contents.draw_text(0,height,width,height,string2)
      end
    end
    
    def located_refresh
      @party_window.each do |window|
        window.refresh_index(@menu_index)
        window.switch(@on_switch)
      end
      
      (@menu_index - 1).upto(@menu_index + 1) do |i|
        if @party_window[i] != nil
          @party_window[i].refresh
        end
      end
    end
    
    def hp_refresh
      @party_window[@menu_index].hp_refresh
    end
    
    def item_refresh
      @party_window[@menu_index].refresh
    end
    
    def update_action_battle
      @action_window.update
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @action_window.visible = false
        @action_window.active = false
        text_refresh
      end
      if Input.trigger?(Input::C)
        case @action_window.index
        when 0 # Rappel au combat du Poké sélectionné
          if @menu_index == 0 or $pokemon_party.actors[@order[@menu_index]].dead?
            # Le pokémon du premier rang et les morts ne peuvent etre envoyés
            $game_system.se_play($data_system.buzzer_se)
          else #NOTA
            if $battle_var.action_id == 0
              $battle_var.action_id = 2
            end
            # Changement
            @return_data = @menu_index
            @done = true
          end
        when 1 # Résumé
          pokemon = $pokemon_party.actors[@order[@menu_index]]
          scene = Pokemon_Status.new(pokemon, @menu_index)
          scene.main
          @menu_index = scene.return_data
          refresh
          Graphics.transition
        when 2 # Annulation
          $game_system.se_play($data_system.cancel_se)
          @action_window.visible = false
          @action_window.active = false
          text_refresh
        end
        return
      end
    end
    
    def return_data
      return @return_data
    end
      
    def set_action_window
      list = []
      $pokemon_party.actors[@order[@menu_index]].skills_set.each do |skill|
        if skill.map_use != 0
          list.push(Skill_Info.name(skill.id))
        end
      end
      list += ["RESUME", "ORDRE", "OBJET", "RETOUR"]
      if $pokemon_party.actors[@order[@menu_index]].egg
        list.delete("OBJET")
      end
      @action_window = Window_Command.new(240, list)
      @action_window.y = 480 - @action_window.height - 3
      @action_window.x = 3
      @action_window.z = @z_level + 10
    end
    
    def set_action_battle_window
      list = ["ECHANGER", "RESUME", "RETOUR"]
      @action_window = Window_Command.new(240, list)
      @action_window.y = 480 - @action_window.height - 3
      @action_window.x = 3
      @action_window.z = @z_level + 10
      if @menu_index == 0 or $pokemon_party.actors[@order[@menu_index]].dead?
        @action_window.disable_item(0)
      end
    end
    
    def reset_party_window # En permutation
      @party_window.each do |window|
        window.dispose
      end
      @party_window = []
      0.upto($pokemon_party.size - 1) do |i|
        pokemon = $pokemon_party.actors[@order[i]]
        @party_window.push(Pokemon_Party_Window.new(pokemon, i, @z_level, @mode, @data))
      end
      refresh
    end
  end
end