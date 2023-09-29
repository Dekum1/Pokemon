#==============================================================================
# ■ Pokemon_Item_Bag
# Pokemon Script Project - Krosk
# 23/08/07
# 31/12/19 - Restructuration par Lizen
#-----------------------------------------------------------------------------
# Scène modifiable si vous savez ce que vous faites
#-----------------------------------------------------------------------------
# Interface du Sac
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#  @bag = [ paramètre, [], [], [], [], [] ]
#  id: id objet, nombre: -1 pour objet utilisable à l'infini.
#  paramètre : optionnel
#  @bag[1] : Items, objets simples, sous la forme [id, nombre]
#  @bag[2] : Balls [id, nombre]
#  @bag[3] : CT/CS [id, nombre]
#  @bag[4] : Baies sous la forme [id, nombre]
#  @bag[5] : Objets rares
#-----------------------------------------------------------------------------


module POKEMON_S
  class Pokemon_Item_Bag
    # -------------------------------------------
    # Initialisation
    #    socket: cf rubrique @bag, indique la poche
    #    item_index: index du curseur
    #    mode =
    # -------------------------------------------
    def initialize(socket_index = $pokemon_party.bag_index, z_level = 100, mode = 0)
      @raccourcis = false
      @bag_index = socket_index[0]
      @item_index = socket_index[1]
      @z_level = z_level
      @mode = mode
    end

    def main

      # ---------------------------------------------------------------------------------
      # Nom d'arrière plan et Sac en fonction du choix Fille/Garçon
      # ---------------------------------------------------------------------------------
      if $game_switches[FILLE] # Choix Fille
        background_name = DATA_SAC[:background_fille]
        bag_name = DATA_SAC[:icon_sac_fille]
      elsif $game_switches[GARCON] # Choix Gars
        background_name = DATA_SAC[:background_gars]
        bag_name = DATA_SAC[:icon_sac_gars]
      else # Valeur par défaut (si aucun choix)
        background_name = DATA_SAC[:background_gars]
        bag_name = DATA_SAC[:icon_sac_gars]
      end


      Graphics.freeze
      @background = Sprite.new
      @background.bitmap = RPG::Cache.picture("bag/#{background_name}")
      @background.z = @z_level

      # Sprite du Sac
      sac_l = 128 # largeur découpe
      sac_h = 128 # hauteur découpe
      @bag_sprite = Sprite.new
      @bag_sprite.bitmap = RPG::Cache.picture("bag/#{bag_name}")
      @bag_sprite.src_rect.set(0, 0, sac_l, sac_h)
      @bag_sprite.x = 102 # Axe X
      @bag_sprite.y = 96  # Axe Y
      @bag_sprite.z = @z_level + 1

      # Nom de la poche
      @socket_name = Window_Base.new(51-16, 27-16, 228+32, 45+32)
      @socket_name.contents = Bitmap.new(228, 45)
      @socket_name.opacity = 0
      @socket_name.z = @z_level + 1
      @socket_name.contents.font.name = $fontface
      @socket_name.contents.font.size = 35
      @socket_name.contents.font.color = @socket_name.normal_color

      # Flèche
      @item_arrow = Sprite.new
      @item_arrow.bitmap = RPG::Cache.picture(DATA_SAC[:navigation])
      @item_arrow.x = 517
      @item_arrow.y = 382
      @item_arrow.z = @z_level + 5
      @item_arrow.visible = false

      # Liste des Objets
      @item_list = POKEMON_S::Pokemon_Item_Bag_List.new(@bag_index, @item_index)
      @item_list.opacity = 0
      @item_list.z = @z_level + 1
      @item_list.active = true
      @item_list.visible = true

      # Description des Objets
      @text_window = Window_Base.new(6, 296, 273, 193)
      @text_window.opacity = 0
      @text_window.contents = Bitmap.new(241, 161)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = 35
      @text_window.contents.font.color = @text_window.normal_color
      @text_window.z = @z_level + 1

      @item_icon = Sprite.new
      @item_icon.z = @z_level + 2
      @item_icon.x = 12
      @item_icon.y = 213
      @item_icon.zoom_x = 3
      @item_icon.zoom_y = 3
      @item_icon.bitmap = RPG::Cache.icon(item_icon)

      # Fenêtre de la quantité d'objets
      @drop_counter = Window_Base.new(0, 0, 120, 64)
      @drop_counter.contents = Bitmap.new(150-32, 32)
      @drop_counter.x = 640 - 120 - 3
      @drop_counter.y = 480 - 64 - 3
      @drop_counter.z = @z_level + 4
      @drop_counter.contents.font.name = $fontface
      @drop_counter.contents.font.size = 25
      @drop_counter.contents.font.color = @drop_counter.normal_color
      @drop_counter.visible = false
      @drop_counter_number = 1

      list = ["UTILISER", "DONNER", "JETER", "ORDRE", "RETOUR"]
      if $battle_var.in_battle
        list = ["UTILISER", "RETOUR"]
      end
      @command_window = Window_Command.new(260, list)
      @command_window.active = false
      @command_window.visible = false
      @command_window.x = 640 - 260 - 3
      @command_window.y = 480 - @command_window.height - 3
      @command_window.z = @z_level + 10

      refresh_all

      Graphics.transition
      loop do
        Graphics.update
        if @done
          break
        end
        Input.update
        if @raccourcis then
          update_raccourcis
          next
        end
        if @drop_counter.visible
          update_drop
          next
        end
        if @command_window.active
          update_command
          next
        end
        if not @command_window.active
          @item_list.update
          update
          next
        end
      end

      $pokemon_party.bag_index[0] = @bag_index
      $pokemon_party.bag_index[1] = @item_list.index

      Graphics.freeze
      @item_list.dispose
      @text_window.dispose
      @item_icon.dispose
      @background.dispose
      @bag_sprite.dispose
      @item_arrow.dispose
      @socket_name.dispose
      @drop_counter.dispose
    end

    def update
      if Input.repeat?(Input::DOWN) or Input.repeat?(Input::UP)
        # Condition pour empecher le bug quand on descend après une suppression
        if $pokemon_party.bag[@bag_index][@item_list.index] != nil
          refresh
          return
        else
          #Si plus d'item dans la poche, on descend pas plus bas
          if @item_list.size == 0
          @item_list.refresh
          refresh_all
          end
        return
        end
      end

      if Input.repeat?(Input::RIGHT) and @item_list.on_switch == -1
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:curseur_poche]}")
        @bag_index += @bag_index == 5 ? -4 : 1
        @item_list.refresh(@bag_index)
        refresh_all
        return
      end

      if Input.repeat?(Input::LEFT) and @item_list.on_switch == -1
        Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:curseur_poche]}")
        @bag_index += @bag_index == 1 ? 4 : -1
        @item_list.refresh(@bag_index)
        refresh_all
        return
      end

      if Input.trigger?(Input::C)
        if @mode == "sell"
          if @item_list.index == @item_list.size
            @done = true
            return
          end
          # item invendable
          if not(POKEMON_S::Item.soldable?(item_id)) or (POKEMON_S::Item.price(item_id) == 0)
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          # $scene = Pokemon_Item_Shop.new
          $scene.call_item_amount([item_id, item_amount], "sell", @z_level + 100)
          refresh_all
          return
        end

        # Echange d'objet
        if @item_list.on_switch != -1
          if @item_list.index != @item_list.size
            $game_system.se_play($data_system.decision_se)
            $pokemon_party.item_switch(@bag_index, @item_list.index, @item_list.on_switch)
            @item_list.on_switch = -1
            refresh_all
          else
            $game_system.se_play($data_system.cancel_se)
            @item_list.on_switch = -1
            refresh_all
          end
          return
        end

        # Mode sélection objet à donner
        if @mode == "hold"
          # Fermer le sac
          if @item_list.index == @item_list.size
            $game_system.se_play($data_system.decision_se)
            @done = true
            @return_data = [0, false]
          # Fermer le sac
          elsif POKEMON_S::Item.holdable?(item_id)
            $game_system.se_play($data_system.decision_se)
            @done = true
            @return_data = [item_id, true]
          else
            $game_system.se_play($data_system.buzzer_se)
          end
          return
        end

        # Retour
        if @item_list.index == @item_list.size
          @done = true
          # Retour au combat
          if $battle_var.in_battle
            return
          end
          $scene = POKEMON_S::Pokemon_Menu.new(3)
          return
        # Sélection item
        else
          @command_window.active = true
          refresh
          @command_window.visible = true
          return
        end
      end

      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        if @mode == "hold"
          @done = true
          @return_data = [0, false]
          return
        end

        if @mode == "sell"
          @done = true
          return
        end

        if @item_list.on_switch != -1
          @item_list.on_switch = -1
          refresh_all
          return
        end

        if $battle_var.in_battle
          $game_system.se_play($data_system.cancel_se)
          @return_data = 0
          @done = true
          return
        end

        $game_system.se_play($data_system.cancel_se)
        $scene = POKEMON_S::Pokemon_Menu.new(3)
        @done = true
        return
      end
    end

    def return_data
      return @return_data
    end

    # ----------------------------------
    # Appel en cas de changement d'item
    # ----------------------------------
    def refresh

      # Sprite du sac
      case @bag_index
          when 1 # Poche objet
            @bag_sprite.src_rect.set(0, 0, 128, 128)
          when 2 # Poche balls
              @bag_sprite.src_rect.set(0, 128, 128, 128)
          when 3 # Poche CT/CS
            @bag_sprite.src_rect.set(0, 256, 128, 128)
          when 4 # Poche Baies
              @bag_sprite.src_rect.set(0, 384, 128, 128)
          when 5 # Poche Objets Rares
               @bag_sprite.src_rect.set(0, 512, 128, 128)
      end



      # Nom de la poche
      @socket_name.contents.clear
      @socket_name.contents.draw_text(0,0, 228, 48, socket_name, 1)

      # Tracage de l'icone objet
      @item_icon.bitmap = RPG::Cache.icon(item_icon)

      # Texte de description
      if @command_window.active
        string = []
        string[0] = POKEMON_S::Item.name(item_id)
        string[1] = "est sélectionné."
      elsif @drop_counter.visible
        string = []
        string[0] = "En jeter"
        string[1] = "combien?"
      elsif @item_list.on_switch != -1
        string = []
        string[0] = "Echanger avec"
        string[1] = "lequel?"
      else
        string = string_builder(item_descr, 25)
      end

      text_window_draw(string)

      refresh_command_list
    end



    # ------------------------------------
    # Appel en cas de changement de poche
    # ------------------------------------
    def refresh_all
      refresh_list
      refresh
    end

    # ------------------------------------
    # Rafraichissement de liste (même poche)
    # ------------------------------------
    def refresh_list
      @item_list.refresh_list
    end

    # ----------------------------------
    # Liste d'actions associé à l'item
    # ----------------------------------
    def update_command
      @command_window.update

      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @command_window.active = false
        @command_window.visible = false
        refresh
        return
      end

      if Input.trigger?(Input::C)
        case @command_window.index
        # Utiliser
        when 0
          if $battle_var.in_battle and not(POKEMON_S::Item.battle_usable?(item_id))
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          if not($battle_var.in_battle) and not(POKEMON_S::Item.map_usable?(item_id))
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          $game_system.se_play($data_system.decision_se)
          @command_window.active = false
          @command_window.visible = false
          if POKEMON_S::Item.use_on_pokemon?(item_id)
            item_mode = "item_use"
            if POKEMON_S::Item.item_able_mode?(item_id)
              item_mode = "item_able"
            end
            scene = POKEMON_S::Pokemon_Party_Menu.new(0, @z_level + 100, item_mode, item_id)
            scene.main
            # return_data = [id item_utilisé, item utilisé oui/non, ]
            data = scene.return_data
            used = data[1]
            item_used = 0
          else
            # Utilisé
            data = POKEMON_S::Item.effect(item_id)
            used = data[0]
            item_used = item_id
            string = data[1]
            return_map = data[2]
            if string.type == String and string != ""
              window = Pokemon_Window_Help.new
              window.draw_text(string)
              Input.update
              until Input.trigger?(Input::C)
                Graphics.update
                Input.update
              end
              window.dispose
            end
          end
          if used
            $pokemon_party.use_item(item_id)
          end
          # En combat, retour à l'écran après utilisation de l'objet
          if $battle_var.in_battle and used
            $battle_var.action_id = 1
            @done = true
            @return_data = item_used
            return
          end
          if used and return_map
            @done = true
            return
          end
          refresh_all
          @item_list.refresh
          Graphics.transition
          return
        # Retour (dernière option)
        when @command_window.item_max-1
          $game_system.se_play($data_system.cancel_se)
          @command_window.active = false
          @command_window.visible = false
          refresh
          return
        # Donner
        when 1
          if not(POKEMON_S::Item.holdable?(item_id))
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          $game_system.se_play($data_system.decision_se)
          @command_window.active = false
          @command_window.visible = false
          scene = POKEMON_S::Pokemon_Party_Menu.new(0, @z_level + 100, "hold", item_id)
          scene.main
          return_data = scene.return_data
          # return_data = [item tenu true/false, id item_tenu, item remplacé true/false, id item remplacé]
          item_id2 = return_data[2]
          replaced = return_data[3]
          if replaced
            $pokemon_party.add_item(item_id2)
          end
          item_id1 = return_data[0]
          hold = return_data[1]
          if hold
            $pokemon_party.drop_item(item_id1)
          end
          refresh_all
          Graphics.transition
          return
        # Jeter
        when 2
          if not(POKEMON_S::Item.holdable?(item_id))
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          $game_system.se_play($data_system.decision_se)
          @command_window.active = false
          @command_window.visible = false
          @drop_counter.visible = true
          @item_arrow.visible = true
          refresh
          refresh_drop_counter
          return
        # Ordre
        when 3
          @item_list.on_switch = @item_list.index
          @command_window.active = false
          @command_window.visible = false
          refresh_all
          return
        #Raccourcis
        when 4
          if not POKEMON_S::Item.map_usable?(item_id) then
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          @item_list.on_switch = @item_list.index
          $game_system.se_play($data_system.decision_se)
          @raccourcis = true
          @command_window.active = false
          @command_window.visible = false
          refresh
          return
        end
      end

    end

    def refresh_command_list
      # Fermer le sac
      if @item_list.index == @item_list.size
        return
      end
      # En combat
      if $battle_var.in_battle
        if POKEMON_S::Item.battle_usable?(item_id)
          @command_window.enable_item(0)
        else
          @command_window.disable_item(0)
        end
      # En map
      else
        if POKEMON_S::Item.map_usable?(item_id)
          @command_window.enable_item(0)
          @command_window.enable_item(4)
        else
          @command_window.disable_item(0)
          @command_window.disable_item(4)
        end
        if POKEMON_S::Item.holdable?(item_id)
          @command_window.enable_item(1)
          @command_window.enable_item(2)
        else
          @command_window.disable_item(1)
          @command_window.disable_item(2)
        end
      end
    end

    def update_drop
      if Input.repeat?(Input::UP)
        if @drop_counter_number < item_amount
          @drop_counter_number += 1
          refresh_drop_counter
        end
        return
      end

      if Input.repeat?(Input::DOWN)
        if @drop_counter_number > 1
          @drop_counter_number -= 1
          refresh_drop_counter
        end
        return
      end

      if Input.repeat?(Input::LEFT)
        if @drop_counter_number > 1
          @drop_counter_number -= 10
          if @drop_counter_number < 1
            @drop_counter_number = 1
          end
          refresh_drop_counter
        end
        return
      end

      if Input.repeat?(Input::RIGHT)
        if @drop_counter_number < item_amount
          @drop_counter_number += 10
          if @drop_counter_number > item_amount
            @drop_counter_number = item_amount
          end
          refresh_drop_counter
        end
        return
      end

      if Input.repeat?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @drop_counter_number = 1
        @drop_counter.visible = false
        @item_arrow.visible = false
        @command_window.active = true
        @command_window.visible= true
        refresh
        return
      end

      if Input.repeat?(Input::C)
        $game_system.se_play($data_system.decision_se)
        if decision
          $game_system.se_play($data_system.decision_se)
          id_ = item_id
          $pokemon_party.drop_item(id_, @drop_counter_number)
          @drop_counter.visible = false
          @item_arrow.visible = false
          refresh_list
          text_window_draw(["Jeté " + @drop_counter_number.to_s, POKEMON_S::Item.name(id_) + "."])
          @drop_counter_number = 1
          @command_window.active = false
          @command_window.visible = false
          Input.update
          until Input.trigger?(Input::C)
            Graphics.update
            Input.update
          end
          #Refresh liste après suppression
          @item_list.refresh
          refresh_all
          return
        else
          $game_system.se_play($data_system.cancel_se)
          @drop_counter_number = 1
          @drop_counter.visible = false
          @item_arrow.visible = false
          @command_window.active = false
          @command_window.visible = false
          refresh
          return
        end
      end
    end

    def refresh_drop_counter
      @drop_counter.contents.clear
      @drop_counter.contents.draw_text(-2,0,88,32, "x " + @drop_counter_number.to_s, 2)
    end

    # ----------------------------------
    # Identification de l'item !!!!!!! Utilise l'index de la poche
    # ----------------------------------
    def item_id
      if @item_list.index >= $pokemon_party.bag[@bag_index].size
        @item_list.index = $pokemon_party.bag[@bag_index].size
        return 0
      end
      return $pokemon_party.bag[@bag_index][@item_list.index][0]
    end

    def item_icon
      if @item_list.index == @item_list.size
        return "return.png"
      else
        return POKEMON_S::Item.icon(item_id)
      end
    end

    def item_descr
      if @item_list.index == @item_list.size
        if $battle_var.in_battle
          return "Retourner au combat."
        end
        if @mode == "sell"
          return "Retourner au magasin."
        end
        return "Retourner au jeu."
      else
        return POKEMON_S::Item.descr(item_id)
      end
    end

    def item_amount
      return $pokemon_party.bag[@bag_index][@item_list.index][1]
    end

    # ----------------------------------
    # Decision
    # ----------------------------------
    def decision
      @command = Window_Command.new(120, ["Oui", "Non"], $fontsize)
      @command.x = 517
      @command.y = 480 - 6 - @drop_counter.height - @command.height
      @command.z = @z_level + 15
      loop do
        Graphics.update
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          @command.dispose
          @command = nil
          return true
        end
        if (Input.trigger?(Input::C) and @command.index == 1) or Input.trigger?(Input::B)
          @command.dispose
          @command = nil
          return false
        end
      end
    end

    # ----------------------------------
    # Texte
    # ----------------------------------
    def socket_name
      case @bag_index
      when 1
        return "Objets"
      when 2
        return "Poké-balls"
      when 3
        return "CT & CS"
      when 4
        return "Baies"
      when 5
        return "Obj.Rares"
      end
    end

    def text_window_draw(list)
      @text_window.contents.clear
      0.upto(list.length - 1) do |i|
        @text_window.contents.draw_text(0, 38*i, 241, $fhb, list[i])
      end
    end

    def dialog_window_draw(string)
    end

    def string_builder(text, limit)
      length = text.size
      full1 = false
      full2 = false
      full3 = false
      full4 = false
      string1 = ""
      string2 = ""
      string3 = ""
      string4 = ""
      word = ""
      0.upto(length) do |i|
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
