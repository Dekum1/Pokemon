#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Objects_Verif - Damien Linux
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
  # Méthodes de vérification de l'utilisation des objets par l'IA
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    def objet_plus_verif(type, i)
      # STAT = modification de stat requise avant utilisation
      # [-6, -5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5, 6 ou 12]
      # NOM => Le nom du pokémon sur lequel l'objet doit être utilisé
      condition = (type != "Hash" or
                   @objects[i]["STAT"] == nil or 
                   @objects[i]["STAT"] == stat_object(@enemy, @objects[i]))
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def antidote_verif(type, i)
      condition = (@enemy.poisoned? or @enemy.toxic)
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def anti_para_verif(type, i)
      condition = @enemy.paralyzed?
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def antigel_verif(type, i)
      condition = @enemy.frozen?
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def anti_brule_verif(type, i)
      condition = @enemy.burn?
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def reveil_verif(type, i)
      condition = @enemy.asleep?
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def soin_total_verif(type, i)
      # STATUS => Status que le pokémon doit avoir pour utiliser l'objet
      if type == :hash
        condition = (@objects[i]["STATUS"] == nil or 
                     @objects[i]["STATUS"] == check_status(@enemy) or
                    (@objects[i]["STATUS"].is_a?(Array) and
                     @objects[i]["STATUS"].include?(check_status(@enemy))))
      end
      if type != :hash or @objects[i]["STATUS"] == nil
        condition = (@enemy.poisoned? or @enemy.toxic? or
                     @enemy.paralyzed? or @enemy.frozen? or
                     @enemy.burn? or @enemy.asleep? or
                     @enemy.confused?)
      end
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def guerison_pv_verif(type, i)
      if type == :hash
        # PV => Nombre de PV brut restant au maximum avant utilisation
        # COEFPV => Pourcentage de PV restant par rapport au PV max avant
        # utilisation
        condition = ((@objects[i]["PV"] == nil or
                      @objects[i]["PV"] > @enemy.hp) and
                     (@objects[i]["COEFPV"] == nil or
                      @enemy.hp < Integer(@enemy.max_hp * @objects[i]["COEFPV"])) and
                     (@objects[i]["STATUS"] == nil or 
                      @objects[i]["STATUS"] == check_status(@enemy) or
                     (@objects[i]["STATUS"].is_a?(Array) and
                      @objects[i]["STATUS"].include?(check_status(@enemy)))))
        if @objects[i]["PV"] == nil and @objects[i]["COEFPV"] == nil
          condition = (condition and @enemy.hp < @enemy.max_hp * 0.25)
        end
      else
        condition = @enemy.hp < @enemy.max_hp * 0.25
      end
      return utilisation_general(@enemy, type, i, condition)
    end
    
    def rappel_ko_verif(type, i)
      compteur = 0
      requis = 0
      num = nil
      pokemon = @enemy
      if type == :hash
        # NBKO => Correspond au nombre de Pokémon K.O.
        if @objects[i]["NBKO"] != nil
          requis = @objects[i]["NBKO"]
        end
        # NBKO => Correspond au numéro du pokémon K.O. 
        # Exemple : Si Dracaufeu est K.O. puis Carabaffe K.O.
        # alors : Dracaufeu sera le numéro 0 et Carabaffe le numéro 1
        # Si NUMKO = 2, alors ce sera à Carabaffe d'être sauvée
        if @objects[i]["NUMKO"] != nil and requis < @objects[i]["NUMKO"]
          requis = @objects[i]["NUMKO"]
          num = @objects[i]["NUMKO"]
        elsif @objects[i]["NUMKO"] != nil
          num = @objects[i]["NUMKO"]
        end
        # COEFKO => Correspond au coefficient de l'équipe à devoir
        # être K.O.
        party_enemy = $battle_var.enemy_party
        if @objects[i]["COEFKO"] != nil and 
            requis < Integer(party_enemy.size * @objects[i]["COEFKO"])
            requis = Integer(party_enemy.size * @objects[i]["COEFKO"])
        end
      end
      criteres_valide = compteur_valide = false
      $battle_var.enemy_party.actors.each do |actor|
        # Si rien est précisé : par défaut la boucle est quittée
        # au premier acteur K.O.
        if actor.dead?
          compteur += 1
          # Vérifie que le nombre de pokémon K.O. minimal est correcte
          compteur_valide = compteur >= requis
          
          # Vérifie chaque critère => Numéro à ressusciter, le ou les noms
          # et l'ID dans l'équipe
          num_valide = (num == nil or compteur == num)
          nom_valide = (@objects[i]["NOM"] == nil or
                        actor.name.upcase == @objects[i]["NOM"] or
                       (@objects[i]["NOM"].is_a?(Array) and
                        @objects[i]["NOM"].include?(actor.name.upcase)))
          id_valide = (@objects[i]["ID"] == nil or
                       actor.party_index_enemy == @objects[i]["ID"] or
                      (@objects[i]["ID"].is_a?(Array) and
                       @objects[i]["ID"].include?(actor.party_index_enemy)))
          # Enregistre le premier pokémon répondant aux critères
          if not criteres_valide and num_valide and nom_valide and
            id_valide
            criteres_valide = true
            pokemon = actor
          end
          # Valide si : nombre minimal K.O. atteint et critères vérifiés
          if compteur_valide and criteres_valide
            break
          end
        end
      end
      # PV et COEFPV correspondent à l'ennemi en jeu
      condition = ((compteur_valide and criteres_valide) and 
                   (@objects[i]["PV"] == nil or
                    @objects[i]["PV"] > @enemy.hp) and
                   (@objects[i]["COEFPV"] == nil or
                    @enemy.hp < @enemy.max_hp * @objects[i]["COEFPV"])
                  )
      return utilisation_general(pokemon, type, i, condition)
    end
  end
end