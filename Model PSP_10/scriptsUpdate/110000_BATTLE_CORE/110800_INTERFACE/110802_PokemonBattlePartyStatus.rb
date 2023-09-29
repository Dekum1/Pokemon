#==============================================================================
# ■ Pokemon_Battle_Party_Status
# Pokemon Script Project - Krosk 
# 26/07/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 02/11/19
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#----------------------------------------------------------------------------- 
module POKEMON_S
  #------------------------------------------------------------  
  # Fenêtre de statut de l'équipe
  #------------------------------------------------------------  
  class Pokemon_Battle_Party_Status < Window_Base
    attr_accessor :battle_order
    
    def initialize(party, order, enemy, z_level = 15)
      @enemy = enemy # True / False
      @battle_order = order
      if @enemy
        super(0-16,63-16,315+32,42+32)
      else
        super(325-16, 261-16, 315+32,42+32)
      end
      self.contents = Bitmap.new(width - 32, height - 32)
      self.opacity = 0
      self.z = z_level
      @party = party
      refresh
    end
    
    def refresh
      self.contents.clear
      src_rect = Rect.new(0, 0, 315, 42)
      if @enemy
        bitmap = RPG::Cache.picture(DATA_BATTLE[:party_status_enemy])
      else
        bitmap = RPG::Cache.picture(DATA_BATTLE[:party_status_actor])
      end
      self.contents.blt(0, 0, bitmap, src_rect, 255)
      
      src_rect = Rect.new(0, 0, 21, 21)
      if @enemy
        ball_x = 231
        coeff = -1
      else
        ball_x = 63
        coeff = 1
      end
      
      0.upto(@party.size - 1) do |i|
        bitmap = RPG::Cache.picture(DATA_BATTLE[:ball_party_status])
        if @party.actors[@battle_order[i]].dead?
          bitmap = RPG::Cache.picture(DATA_BATTLE[:ball_party_status_ko])
        end
        self.contents.blt(ball_x + coeff*30*(i), 3, bitmap, src_rect, 255)
      end
    end
    
    def reset_position
      if @enemy
        self.x = -16
      else
        self.x = 325-16
      end
      refresh
    end
  end
end