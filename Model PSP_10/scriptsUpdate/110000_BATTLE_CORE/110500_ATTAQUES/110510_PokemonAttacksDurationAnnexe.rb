#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attacks_Duration - Damien Linux
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
  # - Modificateur d'effets sur la durée
  #------------------------------------------------------------
  # La mention "_ko" après "_annexe" signifie que l'effet
  # a lieu même si l'adversaire est K.O.
  # pensez à rajouter "_ko" pour les attaques qui peuvent avoir
  # lieu sans la présence de l'adversaire sur le terrain
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Modificateur d'effets sur la durée
    #------------------------------------------------------------
    def adaptation_annexe_ko
      list = []
      0.upto(@user.skills_set.length - 1) { |i| list.push(i) }
      list.shuffle!
      
      chosen_type = @user.skills_set[list.pop].type
      until chosen_type != 0 and 
        not([@user.type1, @user.type2].include?(chosen_type))
        chosen_type = @user.skills_set[list.pop].type
      end
      @user.skill_effect(:adaptation, -1, chosen_type)
      string = type_string(chosen_type) + "!"
      draw_text("#{@user.given_name} est", "maintenant de type " + string)
      wait(40)
    end
    
    def picots_annexe_ko
      draw_text("#{@user.given_name} pose des", "picots vers l'ennemi !")
      wait(40)  
    end
    
    def pics_toxik_annexe_ko
      draw_text("#{@user.given_name} pose des", "pics empoisonnés vers l'ennemi !")
      wait(40)
    end
    
    def piege_de_roc_annexe_ko
      draw_text("Des pierres pointues lévitent", "autour de l'équipe ennemie !")
      wait(40)   
    end

    def mur_lumiere_annexe_ko
      @target.skill_effect(:mur_lumiere, 5)
      draw_text("#{@user.given_name}", "est protégé !")
      wait(40)
    end

    def ligotement_annexe
      if not(@target.effect_list.include?(:ligotement))
        turn = rand(4) + 3
        @target.skill_effect(:ligotement, turn)
        draw_text("#{@target.given_name} est", "piégé par #{@user_skill.name} !")
        wait(40)
      end
    end

    def brume_annexe_ko
      @user.skill_effect(:brume, 5)
      draw_text("#{@user.given_name} s'entoure", "de brume !")
      wait(40)
    end

    def puissance_annexe_ko
      @user.skill_effect(:puissance)
      draw_text("#{@user.given_name}", "se gonfle !")
      wait(40)
    end

    def morphing_annexe
      morphing(@user, @target)
      draw_text("#{@user.given_name}", "se métamorphose !")
      wait(40)
    end

    def protection_annexe_ko
      @target.skill_effect(:protection, 5)
      draw_text("#{@user.given_name}", "est protégé !")
      wait(40)
    end 

    def frenesie_annexe_ko
      if not(@user.effect_list.include?(:frenesie))
        @user.skill_effect(:frenesie, -1, 0)
      end
    end

    def copie_annexe
      cloned_skill = @target_last_skill.clone
      cloned_skill.define_ppmax(5)
      cloned_skill.refill
      @user.skill_effect(:copie, -1, [@user_skill.clone, cloned_skill])
      index = @user.skills_set.index(@user_skill)
      @user.skills_set[index] = cloned_skill
      draw_text("#{@user.given_name} copie", cloned_skill.name+" !")
      wait(40)
    end

    def vampigraine_annexe
      @target.skill_effect(:vampigraine)
      draw_text("#{@target.given_name}", "est infecté !")
      wait(40)
    end

    def trempette_annexe_ko
      draw_text("Mais rien ne se passe...")
      wait(40)
    end

    def entrave_annexe
      index = @target.skills_set.index(@target_last_skill)
      if index != nil
        @target.skill_effect(:entrave, 4, index)
        @target.skills_set[index].disable
        draw_text(@target.skills_set[index].name+" est bloqué !")
        wait(40)
      end
    end

    def encore_annexe
      index = @target.skills_set.index(@target_last_skill)
      @target.skill_effect(:encore, rand(4) + 3, index)
    end

    def reussite_sur_annexe
      @user.skill_effect(:reussite_sur, 2)
      draw_text("#{@user.given_name} cible #{@target.given_name} !")
      wait(40)
    end

    def gribouille_annexe
      index = @user.skills_set.index(@user_last_skill)
      @user.skills_set[index] = @target_last_skill
      draw_text("#{@user.given_name} a copié", @target_last_skill.name+" !")
      wait(40)
    end

    def prlvt_destin_annexe
      @user.skill_effect(:prlvt_destin, 2)
      draw_text("#{@user.given_name} lie son" , "destin.")
      wait(40)
    end

    def depit_annexe
      amount = rand(4)+2
      string1 = " a perdu #{amount.to_s} PP !"
      draw_text(target_last_used.name, string1)
      wait(40)
      target_last_used.pp -= amount
    end

    def pique_objet_annexe
      if @target.ability_symbol == :glue and 
        not (@target.effect_list.include?(:suc_digestif) or 
        @target.effect_list.include?(:soucigraine))
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empêche le vol d'objet !")
        wait(40)
      elsif @user.item_hold == 0 and @target.item_hold != 0
        @target.save_item = @target.item_hold
        @user.item_hold = @target.item_hold
        @target.item_hold = 0
        draw_text("#{@user.given_name} vole ", "#{@user.item_name} !")
          wait(40)
      end
    end

    def empeche_fuite_annexe
      @target.skill_effect(:empeche_fuite)
      draw_text("#{@target.given_name}", "ne peut plus fuir !")
      wait(40)
    end 

    def cauchemard_annexe
      @target.skill_effect(:cauchemard)
      draw_text("#{@target.given_name} fait des" , "cauchemars !")
      wait(40)
    end

    def encaissement_attaque_annexe
      if @user.effect_list.include?(:encaissement_attaque)
        index = @user.effect_list.index(:encaissement_attaque)
        effect = @user.effect[index]
        effect[1] = 2
        effect[2] += 1
      else
        @user.skill_effect(:encaissement_attaque, 2, 1)
      end
      draw_text("#{@user.given_name}", "se protège !")
      wait(40)
    end

    def empeche_esquive_annexe
      @target.skill_effect(:empeche_esquive, -1)
      draw_text("#{@user.given_name} identifie ", "#{@target.given_name}.")
      wait(40)
    end

    def requiem_annexe
      if not(@user.effect_list.include?(:requiem))
        @user.skill_effect(:requiem, 4)
      end
      if not(@target.effect_list.include?(:requiem))
        @target.skill_effect(:requiem, 4)
      end
      draw_text("Une chanson déprimante.")
      wait(40)
    end

    def tenacite_annexe
      if @user.effect_list.include?(:tenacite)
        index = @user.effect_list.index(:tenacite)
        effect = @user.effect[index]
        effect[1] = 2
      else
        @user.skill_effect(:tenacite, 2)
      end
      draw_text("#{@user.given_name} se prépare à", "encaisser les coups !")
      wait(40)
    end

    def multi_tour_puissance_annexe_ko
      if not(@user.effect_list.include?(:multi_tour_puissance))
        @user.skill_effect(:multi_tour_puissance, 5, 5)
      elsif @damage > 0 
        index = @user.effect_list.index(:multi_tour_puissance)
        @user.effect[index][2] -= 1
      elsif @damage == 0
        index = @user.effect_list.index(:multi_tour_puissance)
        @user.effect.delete_at(index)
      end
    end

    def effets_augmentes_tour_annexe_ko
      if not(@user.effect_list.include?(:effets_augmentes_tour))
        @user.skill_effect(:effets_augmentes_tour, -1, -1)
      elsif @damage > 0
        index = @user.effect_list.index(:effets_augmentes_tour)
        @user.effect[index][2] -= 1
      end
    end
    
    def attraction_annexe
      # N'est pas affecté si a Bénêt
      if @target.ability_symbol != :benet
        @target.skill_effect(:attraction)
        draw_text("#{@target.given_name} tombe amoureux", "de #{@user.given_name}"+" !")
        wait(40)
      else
        draw_text("Ça n'affecte pas #{@target.given_name} !")
        wait(40)
      end
    end

    def rune_protect_annexe_ko
      @target.skill_effect(:rune_protect, 5)
      draw_text("#{@target.given_name}", "est protégé !")
      wait(40)
    end

    def ampleur_annexe_ko
      draw_text("Séisme de magnitude...", "#{@action_atk}!")
      wait(40)
    end
    
    def brouhaha_annexe_ko
      turn = rand(3)+3
      @user.skill_effect(:brouhaha, turn)
      draw_text("#{@user.given_name}", "fait un BROUHAHA !")
      wait(40)
    end

    def stockage_annexe_ko
      # @stockage[0] => acteur
      # @stockage[1] => ennemi
      index = @user == @actor ? 0 : 1
       @stockage ||= [0, 0] # Initialisation
      @stockage[index] = @stockage[index] == 3 ? 1 : @stockage[index] + 1
      draw_text("#{@user.given_name} utilise la", 
                "capacité stockage #{@stockage[index]} fois !")
      wait(40)
      augmentation_stat("DFE", 1, @target, @user)
      augmentation_stat("DFS", 1, @target, @user)
    end

    def relache_annexe
      index = @user == @actor ? 0 : 1
      if @stockage != nil and @stockage[index] > 0
        reduction_stat("DFE", -@stockage[index], @user)
        reduction_stat("DFS", -@stockage[index], @user)
        draw_text("Les effets accumulés par", 
                  "#{@user.given_name} se dissipent !")
        @stockage[index] = 0
        wait(40)
      end
    end

    def avale_annexe_ko
      index = @user == @actor ? 0 : 1
      if @stockage != nil and @stockage[index] > 0
        bonus = 0
        case @stockage[index]
        when 1
          bonus = @user.max_hp / 4
        when 2
          bonus = @user.max_hp / 2
        when 3
          bonus = @user.max_hp
        end
        heal(@user, @user_sprite, @user_status, bonus)
        draw_text("#{@user.given_name} récupère des PV !")
        wait(40)
        reduction_stat("DFE", -@stockage[index], @user)
        reduction_stat("DFS", -@stockage[index], @user)
        @stockage[index] = 0
        draw_text("Les effets accumulés par", 
                  "#{@user.given_name} se dissipent !")
        wait(40)
      end
    end

    def tourmente_annexe
      index = @target.skills_set.index(@target_last_skill)
      @target.skill_effect(:tourmente, -1, index)
      @target.skills_set[index].disable
      draw_text("#{@target.given_name}", "est tourmenté !")
      wait(40)
    end

    def flatterie_annexe
      augmentation_stat("ATS", 2, @target, @user)
      status_check(@target, 6)
      @target_status.refresh
    end

    def chargeur_annexe_ko
      if @user.effect_list.include?(:chargeur)
        index = @user.effect_list.index(:chargeur)
        @user.effect.delete_at(index)
      end
      @user.skill_effect(:chargeur, 2)
      draw_text("#{@user.given_name}", "est chargé !")
      wait(40)
    end

    def provoc_annexe
      # N'est pas affecté si a Bénêt
      if @target.ability_symbol != :benet
        @target.skill_effect(:provoc, 3)
        draw_text("#{@target.given_name} cède à la", "provocation !")
        wait(40)
      else
        draw_text("Ça n'affecte pas #{@target.given_name} !")
        wait(40)
      end
      index = @target.effect_list.index(:provoc)
      @target.skills_set.each do |skill|
        if skill.status and @target.effect[index][1] > 0 and skill.enabled?
          skill.disable
        end
      end
    end

    def echange_objet_annexe
      if @target.ability_symbol == :glue and 
         not (@target.effect_list.include?(:suc_digestif) or 
         @target.effect_list.include?(:soucigraine))
        draw_text("#{@target.ability_name} de #{@target.given_name}", 
                  "empêche le vol d'objet !")
        wait(40)
      elsif not(@user.item_hold == 0 and @target.item_hold == 0)
        @target.save_item = @target.item_hold
        @user.save_item = @user.item_hold
        hold = @user.item_hold
        @user.item_hold = @target.item_hold
        @target.item_hold = hold
        if @user.item_hold == 0
          string = "et ne reçoit rien!"
        else
          string = "et reçoit #{@user.item_name}!"
        end
        draw_text("#{@user.given_name} échange les objets", string)
        wait(40)
      end
    end

    def voeu_annexe_ko
      @user.skill_effect(:voeu, 1)
    end
    
    def racines_annexe_ko
      @user.skill_effect(:racines)
      draw_text("#{@user.given_name}" , "est enraciné !")
      wait(40)
    end

    def baillement_annexe
      @target.skill_effect(:baillement, 2)
      draw_text("#{@target.given_name}" , "baîlle !")
      wait(40)
    end

    def sabotage_annexe
      @target.save_item = @target.item_hold
      if @target.hp > 0 and @target.item_hold != 0
        draw_text("#{@target.given_name} lâche ", 
                  "#{Item.name(@target.item_hold)} !")
        @target.item_hold = 0
        wait(40)
      end
    end

    def rancune_annexe_ko
      @user.skill_effect(:rancune, 2)
      draw_text("#{@user.given_name}" , "est rancunier !")
      wait(40)
    end

    def lance_boue_annexe_ko
      @user.skill_effect(:lance_boue)
      draw_text("#{@user.given_name}" , "est couvert de boue !")
      wait(40)
    end

    def tourniquet_annexe_ko
      @user.skill_effect(:tourniquet)
      draw_text("#{@user.given_name}" , "est mouillé! ... ...")
      wait(40)
    end

    def gravite_annexe
      @target.skill_effect(:gravite)
      draw_text("#{@target.given_name}" , "est collé au sol !")
      wait(40)
    end

    def vent_arriere_annexe_ko
      @user.skill_effect(:vent_arriere)
      draw_text("#{@user.given_name}" , "est plus rapide !")
    end

    def embargo_annexe
      @target.skill_effect(:embargo, 6)
      draw_text("#{@target.given_name} ne peut" , "plus utiliser d'objet !")
      wait(40)
    end

    def anti_soin_annexe
      @target.skill_effect(:anti_soin, 6)
      draw_text("#{@target.given_name} ne peut" , "plus se soigner !")
      wait(40)
    end

    def suc_digestif_annexe
      @target.skill_effect(:suc_digestif)
      draw_text("SUC DIGESTIF annule le" , "talent de #{@target.given_name} !")
      wait(40)
    end

    def air_veinard_annexe_ko
      @user.skill_effect(:air_veinard, 6)
      draw_text("#{@user.given_name} est" , "protégé des coups critiques !")
      wait(40)
    end

    def soucigraine_annexe
      @target.skill_effect(:soucigraine)
      draw_text("Le talent de #{@target.given_name}" , 
                "est maintenant Insomnia !")
      wait(40)
    end

    def anneau_hydro_annexe_ko
      @user.skill_effect(:anneau_hydro)
      draw_text("#{@user.given_name} s'enveloppe" , "d'un ANNEAU HYDRO !")
      wait(40)
    end

    def vol_magnetik_annexe_ko
      @user.skill_effect(:vol_magnetik)
      draw_text("#{@user.given_name} lévite" , "grâce à VOL MAGNETIK !")
      wait(40)
    end
  end
end