#==============================================================================
# ■ Pokemon_Computer_Item_Retiring
# Pokemon Script Project - Krosk
# 23/08/07
# Auteur d'origine : Néva
# 31/12/19 - Restructuration par Lizen
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Interface du retrait d'objets
#-----------------------------------------------------------------------------
#  @ordi = [ paramètre, [], [], [], [], [] ]
#  id: id objet, nombre: -1 pour objet utilisable à l'infini.
#  paramètre : optionnel
#  @ordi[1] : Items, objets simples, sous la forme [id, nombre]
#  @ordi[2] : Balls [id, nombre]
#  @ordi[3] : CT/CS [id, nombre]
#  @ordi[4] : Baies sous la forme [id, nombre]
#  @ordi[5] : Objets rares
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Computer_Item_Retiring
    # -------------------------------------------
    # Initialisation
    #    socket: cf rubrique @ordi, indique la poche
    #    item_index: index du curseur
    #    mode =
    # -------------------------------------------
    def initialize(socket_index = $pokemon_party.ordi_index, z_level = 100, mode = 0)
      @ordi_index = socket_index[0]
      @item_index = socket_index[1]
      @z_level = z_level
      @mode = mode
    end

    def main
      Graphics.freeze

      # Background du PC
      @background = Sprite.new
      @background.bitmap = RPG::Cache.picture(DATA_PC[:background_retire])
      @background.z = @z_level

      # Dessin des "poches"
      @ordi_sprite = Sprite.new
      @ordi_sprite.bitmap = RPG::Cache.picture(DATA_PC[:icon_sac])
      @ordi_sprite.src_rect.set(0, 0, 96, 96)
      @ordi_sprite.x = 80
      @ordi_sprite.y = 160
      @ordi_sprite.z = @z_level + 1

      # Nom de la poche
      @socket_name = Window_Base.new(341-48, 9-16, 228+32, 45+32)
      @socket_name.contents = Bitmap.new(228, 45)
      @socket_name.opacity = 0
      @socket_name.z = @z_level + 1
      @socket_name.contents.font.name = $fontface
      @socket_name.contents.font.size = 35
      @socket_name.contents.font.color = @socket_name.normal_color

      # Flèche
      @item_arrow = Sprite.new
      @item_arrow.bitmap = RPG::Cache.picture(DATA_PC[:fleche_sac])
      @item_arrow.x = 517
      @item_arrow.y = 382
      @item_arrow.z = @z_level + 5
      @item_arrow.visible = false

      # Liste des Objets
      @item_list = POKEMON_S::Pokemon_Computer_Item_List.new(@ordi_index, @item_index)
      @item_list.opacity = 0
      @item_list.z = @z_level + 1
      @item_list.active = true
      @item_list.visible = true

      # Description des Objets
      @text_window = Window_Base.new(100, 371, 457, 276)
      @text_window.opacity = 0
      @text_window.contents = Bitmap.new(425, 244)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = 35
      @text_window.contents.font.color = @text_window.white#normal_color
      @text_window.z = @z_level + 1

      # icon des Objets
      @item_icon = Sprite.new
      @item_icon.z = @z_level + 2
      @item_icon.x = 12
      @item_icon.y = 386
      @item_icon.zoom_x = 3
      @item_icon.zoom_y = 3
      @item_icon.bitmap = RPG::Cache.icon(item_icon)

      @drop_counter = Window_Base.new(0, 0, 120, 64)
      @drop_counter.contents = Bitmap.new(150-32, 32)
      @drop_counter.x = 640 - 120 - 3
      @drop_counter.y = 480 - 64 - 20
      @drop_counter.z = @z_level + 4
      @drop_counter.contents.font.name = $fontface
      @drop_counter.contents.font.size = $fontsize
      @drop_counter.contents.font.color = @drop_counter.normal_color
      @drop_counter.visible = false
      @item_arrow.visible = false
      @drop_counter_number = 1

      list = ["RETIRER", "RETOUR"]
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

      $pokemon_party.ordi_index[0] = @ordi_index
      $pokemon_party.ordi_index[1] = @item_list.index

      Graphics.freeze
      @item_list.dispose
      @text_window.dispose
      @item_icon.dispose
      @background.dispose
      @ordi_sprite.dispose
      @item_arrow.dispose
      @socket_name.dispose
      @drop_counter.dispose
    end

    def update
      if Input.repeat?(Input::DOWN) or Input.repeat?(Input::UP)
        refresh
        return
      end

      if Input.repeat?(Input::RIGHT) and @item_list.on_switch == -1
    $game_system.se_play($data_system.cursor_se)
    @ordi_index += @ordi_index == 5 ? -4 : 1
    @item_list.refresh(@ordi_index)
    refresh_all
    return
  end

  if Input.repeat?(Input::LEFT) and @item_list.on_switch == -1
    $game_system.se_play($data_system.cursor_se)
    @ordi_index += @ordi_index == 1 ? 4 : -1
    @item_list.refresh(@ordi_index)
    refresh_all
    return
  end

      if Input.trigger?(Input::C)
        # Retour
        if @item_list.index == @item_list.size
          @done = true
         $scene = POKEMON_S::Pokemon_Computer.new(2, 1) #$scene = Scene_Map.new
          return
        else
          @command_window.active = true
          refresh
          @command_window.visible = true
          return
        end
      end

      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)

        if @item_list.on_switch != -1
          @item_list.on_switch = -1
          refresh_all
          return
        end

        $game_system.se_play($data_system.cancel_se)
         $scene = POKEMON_S::Pokemon_Computer.new(2, 1) #$scene = Scene_Map.new
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

      # Icone de la poche
      case @ordi_index
          when 1 # Poche objet
            @ordi_sprite.src_rect.set(0, 0, 96, 96)
          when 2 # Poche balls
              @ordi_sprite.src_rect.set(0, 96, 96, 96)
          when 3 # Poche CT/CS
            @ordi_sprite.src_rect.set(0, 192, 96, 96)
          when 4 # Poche Baies
              @ordi_sprite.src_rect.set(0, 288, 96, 96)
          when 5 # Poche Objets Rares
               @ordi_sprite.src_rect.set(0, 384, 96, 96)
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
        string[0] = "En retirer"
        string[1] = "combien?"
      else
        string = string_builder(item_descr, 36) # 15
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
        # Stocker
        when 0
          $game_system.se_play($data_system.decision_se)
          @command_window.active = false
          @command_window.visible = false
          @drop_counter.visible = true
          @item_arrow.visible = true
          refresh
          refresh_drop_counter
          return
        # Retour (dernière option)
        when 1
          $game_system.se_play($data_system.cancel_se)
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
      @command_window.enable_item(0)
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
          $pokemon_party.add_item(item_id, @drop_counter_number)
          $pokemon_party.jeter_item(item_id, @drop_counter_number)
          @drop_counter.visible = false
          @item_arrow.visible = false
          refresh_list
          text_window_draw(["retiré(s) " + @drop_counter_number.to_s, POKEMON_S::Item.name(id_) + "."])
          @drop_counter_number = 1
          @command_window.active = false
          @command_window.visible = false
          wait(20)
          @item_list.refresh(@ordi_index)
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
      return $pokemon_party.ordi[@ordi_index][@item_list.index][0]
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
        return "Retourner au jeu."
      else
        return POKEMON_S::Item.descr(item_id)
      end
    end

    def item_amount
      return $pokemon_party.ordi[@ordi_index][@item_list.index][1]
    end

    # ----------------------------------
    # Decision
    # ----------------------------------
    def decision
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsize)
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
      case @ordi_index
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
        @text_window.contents.draw_text(0, 38*i, 400, $fhb, list[i])
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
