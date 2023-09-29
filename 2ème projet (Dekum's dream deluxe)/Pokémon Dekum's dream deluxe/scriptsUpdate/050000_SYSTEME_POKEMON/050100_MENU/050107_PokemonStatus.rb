#==============================================================================
# ¦ Pokemon_Status
# Pokemon Script Project - Krosk
# 20/07/07
# Restructuré par Lizen
# 05/01/2020
# Correction du glitch lors de la navigation des attaques par Damien Linux
# 08/01/2020
#-----------------------------------------------------------------------------
# Scène modifiable
#-----------------------------------------------------------------------------
# Menu statistique individuelle
#-----------------------------------------------------------------------------
# data_ext from Box: [@mode, @box_party.index]
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Status
    def initialize(pokemon, index = -1, z_level = 150, data_ext = nil, current_index = 0)
      # Index du Pokémon dans l'équipe
      # -1 signifie on ne peut naviguer dans l'index d'équipe
      @party_index = index
      @data_ext = data_ext # Elements de sauvegarde
      @pokemon = pokemon
      @index = current_index # Position du menu
      @party_order = $battle_var.in_battle ? $battle_var.battle_order : [0,1,2,3,4,5]
      @z_level = z_level
    end

    def main
      Graphics.freeze
      # Background
      @background = Sprite.new
      @background.z = @z_level

      case @index
      when 0 #Info générales
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_informations])
      when 1 #Info statistiques
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_informations])
      when 2 #Skills
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_skills])
      when 3 #Skills details
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_skills_details])
      end


      # Sprite du Pokémon et de sa Ball
      # Chercher "FONCTIONS AUXILIAIRES" (sans les guillemets) avec CTRL + F pour plus de détails
      @pokemon_sprite = Sprite.new
      @pokemon_sprite.mirror = true
      @pokemon_sprite.z = @z_level + 1
      @ball_sprite = Sprite.new
      @ball_sprite.bitmap = RPG::Cache.picture(@pokemon.ball_sprite)
      @ball_sprite.x = 270
      @ball_sprite.y = 249
      @ball_sprite.z = @z_level + 1

      # Ne pas modifier : indique la position du curseur de selectionde
      # pour la première attaque
      @skill_index = 0
      @skill_selected = -1

      reset_pokemon_sprite

      #-------------------------------------------------------------------------------
      #                         DESSIN DES INTERFACES PRINCIAPELES
      #     Chercher "FONCTIONS DES INTERFACES PRINCIAPELES" (sans les guillemets)
      #     avec CTRL + F pour plus de détails
      #-------------------------------------------------------------------------------

      # Fenêtre du Pokémon(Interface A et B) regroupant Niveau, Nom et genre du Pokémon
      draw_pokemon_window
      # Fenetre d'identité (ID, Nom, Dresseur, etc. sur l'interface A et les stats sur l'interface B)
      draw_infos_stats
      # Memo Dresseur
      draw_memo
      # Infos sur l'EXP
      draw_exp_info
      # Nom du talent
      draw_talent
      # Description du talent
      draw_descr_talent
      # Fenêtre des attaques
      draw_skill_window
      # Fenêtre Précision / Pouvoir
      draw_info_damage
      # Catégorie de l'attaque
      draw_skill_categorie
      # Description de l'attaque
      draw_descr_skill

      refresh
      # Cri du Pokémon
      if FileTest.exist?(@pokemon.cry)
        Audio.se_play(@pokemon.cry)
      end

      Graphics.transition
      loop do
        Graphics.update
        Input.update
        if @index == 3
          update_skill
        else
          update
        end
        if @done
          break
        end
      end
      Graphics.freeze
      @ball_sprite.dispose
      @background.dispose
      @pokemon_sprite.dispose
      @pokemon_window.dispose
      @infos_stats.dispose
      @memo_dresseur.dispose
      @exp_info.dispose
      @talent_name.dispose
      @talent_descr.dispose
      @skill_window.dispose
      @infos_damage.dispose
      @skill_categorie.dispose
      @skill_descr.dispose
    end

    def return_data
      return @return_data
    end

    def update
      # Annulation
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        if $temp_computer # PC
          # data_ext[0] = mode, @data_ext[1] = index
          @done = true
        else # Autre
          @return_data = @party_index
          @done = true
        end
        return
      end

      if Input.trigger?(Input::C) and @index == 2
        $game_system.se_play($data_system.decision_se)
        @index = 3
        refresh
        return
      end

      if Input.trigger?(Input::RIGHT)
        if @pokemon.egg
          @index = 0
          refresh
          return
        end
        $game_system.se_play($data_system.decision_se)
        @index += (@index == 2) ? 0 : 1
        refresh
        return
      end

      if Input.trigger?(Input::LEFT)
        if @pokemon.egg
          @index = 0
          refresh
          return
        end
        $game_system.se_play($data_system.decision_se)
        @index -= (@index == 0) ? 0 : 1
        refresh
        return
      end

      if Input.trigger?(Input::UP) and @party_index != -1
        Graphics.freeze
        $game_system.se_play($data_system.decision_se)
        @party_index = @party_index == 0 ? $pokemon_party.size - 1 : @party_index - 1
        change_pokemon
        Graphics.transition
        return
      end

      if Input.trigger?(Input::DOWN) and @party_index != -1
        Graphics.freeze
        $game_system.se_play($data_system.decision_se)
        @party_index = @party_index < $pokemon_party.size - 1 ? @party_index + 1 : 0
        change_pokemon
        Graphics.transition
        return
      end
    end

    def change_pokemon
      @pokemon = $pokemon_party.actors[@party_order[@party_index]]
      refresh_all_pokemon_window
      if @pokemon.egg
        @index = 0
      end
      refresh
      # Cri du Pokémon
      if FileTest.exist?(@pokemon.cry)
        Audio.se_play(@pokemon.cry)
      end
    end

    def update_skill
      if Input.trigger?(Input::B) and @skill_selected == -1
        $game_system.se_play($data_system.cancel_se)
        @index = 2
        @ball_sprite.visible = true
        @pokemon_sprite.visible = true
        @pokemon_window.visible = true
        reset_pokemon_sprite
        refresh
        return
      end

      if Input.trigger?(Input::DOWN)
        max = @pokemon.skills_set.length-1
        if @skill_index != max
          $game_system.se_play($data_system.cursor_se)
        end
        @skill_index += @skill_index == max ? 0 : 1
        refresh
        return
      end

      if Input.trigger?(Input::UP)
        if @skill_index != 0
          $game_system.se_play($data_system.cursor_se)
        end
        @skill_index -= @skill_index == 0 ? 0 : 1
        refresh
        return
      end

      if Input.trigger?(Input::C) and @skill_selected == -1
        $game_system.se_play($data_system.decision_se)
        @skill_selected = @skill_index
        refresh
        return
      end

      if Input.trigger?(Input::C) and @skill_selected != -1
        $game_system.se_play($data_system.decision_se)
        @pokemon.skills_set.switch({ @skill_selected=>@skill_index , @skill_index=>@skill_selected })
        @skill_selected = -1
        refresh
        return
      end

      if Input.trigger?(Input::B) and @skill_selected != -1
        $game_system.se_play($data_system.decision_se)
        @skill_selected = -1
        refresh
        return
      end

    end

    def nature_test(n)
      return Color.new(255, 50, 50, 255) if @pokemon.nature[n] > 100
      return Color.new(50, 50, 255, 255) if @pokemon.nature[n] < 100
      return Color.new(0, 0, 0, 255)
    end
    def refresh
      normal_color = Color.new(60, 60, 60, 255)
      case @index
      when 0 # Infos générales (Interface A)
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_informations])
        refresh_all_pokemon_window
        @infos_stats.visible = true
        @memo_dresseur.visible = true
        @exp_info.visible = false
        @talent_name.visible = false
        @talent_descr.visible = false
        @skill_window.visible = false
        @infos_damage.visible = false
        @skill_categorie.visible = false
        @skill_descr.visible = false

        @infos_stats.draw_text(3, 59, 194, $fhb, @pokemon.name, 0, normal_color)

        # Fenêtre d'infos oeuf
        if @pokemon.egg
          @infos_stats.draw_text(3, 149, 194, $fhb, "?????", 0, normal_color) # Nom du Dresseur
          @infos_stats.draw_text(3, 194, 194, $fhb, "?????", 0, normal_color) # ID du Dresseur

          # Memo Dresseur Oeuf
          if @pokemon.step_remaining >= 10241
            string = ["Cet œuf va sûrement", "mettre du temps à éclore."]
          elsif @pokemon.step_remaining >= 2561
            string = ["Qu'est-ce qui va en sortir ? ", "Ça va mettre du temps."]
          elsif @pokemon.step_remaining >= 1281
            string = ["Il bouge de temps en temps.", "Il devrait bientôt éclore."]
          elsif @pokemon.step_remaining >= 1
            string = ["Il fait du bruit.", "Il va éclore !"]
          end
          @memo_dresseur.draw_text(5, 0, 452, $fhb, string[0], 0, normal_color)
          @memo_dresseur.draw_text(5, 42, 452, $fhb, string[1], 0, normal_color)
          return
        end

        # Fenêtre d'infos
        @infos_stats.draw_text(3, 14, 194, $fhb, sprintf("%03d", @pokemon.id), 0, normal_color)
        @infos_stats.draw_text(3, 149, 194, $fhb, @pokemon.trainer_name, 0, normal_color)
        @infos_stats.draw_text(3, 194, 194, $fhb, @pokemon.trainer_id, 0, normal_color)
        @infos_stats.draw_text(3, 239, 194, $fhb, @pokemon.item_name, 0, normal_color)

        draw_type_pokemon_2(0, 107, @pokemon.type1)
        draw_type_pokemon_2(0 + 96 + 3, 107, @pokemon.type2)

        string = @pokemon.nature[0] + " de nature."
        @memo_dresseur.draw_text(5, 0, 382, $fhb, string, 0, normal_color)
      when 1 # Statistiques (Interface B)
        @pokemon.statistic_refresh
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_informations_stats])
        refresh_all_pokemon_window
        @infos_stats.visible = true
        @memo_dresseur.visible = false
        @exp_info.visible = true
        @talent_name.visible = true
        @talent_descr.visible = true
        @skill_window.visible = false
        @infos_damage.visible = false
        @skill_categorie.visible = false
        @skill_descr.visible = false
        # Fenêtre des stats
        hp = @pokemon.hp > 0 ? @pokemon.hp : 0
        string = hp.to_s + "/ "+ @pokemon.maxhp_basis.to_s
        @infos_stats.draw_text(18, 14, 173, $fhb, string, 2, normal_color)
        @infos_stats.draw_text(95, 68, 96, $fhb, @pokemon.atk.to_s, 2, nature_test(1))
        @infos_stats.draw_text(95, 107, 96, $fhb, @pokemon.dfe.to_s, 2, nature_test(2))
        @infos_stats.draw_text(95, 146, 96, $fhb, @pokemon.ats.to_s, 2, nature_test(4))
        @infos_stats.draw_text(95, 185, 96, $fhb, @pokemon.dfs.to_s, 2, nature_test(5))
        @infos_stats.draw_text(95, 224, 96, $fhb, @pokemon.spd.to_s, 2, nature_test(3))
        # Fenêtre des points d'EXP
        @exp_info.draw_text(0, 0, 201, $fhb, "POINTS", 0, normal_color)
        @exp_info.draw_text(0, 39, 201, $fhb, "N. SUIVANT", 0, normal_color)
        @exp_info.draw_text(206, 0, 213, $fhb, @pokemon.exp.to_s, 2, normal_color)
        @exp_info.draw_text(206, 39, 213, $fhb, @pokemon.next_exp.to_s, 2, normal_color)
        # Fenêtres liées au talent
        @talent_name.draw_text(0, 0, 231, $fhb, @pokemon.ability_name, 0, normal_color)
        @talent_descr.draw_text(0, 0, 603, $fhb, @pokemon.ability_descr, 0, normal_color)
        # Contrôle de l'EXP
        if @pokemon.level < 100
          level = @pokemon.next_exp.to_f /
            (@pokemon.exp_list[@pokemon.level+1] - @pokemon.exp_list[@pokemon.level]).to_f
        else
          level = 0
        end
        draw_exp_bar(263, 84, 1.0 - level, 150) #(475, 336, 1.0 - level, 150)
      when 2 # Skills (Interface C)
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_skills])
        refresh_all_pokemon_window
        @infos_stats.visible = false
        @memo_dresseur.visible = false
        @exp_info.visible = false
        @talent_name.visible = false
        @talent_descr.visible = false
        @skill_window.visible = true
        @infos_damage.visible = false
        @skill_categorie.visible = false
        @skill_descr.visible = false

        # Affichage des attaques
        i = 0
        @pokemon.skills_set.each do |skill|
          draw_type_skill(0, 84 * i, skill.type)
          @skill_window.draw_text(99, -3 + 84 * i, 216, $fhb, skill.name, 0, normal_color)
          @skill_window.draw_text(99, -3 + 84 * i + 36, 213, $fhb, "PP " + skill.pp.to_s + "/" + skill.ppmax.to_s, 2, normal_color)
          i += 1
        end
      when 3 # Skills détaillé (Interface D)
        @background.bitmap = RPG::Cache.picture(DATA_MENU[:interface_skills_details])
        refresh_all_pokemon_window
        @ball_sprite.visible = false
        @infos_stats.visible = false
        @memo_dresseur.visible = false
        @exp_info.visible = false
        @talent_name.visible = false
        @talent_descr.visible = false
        @skill_window.visible = true
        @infos_damage.visible = true
        @skill_categorie.visible = true
        @skill_descr.visible = true
        # Fenêtre du Pokémon - Sprite et type (Interface C et D)
        @pokemon_sprite.bitmap = RPG::Cache.battler(@pokemon.icon, 0)
        @pokemon_sprite.x = 12
        @pokemon_sprite.y = 93
        draw_type_pokemon(72, 36, @pokemon.type1)
        draw_type_pokemon(171, 36, @pokemon.type2)
        # Navigation attaque
        i = 0
        while @skill_index >= @pokemon.skills_set.size
          @skill_index -= 1
        end
        @pokemon.skills_set.each do |skill|
          if @skill_index == i
            if @skill_selected != @skill_index
              rect = Rect.new(0, 0, 303, 72)
              bitmap = RPG::Cache.picture(SKILL_SELECTION)
              @skill_window.contents.blt(12, 3 + 84*i, bitmap, rect)
            end
            if skill.power == 0 or skill.power == 1
              string = "---"
            else
              string = skill.power.to_s
            end
            # Fenêtre Précision / Pouvoir
            @infos_damage.draw_text(1, 0, 74, $fhb, string, 1, normal_color)
            if skill.accuracy == 0
              string = "---"
            else
              string = skill.accuracy.to_s
            end
            # Type d'attaque
            rect = Rect.new(0, 0, 100, 100) 
            if skill.physical # Physique
              bitmap = RPG::Cache.picture(DATA_MENU[:icon_physique]) 
            elsif skill.special # Spéciale
              bitmap = RPG::Cache.picture(DATA_MENU[:icon_speciale])
            elsif skill.status # Status
              bitmap = RPG::Cache.picture(DATA_MENU[:icon_status])
            end
            @skill_categorie.contents.blt(0, 0, bitmap, rect, 255)
            # Description de l'attaque
            @infos_damage.draw_text(1, 42, 74, $fhb, string, 1, normal_color)
            list = string_builder(skill.description, 29)
            0.upto(3) do |k|
              @skill_descr.draw_text(2, 10 + 42*k, 276, $fhb, list[k], 0, normal_color)
            end
          end


          # Attaque sélectionnée
          if @skill_selected == i
            rect = Rect.new(0, 0, 303, 72)
            bitmap = RPG::Cache.picture(SKILL_SELECTIONNE)
            @skill_window.contents.blt(12, 3 + 84*i, bitmap, rect)
          end
          draw_type_skill(0, 84 * i, skill.type)
          @skill_window.draw_text(99, -3 + 84 * i, 216, $fhb, skill.name, 0, normal_color)
          @skill_window.draw_text(99, -3 + 84 * i + 36, 213, $fhb, "PP " + skill.pp.to_s + "/" + skill.ppmax.to_s, 2, normal_color)
          i += 1
        end
      end
    end

    #-------------------------------------------------------------------------------
    #                     FONCTIONS DES INTERFACES PRINCIAPELES
    #                            Ne pas déplacer
    #-------------------------------------------------------------------------------
    # Sprite du Pokémon (Interface A et B)
    def reset_pokemon_sprite
      @pokemon_sprite.visible = true
      @pokemon_sprite.bitmap = RPG::Cache.battler(@pokemon.battler_face(false), 0) # Sprite fixe
      @pokemon_sprite.x = 59
      @pokemon_sprite.y = 108
    end

    # Fenetre du Pokémon (Interface A et B) regroupant Niveau, Nom et genre du Pokémon
    def draw_pokemon_window
      @pokemon_window = Window_Base.new(0, 47, 304 + 32, 88 + 32)
      @pokemon_window.opacity = 0
      @pokemon_window.z = @z_level + 1
      @pokemon_window.contents = Bitmap.new(334, 129)
      @pokemon_window.contents.font.name = $fontface
      @pokemon_window.contents.font.size = $fontsizebig
      @pokemon_window.draw_text(95, -9, 186, 39, @pokemon.given_name)

      if @pokemon.egg
        return
      end

      @pokemon_window.draw_text(4, -9, 87, 39, "N."+ @pokemon.level.to_s)
      draw_gender(271, -3, @pokemon.gender)
      draw_shiny(246, 4, @pokemon.get_shiny)
    end

    # Fenetre d'identité (ID, Nom, Dresseur, etc. sur l'interface A et les stats sur l'interface B)
    def draw_infos_stats
      @infos_stats = Window_Base.new(421, 27, 213 + 32, 278 + 32)
      @infos_stats.opacity = 0
      @infos_stats.contents = Bitmap.new(227, 292)
      @infos_stats.contents.font.name = $fontface
      @infos_stats.contents.font.size = $fontsizebig
      @infos_stats.z = @z_level + 1
    end

    # Memo Dresseur
    def draw_memo
      @memo_dresseur = Window_Base.new(5, 329, 633 + 32, 135 + 32)
      @memo_dresseur.opacity = 0
      @memo_dresseur.contents = Bitmap.new(633, 135)
      @memo_dresseur.contents.font.name = $fontface
      @memo_dresseur.contents.font.size = $fontsizebig
      @memo_dresseur.z = @z_level + 1
    end

    # Infos sur l'EXP
    def draw_exp_info
      @exp_info = Window_Base.new(196, 290, 437 + 32, 93 + 32)
      @exp_info.opacity = 0
      @exp_info.contents = Bitmap.new(437, 93)
      @exp_info.contents.font.name = $fontface
      @exp_info.contents.font.size = $fontsizebig
      @exp_info.z = @z_level + 2
    end

    # Nom du talent
    def draw_talent
      @talent_name = Window_Base.new(196, 372, 259, 64)
      @talent_name.opacity = 0
      @talent_name.contents = Bitmap.new(227, 50)
      @talent_name.contents.font.name = $fontface
      @talent_name.contents.font.size = $fontsize
      @talent_name.z = @z_level + 3
    end

    # Description du talent
    def draw_descr_talent
      @talent_descr = Window_Base.new(17, 407, 617 + 32, 54 + 32)
      @talent_descr.opacity = 0
      @talent_descr.contents = Bitmap.new(617, 54)
      @talent_descr.contents.font.name = $fontface
      @talent_descr.contents.font.size = $fontsize
      @talent_descr.z = @z_level + 2
    end

    # Fenêtre des attaque
    def draw_skill_window
      @skill_window = Window_Base.new(307, 44, 347, 359)
      @skill_window.opacity = 0
      @skill_window.contents = Bitmap.new(333, 327)
      @skill_window.contents.font.name = $fontface
      @skill_window.contents.font.size = $fontsizebig
      @skill_window.z = @z_level + 2
    end

    # Fenêtre Précision / Pouvoir
    def draw_info_damage
      @infos_damage = Window_Base.new(142, 152, 109, 113)
      @infos_damage.opacity = 0
      @infos_damage.contents = Bitmap.new(109, 113)
      @infos_damage.contents.font.name = $fontface
      @infos_damage.contents.font.size = $fontsizebig
      @infos_damage.z = @z_level + 2
    end
    
    # Catégorie de l'attaque (physique / spéciale / statut)
    def draw_skill_categorie
      @skill_categorie = Window_Base.new(162, 244, 100, 100)
      @skill_categorie.opacity = 0
      @skill_categorie.contents = Bitmap.new(109, 113)
      @skill_categorie.contents.font.name = $fontface
      @skill_categorie.contents.font.size = $fontsizebig
      @skill_categorie.z = @z_level + 2
    end

    # Description de l'attaque
    def draw_descr_skill
      @skill_descr = Window_Base.new(0, 274, 312, 220)
      @skill_descr.opacity = 0
      @skill_descr.contents = Bitmap.new(312, 220)
      @skill_descr.contents.font.name = $fontface
      @skill_descr.contents.font.size = 38
      @skill_descr.z = @z_level + 3
    end

    #-------------------------------------------------------------------------------
    #                         FONCTIONS AUXILIAIRES
    #-------------------------------------------------------------------------------
    # Met à jour toutes les interfaces ainsi que le Sprite et la ball du Pokémon
    def refresh_all_pokemon_window
      @pokemon_window.contents.clear
      @infos_stats.contents.clear
      @memo_dresseur.contents.clear
      @exp_info.contents.clear
      @talent_name.contents.clear
      @talent_descr.contents.clear
      @skill_window.contents.clear
      @infos_damage.contents.clear
      @skill_descr.contents.clear
      # Ball et sprite du Pokémon
      @ball_sprite.bitmap = RPG::Cache.picture(@pokemon.ball_sprite)
      @pokemon_sprite.bitmap = RPG::Cache.battler(@pokemon.battler_face(false), 0) # Sprite fixe
      @pokemon_window.draw_text(95, -9, 186, 39, @pokemon.given_name)
      if @pokemon.egg
        return
      end
      @pokemon_window.draw_text(4, -9, 87, 39, "N."+ @pokemon.level.to_s)
      draw_gender(271, -3, @pokemon.gender)
      draw_shiny(246, 4, @pokemon.get_shiny)
    end

    # Emplacement du type du Pokémon affiché lorsque les interfaces C et D sont visibles
    def draw_type_pokemon(x, y, type)
      src_rect = Rect.new(0, 0, 96, 42)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @pokemon_window.contents.blt(x, y, bitmap, src_rect, 255)
    end

    # Emplacement du type du Pokémon dans la fenêtre d'infos
    def draw_type_pokemon_2(x, y, type)
      src_rect = Rect.new(0, 0, 96, 42)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @infos_stats.contents.blt(x, y, bitmap, src_rect, 255)
    end

    # Emplacement du type de l'attaque
    def draw_type_skill(x, y, type)
      src_rect = Rect.new(0, 0, 96, 42)
      bitmap = RPG::Cache.picture("T" + type.to_s + ".png")
      @skill_window.contents.blt(x, y, bitmap, src_rect, 255)
    end

    def draw_exp_bar(x, y, level, width)
      rect1 = Rect.new(x, y, level*width.to_i, 9)
      @exp_info.contents.fill_rect(rect1, Color.new(255, 255, 160, 160))
    end

    def draw_shiny(x, y, shiny)
      if shiny
        rect = Rect.new(0, 0, 18, 33)
        bitmap = RPG::Cache.picture(SHINY_INTERFACE)

        @pokemon_window.contents.blt(x, y, bitmap, rect, 255)
      end
    end

    def draw_gender(x, y, gender)
      if gender == 1
        rect = Rect.new(0, 0, 18, 33)
        bitmap = RPG::Cache.picture(MALE)
        @pokemon_window.contents.blt(x, y, bitmap, rect, 255)
      elsif gender == 2
        rect = Rect.new(0, 0, 18, 33)
        bitmap = RPG::Cache.picture(FEMELLE)
        @pokemon_window.contents.blt(x, y, bitmap, rect, 255)
      end
    end

    def string_builder(text, limit)
      length = text.size
      full1 = false
      full2 = false
      full3 = false
      full4 = false
      string1 = ""
      string2 = ""
      string3 = ""
      string4 = ""
      word = ""
      0.upto(length) do |i|
        letter = text[i..i]
        if letter != " " and i != length
          word += letter.to_s
        else
          word = word + " "
          if (string1 + word).length < limit and not(full1)
            string1 += word
            word = ""
          else
            full1 = true
          end

          if (string2 + word).length < limit and not(full2)
            string2 += word
            word = ""
          else
            full2 = true
          end

          if (string3 + word).length < limit and not(full3)
            string3 += word
            word = ""
          else
            full3 = true
          end
          string4 += word
          word = ""
        end
      end
      if string4.length > 1
        string4 = string4[0..string4.length-2]
      end
      return [string1, string2, string3, string4]
    end
  end
end
