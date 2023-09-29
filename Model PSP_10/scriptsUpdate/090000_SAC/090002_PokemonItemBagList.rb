#==============================================================================
# ■ Pokemon_Item_Bag_List
# Pokemon Script Project - Krosk
# 23/08/07
# Auteur d'origine : Néva
# 29/12/19 - Ajustement par Lizen
#-----------------------------------------------------------------------------
# Scène modifiable si vous savez ce que vous faites
#-----------------------------------------------------------------------------
# Liste des Objets du SAC
#-----------------------------------------------------------------------------
# class liste des objets dans une poche du sac
# ----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Item_Bag_List < Window_Selectable
    attr_accessor :on_switch

    def initialize(socket = 1, index = 1)
      super(287, 32, 356, 416, $fn)
      self.contents = Bitmap.new(324, 384)
      self.contents.font.name = $fontnarrow
      self.contents.font.size = $fontnarrowsize
      self.contents.font.color = normal_color
      @bag_index = socket
      @item_max = size + 1
      @on_switch = -1
      # Garde la compatibilité des saves si un bug se produit sur le sac (< PSPE 0.10)
      if index >= @item_max
        index = size
      end
      self.index = index
    end

    def refresh(socket = @bag_index)
      self.index = 0 if socket != @bag_index
      @bag_index = socket
      @item_max = size + 1
      refresh_list
    end

    def refresh_list
      self.contents.clear
      self.contents = Bitmap.new(356, $fhb*(size+1))
      self.contents.font.name = $fontnarrow
      self.contents.font.size = 40
      self.contents.font.color = normal_color
      @item_max = size + 1
      hl = $fn
      i = 0
      $pokemon_party.bag[@bag_index].each do |item|
        id = item[0]
        amount = item[1]
        if @on_switch == i
          self.contents.font.color = text_color(2) # Rouge
        end
        self.contents.draw_text(14, hl*i, 304, hl, POKEMON_S::Item.name(id))
        if POKEMON_S::Item.holdable?(id)
          self.contents.draw_text(-4, hl*i, 304, hl, "x   ", 2) #14
          self.contents.draw_text(14, hl*i, 304, hl, amount.to_s, 2)
        end
        if @on_switch == i
          self.contents.font.color = normal_color
        end
        i += 1
      end
      self.contents.draw_text(14, hl*i, 310, hl, "FERMER LE SAC")
    end

    def item_id(index = @bag_index)
      return $pokemon_party.bag[index][self.index]
    end

    def size
      return $pokemon_party.bag_list(@bag_index).length
    end
  end
end
