#==============================================================================
# ■ Pokemon_Computer_Item_List
# Pokemon Script Project - Krosk
# 23/08/07
# Auteur d'origine : Néva
# 29/12/19 - Ajustement par Lizen
#-----------------------------------------------------------------------------
# Scène modifiable si vous savez ce que vous faites
#-----------------------------------------------------------------------------
# Liste des Objets du PC
#-----------------------------------------------------------------------------
# class liste des objets dans une poche du PC (socket)
# ----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Computer_Item_List < Window_Selectable
    attr_accessor :on_switch

    def initialize(socket = 1, index = 1)
      super(252, 69, 355, 293, $fn)
      self.contents = Bitmap.new(323, 267)
      self.contents.font.name = $fontnarrow
      self.contents.font.size = $fontnarrowsize
      self.contents.font.color = normal_color
      @ordi_index = socket
      @item_max = size + 1
      @on_switch = -1
      self.index = index
    end

    def refresh(socket = @ordi_index)
      self.index = 0
      @ordi_index = socket
      @item_max = size + 1
      refresh_list
    end
  
    def refresh_list
      self.contents.clear
      self.contents = Bitmap.new(356, $fhb*(size+1))
      self.contents.font.name = $fontnarrow
      self.contents.font.size = 40
      self.contents.font.color = normal_color
      hl = $fn
      i = 0
      $pokemon_party.ordi[@ordi_index].each do |item|
        id = item[0]
        amount = item[1]
        if @on_switch == i
          self.contents.font.color = text_color(2) # Rouge
        end
        self.contents.draw_text(14, hl*i, 304, hl, POKEMON_S::Item.name(id))
        if POKEMON_S::Item.holdable?(id)
          self.contents.draw_text(-4, hl*i, 304, hl, "x   ", 2)
          self.contents.draw_text(14, hl*i, 304, hl, amount.to_s, 2)
        end
        if @on_switch == i
          self.contents.font.color = normal_color
        end
        i += 1
      end
      self.contents.draw_text(14, hl*i, 310, hl, "DECONNEXION")
    end

    def item_id(index = @ordi_index)
      return $pokemon_party.ordi[index][self.index]
    end

    def size
      return $pokemon_party.ordi_list(@ordi_index).length
    end
  end
end

