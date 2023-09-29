#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Objects_Util - Damien Linux
# 13/01/2020
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
  # Méthodes d'utilisation des objets
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    def attaque_plus_util
      augmentation_stat("ATK", 2, @enemy)
    end
    
    def defense_plus_util
      augmentation_stat("DFE", 2, @enemy)
    end
    
    def vitesse_plus_util
      augmentation_stat("SPD", 2, @enemy)
    end
    
    def special_plus_util
      augmentation_stat("ATS", 2, @enemy)
    end
    
    def defense_spe_plus_util
      augmentation_stat("DFS", 2, @enemy)
    end
    
    def muscle_plus_util
      @enemy.add_critical_base
    end
    
    def precision_plus_util
      augmentation_stat("ACC", 2, @enemy)
    end
    
    def defense_spec_util
      @enemy.skill_effect(:defense_spec, 5)
      draw_text("#{@enemy.given_name} est", "protégé des réductions de stats !")
      wait(40)
    end
    
    def antidote_util
      @enemy.cure
      draw_text("#{@enemy.given_name} n'est", "plus empoisonné !")
      wait(40)
    end
    
    def anti_para_util
      @enemy.cure
      draw_text("#{@enemy.given_name} n'est", "plus paralysé !")
      wait(40)
    end
    
    def antigel_util
      @enemy.cure
      draw_text("#{@enemy.given_name} n'est", "plus gelé !")
      wait(40)
    end
    
    def anti_brule_util
      @enemy.cure
      draw_text("#{@enemy.given_name} n'est", "plus brûlé !")
      wait(40)
    end
    
    def reveil_util
      @enemy.cure
      draw_text("#{@enemy.given_name} se", "réveille !")
      wait(40)
    end
    
    def soin_total_util
      @enemy.cure
      @enemy.cure_state
      draw_text("#{@enemy.given_name} n'a plus", "de problèmes de statut !")
      wait(40)
    end  
    
    def potion_util
      heal(@enemy, @enemy_sprite, @enemy_status, 20)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def eau_fraiche_util
      heal(@enemy, @enemy_sprite, @enemy_status, 30)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def soda_cool_util
      heal(@enemy, @enemy_sprite, @enemy_status, 50)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def super_potion_util
      heal(@enemy, @enemy_sprite, @enemy_status, 60)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def limonade_util
      heal(@enemy, @enemy_sprite, @enemy_status, 70)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def lait_meumeu_util
      heal(@enemy, @enemy_sprite, @enemy_status, 100)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def hyper_potion_util
      heal(@enemy, @enemy_sprite, @enemy_status, 120)
      draw_text("#{@enemy.given_name} récupère", "des PV !")
      wait(40)
    end
    
    def potion_max_util
      hp_gueris = @enemy.max_hp - @enemy.hp
      heal(@enemy, @enemy_sprite, @enemy_status, hp_gueris)
      draw_text("#{@enemy.given_name} récupère", "tous ses PV !")
      wait(40)
    end
    
    def guerison_util
      hp_gueris = @enemy.max_hp - @enemy.hp
      heal(@enemy, @enemy_sprite, @enemy_status, hp_gueris)
      @enemy.cure
      @enemy.cure_state
      draw_text("#{@enemy.given_name} est", "totalement guéri !")
      wait(40)
    end
    
    def rappel_util
      requis = @object_use[:num_rappel] != nil ? @object_use[:num_rappel] : 
                                                 nil
      compteur = 0
      $battle_var.enemy_party.actors.each do |actor|
        if actor.dead?
          compteur += 1
          # Vérifie chaque critère => Numéro à rescussiter, le ou les noms
          # et l'ID dans l'équipe
          num_valide = (requis == nil or compteur == requis)
          nom_valide = (@object_use[:pokemon] == nil or 
                        actor.name.upcase == @object_use[:pokemon] or
                       (@object_use[:pokemon].is_a?(Array) and
                        @object_use[:pokemon].include?(actor.name.upcase)))
          id_valide = (@object_use[:id_party] == nil or
                       actor.party_index_enemy == @object_use[:id_party] or
                      (@object_use[:id_party].is_a?(Array) and
                       @object_use[:id_party].include?(actor.party_index_enemy)))
          if num_valide and nom_valide and id_valide
            actor.hp = Integer(actor.max_hp / 2)
            draw_text("#{actor.given_name} n'est", "plus K.O. !")
            wait(40)
            break
          end
        end
      end
    end
    
    def rappel_max_util
      requis = @object_use[:num_rappel] != nil ? @object_use[:num_rappel] : 
                                                 nil
      compteur = 0
      $battle_var.enemy_party.actors.each do |actor|
        if actor.dead?
          compteur += 1
          # Vérifie chaque critère => Numéro à rescussiter, le ou les noms
          # et l'ID dans l'équipe
          num_valide = (requis == nil or compteur == requis)
          nom_valide = (@object_use[:pokemon] == nil or 
                        actor.name.upcase == @object_use[:pokemon] or
                       (@object_use[:pokemon].is_a?(Array) and
                        @object_use[:pokemon].include?(actor.name.upcase)))
          id_valide = (@object_use[:id_party] == nil or
                       actor.party_index_enemy == @object_use[:id_party] or
                      (@object_use[:id_party].is_a?(Array) and
                       @object_use[:id_party].include?(actor.party_index_enemy)))
          if num_valide and nom_valide and id_valide
            actor.hp = actor.max_hp
            draw_text("#{actor.given_name} n'est", "plus K.O. !")
            wait(40)
            break
          end
        end
      end
    end
    
    def cendresacree_util
      $battle_var.enemy_party.actors.each do |actor|
        if actor.dead?
          actor.hp = actor.max_hp
        end
      end
      draw_text("Tout les pokémon de l'équipe ennemie", "ne sont plus K.O. !")
      wait(40)
    end
  end
end