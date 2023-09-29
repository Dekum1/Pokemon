#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Pre_Attack - Damien Linux
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
  # - Squelette
  # - Attaques de type "copie"
  # - Attaques provoquant un saut
  # - Condition de touche
  # - Condition de foirage
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Squelette
    #------------------------------------------------------------
    def pre_miss_attack
      # miss: indicateur que l'attaque touche l'adversaire mais inefficace
      #       "Mais cela échoue!" => true == échec
      # Attaques de types copies
      
      # Si la cible est K.O., l'attaque est impossible à réaliser donc
      # le tour est sauté
      # Cas où le pokémon est intouchable
      if @target.dead?
        wait(10)
        draw_text("Il n'y aucun pokémon", "à attaquer...")
        wait(40)
        @jumper_end = true
        return false
      end
      
      miss = execution_return(@user_skill.effect_symbol, "copie", false)
      # Effet d'avant attaque - animation
      miss = (miss or execution_return(@user_skill.effect_symbol, "pre", false))
       # Vérifie que l'attaque n'est pas bloquée
      miss = (miss or not @user_skill.enabled?)
      return miss
    end
    
    #------------------------------------------------------------ 
    # Attaques de type "copie"
    #------------------------------------------------------------
    def mimique_copie
      unlist = [:copie, :mimique, :morphing, :metronome, :gribouille, 
                :blabla_dodo, :malediction, :picots, :danse_folle, :assistance,
                :boost, :attaque_prevu, :mitra_poing, :force_nature, :imitation]
      miss = (@target_last_skill == nil or @user_last_taken_damage == 0)
      if not miss
        miss = (@target_last_skill.target == 10 or 
                unlist.include?(@target_last_skill.effect))
        if not miss
          @user_skill = @target_last_skill.clone
          @user_skill.enable
          @user_skill.refill
        end
      end
      return miss
    end

    def copie_copie
      list = [102, 166, 118, 165]
      @user.skills_set.each do |skill|
        list.push(skill.id)
      end
      # Conditions de validité: ne copie pas la luste ni lorsqu'il y a Morphing
      miss = (@target_last_skill == nil)
      if not miss
        miss = (list.include?(@target_last_skill.id) or 
                @user.effect_list.include?(:morphing))
      end
      return miss
    end

    def metronome_copie
      list = [:metronome, :copie, :riposte, :voile_miroir, 
              :encaissement_attaque, :tenacite, :prlvt_destin, :blabla_dodo, 
              :pique_objet, :par_ici, :saisie, :coup_main, :echange_objet,
              :mitra_poing]
      until not(list.include?(@user_skill.effect_symbol) or 
            @user_skill.id == 165) # Tant que le skill copié est interdit
        @user_skill = POKEMON_S::Skill.new(rand($data_skills_pokemon.length)+1)
      end
      return false
    end

    def blabla_dodo_copie
      miss = (not @user.asleep?)
      if not miss
        list = []
        0.upto(@user.skills_set.size - 1) { |i| list.push(i) }
        list.shuffle!
        
        copied_skill = @user.skills_set[list.shift]
        tab = [:patience, :blabla_dodo, :assistance, :mimique, :copie, 
               :mitra_poing, :brouhaha, :coupe_vent, :pique, :coud_krane, 
               :lance_soleil]
        while !(copied_skill.usable? and not copied_skill.effect == tab)
          copied_skill = @user.skills_set[list.shift]
        end
        draw_text("#{@user.given_name} utilise","#{copied_skill.name} !")
        @user_skill = copied_skill
      end
      return miss
    end
  
    def assistance_copie
      no = [:metronome, :copie, :riposte, :voile_miroir, :encaissement_attaque,
            :tenacite, :prlvt_destin, :blabla_dodo, :pique_objet, :par_ici, 
            :saisie, :coup_main, :echange_objet, :mitra_poing, :assistance,
            :tunnel, :plongee, :vol]
      list = []
      copied_skill = @user_skill
      if @user == @actor
        @party.actors.each do |pokemon|
          pokemon.skills_set.each { |skill| list.push(skill.clone) }
        end
        list.shuffle!
        copied_skill = list.shift
        # Jusqu'a que le skill copié est interdit
        until not(no.include?(copied_skill)) 
          copied_skill = list.shift
        end
      elsif @user == @target
        @user.skills_set.each { |skill| list.push(skill.clone) }
        list.shuffle!
        copied_skill = list.shift
        # Jusqu'à que le skill copié est interdit
        until not(no.include?(copied_skill)) 
          copied_skill = list.shift
        end
      end
      draw_text("#{@user.given_name} utilise","#{copied_skill.name} !")
      wait(40)
      @user_skill = copied_skill
      return false
    end
    
    #------------------------------------------------------------ 
    # Attaques provoquant un saut
    #------------------------------------------------------------
    def auto_ko_pre
      if @target.ability_symbol == :moiteur and 
         not (@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empêche l'auto-destruction.")
        wait(40)
        @jumper_end = true # PROVOQUE UN SAUT
      end
      if @user.ability_symbol == :moiteur and 
         not (@user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine))
        draw_text("#{@user.ability_name} de #{@user.given_name}", 
                  "empêche l'auto-destruction.")
        wait(40)
        @jumper_end = true # PROVOQUE UN SAUT
      end
      return false
    end

    def attraction_pre
      gender_target = @target.get_illusion != nil ? @target.get_gender : 
                                                    @target.gender
      gender_user = @user.get_illusion != nil ? @user.get_gender : @user.gender
      miss = (@target.effect_list.include?(:attraction) or  (gender_target + gender_user) != 3)
      # Benet / Oblivious (ab)
      if (@target.ability_symbol == :benet and 
         not (@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))) and not miss
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "l'empêche d'être amoureux.")
        wait(40)
        @jumper_end = true # PROVOQUE UN SAUT
      end
      return miss
    end

    def teleport_pre
      # Arena Trap / Piege (ab) // Run away / Fuite (ab)
      if @target.ability_symbol == :piege_sable and 
        (@user.ability_symbol != :fuite or 
         @user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine)) and 
         not(@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empêche la fuite.")
        wait(40)
        @jumper_end = true # PROVOQUE UN SAUT
      end
      # Magnet Pull / Magnepiege (ab) // Run away / Fuite (ab)
      if @target.ability_symbol == :magnepiege and 
        (@user.ability_symbol != :fuite or 
         @user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine)) and 
         not(@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empêche la fuite.")
        wait(40)
        @jumper_end = true # PROVOQUE UN SAUT
      end
      # Shadow Tag / Marque ombre (ab) // Run away / Fuite (ab)
      if @target.ability_symbol == :marque_ombre and 
        (@user.ability_symbol != :fuite or 
         @user.effect_list.include?(:suc_digestif) or 
         @user.effect_list.include?(:soucigraine)) and 
         not(@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empêche la fuite.")
        wait(40)
        @jumper_end = true # PROVOQUE UN SAUT
      end
    end
    
    #------------------------------------------------------------ 
    # Condition de touche
    #------------------------------------------------------------
    def sans_echec_pre
      @hit = true 
      return false
    end 
    
    def attaque_combo_pre
      number = rand(8)
      case number
      when 0
        @multi_hit = 5
      when 1
        @multi_hit = 4
      end
      if [2,3,4].include?(number)
        @multi_hit = 3
      elsif [5,6,7].include?(number)
        @multi_hit = 2
      end
      @total_hit = @multi_hit
      return false
    end

    def double_frappe_pre
      @multi_hit = 2
      @total_hit = 2
      return false
    end

    def double_dard_pre
      @multi_hit = 2
      @total_hit = 2
      @hit = true
      return false
    end

    def triple_pied_pre
      @multi_hit = 3
      @total_hit = 3
      return true
    end

    def fatal_foudre_pre
      if $battle_var.rain?
        @hit = true
      end
      return false
    end
    
    #------------------------------------------------------------ 
    # Condition de foirage
    #------------------------------------------------------------
    def adaptation_pre
       # Si il existe un skill qui est valide
      list = []
      @user.skills_set.each do |skill|
        list.push(skill.type)
      end
      list.delete(@user.type1)
      list.delete(@user.type2)
      list.delete(0) # Curse / Malédiction
      return list.length == 0
    end
    
    def devoreve_pre
      return (not @target.asleep?)
    end

    def guerison_pre
      return @user.hp == @user.max_hp
    end

    def mur_lumiere_pre
      return @user.effect_list.include?(:mur_lumiere)
    end

    def brume_pre
      return (@user.effect_list.include?(:brume) and 
              @user.ability_symbol != :infiltration)
    end

    def morphing_pre
      party = @target == @actor ? @party : $battle_var.enemy_party
      return (@target.effect_list.include?(:morphing) or 
              @target.ability_symbol == :illusion and
              party.size > 1 or @user.effect_list.include?(:morphing))
    end

    def protection_pre
      return @user.effect_list.include?(:protection)
    end 

    def vampigraine_pre
      return ([@target.type1, @target.type2].include?(5) or
               @target.effect_list.include?(:vampigraine))
    end

    def entrave_pre
      # Skill invalide ou non possédé
      miss = (@target_last_skill == nil or 
              @target.skills_set.index(@target_last_skill) == nil)
      if not miss
        miss = (@target.effect_list.include?(:entrave) or 
                @target_last_skill.pp == 0)
      end
      return miss
    end

    def riposte_pre
      miss = (@target_last_skill == nil or @user_last_taken_damage == 0 or
              @strike_first)
      if not miss
        miss = (not @target_last_skill.physical)
      end
      return miss
    end

    def encore_pre
      miss = (@target_last_skill == nil)
      if not miss
        miss = (@target_last_skill.pp == 0 or 
                not @target.skills_set.include?(@target_last_skill) or
                [165, 227, 119].include?(@target_last_skill.id))
        if not miss
          miss = (@target.effect_list.include?(:encore) or 
                  @user.effect_list.include?(:encore))
        end
      end
      return miss
    end

    def ronflement_pre
      return (not @user.asleep?)
    end

    def gribouille_pre
      return (@target_last_skill == nil or 
              [166, 165].include?(@target_last_skill.id) or
              @user.skills.include?(@target_last_skill.id))
    end

    def depit_pre
      miss = (@target_last_skill == nil)
      if not miss
        miss = (@target_last_skill.pp <= 1 or 
                @target.skills_set.include?(@target_last_skill)) 
      end
      return miss
    end

    def empeche_fuite_pre
      return @target.effect_list.include?(:empeche_fuite)
    end 

    def cauchemard_pre
      return (not @target.asleep? or 
              @target.effect_list.include?(:cauchemard))
    end

    def malediction_pre
      return @target.effect_list.include?(:malediction)
    end
    
    def encaissement_attaque_pre
      if @user.effect_list.include?(:encaissement_attaque)
        index = @user.effect_list.index(:encaissement_attaque)
        used = @user.effect[index][2] + 1
        rate = rand(2**16)
        return (rate > ((2**16) / used))
      end
      return false
    end
    
    def picots_pre
      # @picot[0] => L'acteur positionne le piège sur l'ennemie jusqu'à 3 fois
      # @picot[1] => L'ennemie positionne le piège sur l'acteur jusqu' 3 fois
      @picot ||= [0, 0]
      index = @user == @actor ? 0 : 1
      miss = (@picot[index] >= 3)
      if not miss
        @picot[index] += 1
        @list_piege[index].push(@picot)
      end
      return miss
    end

    def tenacite_pre
      if @user.effect_list.include?(:tenacite)
        index = @user.effect_list.index(:tenacite)
        used = @user.effect[index][1] + 1
        if (rand(2**16) > ((2**16) / used))
          @user.effect.delete_at(index)
          return true # Echec
        end
      end
      return false
    end

    def rune_protect_pre
       return @user.effect_list.include?(:rune_protect)
    end

    def cognobidon_pre
      return (@user.hp <= (@user.max_hp / 2) or @user.atk_stage >= 6)
    end

    def voile_miroir_pre
      return (not @target_last_skill.special or @user_last_taken_damage == 0)
    end

    def bluff_pre
      return (@precedent != nil or @user.round > 1)
    end

    def relache_pre
      index = @user == @actor ? 0 : 1
      return (@stockage == nil or @stockage[index] == 0)
    end

    def avale_pre
      index = @user == @actor ? 0 : 1
      return (@stockage == nil or @stockage[index] == 0)
    end

    def tourmente_pre
      index = @target.skills_set.index(@target_last_skill)
      return index == nil
    end

    def mitra_poing_pre
      if @user_last_taken_damage != 0 and 
         @user.effect_list.include?(:mitra_poing)
        index = @user.effect_list.index(:mitra_poing)
        @user.effect.delete_at(index)
        return true
      end #else
      # Si n'échoue pas et n'inclut pas Mitra-Poing alors se concentre
      if not @user.effect_list.include?(:mitra_poing)
        wait(10)
        draw_text("#{@user.given_name} se concentre", "au maximum !")
        wait(40)
        @user.skill_effect(:mitra_poing)
        @jumper_end = true
      else
        index = @user.effect_list.index(:mitra_poing)
        @user.effect.delete_at(index)
      end
      return false
    end

    def echange_objet_pre
      return (@user.item_hold == 0 and @target.item_hold == 0)
    end

    def voeu_pre
      return @user.effect_list.include?(:voeu)
    end

    def racines_pre
      return @user.effect_list.include?(:racines)
    end

    def casse_brique_pre
      if @hit
        @target.effect.delete(:protection)
        @target.effect.delete(:mur_lumiere)
      end
      return false
    end

    def baillement_pre
      return (@target.status != 0 or 
              @target.effect_list.include?(:rune_protect))
    end

    def saisie_pre
      # Echec : Saisie a lieu en dernier ou switch
      miss = (@precedent != nil or @actor_action == 2)
      if not miss
        @target.skill_effect(:saisie, 1)
      end
      return miss
    end

    def lance_boue_pre
      return @user.effect_list.include?(:lance_boue)
    end

    def tourniquet_pre
      return @user.effect_list.include?(:tourniquet)
    end

    def oeil_miracle_pre
      @target.eva_stage=(0)
      draw_text("#{@user.given_name} sait", "où est #{@target.given_name} !")
      @target.skill_effect(:oeil_miracle)
      return false
    end

    def voeu_soin_pre
      miss = ($pokemon_party.number_alive == 1)
      if not miss
        @user.skill_effect(:voeu_soin)
        rec_damage = @user.hp
        self_damage(@user, @user_sprite, @user_status, rec_damage)
        draw_text("#{@user.given_name}", "se sacrifie pour son allié !")
        wait(40)
      end
      return miss
    end

    def vent_arriere_pre
      return @user.effect_list.include?(:vent_arriere)
    end

    def acupression_pre
      random_raise(@user)
    end

    def fulmifer_pre
      return (@strike_first or @user_last_taken_damage == 0)
    end

    def embargo_pre
      return @target.effect_list.include?(:embargo)
    end

    def degommage_pre
      list = [0..12, 176, 193..204, 253..260, 277..329, 332..350]
      return (@user.item_hold ==  list or 
             (@user.item_hold == [261..276] and @user.id == 493))
    end

    def echange_psy_pre
      miss = (@target.status != 0)
      if not miss
        if @user.poisoned?
          status_check(@target, 1)
        elsif @user.paralyzed?
          status_check(@target, 2)
        elsif @user.burn?
          status_check(@target, 3)
        elsif @user.asleep?
          status_check(@target, 4)
        elsif @user.frozen?
          status_check(@target, 5)
        elsif @user.confused?
          status_check(@target, 6)
        elsif @user.toxic?
          status_check(@target, 8)
        else
          miss = true
        end
        @target_status.refresh
      end
      return miss
    end

    def moi_dabord_pre
      actor_user = true
      if @user != @enemy
        @target_skill = @enemy_skill
        actor_user = false
      else 
        @target_skill = @actor_skill
      end
      miss = (not @strike_first or @target_skill.power == 0)
      if not miss
        @me_first = true
        if actor_user
          @target_skill = @actor_skill
          attack_action(@enemy, @enemy_skill, @actor)
        else
          @actor_skill = @enemy_skill
          attack_action(@actor, @actor_skill, @enemy)
        end
      end
      return miss
    end

    def photocopie_pre
      miss = (@target_last_skill == nil)
      if not miss
        @user_skill = @target_last_skill.clone
        if @user_skill.target == 10
          @target = @user
        end
        @user_skill.enable
        @user_skill.refill
      end
      return miss
    end

    def dernierecour_pre
      miss = false
      @user.skills_set.each do |skill|
        miss = (skill.pp == skill.ppmax and skill.name != "DERNIERECOUR")
        if miss
          break
        end
      end
      return miss
    end

    def soucigraine_pre
      return @target.effect_list.include?(:soucigraine)
    end
    
    def coup_bas_pre
      if @user != @actor
        miss = (not @strike_first or @actor_skill == nil or 
                     @actor_skill.power == 0)
      else
        miss = (not @strike_first or @enemy_skill == nil or 
                     @enemy_skill.power == 0)
      end
      return miss
    end
    
    def pics_toxik_pre
      # @picot_toxik[0] => L'acteur positionne le piège sur l'ennemie 
      # jusqu'à 2 fois
      # @picot_toxik[1] => L'ennemie positionne le piège sur l'acteur 
      # jusqu' 2 fois
      @picot_toxik ||= [0, 0]
      index = @user == @actor ? 0 : 1
      miss = (@picot_toxik[index] >= 2)
      if not miss
        @picot_toxik[index] += 1
        @list_piege[index].push(@picot_toxik)
      end
      return miss
    end

    def anneau_hydro_pre
      return @user.effect_list.include?(:anneau_hydro)
    end

    def vol_magnetik_pre
      return @user.effect_list.include?(:vol_magnetik)
    end

    def anti_brume_pre
      index = @target == @target ? 1 : 0
      # Désactivation des pièges (acteur et ennemie)
      @list_piege[index].each do |piege|
        suppression_effets_tour(@user, piege)
        @list_piege[index].delete(piege)
      end
      index = index == 1 ? 0 : 1
      @list_piege[index].each do |piege|
        suppression_effets_tour(@target, piege)
        @list_piege[index].delete(piege)
      end
      [:protection, :mur_lumiere, :brume, :rune_protect].each do |effect|
        if @target.effect_list.include?(effect)
          @target.effect.delete(effect)
        end
      end
      reduction_stat("EVA", -1, @target, @user)
      return false
    end

    def distorsion_pre
      miss = (@user.effect_list.include?(:distorsion))
      if not miss
        @user.skill_effect(:distorsion, 6)
      end
    end
      
    def seduction_pre
      return ((@target.gender + @user.gender) != 3)
    end
    
    def piege_de_roc_pre
      # @piege_de_roc_actif[0] => L'acteur positionne le piège sur l'ennemie
      # @piege_de_roc_actif[1] => L'ennemie positionne le piège sur l'acteur
      @piege_de_roc_actif ||= [0, 0]
      index = @user == @actor ? 0 : 1
      miss = (@piege_de_roc_actif[index] != 0)
      if not miss
        @piege_de_roc_actif[index] = 1
        @list_piege[index].push(@piege_de_roc_actif)
      end
      return miss
    end
    
    def repos_pre
      return (@user.hp == @user.max_hp and @user.ability_symbol != :insomnia and
              @user.ability_symbol != :esprit_vital)
    end

    def changement_force_pre
      dead_counter = 0
      $battle_var.enemy_party.actors.each do |enemy|
        dead_counter += 1 if enemy.dead?
      end
      return ((@target != @actor and dead_counter == ($battle_var.enemy_party.actors.size - 1)) or
                  (@target != @enemy and dead_counter == (@party.actors.size - 1)))
    end
    
    def para_spore_pre
      # Ineficace sur les types électriques et plantes
      @jumper_end = (@target.type_electric? or @target.type_grass? or 
                     @target.ability_symbol == :envelocape)
      if @jumper_end
        draw_text("Ca n'a aucun effet...")
        wait(40)
      end
      return false
    end
    
    def poudre_toxik_pre
      # Ineficace sur les types acier et poison
      @jumper_end = (@target.type_steel? or @target.type_poison? or 
                     @target.ability_symbol == :envelocape)
      if @jumper_end
        draw_text("Ca n'a aucun effet...")
        wait(40)
      end
      return false
    end
    
    def poudre_dodo_pre
      # Contact + dommages + 10% chance # force?
      @jumper_end = (@target.type_grass? or@target.ability_symbol == :envelocape)
      if @jumper_end
        draw_text("Ca n'a aucun effet...")
        wait(40)
      end
      return false
    end
    
    def cage_eclair_pre
      @jumper_end = (@target.type_electric? or @target.type_ground?) 
      # Ineficace sur les types électriques et sol
      if @jumper_end
        draw_text("Ca n'a aucun effet...")
        wait(40)
      end
      return false
    end
    
    def prescience_pre
      return (@user.effect_list.include?(:prescience) or @user.effect_list.include?(:carnareket))
    end
    alias carnareket_pre prescience_pre
  end
end