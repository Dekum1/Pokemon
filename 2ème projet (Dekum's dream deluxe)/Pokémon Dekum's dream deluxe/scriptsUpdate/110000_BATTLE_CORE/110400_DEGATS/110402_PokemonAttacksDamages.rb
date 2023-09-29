#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attack_Damages - Damien Linux
# 04/01/2020
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
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
  # Pokemon_Battle_Core
  # Calcul des damages et damages spécifiques :
  # - Calcul des dégâts en fonction des effets
  # - Dégâts en tenant compte d'effets sur l'ennemi
  # - Dégâts en tenant compte des malus à cause d'effets adverses
  # - Dégâts en tenant compte des bonus côté acteur
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Calcul des dégâts en fonction des effets
    #------------------------------------------------------------
    def auto_ko_damages(hash)
      hash[:dfe] = hash[:dfe] / 2
      return hash
    end

    def devoreve_damages(hash)
      a = @user.hp * 48.0 / @user.max_hp
      if a >= 33
        hash[:base_damage] = 20
      elsif a >= 17
        hash[:base_damage] = 40
      elsif a >= 10
        hash[:base_damage] = 80
      elsif a >= 5
        hash[:base_damage] = 100
      elsif a >= 2
        hash[:base_damage] = 150
      else
        hash[:base_damage] = 200
      end
      return hash
    end
    alias degats_faible_damages devoreve_damages

    def triple_pied_damages(hash)
      if @user.effect_list.include?(:triple_pied)
        index = @user.effect_list.index(:triple_pied)
        hash[:base_damage] += 10 * @user.effect[index][2]
      end
      return hash
    end
    
    def multi_tour_puissance_damages(hash)
      # Bonus cumulatif
      if @user.effect_list.include?(:multi_tour_puissance)
        index = @user.effect_list.index(:multi_tour_puissance)
        hash[:base_damage] *= (5-@user.effect[index][1])**2
      end
      # Defense Curl/Boul'Armure bonus
      if @user.effect_list.include?(:boul_armure)
        hash[:base_damage] *= 2
      end
      return hash
    end

    def effets_augmentes_tour_damages(hash)
      if @user.effect_list.include?(:effets_augmentes_tour)
        index = @user.effect_list.index(:effets_augmentes_tour)
        hash[:multiplier] = - @user.effect[index][1]
        if hash[:multiplier] < 5
          hash[:base_damage] *= hash[:multiplier]**2
        elsif hash[:multiplier] >= 5
          hash[:base_damage] *= 5**2
        end
      end
      return hash
    end

    def retour_damages(hash)
      hash[:base_damage] = @user.loyalty * 10 / 25
      return hash
    end

    def frustration_damages(hash)
      hash[:base_damage] = (255 - @user.loyalty) * 10 / 25
      return hash
    end

    def ampleur_damages(hash)
      a = rand(100)
      if a < 5
        hash[:data] = 4
        hash[:base_damage] = 10
      elsif a < 15
        hash[:data] = 5
        hash[:base_damage] = 30
      elsif a < 35
        hash[:data] = 6
        hash[:base_damage] = 50
      elsif a < 65
        hash[:data] = 7
        hash[:base_damage] = 70
      elsif a < 85
        hash[:data] = 8
        hash[:base_damage] = 90
      elsif a < 95
        hash[:data] = 9
        hash[:base_damage] = 110
      else
        hash[:data] = 10
        hash[:base_damage] = 150
      end
      return hash
    end

    def relache_damages(hash)
      index = @user == @actor ? 0 : 1
      if @stockage != nil and @stockage[index] > 0
        hash[:base_damage] = 0
        case @stockage[index]
        when 1
          hash[:base_damage] = 100
        when 2
          hash[:base_damage] = 200
        when 3
          hash[:base_damage] = 300
        end
      end
      return hash
    end

    def degats_si_pv_damages(hash)
      hash[:base_damage] = [1, @user.hp * 150 / @user.max_hp].max
      return hash
    end

    def poids_degats_damages(hash)
      string = Pokemon_Info.weight(@target.id)
      weight = string[0..string.length-2].to_f
      # CAS DE LA CAPACITE SPECIALE : Heavy Metal et Light Metal
      if @target.ability_symbol == :heavy_metal
        weight *= 2
      elsif @target.ability_symbol == :light_metal
        weight = Integer(weight / 2)
      end
      if weight < 10
        hash[:base_damage] = 20
      elsif weight < 25
        hash[:base_damage] = 40
      elsif weight < 50
        hash[:base_damage] = 60
      elsif weight < 100
        hash[:base_damage] = 80
      elsif weight < 200
        hash[:base_damage] = 100
      else
        hash[:base_damage] = 120
      end
      return hash
    end

    def tacle_damages(hash)
      string = Pokemon_Info.weight(@user.id)
      weight_user = string[0..string.length-2].to_f
      string = Pokemon_Info.weight(@target.id)
      weight_target = string[0..string.length-2].to_f
      # CAS DE LA CAPACITE SPECIALE : Heavy Metal et Light Metal
      if @target.ability_symbol == :heavy_metal
        weight *= 2
      elsif @target.ability_symbol == :light_metal
        weight = Integer(weight / 2)
      end
      if weight_target <= weight_user * 0.2
        hash[:base_damage] = 120
      elsif weight_target <= weight_user * 0.25
        hash[:base_damage] = 100
      elsif weight_target <= weight_user * 0.33
        hash[:base_damage] = 80
      elsif weight_target <= weight_user * 0.5
        hash[:base_damage] = 60
      else
        hash[:base_damage] = 40
      end
      return hash
    end

    def reveil_force_damages(hash)
      if @target.asleep?
        hash[:base_damage] *= 2
        loop do
          @target.sleep_check 
          break if not @target.sleep_check
        end
        draw_text("#{@target.given_name}","se réveille de force!")
      end
      return hash
    end

    def gyroballe_damages(hash)
      hash[:base_damage] = 25 * (@user.spd / @target.spd)
      return hash
    end

    def don_naturel_damages(hash)
      item_berry = true
      # Type
      if [205, 221, 237, 364].include?(@user.item_hold)
        hash[:skill_type] = 2    # Feu
      elsif [206, 222, 238, 365].include?(@user.item_hold)
        hash[:skill_type] = 3    # Eau
      elsif [207, 223, 239, 366].include?(@user.item_hold)
        hash[:skill_type] = 4    # Électrik
      elsif [208, 224, 240, 367].include?(@user.item_hold)
        hash[:skill_type] = 5    # Plante
      elsif [209, 225, 241, 368].include?(@user.item_hold)  
        hash[:skill_type] = 6    # Glace
      elsif [210, 226, 242, 369].include?(@user.item_hold)
        hash[:skill_type] = 7    # Combat
      elsif [211, 227, 243, 370].include?(@user.item_hold)
        hash[:skill_type] = 8    # Poison
      elsif [212, 228, 244, 371].include?(@user.item_hold)
        hash[:skill_type] = 9    # Sol
      elsif [213, 229, 245, 372].include?(@user.item_hold)
        hash[:skill_type] = 10   # Vol
      elsif [214, 230, 246, 373].include?(@user.item_hold)
        hash[:skill_type] = 11   # Psy
      elsif [215, 231, 247, 374].include?(@user.item_hold)
        hash[:skill_type] = 12   # Insecte
      elsif [216, 232, 375, 381].include?(@user.item_hold)
        hash[:skill_type] = 13   # Roche
      elsif [217, 233, 376, 382].include?(@user.item_hold)
        hash[:skill_type] = 14   # Spectre
      elsif [218, 234, 377, 383].include?(@user.item_hold)
        hash[:skill_type] = 15   # Dragon
      elsif [219, 235, 379, 384, 385].include?(@user.item_hold) 
        hash[:skill_type] = 16   # Ténèbres
      elsif [220, 236, 378].include?(@user.item_hold)
        hash[:skill_type] = 17   # Acier
      elsif [380, 386].include?(@user.item_hold)
        hash[:skill_type] = 18   # Fée
      else
        hash[:skill_type] = 1 # Normal
        item_berry = @user.item_hold != 363 # Baie Zalis
      end
      # Puissance
      list_1 = [205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 
                218, 219, 220, 363, 364, 365, 366, 367, 368, 369, 370, 371, 372, 
                373, 374, 375, 376, 377, 378, 379, 380]
      list_2 = [221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 
                233, 234, 235, 236]
      list_3 = [237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 381, 382, 
                383, 384, 385, 386]
      if list_1.include?(@user.item_hold) # Baies de niveau 1
        hash[:base_damage] = 80
      elsif list_2.include?(@user.item_hold) # Baies de niveau 2
        hash[:base_damage] = 90
      elsif list_3.include?(@user.item_hold) # Baies de niveau 3
        hash[:base_damage] = 100
      else
        hash[:base_damage] = 50
      end
      # Enlève l'objet si le joueur a une baie
      if item_berry then @user.item_hold = 0 end
      return hash
    end

    def fulmifer_damages(hash)
      if hash[:target_last_skill]
        hash[:base_damage] = hash[:target_last_skill].power * 1.5
      end
      return hash
    end

    def represailles_damages(hash)
      if (@user == @enemy and @strike_first) or (@user == @actor and 
                                                 not @strike_first)
        if hash[:user_last_taken_damages] > 0
          hash[:base_damage] *= 2
        end
      end
      return hash
    end

    def assurance_damages(hash)
      if (@user == @enemy and @strike_first) or (@user == @actor and 
                                                 not @strike_first)
        if hash[:target_last_skill] != nil and 
           [:charge_blesse, :degats, 
            :cognobidon].include?(hash[:target_last_skill].effect_symbol)
          hash[:base_damage] *= 2
        end
      end
      return hash
    end

    def degommage_damages(hash)
      if [74, 82, 85, 92, 93, 96, 97, 100, 102, 109, 
          (205..252).to_a, 331].include?(@user.item_hold)
        hash[:base_damage] = 10
      elsif [(13..73).to_a, (75..80).to_a, 84, 87, (89..91).to_a, 98, 
             99, 101, 103, (106..108).to_a, (110..112).to_a, (114..116).to_a, 
             (177..181).to_a, (184..191).to_a].include?(@user.item_hold)
        hash[:base_damage] = 30
      elsif @user.item_hold == 117
        hash[:base_damage] = 40
      elsif [83, 331].include?(@user.item_hold)
        hash[:base_damage] = 50
      elsif [94, 182].include?(@user.item_hold)
        hash[:base_damage] = 60
      elsif [81, 87].include?(@user.item_hold)
        hash[:base_damage] = 70
      elsif [95, 192].include?(@user.item_hold)
        hash[:base_damage] = 80
      elsif [113, 183, (261..276).to_a].include?(@user.item_hold)
        hash[:base_damage] = 90
      elsif @user.item_hold == 86
        hash[:base_damage] = 100
      else
        hash[:base_damage] = 1
      end
      if @user.item_hold == 81 # Pics Toxic
        status_check(@target, 1)
        @target_status.refresh
      elsif @user.item_hold == 362 # Orbe Toxique
        status_check(@target, 8)
        @target_status.refresh
      elsif @user.item_hold == 361 # Orbe Flamme
        status_check(@target, 3)
        @target_status.refresh
      elsif @user.item_hold == 116 # Balle Lumière
        status_check(@target, 2)
        @target_status.refresh
      elsif [98, 202].include?(@user.item_hold)  # Roche Royale / Croc Rasoir
        status_check(@target, 7)
        @target_status.refresh
      elsif @user.item_hold == 93 # Herbe Blanche 
        @target.reset_stat_stage(true)
      elsif @user.item_hold == 96 # Herbe Mental
        if @target.effect_list.include?(:attraction)
          @target.effect.delete(:attraction) 
        end
      end
      @user.item_hold = 0
      return hash
    end

    def atout_damages(hash)
      case @user_skill.pp
      when 1
        hash[:base_damage] = 200
      when 2
        hash[:base_damage] = 80
      when 3
        hash[:base_damage] = 60
      when 4
        hash[:base_damage] = 50
      else
        hash[:base_damage] = 40
      end
      return hash
    end
    
    def boule_elek_damages(hash)
      vitesse = @target.spd.to_f/@user.spd.to_f
      if vitesse > 1
        hash[:base_damage] = 40
      elsif vitesse > 0.5
        hash[:base_damage] = 60
      elsif vitesse > 0.33
        hash[:base_damage] = 80
      elsif vitesse > 0.25
        hash[:base_damage] = 120
      else
        hash[:base_damage] = 150
      end
      return hash
    end

    def degats_plus_de_pv_damages(hash)
      hash[:base_damage] = Integer(110.0 * (@target.hp.to_f/@target.max_hp.to_f))
      return hash
    end

    def punition_damages(hash)
      augment_bonus = 0
      if @target.atk_stage > 0 then augment_bonus += @target.atk_stage end
      if @target.dfe_stage > 0 then augment_bonus += @target.dfe_stage end
      if @target.spd_stage > 0 then augment_bonus += @target.spd_stage end
      if @target.eva_stage > 0 then augment_bonus += @target.eva_stage end
      if @target.acc_stage > 0 then augment_bonus += @target.acc_stage end
      if @target.dfs_stage > 0 then augment_bonus += @target.dfs_stage end
      if @target.ats_stage > 0 then augment_bonus += @target.ats_stage end
      hash[:base_damage] = 60 + 20 * augment_bonus
      if hash[:base_damage] > 200 then hash[:base_damage] = 200 end
      return hash
    end

    def jugement_damages(hash)
      # Type
      if ((326..343).to_a).include?(@user.item_hold)
        hash[:skill_type] = @user.item_hold - 324
      else
        hash[:skill_type] = 1    # Normal
      end
      return hash
    end

    #------------------------------------------------------------  
    # Dégâts en tenant compte d'effets sur l'ennemi
    #------------------------------------------------------------
    def adaptation_damages_enemy(hash)
       index = @target.effect_list.index(:adaptation)
       hash[:hash[:target_type1]] = @target.effect[index][2]
       hash[:hash[:target_type2]] = 0
       return hash
    end

    def tunnel_damages_enemy(hash)
      if [:ampleur, :seisme].include?(@user_skill.effect_symbol)
        hash[:base_damage] *= 2
      end
      return hash
    end
    
    def vol_damages_enemy(hash)
      if [:tornade, :fatal_foudre, :ouragan].include?(@user_skill.effect_symbol)
        hash[:base_damage] *= 2
      end
      return hash
    end

    def rebond_damages_enemy(hash)
      if [:tornade, :fatal_foudre, :ouragan].include?(@user_skill.effect_symbol)
        hash[:base_damage] *= 2
      end
      return hash
    end

    def plongee_damages_enemy(hash)
      if @user_skill.id == 15
        hash[:base_damage] *= 2
      end
      return hash
    end
    
    #------------------------------------------------------------  
    # Dégâts en tenant compte des malus à cause d'effets adverses
    #------------------------------------------------------------
    def mur_lumiere_damages_malus_enemy(hash)
      if @user_skill.special and not(hash[:critical_hit]) and 
         @user.ability_symbol != :infiltration
        hash[:multiplier] *= 0.5
      end
      return hash
    end
 
    def protection_damages_malus_enemy(hash)
      if @user_skill.physical and not(hash[:critical_hit]) and 
         @user.ability_symbol != :infiltration
        hash[:multiplier] *= 0.5
      end
      return hash
    end 

    def lilliput_damages_malus_enemy(hash)
      if @user_skill.effect_symbol == :apeurer_attaque
        hash[:multiplier] *= 2
      end
      return hash
    end

    def empeche_esquive_damages_malus_enemy(hash)
      list = [hash[:target_type1], hash[:target_type2]]
      if [1, 7].include?(hash[:skill_type]) and list.include?(14)
        hash[:skill_type] = 0
      end
      return hash
    end

    def chargeur_damages_malus_enemy(hash)
      if hash[:skill_type] == 4
        hash[:multiplier] *= 2
      end
      return hash
    end

    def lance_boue_damages_malus_enemy(hash)
      if hash[:skill_type] == 4
        hash[:multiplier] *= 0.5
      end
      return hash
    end

    def tourniquet_damages_malus_enemy(hash)
      if hash[:skill_type] == 2
        hash[:multiplier] *= 0.5
      end
      return hash
    end
    
    #------------------------------------------------------------  
    # Dégâts en tenant compte des bonus côté acteur
    #------------------------------------------------------------
    def facade_damages_bonus(hash)
      if [1,2,3].include?(@user.status)
        hash[:multiplier] *= 2
      end
      return hash
    end

    def stimulant_damages_bonus(hash)
      if @target.status == 2
        hash[:multiplier] *= 2
      end
      return hash
    end
  end
end