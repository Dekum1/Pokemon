#==============================================================================
# ■ Pokemon
# Pokemon Script Project - Krosk 
# 20/07/07
# 26/08/08 - révision, support des oeufs
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré et complété par Damien Linux
# 04/11/19
#-----------------------------------------------------------------------------
# Gestion individuelle
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # class Pokemon : génère l'information sur un Pokémon.
  # Méthodes sur le status du Pokémon :
  # - Gestion combat/statut
  # - Gestion de statut
  # - Gestion de soin
  #------------------------------------------------------------
  class Pokemon
    #------------------------------------------------------------
    # Gestion combat/statut
    #------------------------------------------------------------        
    def confuse_damage
      power = 40
      base_damage = Integer(((@level*2/5.0+2)*power*@atk/@dfe)/50)
      return base_damage
    end
    
    def remove_hp(amount)
      @hp -= amount
      if @hp < 0
        @hp = 0
      elsif @hp > max_hp
        @hp = max_hp
      end
    end
    
    def add_hp(amount)
      @hp += amount
      if @hp < 0
        @hp = 0
      elsif @hp > max_hp
        @hp = max_hp
      end
    end

    def dead?
      if @hp <= 0
        @hp = 0
        cure
        cure_state
        reset_stat_stage
        @ability_active = false
        @ability_token = nil
        return true
      else
        return (false or @egg)
      end
    end 
    
    def party_index
      return $pokemon_party.actors.index(self)
    end
    
    # Renvoie l'index d'un pokémon dans la partie côté ennemi
    def party_index_enemy 
      return $battle_var.enemy_party.actors.index(self)
    end
    
    #------------------------------------------------------------
    # Gestion de statut
    #------------------------------------------------------------           
    # @status:
    # 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
    # @confuse (6), @flinch (7)
    # renvoie les détails du status
    def get_status
      return @status
    end
  
    # Cure
    def cure
      @status = 0
      @status_count = 0
    end
  
    # Poison
    def poisoned?
      if @status == 1
        return true
      else
        return false
      end
    end
    
    def status_poison(forcing = false)
      if @status == 0 or forcing
        @status = 1
        return true # status imposé
      else
        return false # autre statut
      end
    end
    
    def poison_effect
      if @status == 1
        return Integer(maxhp_basis / 8.0)
      end
    end
    
    # Paralysis
    def paralysis_check
      if rand(100) < 25
        return true #lose attack chance
      else
        return false
      end
    end
    
    def status_paralyze(forcing = false)
      if @status == 0 or forcing
        @status = 2
        return true # status imposé
      else
        return false # autre statut
      end
    end
    
    def paralyzed?
      if @status == 2
        return true
      else
        return false
      end
    end
    
    # Burn
    def burn?
      if @status == 3
        return true
      else
        return false
      end
    end
    
    def burn_effect
      if @status == 3
        return @hp - Integer(@hp * 0.875)
      end
    end
    
    def status_burn(forcing = false)
      if @status == 0 or forcing
        @status = 3
        return true # status imposé
      else
        return false # autre statut
      end
    end
    
    # Sleep
    def asleep?
      if @status == 4
        return true
      else
        return false
      end
    end
    
    def status_sleep(forcing = false)
      if @status == 0 or forcing
        @status = 4
        @status_count = rand(7) + 1
        return true
      else
        return false
      end
    end
    
    def sleep_check
      @status_count -= 1
      if @status_count > 0
        return true #Dort
      else
        @status = 0
        return false #réveillé
      end
    end
    
    # Frozen
    def frozen?
      if @status == 5
        return true
      else
        return false
      end
    end
    
    def status_frozen(forcing = false)
      if @status == 0 or (forcing)
        @status = 5
        return true
      else
        return false
      end
    end
    
    def froze_check
      i = rand(100)
      if @status == 5 and i < 10 
        @status = 0
        return false #defrosted
      elsif @status == 5 and i >= 10
        return true #still frozen
      end
    end
        
    # Confuse
    def confused?
      return @confused
    end
    
    def status_confuse
      if not(@confused)
        @confused = true
        @state_count = rand(4) + 2
        return true
      end
      return false
    end
    
    def confuse_check
      if @confused and @state_count > 0
        if rand(2) > 0 
          return true # Auto damage
        end
      elsif @confused and @state_count == 0
        cure_state
        return "cured"
      end
      return false
    end
    
    def confuse_decrement
      if @confused
        @state_count -= 1
      end
    end
    
    def cure_state
      @confused = false
      @state_count = 0
    end
    
    # Flinch (peur?)
    def flinch?
      return @flinch
    end
    
    def status_flinch
      return @flinch = true
    end
    
    def flinch_check
      @flinch = false
    end
    
    # Toxic
    def toxic?
      if @status == 8
        return true
      end
      return false
    end
    
    def status_toxic(forcing = false)
      if @status == 0 or forcing
        @status = 8
        @status_count = 0
        return true
      end
      return false
    end
    
    def toxic_effect
      if @status == 8
        @status_count += 1
        return Integer(maxhp_basis / 16.0 * @status_count)
      end
    end
    
    def reset_toxic_count
      if @status == 8
        @status_count = 0
      end
    end
    
    #------------------------------------------------------------
    # Gestion de soin
    #------------------------------------------------------------       
    def refill_skill
      @skills_set.each do |skill|
        skill.refill
      end
    end
    
    def refill_skill(id, amount = 99)
      if @skills_set[id] != nil
        amount = [amount, @skills_set[id].ppmax-@skills_set[id].pp].min
        @skills_set[id].pp += amount
        return amount
      end
    end
    
    def refill_hp
      @hp = maxhp_basis
    end
    
    def refill
      refill_hp
      @skills_set.each do |skill|
        skill.refill
      end
      cure
      cure_state
    end    
    
    def kill
      @hp = 0
    end
  end
end