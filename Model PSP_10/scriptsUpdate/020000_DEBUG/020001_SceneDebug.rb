#==============================================================================
# ● Menu Debug - Pokémon
# Pokemon Script Project - Krosk 
# 18/07/07
#==============================================================================
# Contributions :
#   Drakhaine - Fonction Modifier
#==============================================================================
class Scene_Debug
  include POKEMON_S
  def main
    @z_level = 200
    
    @left_window = Window_DebugLeft.new
    @right_window = Window_DebugRight.new
    @left_window.z = 0
    @right_window.z = 0
    
    c1 = "Régénérer l'équipe"
    c2 = "Invincible"
    c3 = "Argent"
    c4 = "Rencontres aléatoires"
    c5 = "Objets"
    c6 = "Armes"
    c7 = "Armures"
    c8 = "Téléporter"
    c9 = "Vitesse de marche"
    c10 = "Sauvegarder"
    
    c1 = "Ajouter"
    c2 = "Supprimer"
    c3 = "Modifier"
    c4 = "Soigner"
    c5 = "Objets"
    c55 = "Argent"
    c6 = "Pokédex"
    c7 = "Rencontres"
    c8 = "Invincibilité"
    c9 = "Vitesse"
    c10 = "Téléporter"
    c11 = "MAJ BDD"
    c12 = "Compiler"
    
    x1 = "Activé"
    x2 = "Désactivé"
    
    w1 = "La plus basse"
    w2 = "Très basse"
    w3 = "Basse"
    w4 = "Rapide"
    w5 = "Très rapide"
    w6 = "La plus rapide"
    
    d1 = "Point de Retour"
    d2 = "Enregistrer Pos"
    
    p1 = "Désactivé"
    p2 = "Activé"
    p3 = "Activé et vierge"
    p4 = "Activé et complété"
    p5 = "Mettre à jour"
    
    
    main_commands = [c1, c2, c3, c4, c5, c55, c6, c7, c8, c9, c10, c11, c12]
    speed_commands = [w1, w2, w3, w4, w5, w6]
    toggle_commands = [x1, x2]
    warp_commands = [d1, d2]
    pkdx_commands = [p1, p2, p3, p4, p5]
    
    
    
    @other_window = Window_Command.new(192, main_commands)
    @other_window.z = @z_level + 20
    @speed_window = Window_Command.new(200, speed_commands)
    @enc_window = Window_Command.new(150, toggle_commands)
    @god_window = Window_Command.new(150, toggle_commands)
    @warp_window = Window_Command.new(240, warp_commands)
    @target_window = Window_Target.new
    @skills_window = Skills_List.new
    @skills_window.z = @z_level + 40
    @slots_window = Window_Command.new(300, ["Slot 1", "Slot 2", "Slot 3", "Slot 4"])
    @slots_window.z = @z_level + 40 
    
    @party_window = POKEMON_S::Debug_Party_Window.new
    @party_window.active = false
    @party_window.visible = false
    @party_window.z = @z_level + 10
    
    @menu_gene = Window_Command.new(150, ["ID", "Niveau", "Générer"], $fontsize)
    @menu_gene.x = 8
    @menu_gene.y = 8
    @menu_gene.z = @z_level + 30
    @menu_gene.visible = false
    @menu_gene.active = false

    @sprite_gene = Window_Base.new(285, 8, 192, 192 + 128)
    @sprite_gene.contents = Bitmap.new(160,160 + 128)
    @sprite_gene.z = @z_level + 40
    @sprite_gene.visible = false
    @sprite_gene.active = false
    @sprite_gene.contents.font.name = $fontface
    @sprite_gene.contents.font.size = $fontsize
    @sprite_gene.contents.font.color = @sprite_gene.normal_color
      
    @id_gene = Window_Base.new(8, 138, 150, 64)
    @id_gene.contents = Bitmap.new(150-32, 32)
    @id_gene.z = @z_level + 40
    @id_gene.contents.font.name = $fontface
    @id_gene.contents.font.size = $fontsize
    @id_gene.active = false
    @id_gene.visible = false
    @id_gene.contents.font.color = @id_gene.normal_color
    @id_gene_index = 0 # Index Digit: 0 unité, 1 dizaines, 2 centaines
      
    @level_gene = Window_Base.new(8, 138, 150, 64)
    @level_gene.contents = Bitmap.new(150-32, 32)
    @level_gene.z = @z_level + 40
    @level_gene.contents.font.name = $fontface
    @level_gene.contents.font.size = $fontsize
    @level_gene.active = false
    @level_gene.visible = false
    @level_gene.contents.font.color = @level_gene.normal_color
    
    @pkdx_window = Window_Command.new(240, pkdx_commands)
    @pkdx_window.active = false
    @pkdx_window.visible = false
    
    @level = 1
    @id = 1
    refresh_sprite
    
    @money_window = Window_Gold.new
    @number_window = Window_InputNumber.new(7)
    @var_window = Window_InputNumber.new(8)
    @help_window = Window_Base.new(192, 352, 448, 128)
    @help_window.contents = Bitmap.new(406, 96)
    #@help_window.contents.font.name = "Arial"
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
    @skills_window.visible = false
    @skills_window.active = false
    @skills_window.refresh
    @slots_window.visible = false
    @slots_window.active = false 
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
    @target_window.x = 304
    @target_window.y = 0
    @target_window.z = @z_level + 100
    @target_window.opacity = 255
    @pkdx_window.x = 270
    @pkdx_window.y = 100
    @pkdx_window.z = @z_level + 100
    @enc_window.x = 225
    @enc_window.y = 180
    @enc_window.z = @z_level + 50
    @enc_window.opacity = 255
    @god_window.x = 225
    @god_window.y = 180
    @god_window.z = @z_level + 50
    @god_window.opacity = 255
    @speed_window.x = 270
    @speed_window.y = 100
    @speed_window.z = @z_level + 50
    @speed_window.opacity = 255
    @warp_window.x = 270
    @warp_window.y = 100
    @warp_window.z = @z_level + 50
    @warp_window.opacity = 255
    @skills_window.x = 0
    @skills_window.y = 0
    @skills_window.opacity = 255
    @slots_window.x = 170
    @slots_window.y = 100
    @slots_window.opacity = 255 
    @itemset_window.x = 0
    @itemset_window.y = 0
    @itemset_window.z = @z_level + 100
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
    @skills_window.dispose
    @slots_window.dispose 
    @itemset_window.dispose
    @weaponset_window.dispose
    @armorset_window.dispose
    @money_window.dispose
    @var_window.dispose
    @party_window.dispose
    @pkdx_window.dispose
    @menu_gene.dispose
    @id_gene.dispose
    @level_gene.dispose
    @sprite_gene.dispose
  end

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
    @skills_window.update
    @slots_window.update 
    @money_window.update
    @number_window.update
    @var_window.update
    $game_temp.debug_top_row = @left_window.top_row
    $game_temp.debug_index = @left_window.index
    
    @menu_gene.update
    @level_gene.update
    @id_gene.update
    @party_window.update
    @pkdx_window.update
    
    if @level_gene.active
      update_gen_level
      return
    end
    if @id_gene.active
      update_gen_id
      return
    end
    if @menu_gene.active
      update_gene
      return
    end
    
    if @party_window.active
      update_party
      return
    end
    if @pkdx_window.active
      update_pkdx
      return
    end
    
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
    if @skills_window.active
      update_skills
      return
    end
    if @slots_window.active
      update_slots
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
      @party_window.visible = true
    end
  end
  
  
  def update_gene
    # Fenetre level
    if Input.trigger?(Input::C) and @menu_gene.index == 1
      $game_system.se_play($data_system.decision_se)
      @menu_gene.active = false
      @level_gene.active = true
      @level_gene.visible = true
      refresh_gen_level
      return
    end
    
    # Fenetre ID
    if Input.trigger?(Input::C) and @menu_gene.index == 0
      $game_system.se_play($data_system.decision_se)
      @menu_gene.active = false
      @id_gene.visible = true
      @id_gene.active = true
      refresh_id
      return
    end
    
    # Générer
    if Input.trigger?(Input::C) and @menu_gene.index == 2
      @menu_gene.active = false
      @menu_gene.visible = false
      @sprite_gene.visible = false
      $game_system.se_play($data_system.decision_se)
      $pokemon_party.add(POKEMON_S::Pokemon.new(@id, @level))
      @party_window.refresh
      @other_window.active = true
      return
    end
      
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.buzzer_se)
      @menu_gene.active = false
      @menu_gene.visible = false
      @sprite_gene.visible = false
      @other_window.active = true
      return
    end
  end
  
  def update_gen_level
    if Input.repeat?(Input::UP)
      if @level >= MAX_LEVEL
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @level += 1
      refresh_sprite
      refresh_gen_level
      return
    end
      
    if Input.repeat?(Input::DOWN)
      if @level <= 1
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @level -= 1
      refresh_sprite
      refresh_gen_level
      return
    end
      
    if Input.repeat?(Input::RIGHT)
      if @level >= MAX_LEVEL
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @level += 10
      if @level >= MAX_LEVEL
        @level = MAX_LEVEL
      end
      refresh_sprite
      refresh_gen_level
      return
    end
      
    if Input.repeat?(Input::LEFT)
      if @level <= 1
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @level -= 10
      if @level <= 1
        @level = 1
      end
      refresh_sprite
      refresh_gen_level
      return
    end
      
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      $game_system.se_play($data_system.decision_se)
      @level_gene.active = false
      @level_gene.visible = false
      @menu_gene.active = true
      refresh_sprite
      return
    end
  end
  
  def update_gen_id
    if Input.trigger?(Input::LEFT)
      if @id_gene_index == 2
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @id_gene_index += 1
      refresh_id
    end
    
    if Input.trigger?(Input::RIGHT)
      if @id_gene_index == 0
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @id_gene_index -= 1
      refresh_id
    end
    
    if Input.repeat?(Input::UP)
      if @id >= $data_pokemon.length-1
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @id += 10 ** @id_gene_index
      if @id >= $data_pokemon.length-1
        @id = $data_pokemon.length-1
      end
      while Pokemon_Info.name(@id) == "-------"
        @id += 1
        if @id > $data_pokemon.length-1
          @id = 1
        end
      end
      refresh_sprite
      refresh_id
      return
    end
    
    if Input.repeat?(Input::DOWN)
      if @id <= 1
        $game_system.se_play($data_system.buzzer_se)
        return
      end
      @id -= 10 ** @id_gene_index
      if @id <= 1
        @id = 1
      end
      while Pokemon_Info.name(@id) == "-------"
        @id -= 1
        if @id < 1
          @id = $data_pokemon.length-1
        end
      end
      refresh_sprite
      refresh_id
      return
    end
    
    if Input.trigger?(Input::C) or Input.trigger?(Input::B)
      $game_system.se_play($data_system.decision_se)
      @id_gene.active = false
      @id_gene.visible = false
      @menu_gene.active = true
      refresh_sprite
      return
    end
  end
  
  def refresh_sprite
    @sprite_gene.contents.clear
    src_rect = Rect.new(0, 0, 160, 160)
    ida = sprintf("%03d", @id)
    bitmap = RPG::Cache.battler("Front_Male/#{ida}.png", 0)
    @sprite_gene.contents.blt(0, 0, bitmap, src_rect, 255)
    string = POKEMON_S::Pokemon_Info.name(@id)
    @sprite_gene.contents.draw_text(0, 160, 160, 32, string, 1)
    @sprite_gene.contents.draw_text(0, 192, 160, 32, "ID: "+ida.to_s, 1)
    @sprite_gene.contents.draw_text(0, 224, 160, 32, "Nv: "+@level.to_s, 1)
  end
  
  def refresh_id
    @id_gene.contents.clear
    @id_gene.contents.draw_text(0, 0, 118, 32, "ID")
    string = ("000" + @id.to_s)[-3..-1]
    for i in 0..2
      if $pokedex.data[@id] == nil
        $pokedex.data[@id] = [ 0, [] ] #[vu ou capturé, [liste formes]]
      end
      if i == @id_gene_index
        @id_gene.contents.font.color = @id_gene.text_color(2)
      end
      @id_gene.contents.draw_text(0, 0, 118 - 22*i, 32, string[2-i..2-i], 2)
      @id_gene.contents.font.color = @id_gene.normal_color
    end
    @id_gene.contents.font.color = @id_gene.normal_color
  end
    
  def refresh_gen_level
    @level_gene.contents.clear
    @level_gene.contents.draw_text(0, 0, 150-32, 32, "Niveau")
    @level_gene.contents.draw_text(0, 0, 150-32, 32, @level.to_s, 2)
  end
  
  def update_pkdx
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      case @pkdx_window.index
      when 0
        $pokedex.disable #désactivé
      when 1
        $pokedex.enable #activé
      when 2
        $pokedex.enable
        $pokedex.delete
      when 3
        $pokedex.enable
        $pokedex.complete
      when 4
        $pokedex.update
      end
      return
    end
    
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @pkdx_window.visible = false
      @pkdx_window.active = false
      @other_window.active = true
      return
    end
  end
  
  def update_skills
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @skills_window.active = false
      @party_window.active = true
      @skills_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      @skills_window.active = false
      @slots_window.active = true
      @skills_window.visible = false
      @slots_window.visible = true
    end
  end
  
  def update_slots
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @slots_window.active = false
      @skills_window.active = true
      @slots_window.visible = false
      @skills_window.visible = true
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      $pokemon_party.actors[@party_window.index].replace_skill_index(@slots_window.index,$data_skills_pokemon[@skills_window.index+1][0])
      @slots_window.active = false
      @skills_window.active = true
      @slots_window.visible = false
      @skills_window.visible = true
    end
  end
    
  def update_party
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      case @other_window.index
      when 1 # Supprimer sélectionné
        $pokemon_party.remove_id(@party_window.index)
        @party_window.refresh
      when 2 # Modifier séléctionner
        @party_window.active = false
        @skills_window.active = true
        @skills_window.visible = true
      end
      return
    end
    
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @party_window.active = false
      @party_window.index = -1
      @other_window.active = true
      return
    end
    
  end
    
  # ------------------------------
  def update_command
    if Input.trigger?(Input::B)
      $game_system.se_play($data_system.cancel_se)
      @other_window.active = false
      @left_window.active = true
      @other_window.visible = false
      @party_window.visible = false
      return
    end
    if Input.trigger?(Input::C)
      $game_system.se_play($data_system.decision_se)
      case @other_window.index
      when 0 #Ajouter
        @menu_gene.active = true
        @menu_gene.visible = true
        @sprite_gene.visible = true
        @other_window.active = false
      when 1 #Supprimer
        @other_window.active = false
        @party_window.active = true
        @party_window.index = 0
      when 2 #Modifier
        @other_window.active = false
        @party_window.active = true
        @party_window.index = 0 
      when 3 #Soigner
        $pokemon_party.refill_party
        @party_window.refresh
      when 4 #Objets
        @itemset_window.index = 0
        @itemset_window.active = true
        @itemset_window.visible = true
        @other_window.active = false
      when 5 #Argent
        @number_window.number = 0
        @money_window.visible = true
        @number_window.active = true
        @number_window.visible = true
        @other_window.active = false
      when 6 #Pkdx
        @pkdx_window.active = true
        @pkdx_window.visible = true
        @other_window.active = false
      when 7 #Rencontres
        @enc_window.index = 0
        if $game_system.encounter_disabled
          @enc_window.index = 1
        end
        @enc_window.active = true
        @enc_window.visible = true
        @other_window.active = false
      when 8 #Invincible
        @god_window.index = 1
        if $game_temp.god_mode
          @god_window.index = 0
        end
        @god_window.active = true
        @god_window.visible = true
        @other_window.active = false
      when 10
        @warp_window.active = true
        @warp_window.visible = true
        @other_window.active = false
      when 9
        @speed_window.index = $game_player.move_speed - 1
        @speed_window.active = true
        @speed_window.visible = true
        @other_window.active = false
      when 11
        pokemon_conversion
      when 12
        update_library
        update_datafile
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
      $pokemon_party.lose_money(9999999)
      $pokemon_party.add_money(@number_window.number)
      @money_window.refresh
    end
    if Input.repeat?(Input::X)
      $game_system.se_play($data_system.cursor_se)
      $pokemon_party.add_money(9999999)
      @money_window.refresh
    end
     if Input.repeat?(Input::Y)
      $game_system.se_play($data_system.cursor_se)
      $pokemon_party.add_money(9999999)
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
      $pokemon_party.add_item(@itemset_window.index + 1, 1)
      @itemset_window.refresh
    end
    if Input.repeat?(Input::LEFT)
      $game_system.se_play($data_system.cursor_se)
      $pokemon_party.drop_item(@itemset_window.index + 1, 1)
      @itemset_window.refresh
    end
    if Input.repeat?(Input::X)
      $game_system.se_play($data_system.cursor_se)
      $pokemon_party.drop_item(@itemset_window.index + 1, 10)
      @itemset_window.refresh
    end
    if Input.repeat?(Input::Y)
      $game_system.se_play($data_system.cursor_se)
      $pokemon_party.add_item(@itemset_window.index + 1, 10)
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
        $game_temp.player_new_map_id = $game_variables[MAP_ID]
        $game_temp.player_new_x = $game_variables[MAP_X]
        $game_temp.player_new_y = $game_variables[MAP_Y]
        @warp_window.active = false
        @other_window.active = true
        @warp_window.visible = false
      when 1
        $game_temp.player_transferring = false
        $game_variables[MAP_ID] = $game_map.map_id
        $game_variables[MAP_X] = $game_player.x
        $game_variables[MAP_Y] = $game_player.y
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
        if $game_variables[current_id].type != Fixnum
          return
        end
        $game_variables[current_id] += 1
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        if $game_variables[current_id].type != Fixnum
          return
        end
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
        if $game_variables[current_id].type != Fixnum
          return
        end
        @var_window.number = $game_variables[current_id].abs
        @var_window.visible = true
        @var_window.active = true
        @right_window.active = false
      end
       if Input.repeat?(Input::X)
        $game_system.se_play($data_system.decision_se)
        current_id = @right_window.top_id + @right_window.index
        if $game_variables[current_id].type != Fixnum
          return
        end
        $game_variables[current_id] *= -1
        @right_window.refresh
      end
      if Input.repeat?(Input::R)
        $game_system.se_play($data_system.cursor_se)
        if $game_variables[current_id].type != Fixnum
          return
        end
        $game_variables[current_id] += 10
        if $game_variables[current_id] > 99999999
          $game_variables[current_id] = 99999999
        end
        @right_window.refresh
        return
      end
      if Input.repeat?(Input::L)
        $game_system.se_play($data_system.cursor_se)
        if $game_variables[current_id].type != Fixnum
          return
        end
        $game_variables[current_id] -= 10
        if $game_variables[current_id] < -99999999
          $game_variables[current_id] = -99999999
        end
        @right_window.refresh
        return
      end
    end
  end
  
  
  def pokemon_conversion
    window = Window_Base.new(170, 208, 300, 64)
    window.contents = Bitmap.new(300-32, 64-32)
    window.contents.font.name = $fontface
    window.contents.font.size = $fontsize
    window.active = false
    window.visible = true
    window.z = 10000
    window.contents.font.color = window.normal_color
    window.contents.draw_text(0, 0, 300-32, 32, "Mise à jour en cours...", 1)
    
    
    # Reecriture Weapon / Armor
    # Inscription des CT/CS
    j = 0
    for i in 1..$data_items.length-1
      if $data_items[i] != nil and $data_items[i].name[0..1] == "CT" and
          $data_items[i].name[2..3].to_i != 0
        if $data_weapons[34+j] == nil
          $data_weapons[34+j] = RPG::Weapon.new
        end
        $data_weapons[34+j].name = POKEMON_S::Item.name(i)
        j += 1
      end
      if $data_items[i] != nil and $data_items[i].name[0..1] == "CS" and
          $data_items[i].name[2..3].to_i != 0
        if $data_weapons[34+j] == nil
          $data_weapons[34+j] = RPG::Weapon.new
        end
        $data_weapons[34+j].name = POKEMON_S::Item.name(i)
        j += 1
      end
    end
    
    # Inscription des capa spé
    for i in 1..$data_ability.length-1
      if $data_armors[i+33] == nil
        $data_armors[i+33] = RPG::Armor.new
      end
      $data_armors[i+33].name = $data_ability[i][0]
      $data_armors[i+33].description = $data_ability[i][1]
    end
    
    
    
    # Inscription des CT/CS
    ct_list = {}
    cs_list = {}
    for element in $data_weapons
      if element == nil
        next
      end
      if element.name[0..1] == "CT" and element.name[2..3].to_i != 0
        ct_list[element.name[2..3].to_i] = element.id
      end
      if element.name[0..1] == "CS" and element.name[2..3].to_i != 0
        cs_list[element.name[2..3].to_i] = element.id
      end
    end
    
    # Conversion
    for id in 1..$data_pokemon.length-1
      Graphics.update
      
      
      if $data_enemies[id] == nil
        $data_enemies[id] = RPG::Enemy.new
      end
      
      if $data_classes[id] == nil
        $data_classes[id] = RPG::Class.new
      end
      
      # Reset données
      $data_enemies[id].mdef = 0
      $data_enemies[id].pdef = 0
      $data_enemies[id].actions = []
      
      $data_classes[id].weapon_set = []
      $data_classes[id].armor_set = []
      
      # Nom
      $data_enemies[id].name = Pokemon_Info.name(id) # pokemon.name
      $data_enemies[id].battler_name = "Front_Male/#{sprintf("%03d",id)}.png"
      
      # ID secondaire
      $data_enemies[id].maxsp = Pokemon_Info.id_bis(id)
      
      # Base Stats
      $data_enemies[id].maxhp = Pokemon_Info.base_hp(id) # pokemon.base_hp
      $data_enemies[id].agi = Pokemon_Info.base_spd(id) # pokemon.base_spd
      $data_enemies[id].int = Pokemon_Info.base_ats(id) # pokemon.base_ats
      $data_enemies[id].str = Pokemon_Info.base_atk(id) # pokemon.base_atk
      $data_enemies[id].dex = Pokemon_Info.base_dfe(id) # pokemon.base_dfe
      $data_enemies[id].atk = Pokemon_Info.base_dfs(id) # pokemon.base_dfs
      
      # Apprentissage des skills
      $data_classes[id].learnings = []
      for skill in Pokemon_Info.skills_table(id)
        learning = RPG::Class::Learning.new
        learning.level = skill[1]
        learning.skill_id = skill[0]
        $data_classes[id].learnings.push(learning)
      end
      
      # CT/CS: support script
      
      # Exp Type
      $data_classes[id].weapon_set.push(Pokemon_Info.exp_type(id) + 15)
      
      # Evolution
      $data_classes[id].name = ""
      # Evolution unique
      if Pokemon_Info.evolve_table(id).length == 2
        # Evolution naturelle seulement
        if Pokemon_Info.evolve_table(id)[1].length == 2
          name = Pokemon_Info.evolve_table(id)[1][0]
          data = Pokemon_Info.evolve_table(id)[1][1]
          if data.type == Fixnum and name != ""
            $data_classes[id].name = name + "/" + data.to_s
            $data_classes[id].weapon_set.push(22)
          elsif data == "loyal"
            $data_classes[id].name = name#"L" + "/" + name
            $data_classes[id].weapon_set.push(24)
          elsif data == "trade"
            $data_classes[id].name = name#"T" + "/" + name
            $data_classes[id].weapon_set.push(25)
          elsif data.type == Array and data[0] == "stone"
            $data_classes[id].name = name#"S" + "/" + name
            $data_classes[id].weapon_set.push(23)
          elsif data != [] and data != nil and name != nil and name != ""
            $data_classes[id].weapon_set.push(26)
          end
        elsif Pokemon_Info.evolve_table(id)[1].length > 2
          name = Pokemon_Info.evolve_table(id)[1][0]
          $data_classes[id].name = name
          $data_classes[id].weapon_set.push(26)
        end
      else
        # Evolution spéciale/multiple
        $data_classes[id].weapon_set.push(26)
      end
      
      # Type
      if Pokemon_Info.type1(id) != 0
        $data_enemies[id].element_ranks[Pokemon_Info.type1(id)] = 1
        $data_classes[id].element_ranks[Pokemon_Info.type1(id)] = 3
      end
      if Pokemon_Info.type2(id) != 0
        $data_enemies[id].element_ranks[Pokemon_Info.type2(id)] = 2
        $data_classes[id].element_ranks[Pokemon_Info.type2(id)] = 3
      end
      
      # Rareté
      $data_enemies[id].gold = Pokemon_Info.rareness(id)
      
      # Genre
      $data_classes[id].armor_set = []
      case POKEMON_S::Pokemon_Info.female_rate(id) # Female rate
      when -1
        $data_classes[id].armor_set.push(2)
      when 0
        $data_classes[id].armor_set.push(3)
      when 12.5
        $data_classes[id].armor_set.push(4)
      when 25
        $data_classes[id].armor_set.push(5)
      when 50
        $data_classes[id].armor_set.push(6)
      when 75
        $data_classes[id].armor_set.push(7)
      when 87.5
        $data_classes[id].armor_set.push(8)
      when 100
        $data_classes[id].armor_set.push(9)
      else
        $data_classes[id].armor_set.push(6)
      end
      
      # Loyauté
      case Pokemon_Info.base_loyalty(id)
      when 0
        $data_classes[id].armor_set.push(11)
      when 35
        $data_classes[id].armor_set.push(12)
      when 70
        $data_classes[id].armor_set.push(13)
      when 90
        $data_classes[id].armor_set.push(14)
      when 100
        $data_classes[id].armor_set.push(15)
      when 140
        $data_classes[id].armor_set.push(16)
      else
        $data_classes[id].armor_set.push(13)
      end
      
      # EV et Base Exp
      i = 0
      for element in Pokemon_Info.battle_list(id)
        if i == Pokemon_Info.battle_list(id).length-1
          $data_enemies[id].exp = element
          next
        end
        
        case element
        when 1
          $data_classes[id].weapon_set.push(2+i)
        when 2
          $data_classes[id].weapon_set.push(8+i)
        when 3
          $data_classes[id].weapon_set.push(2+i)
          $data_classes[id].weapon_set.push(8+i)
        end
        i += 1
      end
      
      # Breed Groupe
      for group in Pokemon_Info.breed_group(id)
        $data_classes[id].armor_set.push(group + 17)
      end
      
      # Egg Hatch
      case Pokemon_Info.hatch_step(id)
      when 1280
        $data_classes[id].weapon_set.push(28)
      when 2560
        $data_classes[id].weapon_set.push(29)
      when 3840
        $data_classes[id].weapon_set.push(28)
        $data_classes[id].weapon_set.push(29)
      when 5120
        $data_classes[id].weapon_set.push(30)
      when 6400
        $data_classes[id].weapon_set.push(30)
        $data_classes[id].weapon_set.push(28)
      when 7680
        $data_classes[id].weapon_set.push(30)
        $data_classes[id].weapon_set.push(29)
      when 8960
        $data_classes[id].weapon_set.push(30)
        $data_classes[id].weapon_set.push(29)
        $data_classes[id].weapon_set.push(28)
      when 10240
        $data_classes[id].weapon_set.push(31)
      when 20480
        $data_classes[id].weapon_set.push(32)
      when 30720
        $data_classes[id].weapon_set.push(31)
        $data_classes[id].weapon_set.push(32)
      else
        $data_classes[id].weapon_set.push(30)
      end
      
      # Liste CT/CS
      for element in Pokemon_Info.skills_tech(id)
        if element.type == Fixnum # CT
          $data_classes[id].weapon_set.push(ct_list[element])
        end
        if element.type == Array
          $data_classes[id].weapon_set.push(cs_list[element[0]])
        end
      end
      
      # Capa Spé
      list = []
      for i in 1..$data_ability.length-1
        list.push($data_ability[i][0])
      end
      for ability in POKEMON_S::Pokemon_Info.ability_list(id)
        abid = list.index(ability) + 1
        $data_classes[id].armor_set.push(abid + 33)
      end
      
      # Attaque par accouplement
      r = 0
      for skill in Pokemon_Info.breed_move(id)
        if $data_enemies[id].actions[r] == nil
          $data_enemies[id].actions[r] = RPG::Enemy::Action.new
        end
        $data_enemies[id].actions[r].kind = 1
        $data_enemies[id].actions[r].skill_id = skill
        r += 1
      end
    end
    
    file = File.open("Data/Enemies.rxdata", "wb")
    Marshal.dump($data_enemies, file)
    file.close
    file = File.open("Data/Classes.rxdata", "wb")
    Marshal.dump($data_classes, file)
    file.close
    file = File.open("Data/Weapons.rxdata", "wb")
    Marshal.dump($data_weapons, file)
    file.close
    file = File.open("Data/Armors.rxdata", "wb")
    Marshal.dump($data_armors, file)
    file.close
    
    window.dispose
    window = Window_Base.new(80, 160, 480, 160)
    window.contents = Bitmap.new(480-32, 160-32)
    window.contents.font.name = $fontface
    window.contents.font.size = $fontsize
    window.active = false
    window.visible = true
    window.z = 10000
    window.contents.font.color = window.normal_color
    window.contents.draw_text(0, 0, 480-32, 32, "Mise à jour terminée.", 1)
    window.contents.draw_text(0, 32, 480-32, 32, "Dans RMXP, cliquez sur 'Fichier'", 1)
    window.contents.draw_text(0, 64, 480-32, 32, "puis sur 'Fermer le projet'.", 1)
    window.contents.draw_text(0, 96, 480-32, 32, "Et réouvrez votre projet.", 1)
    loop do
      Input.update
      Graphics.update
      if Input.trigger?(Input::C)
        break
      end
    end
    window.dispose
    exit
  end

  def update_library
    picture_data = {}
    directory_list = ["Anime/Front_Male/", "Anime/Front_Female/", 
                      "Anime/Back_Male/", "Anime/Back_Female/",
                      "Shiny_Anime/Front_Male/", "Shiny_Anime/Front_Female/", 
                      "Shiny_Anime/Back_Male/", "Shiny_Anime/Back_Female/", 
                      "Icon/", "Icon/Anime/", "Eggs/", "Front_Male/", "Front_Female/",
                      "Shiny_Front_Male/", "Shiny_Front_Female/", "Shiny_Back_Male/", "Back_Male/"]
    for name in directory_list    
      directory = explore("Graphics/Battlers/#{name}")
      directory[0].each do |file|
        picture_data["Graphics/Battlers/#{name}#{file}"] = true
      end
    end
    # Ajout des pokémon pour le FollowMe
    directory = explore("Graphics/Characters")
    directory[0].each do |file|
      picture_data["Graphics/Characters/#{file}"] = true
    end
    file = File.open("Data/Library.rxdata", "wb")
    Marshal.dump(picture_data, file)
    file.close
  end
  
  def update_datafile
    file = File.open("Data/data_pokemon.rxdata", "wb")
    Marshal.dump($data_pokemon, file)
    file.close
    
    file = File.open("Data/data_item.rxdata", "wb")
    Marshal.dump($data_item, file)
    file.close
    
    file = File.open("Data/data_mapzone.rxdata", "wb")
    Marshal.dump($data_mapzone, file)
    file.close
    
    file = File.open("Data/data_zone.rxdata", "wb")
    Marshal.dump($data_zone, file)
    file.close

    # G!n0 : Les données sur les différentes formes des Pokémons
    file = File.open("Data/data_form.rxdata", "wb")
    Marshal.dump($data_form, file)
    file.close
  end
  
end



