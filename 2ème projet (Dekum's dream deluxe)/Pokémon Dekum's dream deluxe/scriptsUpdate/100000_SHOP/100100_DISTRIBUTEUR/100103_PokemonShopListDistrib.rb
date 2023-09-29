#==============================================================================
# ■ Pokemon_Shop
# Pokemon Script Project - Krosk
# 23/08/07
# Distributeur par Lizen et Damien Linux
# 28/01/2020
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Interface de la liste (distributeur)
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Shop_List_Distrib < Window_Selectable
    def initialize(shop_list)
      super(287, 32, 356, 416, $fn)
      self.contents = Bitmap.new(324, 384)
      self.contents.font.name = $fontnarrow
      self.contents.font.size = $fontnarrowsize
      self.contents.font.color = normal_color
      @shop_list = shop_list
      @item_max = size + 1
      self.index = 0
    end

    def refresh
      self.contents.clear
      self.contents = Bitmap.new(356, $fhb*(size+1))
      self.contents.font.name = $fontnarrow
      self.contents.font.size = 40
      self.contents.font.color = normal_color
      hl = $fn
      i = 0
      @shop_list.each do |id|
        self.contents.draw_text(14, hl*i, 224, hl, POKEMON_S::Item.name(id))
        string = (POKEMON_S::Item.price(id).to_s)
        self.contents.draw_text(14, hl*i, 304, hl, string + "$", 2)
        i += 1
      end
      self.contents.font.color = normal_color
      self.contents.draw_text(14, hl*i, 304, hl, "RETOUR")
    end

    def size
      return @shop_list.size
    end
  end
end