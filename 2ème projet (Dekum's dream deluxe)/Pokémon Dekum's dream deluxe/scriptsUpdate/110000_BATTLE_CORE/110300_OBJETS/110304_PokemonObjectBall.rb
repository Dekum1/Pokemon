#==============================================================================
# ■ Pokemon_Object_Ball
# Pokemon Script Project - Palbolsky 
# 11/10/2020
#==============================================================================
# Gestion des balls
# - Accès aux données des balls
# - Taux de capture des balls
# - Calcul de la capture d'un Pokémon
#==============================================================================

module POKEMON_S 
  ID_PKMN_EVOLVE_MOON_STONE = [29, 30, 31, 32, 33, 34, 35, 36, 39, 40, 173, 174, 300, 301, 517, 518]
  ID_PKMN_ULTRA_BEASTS = []     

  class Pokemon_Object_Ball

    def self.name(id_ball)
      return POKEMON_S::Item.name(id_ball)
    end 

    def self.sprite_name(id_ball)
      if HASH_BALL[id_ball][:sprite] == nil       
        raise "The sprite of the ball is not defined. Please fix this."
      end
      return HASH_BALL[id_ball][:sprite]
    end  
    
    def self.open_sprite_name(id_ball)
      if HASH_BALL[id_ball][:sprite] == nil       
        raise "The sprite of the ball is not defined. Please fix this."
      end  
      sprite_name = HASH_BALL[id_ball][:sprite]
      return sprite_name.gsub("ball", "ballopen")
    end

    def self.color(id_ball)
      if HASH_BALL[id_ball][:color].nil?      
        raise "The color of the ball is not defined. Please fix this."
      end 
      return HASH_BALL[id_ball][:color]
    end

    # Exemple utilisation : Pokemon_Object_Ball.get_id(:love_ball)
    # Retournera l'id
    def self.get_id(ball_name)     
      HASH_BALL.each { |hb|        
        if hb[1][:ball] == ball_name
          return hb[0]
        end
      }          
      raise "The ball '#{ball_name}' doesn't exist!"
    end

    def addition_rate(id_ball, actor, enemy)
      if HASH_BALL[id_ball][:ball] == :masse_ball
        method_name = "rate_#{HASH_BALL[id_ball][:ball]}"
        ball_rate = methods.include?(method_name) ? send(method_name, actor, enemy) : 0
        return ball_rate
      end      
      return 0
    end

    # Retourne le nombre d'oscillation ; si égal à 4, le Pokémon est capturé
    def catch_pokemon(id_ball, actor, enemy, safari_infos = nil)
      if enemy.rareness == 0
        return 0
      end
      status_multiplier = 1
      if enemy.asleep? or enemy.frozen?
        status_multiplier = 2
      elsif enemy.burn? or enemy.paralyzed? or enemy.poisoned? or enemy.toxic?
        status_multiplier = 1.5
      end
      multiplier = enemy.rareness * multiplier_rate(id_ball, actor, enemy)          
      maxhp = enemy.maxhp_basis
      hp = enemy.hp
      calcul = ((maxhp * 3 - hp * 2) * multiplier).to_f / (maxhp * 3).to_f
      catch_rate = Integer(calcul * status_multiplier + addition_rate(id_ball, actor, enemy)) # qu'est ce qui se passe si le taux est négatif ?          
      if catch_rate > 0
        division = Math.sqrt(Math.sqrt(16711680 / catch_rate.to_f))
        catch_value = Integer(1048560 / division)
      else
        catch_rate = 0
      end
      list = [rand(65536), rand(65536), rand(65536), rand(65536)]
      if safari_infos
        0.upto(3) do |i|
          list[i] -= (safari_infos[0] * 3277)
          list[i] += (safari_infos[1] * 656)
        end
      end
      oscillation_number = 4
      list.each do |i|
        oscillation_number -= i > catch_value ? 1 : 0
      end
      return oscillation_number         
    end

    def multiplier_rate(id_ball, actor, enemy)           
      if HASH_BALL[id_ball][:ball] == :masse_ball
        return 1     
      end     
      method_name = "rate_#{HASH_BALL[id_ball][:ball]}"
      ball_rate = methods.include?(method_name) ? send(method_name, actor, enemy) : 1
      return ball_rate
    end

    def effect_ball(id_ball, enemy)
      method_name = "effect_#{HASH_BALL[id_ball][:ball]}"
      if methods.include?(method_name)
        return send(method_name, enemy) 
      else
        return enemy
      end
    end

    #------------------------------------------------------------    
    # Rate Balls                          
    #------------------------------------------------------------   
    def rate_master_ball(actor, enemy)
      return 255
    end
    alias rate_reve_ball rate_master_ball
    alias rate_parc_ball rate_master_ball

    def rate_hyper_ball(actor, enemy)
      return 2
    end

    def rate_super_ball(actor, enemy)
      return 1.5
    end 
    alias rate_safari_ball rate_super_ball

    def rate_poke_ball(actor, enemy)
      return 1
    end
    alias rate_soin_ball rate_poke_ball
    alias rate_honor_ball rate_poke_ball
    alias rate_copain_ball rate_poke_ball
    alias rate_luxe_ball rate_poke_ball

    def rate_filet_ball(actor, enemy)
      if enemy.type_water? or enemy.type_insect?
        return 3.5 
      end       
      return 1
    end

    def rate_faiblo_ball(actor, enemy)
      if enemy.level > 30
        return 1
      elsif enemy.level >= 20
        return 2
      end 
      return 3        
    end

    def rate_scuba_ball(actor, enemy)
      if $game_switches[SURF_PECHE]
        return 3.5
      end
      return 1
    end

    def rate_bis_ball(actor, enemy)
      if $pokedex.captured?(enemy.id)
        return 3.5
      end
      return 1   
    end

    def rate_chrono_ball(actor, enemy)
      if ($battle_var.round >= 10)
        return 4
      end
      return (1 + ($battle_var.round * 1229) / 4096).to_i
    end

    def rate_sombre_ball(actor, enemy)
      if $game_switches[GROTTE] or $game_variables[TS_NIGHTDAY] == :night
        return 3
      end
      return 1        
    end

    def rate_rapide_ball(actor, enemy)
      if ID_PKMN_ULTRA_BEASTS.include?(enemy.id)
        return 0.1
      end
      if $battle_var.round == 1
        return 5
      end
      return 1
    end

    def rate_memoire_ball(actor, enemy)
      return 0
    end  
    
    def rate_speed_ball(actor, enemy)
      if enemy.base_spd >= 100
        return 4
      end
      return 1
    end

    def rate_appat_ball(actor, enemy)
      if $game_switches[SURF_PECHE]
        return 3
      end
      return 1
    end

    def rate_niveau_ball(actor, enemy)
      if actor.level >= (enemy.level * 4)
        return 8
      elsif actor.level >= (enemy.level * 2)
        return 4
      elsif actor.level > enemy.level
        return 2
      end
      return 1          
    end

    # Attention : les taux pour cette ball s'additionne !
    def rate_masse_ball(actor, enemy)
      weight = Pokemon_Info.weight(enemy.id, enemy.form).to_i
      if weight < 100
        return -20
      elsif weight >= 100 and weight < 200
        return 0
      elsif weight >= 200 and weight < 300
        return 20
      end
      return 30          
    end

    def rate_love_ball(actor, enemy)
      if (actor.id == enemy.id) and (actor.gender * enemy.gender == 2)
        return 8
      end          
      return 1          
    end

    def rate_lune_ball(actor, enemy)
      if ID_PKMN_EVOLVE_MOON_STONE.include?(enemy.id)
        return 4
      end
      return 1            
    end  

    def rate_compet_ball(actor, enemy)
      return 1.5
    end

    def rate_ultra_ball(actor, enemy)
      if ID_PKMN_ULTRA_BEASTS.include?(enemy.id)
        return 5   
      end       
      return 0.1
    end

    #------------------------------------------------------------    
    # Effects Balls                        
    #------------------------------------------------------------   
    def effect_soin_ball(enemy)
      enemy.hp = enemy.max_hp
      return enemy
    end

    def effect_luxe_ball(enemy)
      enemy.rate_loyalty *= 2
      return enemy
    end

    def effect_copain_ball(enemy)
      enemy.loyalty = 200
      return enemy
    end
  end
end
