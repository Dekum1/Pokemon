#==============================================================================
# ■ Pokemon_Battle_Core
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
  # Pokemon_Battle_Core
  # Méthodes de mises à jour des acteurs en combat
  # et de création d'interface :
  # - Actualisation des stats
  # - Choix des actions en fonction du bouton appuyée
  # - Rédaction du texte spécifique au combat
  # - Rédaction du texte : fenêtre de choix
  # - Arrêt temporaire du temps
  # - Vérifie si un pokémon est K.O.
  # - Interface
  # - Reset party
  # - Force le level des équipes
  #------------------------------------------------------------
	class Pokemon_Battle_Core
    #------------------------------------------------------------  
    # Actualisation des stats
    #------------------------------------------------------------
    def statistic_refresh
      @actor.statistic_refresh
      @enemy.statistic_refresh
    end
    
    def statistic_refresh_modif
      @actor.statistic_refresh_modif
      @enemy.statistic_refresh_modif
    end
    
    #------------------------------------------------------------  
    # Choix des actions en fonction du bouton appuyée
    #------------------------------------------------------------
    # Fonction auxiliaire
    def input
      if Input.trigger?(Input::C) or Input.trigger?(Input::B) or
        Input.trigger?(Input::UP) or Input.trigger?(Input::DOWN) or
        Input.trigger?(Input::LEFT) or Input.trigger?(Input::RIGHT)
        return true
      end
      return false
    end
    
    #------------------------------------------------------------  
    # Rédaction du texte spécifique au combat
    #------------------------------------------------------------
    def draw_text(line1 = "", line2 = "")
      if line1.type == Array
        if line1[1] != nil
          draw_text(line1[0], line1[1])
        else
          draw_text(line1[0])
        end
      else
        Graphics.freeze
        @text_window.contents.clear
        @text_window.draw_text(12, 0, 460, 50, line1, 0, Color.new(0, 0, 0))
        @text_window.draw_text(12, 55, 460, 50, line2, 0, Color.new(0, 0, 0))
        Graphics.transition(5)
      end
    end
    
    def draw_text_valid(line1 = "", line2 = "")
      draw_text(line1, line2)
      loop do
        $scene.battler_anim ; Graphics.update
        Input.update
        if Input.trigger?(Input::C)
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
    end
    
    #------------------------------------------------------------  
    # Rédaction du texte : fenêtre de choix
    #------------------------------------------------------------
    def draw_choice
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsizebig)
      @command.x = 517
      @command.y = 215
      loop do
        $scene.battler_anim ; Graphics.update
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          $game_system.se_play($data_system.decision_se)
          @command.dispose
          @command = nil
          Input.update
          return true
        end
        if Input.trigger?(Input::C) and @command.index == 1
          $game_system.se_play($data_system.decision_se)
          @command.dispose
          @command = nil
          Input.update
          return false
        end
      end
    end
    
    #------------------------------------------------------------  
    # Arrêt temporaire du temps
    #------------------------------------------------------------
    def wait(frame)
      i = 0
      loop do
        i += 1
        $scene.battler_anim ; Graphics.update 
        if i >= frame
          break
        end
      end
    end
    
    def wait_hit
      loop do
        $scene.battler_anim ; Graphics.update
        Input.update
        if input
          $game_system.se_play($data_system.decision_se)
          break
        end
      end
    end
    
    #------------------------------------------------------------  
    # Vérifie si un pokémon est K.O.
    #------------------------------------------------------------
    def faint_check(user = nil)
      autorise = false
      if user == nil
        faint_check(@actor)
        faint_check(@enemy)
      end
      if user == @actor
        if user.dead?
          actor_down
        else
          autorise = use_berry(user, user)
        end
      end
      if user == @enemy
        if user.dead?
          enemy_down
        else
          autorise = use_berry(user, user)
        end
      end
      
      if autorise
        user.item_hold = 0
      end
    end
    
    #------------------------------------------------------------  
    # Interface
    #------------------------------------------------------------       
    def skill_descr_refresh
      @skill_descr.contents.clear
      index = @skills_window.index
      skill = @actor.skills_set[index]
      if skill != nil
        string = skill.pp.to_s + "/" + skill.ppmax.to_s
        type = skill.type
      else
        string = "---"
        type = 0
      end
      black_color = Color.new(60, 60, 60, 255)
      @skill_descr.contents.font.color = black_color
      @skill_descr.contents.draw_text(0,6,96,39, string, 1)
      draw_type(0, 60, type)
    end  
      
    def draw_type(x, y, type)
      src_rect = Rect.new(0, 0, 96, 42)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @skill_descr.contents.blt(x, y, bitmap, src_rect, 255)
    end
    
    #------------------------------------------------------------  
    # Reset party
    #------------------------------------------------------------
    # Réinitialise l'ensemble des acteurs d'une partie (utile en fin de combat)
    # party : le type de partie où les acteurs appartenant à cette dernière
    # ont besoin d'être réinitialisé
    def reset_party(party)
      party.actors.each { |actor| actor.reset_stat_stage }
    end

    # Guérit l'intégralité des acteurs d'une partie (utile en début de combat si on recombat un vaincu)
    # party : L'équipe à guérir
    def refill_party(party)
      party.actors.each { |actor| actor.refill }
    end
    
    #------------------------------------------------------------  
    # Force le level des équipes
    #------------------------------------------------------------
    # Donne un niveau définit à tous les pokémon qui peuvent être mis en
    # combat
    # fin_combat : si true rétablit le level initial
    def refresh_level(fin_combat = false)
      level = $game_variables[LEVEL_TOUR_COMBAT]
      equipes = [@party.actors, $battle_var.enemy_party.actors]
      equipes.each do |party|
        party.each do |pokemon|
          level = pokemon.level_save if fin_combat # Niveau initial du pokémon
          pokemon.refresh_level(level)
        end
      end
    end
  end
end