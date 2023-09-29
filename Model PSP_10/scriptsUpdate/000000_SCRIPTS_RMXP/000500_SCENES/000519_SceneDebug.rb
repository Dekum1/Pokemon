class Scene_Debug
# ------------------------------
#Script modifié par RPG Advocate, traduit et adapté par Bodom-Child
  def main
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    c1 = "Régénérer perso..."
    c2 = "Mode Dieu..."
    c3 = "Argent..."
    c4 = "Monstres..."
    c5 = "Objets..."
    c6 = "Armes..."
    c7 = "Armures..."
    c8 = "Téléporter"
    c9 = "Vitesse de marche"
    c10 = "Sauvegarder"
    x1 = "Activé"
    x2 = "Désactivé"
    w1 = "La plus basse"
    w2 = "Très basse"
    w3 = "Basse"
    w4 = "Rapide"
    w5 = "Très rapide"
    w6 = "La plus rapide"
    d1 = "Destination 1"
    main_commands = [c1, c2, c3, c4, c5, c6, c7, c8, c9, c10]
    speed_commands = [w1, w2, w3, w4, w5, w6]
    toggle_commands = [x1, x2]
    warp_commands = [d1]
    @other_window = Window_Command.new(240, main_commands)
    @speed_window = Window_Command.new(200, speed_commands)
    @enc_window = Window_Command.new(150, toggle_commands)
    @god_window = Window_Command.new(150, toggle_commands)
    @warp_window = Window_Command.new(240, warp_commands)
    @target_window = Window_Target.new
    @money_window = Window_Gold.new
    @number_window = Window_InputNumber.new(7)
    @var_window = Window_InputNumber.new(8)
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    @help_window.contents.font.name = "Arial"
    @help_window.contents.font.size = 24
    @help_window.contents.font.color = @help_window.normal_color
    @left_window.top_row = $game_temp.debug_top_row
    @left_window.index = $game_temp.debug_index
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @other_window.visible = false
    @other_window.active = false
    @target_window.visible = false
    @target_window.active = false
    @enc_window.visible = false
    @enc_window.active = false
    @god_window.visible = false
    @god_window.active = false
    @speed_window.visible = false
    @speed_window.active = false
    @warp_window.visible = false
    @warp_window.active = false
    @money_window.visible = false
    @money_window.active = false
    @number_window.visible = false
    @number_window.active = false
    @var_window.visible = false
    @var_window.active = false
    @itemset_window = Window_Dataset.new(1)
    @itemset_window.visible = false
    @itemset_window.active = false
    @weaponset_window = Window_Dataset.new(2)
    @weaponset_window.visible = false
    @weaponset_window.active = false
    @armorset_window = Window_Dataset.new(3)
    @armorset_window.visible = false
    @armorset_window.active = false
    @other_window.opacity = 255
    @other_window.x = 100
    @other_window.y = 48
    @other_window.z = 200
    @target_window.x = 304
    @target_window.y = 0
    @target_window.z = 300
    @target_window.opacity = 255
    @enc_window.x = 225
    @enc_window.y = 180
    @enc_window.z = 210
    @enc_window.opacity = 255
    @god_window.x = 225
    @god_window.y = 180
    @god_window.z = 210
    @god_window.opacity = 255
    @speed_window.x = 270
    @speed_window.y = 100
    @speed_window.z = 220
    @speed_window.opacity = 255
    @warp_window.x = 270
    @warp_window.y = 100
    @warp_window.z = 220
    @warp_window.opacity = 255
    @itemset_window.x = 0
    @itemset_window.y = 0
    @itemset_window.z = 1000
    @itemset_window.opacity = 255
    @weaponset_window.x = 0
    @weaponset_window.y = 0
    @weaponset_window.z = 1000
    @weaponset_window.opacity = 255
    @armorset_window.x = 0
    @armorset_window.y = 0
    @armorset_window.z = 1000
    @armorset_window.opacity = 255
    @money_window.x = 270
    @money_window.y = 100
    @money_window.z = 700
    @money_window.opacity = 255
    @number_window.x = 270
    @number_window.y = 164
    @number_window.z = 710
    @number_window.opacity = 255
    @var_window.x = 270
    @var_window.y = 164
    @var_window.z = 710
    @var_window.opacity = 255
    @variable_edit = 0
    Graphics.transition
    loop do
      Graphics.update
      Input.update
      update
      if $scene != self
        break
      end
    end
    $game_map.refresh
    Graphics.freeze
    @left_window.dispose
    @right_window.dispose
    @help_window.dispose
    @other_window.dispose
    @god_window.dispose
    @speed_window.dispose
    @enc_window.dispose
    @target_window.dispose
    @warp_window.dispose
    @itemset_window.dispose
    @weaponset_window.dispose
    @armorset_window.dispose
    @money_window.dispose
    @var_window.dispose
  end
  # ------------------------------
  def update
    @right_window.mode = @left_window.mode
    @right_window.top_id = @left_window.top_id
    @left_window.update
    @right_window.update
    @other_window.update
    @enc_window.update
    @itemset_window.update
    @weaponset_window.update
    @armorset_window.update
    @target_window.update
    @god_window.update
    @speed_window.update
    @warp_window.update
    @money_window.update
    @number_window.update
    @var_window.update
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    if @left_window.active
      update_left
      return
    end
    if @right_window.active
      update_right
      return
    end
    if @other_window.active
      update_command
      return
    end
    if @target_window.active
      update_target
      return
    end
    if @enc_window.active
      update_enc
      return
    end
     if @itemset_window.active
      update_itemset
      return
    end
      if @weaponset_window.active
      update_weaponset
      return
    end
    if @armorset_window.active
      update_armorset
      return
    end
     if @god_window.active
      update_god
      return
    end
     if @speed_window.active
      update_speed
      return
    end
     if @warp_window.active
      update_warp
      return
    end
      if @number_window.active
      update_money
      return
    end
      if @var_window.active
      update_var
      return
    end
  end
 # ------------------------------
  def update_left
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      $scene = Scene_Map.new
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      if @left_window.mode == 0
        text1 = "Entrée ou C : Activé / Désactivé"
        @help_window.contents.draw_text(4, 0, 406, 32, text1)
      else
        text1 = "Gauche : -1   Droite : +1"
        text2 = "Q : -10     W : +10"
        text3 = "Entrée ou C : Entrer la valeur"
        text4 = "A: Debug avancé"
        text5 = ""
        @help_window.contents.draw_text(4, 0, 200, 32, text1)
        @help_window.contents.draw_text(4, 32, 200, 32, text2)
        @help_window.contents.draw_text(4, 64, 400, 32, text3)
        @help_window.contents.draw_text(240, 0, 180, 32, text4)
        @help_window.contents.draw_text(240, 32, 180, 32, text5)
      end
      @left_window.active = false
      @right_window.active = true
      @right_window.index = 0
      return
    end
    if Input.trigger?(Input::X)
      $game_system.se_play($data_system.decision_se)
      @other_window.visible = true
      @left_window.active = false
      @other_window.active = true
    end
  end
  # ------------------------------
  def update_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @other_window.active = false
      @left_window.active = true
      @other_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      case @other_window.index
      when 0
        @other_window.active = false
        @target_window.active = true
        @target_window.visible = true
        @target_window.index = 0
      when 1
        @god_window.index = 1
        if $game_temp.god_mode
          @god_window.index = 0
        end
        @god_window.active = true
        @god_window.visible = true
        @other_window.active = false
      when 2
        @number_window.number = 0
        @money_window.visible = true
        @number_window.active = true
        @number_window.visible = true
        @other_window.active = false
      when 3
        @enc_window.index = 0
        if $game_system.encounter_disabled
          @enc_window.index = 1
        end
        @enc_window.active = true
        @enc_window.visible = true
        @other_window.active = false
      when 4
        @itemset_window.index = 0
        @itemset_window.active = true
        @itemset_window.visible = true
        @other_window.active = false
      when 5
        @weaponset_window.index = 0
        @weaponset_window.active = true
        @weaponset_window.visible = true
        @other_window.active = false
      when 6
        @armorset_window.index = 0
        @armorset_window.active = true
        @armorset_window.visible = true
        @other_window.active = false
      when 7
        @warp_window.active = true
        @warp_window.visible = true
        @other_window.active = false
      when 8
        @speed_window.index = $game_player.move_speed - 1
        @speed_window.active = true
        @speed_window.visible = true
        @other_window.active = false
      when 9
        $scene = Scene_Save.new
        return
      end
    end
  end
  # ------------------------------
  def update_money
   if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @number_window.active = false
      @other_window.active = true
      @money_window.visible = false
      @number_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_party.lose_gold(9999999)
      $game_party.gain_gold(@number_window.number)
      @money_window.refresh
    end
    if Input.repeat?(Input::X)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_gold(9999999)
      @money_window.refresh
    end
     if Input.repeat?(Input::Y)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_gold(9999999)
      @money_window.refresh
    end
  end
   # ------------------------------
  def update_itemset
   if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @itemset_window.active = false
      @other_window.active = true
      @itemset_window.visible = false
      return
    end
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_item(@itemset_window.index + 1, 1)
      @itemset_window.refresh
    end
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_item(@itemset_window.index + 1, 1)
      @itemset_window.refresh
    end
    if Input.repeat?(Input::X)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_item(@itemset_window.index + 1, 10)
      @itemset_window.refresh
    end
    if Input.repeat?(Input::Y)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_item(@itemset_window.index + 1, 10)
      @itemset_window.refresh
    end
  end
   # ------------------------------
  def update_weaponset
   if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @weaponset_window.active = false
      @other_window.active = true
      @weaponset_window.visible = false
      return
    end
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_weapon(@weaponset_window.index + 1, 1)
      @weaponset_window.refresh
    end
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_weapon(@weaponset_window.index + 1, 1)
      @weaponset_window.refresh
    end
    if Input.repeat?(Input::X)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_weapon(@weaponset_window.index + 1, 10)
      @weaponset_window.refresh
    end
    if Input.repeat?(Input::Y)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_weapon(@weaponset_window.index + 1, 10)
      @weaponset_window.refresh
    end
  end
   # ------------------------------
  def update_armorset
   if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @armorset_window.active = false
      @other_window.active = true
      @armorset_window.visible = false
      return
    end
    if Input.repeat?(Input::RIGHT)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_armor(@armorset_window.index + 1, 1)
      @armorset_window.refresh
    end
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_armor(@armorset_window.index + 1, 1)
      @armorset_window.refresh
    end
    if Input.repeat?(Input::X)
      $game_system.se_play($data_system.cursor_se)
      $game_party.lose_armor(@armorset_window.index + 1, 10)
      @armorset_window.refresh
    end
    if Input.repeat?(Input::Y)
      $game_system.se_play($data_system.cursor_se)
      $game_party.gain_armor(@armorset_window.index + 1, 10)
      @armorset_window.refresh
    end
  end
  # -------------------------------
   def update_enc
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @enc_window.active = false
      @other_window.active = true
      @enc_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      case @enc_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        $game_system.encounter_disabled = false
        @enc_window.active = false
        @other_window.active = true
        @enc_window.visible = false
      when 1
        $game_system.se_play($data_system.decision_se)
        $game_system.encounter_disabled = true
        @enc_window.active = false
        @other_window.active = true
        @enc_window.visible = false
      end
    end
  end
   # -------------------------------
   def update_god
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @god_window.active = false
      @other_window.active = true
      @god_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      case @god_window.index
      when 0
        $game_system.se_play($data_system.decision_se)
        $game_temp.god_mode = true
        @god_window.active = false
        @other_window.active = true
        @god_window.visible = false
      when 1
        $game_system.se_play($data_system.decision_se)
        $game_temp.god_mode = false
        @god_window.active = false
        @other_window.active = true
        @god_window.visible = false
      end
    end
  end
   # -------------------------------
  def update_speed
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @speed_window.active = false
      @other_window.active = true
      @speed_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_player.move_speed = @speed_window.index + 1
      @speed_window.active = false
      @other_window.active = true
      @speed_window.visible = false
    end
  end
   # -------------------------------
   def update_warp
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @warp_window.active = false
      @other_window.active = true
      @warp_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_temp.player_transferring = true
      case @warp_window.index
      when 0
        $game_temp.player_new_map_id = 1
        $game_temp.player_new_x = 1
        $game_temp.player_new_y = 1
        @warp_window.active = false
        @other_window.active = true
        @warp_window.visible = false
      end
    end
  end
  # ------------------------------
  def update_target
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @target_window.active = false
      @other_window.active = true
      @target_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.save_se)
      for i in 1..$data_states.size
        $game_party.actors[@target_window.index].remove_state(i)
      end
      $game_party.actors[@target_window.index].hp += 9999
      $game_party.actors[@target_window.index].sp += 9999
      @target_window.refresh
    end
    if Input.trigger?(Input::X)
      $game_system.se_play($data_system.save_se)
      $game_party.actors[@target_window.index].hp += 9999
      @target_window.refresh
    end
    if Input.trigger?(Input::Y)
      $game_system.se_play($data_system.save_se)
      $game_party.actors[@target_window.index].sp += 9999
      @target_window.refresh
    end
    if Input.trigger?(Input::A)
      $game_system.se_play($data_system.save_se)
      for i in 1..$data_states.size
        $game_party.actors[@target_window.index].remove_state(i)
      end
      @target_window.refresh
    end
  end
  # ------------------------------
  def update_var
   if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @var_window.active = false
      @var_window.visible = false
      @right_window.active = true
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $game_variables[@variable_edit] = @var_window.number
      @right_window.refresh
      @var_window.active = false
      @var_window.visible = false
      @right_window.active = true
    end
  end
 # ------------------------------
  def update_right
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @left_window.active = true
      @right_window.active = false
      @right_window.index = -1
      @help_window.contents.clear
      return
    end
    current_id = @right_window.top_id + @right_window.index
    if @right_window.mode == 0
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        $game_switches[current_id] = (not $game_switches[current_id])
        @right_window.refresh
        return
      end
    end
    if @right_window.mode == 1
      if Input.repeat?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] += 1
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] -= 1
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::C)
        $game_system.se_play($data_system.decision_se)
        current_id = @right_window.top_id + @right_window.index
        @variable_edit = current_id
        @var_window.number = $game_variables[current_id].abs
        @var_window.visible = true
        @var_window.active = true
        @right_window.active = false
      end
       if Input.repeat?(Input::X)
        $game_system.se_play($data_system.decision_se)
        current_id = @right_window.top_id + @right_window.index
        $game_variables[current_id] *= -1
        @right_window.refresh
      end
      if Input.repeat?(Input::R)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] += 10
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::L)
        $game_system.se_play($data_system.cursor_se)
        $game_variables[current_id] -= 10
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
end

