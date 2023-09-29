#==============================================================================
# ■ Pokemon_Shop
# Pokemon Script Project - Krosk
# 23/08/07
# Restructuré par Damien Linux
# 11/11/19
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Squelette d'un magasin
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Shop
    def initialize(shop_list)
      @shop_list = shop_list
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

      @command_window = Window_Command.new(160, ["ACHETER", "VENDRE", "QUITTER"])
      @command_window.active = false
      @command_window.visible = false
      @command_window.x = 3
      @command_window.y = 3
      @command_window.z = 5

      Graphics.transition
      draw_text("En quoi puis-je vous aider?")
      @command_window.active = true
      @command_window.visible = true

      loop do
        Graphics.update
        Input.update
        update
        if $scene != self
          break
        end
      end
      Graphics.freeze
      @command_window.dispose
      @spriteset.dispose
      @dummy.dispose
      @text_window.dispose
    end

    def update
      @command_window.update

      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        case @command_window.index
        when 0
          @command_window.visible = false
          draw_text("")
          scene = Pokemon_Shop_Buy.new(@shop_list)
          scene.main
          @command_window.visible = true
          draw_text("Que puis-je faire d'autre", "pour vous?")
          Graphics.transition
          return
        when 1
          draw_text("")
          scene = Pokemon_Item_Bag.new($pokemon_party.bag_index, 100, "sell")
          scene.main
          draw_text("Que puis-je faire d'autre", "pour vous?")
          Graphics.transition
          return
        when 2
          draw_text("A une prochaine fois !")
          wait_hit
          $scene = Scene_Map.new
          return
        end
      end

      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        draw_text("A une prochaine fois !")
        wait_hit_escape
        $scene = Scene_Map.new
        return
      end
    end

    def call_item_amount(data, mode = nil, z_level = 200)
      @counter = Window_Base.new(102,230,177,64)
      @counter.contents = Bitmap.new(@counter.width - 32, @counter.height - 32)
      @counter.contents.font.name = $fontface
      @counter.contents.font.size = $fontsize
      @counter.contents.font.color = @counter.normal_color
      @counter.visible = false
      @counter.active = false
      @counter.z = z_level + 5

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

      if @mode == "sell"
        draw_text(POKEMON_S::Item.name(@data[0]) + "?", "Combien voulez-vous en vendre?")
        wait_hit
      end
      if @mode == "buy"
        draw_text(POKEMON_S::Item.name(@data[0]) + "? Bien sûr.", "Combien en voulez-vous?")
        wait_hit
      end

      refresh_counter
      @counter.visible = true
      @counter.active = true
      @money_window.visible = true
      loop do
        Input.update
        Graphics.update
        if @counter.visible
          update_counter
        end
        if @counter_done
          draw_text("")
          break
        end
      end
      @counter_done = false
      @counter.dispose
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

    def wait_hit_escape
      Graphics.update
      Input.update
      until Input.trigger?(Input::B)
        Input.update
        Graphics.update
      end
    end

    def update_counter
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        @counter_done = true
        return
      end
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        @counter.visible = false
        confirm_call
        return
      end
      if Input.repeat?(Input::UP)
        @amount += 1
        if @mode == "sell" and @amount > @data[1]
          @amount = @data[1]
        end
        if @mode == "buy"
          until @amount*Item.price(@data[0]) <= $pokemon_party.money
            @amount -= 1
          end
        end
        refresh_counter
        return
      end
      if Input.repeat?(Input::DOWN)
        @amount -= 1
        if @amount < 1
          @amount = 1
        end
        refresh_counter
        return
      end
    end

    def confirm_call
      if @mode == "sell"
        draw_text("Je peux vous en donner ", (POKEMON_S::Item.price(@data[0])*@amount/2).to_s + "$, ça vous va?")
        if decision
          $pokemon_party.sell_item(@data[0],@amount)
          Audio.se_play("Audio/SE/006-System06")
          refresh_money
          draw_text("Obtenu " + (POKEMON_S::Item.price(@data[0])*@amount/2).to_s + "$", "pour cette vente.")
          wait_hit
          @counter_done = true
        else
          @counter_done = true
        end
      end
      if @mode == "buy"
        draw_text(POKEMON_S::Item.name(@data[0]) + "? Vous en voulez " + @amount.to_s + "?",
          "Ca fera " + (@amount*Item.price(@data[0])).to_s + "$.")
        if decision
          $pokemon_party.buy_item(@data[0], @amount)
          Audio.se_play("Audio/SE/006-System06") # Son $$$
          refresh_money
          draw_text("Vous avez acheté " + @amount.to_s + " " + POKEMON_S::Item.name(@data[0]),
            "pour " + (@amount*Item.price(@data[0])).to_s + "$." )
          wait_hit
          if POKEMON_S::Item.socket(@data[0]) == 2
            nb_honor_ball = @amount / 10
            if nb_honor_ball == 1
              draw_text("#{nb_honor_ball} #{Item.name(10)} vous est offerte en cadeau.")
              wait_hit
            elsif nb_honor_ball > 1
              draw_text("#{nb_honor_ball} #{Item.name(10)} vous sont offertes en cadeau.")
              wait_hit
            end
          end
          @counter_done = true
        else
          @counter_done = true
        end
      end
    end

    def decision
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsize)
      @command.x = 159
      @command.y = 294 - @command.height
      @command.z = @z_level + 30
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

    def refresh_counter
      @counter.contents.clear
      @counter.contents.draw_text(0,0,177-32,32,"x " + @amount.to_s, 0)
      if @mode == "buy"
        @counter.contents.draw_text(0,0,177-32,32,(POKEMON_S::Item.price(@data[0])*@amount).to_s + "$", 2)
      elsif @mode == "sell"
        @counter.contents.draw_text(0,0,177-32,32,(POKEMON_S::Item.price(@data[0])*@amount/2).to_s + "$", 2)
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
  end
end
