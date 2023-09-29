#==============================================================================
# ■ Pokemon_Shop
# Pokemon Script Project - Krosk
# 23/08/07
# Distributeur par Lizen et Damien Linux
# 28/01/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Squelette du distributeur
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Shop_Distrib
    attr_accessor :count_buy
    
    def initialize(shop_list)
      @shop_list = shop_list
      @count_buy = 0
      shop_list_conversion
    end

    def shop_list_conversion
      0.upto(@shop_list.length - 1) do |i|
        if @shop_list[i].type == String
          @shop_list[i] = POKEMON_S::Item.id(@shop_list[i])
        end
      end
    end

    def main
      @spriteset = Spriteset_Map.new

      @text_window = Window_Base.new(21, 342, 597, 126)
      @text_window.contents = Bitmap.new(597 - 32, 126 - 32)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = $fontsize
      @text_window.contents.font.color = @text_window.normal_color
      @text_window.opacity = 0
      @text_window.visible = false
      @text_window.z = 300

      @dummy = Sprite.new
      unless $message_dummy
        @dummy.bitmap = RPG::Cache.picture(MSG)
      else
        @dummy.bitmap = RPG::Cache.picture($message_dummy)
      end
      @dummy.y = 336
      @dummy.visible = false
      @dummy.z = 290

      Graphics.transition
      draw_text("Un distributeur !", "Que choisir?")

      loop do
        Graphics.update
        Input.update
        update
        if $scene != self
          break
        end
      end
      Graphics.freeze
      @spriteset.dispose
      @dummy.dispose
      @text_window.dispose
    end

    def update


      if Input.trigger?(Input::C)
        draw_text("")
        scene = Pokemon_Shop_Buy_Distrib.new(@shop_list)
        scene.main
      end

      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
        Graphics.transition
        string = @count_buy == 0 ? "Vous changez d'avis." : 
                                   "Une prochaine fois peut-être ? !"
        draw_text(string)
        wait_hit
        return
      end
    end

    def call_item_amount(data, mode = nil, z_level = 200)
      @money_window = Window_Base.new(3,3,147,64)
      @money_window.contents = Bitmap.new(147-32,64-32)
      @money_window.contents.font.name = $fontface
      @money_window.contents.font.size = $fontsize
      @money_window.contents.font.color = @money_window.normal_color
      @money_window.contents.draw_text(0,0, 147-32, 64-32, $pokemon_party.money.to_s + "$", 2)
      @money_window.visible = false
      @money_window.z = z_level + 5

      @text_window.z = z_level + 10
      @dummy.z = z_level + 8
      @z_level = z_level
      @mode = mode
      @data = data

      @amount = 1

      draw_text("Voulez-vous acheter cet objet ?")
      @money_window.visible = true
      loop do
        Input.update
        Graphics.update
        if draw_choice
          $game_system.se_play($data_system.decision_se)
          confirm_call
          draw_text("")
          break
        else
          draw_text("")
          break
        end
      end
      @money_window.dispose
    end

    def wait_hit
      Graphics.update
      Input.update
      until Input.trigger?(Input::C)
        Input.update
        Graphics.update
      end
    end

    def confirm_call
      @count_buy += 1
      if @mode == "buy"
          $pokemon_party.buy_item(@data[0], @amount)
          Audio.se_play("Audio/SE/006-System06") # Son $$$
          refresh_money
          draw_text(Player.name + " obtient", POKEMON_S::Item.name(@data[0]))
          wait_hit
      end
    end

    def refresh_money
      @money_window.contents.clear
      @money_window.contents.draw_text(0,0,147-32, 32, $pokemon_party.money.to_s + "$", 2)
    end


    def draw_text(string = "", string2 = "")
      if string == ""
        @text_window.contents.clear
        @dummy.visible = false
        @text_window.visible = false
      else
        @text_window.contents.clear
        @text_window.visible = true
        @dummy.visible = true
        @text_window.contents.draw_text(0,0,597-32,32, string)
        @text_window.contents.draw_text(0,32,597-32,32, string2)
      end
    end

    def draw_choice
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsizebig)
      @command.z = @text_window.z + 1
      @command.x = 515
      @command.y = 348
      loop do
        Graphics.update
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          @command.dispose
          @command = nil
          Input.update
          return true
        end
        if Input.trigger?(Input::C) and @command.index == 1
          @command.dispose
          @command = nil
          Input.update
          return false
        end
      end
    end
  end
end