#==============================================================================
# ■ Pokemon_Computer_Item_Stock
# Pokemon Script Project - Krosk
# 23/08/07
    # Auteur d'origine : Néva
# 31/12/19 - Correction du changement de poche et Restructuration par Lizen
#-----------------------------------------------------------------------------
# Scène modifiable si vous savez ce que vous faites
#-----------------------------------------------------------------------------
# Interface du Sac (Stockage d'objets)
#-----------------------------------------------------------------------------
#  @bag = [ paramètre, [], [], [], [], [] ]
#  id: id objet, nombre: -1 pour objet utilisable à l'infini.
#  paramètre : optionnel
#  @bag[1] : Items, objets simples, sous la forme [id, nombre]
#  @bag[2] : Balles sous la forme [id, nombre]
#  @bag[3] : CT/CS sous la forme [id, nombre]
#  @bag[4] : Baies [id, nombre]
#  @bag[5] : Objets Rares
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Computer_Item_Stock
    # -------------------------------------------
    # Initialisation
    #    socket: cf rubrique @bag, indique la poche
    #    item_index: index du curseur
    #    mode =
    # -------------------------------------------
    def initialize(socket_index = $pokemon_party.bag_index, z_level = 100, mode = 0)
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
      @bag_sprite = Sprite.new
      @bag_sprite.bitmap = RPG::Cache.picture("bag/#{bag_name}")
      @bag_sprite.src_rect.set(0, 0, 128, 128)
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
      @drop_counter.y = 480 - 64 - 20
      @drop_counter.z = @z_level + 4
      @drop_counter.contents.font.name = $fontface
      @drop_counter.contents.font.size = $fontsize
      @drop_counter.contents.font.color = @drop_counter.normal_color
      @drop_counter.visible = false
      @drop_counter_number = 1

      list = ["STOCKER", "RETOUR"]
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
        refresh
        return
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

        # Retour
        if @item_list.index == @item_list.size
          @done = true
          # Retour au combat
          if $battle_var.in_battle
            return
          end
         $scene = POKEMON_S::Pokemon_Computer.new(2, 1)
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

        if @item_list.on_switch != -1
          @item_list.on_switch = -1
          refresh_all
          return
        end

        $game_system.se_play($data_system.cancel_se)
         $scene = POKEMON_S::Pokemon_Computer.new(2, 1)
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
        string[0] = "En stocker"
        string[1] = "combien?"
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
          $pokemon_party.ajouter_item(item_id, @drop_counter_number)
          $pokemon_party.drop_item(item_id, @drop_counter_number)
          @drop_counter.visible = false
                    @item_arrow.visible = false
          refresh_list
          text_window_draw(["stockés " + @drop_counter_number.to_s, POKEMON_S::Item.name(id_) + "."])
          @drop_counter_number = 1
          @command_window.active = false
          @command_window.visible = false
          wait(20)
          @item_list.refresh(@bag_index)
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

    # Nom des poches
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