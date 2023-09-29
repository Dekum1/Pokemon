#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# Pokemon_Attacks_Status_Annexe - Damien Linux
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
  # - Modification du status
  #------------------------------------------------------------
  # La mention "_ko" après "_annexe" signifie que l'effet
  # a lieu même si l'adversaire est K.O.
  # pensez à rajouter "_ko" pour les attaques qui peuvent avoir
  # lieu sans la présence de l'adversaire sur le terrain
  #------------------------------------------------------------
  class Pokemon_Battle_Core
    #------------------------------------------------------------ 
    # Modification du status
    #------------------------------------------------------------
    def sommeil_annexe
      status_check(@target, 4)
      @target_status.refresh
    end 

    def poison_annexe
      status_check(@target, 1)
      @target_status.refresh
    end

    def brulure_annexe
      status_check(@target, 3)
      @target_status.refresh
    end 
    alias ebullition_annexe brulure_annexe

    def gel_annexe
      status_check(@target, 5)
      @target_status.refresh
    end

    def paralysie_annexe
      status_check(@target, 2)
      @target_status.refresh
    end 

    def multi_tour_confus_annexe_ko
      index = @user.effect_list.index(:multi_tour_confus)
      if not(@user.confused?) and @user.effect[index][1] == 1
        status_check(@user, 6)
        @user_status.refresh
      end
    end 
    
    def mania_annexe_ko
      index = @user.effect_list.index(:mania)
      if not(@user.confused?) and @user.effect[index][1] == 1
        status_check(@user, 6)
        @user_status.refresh
      end
    end 

    def apeurer_annexe
      status_check(@target, 7)
      @target_status.refresh
    end
    
    def toxik_annexe
      status_check(@target, 8)
      @target_status.refresh
    end

    def triplattaque_annexe
      choice_effect = 0
      case rand(3)
      when 0
        choice_effect = 2
      when 1
        choice_effect = 3
      when 2
        choice_effect = 5
      end
      status_check(@target, choice_effect)              
      @target_status.refresh
    end

    def confusion_annexe
      status_check(@target, 6)
      @target_status.refresh
    end

    def gaz_toxik_annexe
      status_check(@target, 1)
      @target_status.refresh
    end

    def intimidation_annexe
      status_check(@target, 2)
      @target_status.refresh
    end

    def pique_annexe
      status_check(@target, 7)
      @target_status.refresh
    end

    def confusion_attaque_annexe
      status_check(@target, 6)
      @target_status.refresh
    end

    def double_dard_annexe
      status_check(@target, 1)
      @target_status.refresh
    end

    def ronflement_annexe
      status_check(@target, 7)
      @target_status.refresh
    end

    def soin_status_annexe_ko
      @user.cure
      if @user == @actor
        draw_text("L'équipe est soignée !")
        wait(40)
        @party.cure_party
      end
    end

    def degele_brule_annexe
      status_check(@target, 3)
      @target_status.refresh
    end

    def ouragan_annexe
      status_check(@target, 7)
      @target_status.refresh
    end

    def apeurer_attaque_annexe
      status_check(@target, 7)
      @target_status.refresh
    end

    def fatal_foudre_annexe
      status_check(@target, 2)
      @target_status.refresh
    end

    def bluff_annexe
      if @precedent == nil
        status_check(@target, 7)
        @target_status.refresh
      end
    end

    def feu_follet_annexe
      status_check(@target, 3)
      @target_status.refresh
    end

    def stimulant_annexe_ko
      if @user.paralyzed?
        @user.cure
        @user_status.refresh
      end
    end
    
    def regeneration_annexe_ko
      if @user.paralyzed? or @user.burn? or @user.poisoned?
        @user.cure
        @user_status.refresh
      end
    end

    def danse_folle_annexe_ko
      status_check(@target, 6)
      @target_status.refresh
    end

    def pied_bruleur_annexe
      status_check(@target, 3)
      @target_status.refresh
    end

    def crochet_venin_annexe
      status_check(@target, 8)
      @target_status.refresh
    end

    def queue_poison_annexe
      status_check(@target, 1)
      @target_status.refresh
    end

    def crocs_eclair_annexe
      if rand(2) == 0
        status_check(@target, 2)
        @target_status.refresh
      else
        status_check(@target, 7)
        @target_status.refresh
      end
    end

    def crocs_givre_annexe
      if rand(2) == 0
        status_check(@target, 5)
        @target_status.refresh
      else
        status_check(@target, 7)
        @target_status.refresh
      end
    end

    def crocs_feu_annexe
      if rand(2) == 0
        status_check(@target, 3)
        @target_status.refresh
      else
        status_check(@target, 7)
        @target_status.refresh
      end
    end

    def cage_eclair_annexe
      status_check(@target, 2)
      @target_status.refresh
    end
    alias para_spore_annexe cage_eclair_annexe

    def poudre_toxik_annexe
      status_check(@target, 1)
      @target_status.refresh
    end

    def poudre_dodo_annexe
      status_check(@target, 4)
      @target_status.refresh
    end

    def rebond_annexe
      status_check(@target, 2)
      @target_status.refresh
    end
  end
end