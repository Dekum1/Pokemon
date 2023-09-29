#==============================================================================
# ■ Pokemon_Shop
# Pokemon Script Project - Krosk
# 23/08/07
# Distributeur par Lizen et Damien Linux
# 28/01/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Interface du distributeur
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Shop_Buy_Distrib
    def initialize(shop_list)
      @shop_list = shop_list
      @z_level = 100
    end

    def main
      Graphics.freeze

      @background = Sprite.new
      @background.bitmap = RPG::Cache.picture(DATA_SHOP[:fond_shop])
      @background.z = @z_level + 1

      @item_list = POKEMON_S::Pokemon_Shop_List_Distrib.new(@shop_list)
      @item_list.opacity = 0
      @item_list.z = @z_level + 10
      @item_list.active = true
      @item_list.visible = true

      @item_icon = Sprite.new
      @item_icon.z = @z_level + 4
      @item_icon.x = 12
      @item_icon.y = 213
      @item_icon.zoom_x = 3
      @item_icon.zoom_y = 3
      @item_icon.bitmap = RPG::Cache.icon(item_icon)

      @money_window = Window_Base.new(3,3,147,64)
      @money_window.contents = Bitmap.new(147-32,64-32)
      @money_window.contents.font.name = $fontface
      @money_window.contents.font.size = $fontsize
      @money_window.contents.font.color = @money_window.normal_color
      @money_window.contents.draw_text(0,0, 147-32, 64-32, $pokemon_party.money.to_s + "$", 2)
      @money_window.z = @z_level + 5

      @text_window = Window_Base.new(6, 286, 273, 193)
      @text_window.opacity = 0
      @text_window.contents = Bitmap.new(241, 161)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = $fontsize
      @text_window.contents.font.color = @text_window.normal_color
      @text_window.z = @z_level + 5

      refresh

      Graphics.transition

      loop do
        Input.update
        Graphics.update
        @item_list.update
        update
        if @done
          break
        end
      end
      Graphics.freeze
      @item_icon.dispose
      @item_list.dispose
      @text_window.dispose
      @background.dispose
      @money_window.dispose
    end

    def update
      if Input.repeat?(Input::UP) or Input.repeat?(Input::DOWN)
        refresh_nolist
      end

      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        if @item_list.index == @item_list.size
          @done = true
          string = $scene.count_buy == 0 ? "Vous changez d'avis." :
                                           "Une prochaine fois peut-être ?"
          $scene.draw_text(string)
          $scene.wait_hit
          $scene = Scene_Map.new
          return
        end
        id_item = @shop_list[@item_list.index]
        if $pokemon_party.money < POKEMON_S::Item.price(id_item)
          $scene.draw_text("Vous n'avez pas assez d'argent", "pour acheter cela.")
          $scene.wait_hit
          $scene.draw_text("")
          return
        end
        $scene.call_item_amount([id_item], "buy", @z_level + 100)
        refresh_money
        return
      end

      if Input.trigger?(Input::B)
        @done = true
        return
      end
    end

    def refresh
      @item_list.refresh
      refresh_nolist
    end

    def refresh_nolist
      # Tracage de l'icone objet
      @item_icon.bitmap = RPG::Cache.icon(item_icon)
      # Texte de description
      text_window_draw(string_builder(item_descr, 15))
    end

    def refresh_money
      @money_window.contents.clear
      @money_window.contents.draw_text(0,0,147-32, 32, $pokemon_party.money.to_s + "$", 2)
    end

    def text_window_draw(list)
      @text_window.contents.clear
      0.upto(list.length - 1) do |i|
        @text_window.contents.draw_text(0, 38*i, 241, $fhb, list[i])
      end
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

    def item_id
      return @shop_list[@item_list.index]
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

          string4 += word
          word = ""
        end
      end
      if string4.length > 1
        string4 = string4[0..string4.length-2]
      end
      return [string1, string2, string3, string4]
    end
  end
end