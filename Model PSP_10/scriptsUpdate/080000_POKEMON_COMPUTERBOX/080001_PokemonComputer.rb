#==============================================================================
# ■ Pokemon_Computer# Pokemon Script Project - Krosk
# 20/07/07
# Un peu retouché par Valentin4311
# A nouveau retouché par Zooria !
# Restructuré et ajusté par Damien Linux
# 11/11/19
# 24/12/2019 - Ajustement par Lizen
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Interface PC
#-----------------------------------------------------------------------------
module POKEMON_S
  class Pokemon_Computer

    def initialize(window_active = 0, menu_index = 0, z_level = 200)
      @window_active = window_active # 0 = PC, 1 = PC STOCK, 2 = PC PERSO
      @menu_index = menu_index
      @z_level = z_level

      # Question
      @question = Window_Base.new(149, 54, 358, 63)
      @question.opacity = 0
      @question.z = @z_level + 2
      @question.contents = Bitmap.new(338, 44)
      @question.contents.font.name = $fontface
      @question.contents.font.size = 40 #$fontsize


      # Fenêtre de choix
      @choix = Window_Base.new(110, 121, 420, 238)
      @choix.opacity = 0
      @choix.z = @z_level + 2
      @choix.contents = Bitmap.new(400, 210)
      @choix.contents.font.name = $fontface
      @choix.contents.font.size = 40 #$fontsize

      # Help
      @text_help = Window_Base.new(38, 354, 562, 70)
      @text_help.opacity = 0
      @text_help.z = @z_level + 2
      @text_help.contents = Bitmap.new(552, 60)
      @text_help.contents.font.name = $fontface
      @text_help.contents.font.size = $fontsize
    end

    def main
      @spriteset = Spriteset_Map.new

      # Background
      @background_pc = Sprite.new
      @background_pc.bitmap = RPG::Cache.picture(DATA_PC[:background])
      @background_pc.z = @z_level + 1
      @background_pc.src_rect.set(0, 0, 640, 480)

      # Curseur Choix
      @cursor_choice = Sprite.new
      @cursor_choice.bitmap = RPG::Cache.picture(DATA_PC[:selection])
      @cursor_choice.x = 118
      @cursor_choice.y = 129
      @cursor_choice.z = @z_level + 1

      # Scrollrect (Curseur)
      @scrollrect = Sprite.new
      @scrollrect.bitmap = RPG::Cache.picture(DATA_PC[:scrollrect])
      @scrollrect.x = 612
      @scrollrect.z = @z_level + 2
      @scrollrect.visible = false

      # Scrollbar
      @scrollbar = Sprite.new
      @scrollbar.bitmap = RPG::Cache.picture(DATA_PC[:scrollbar])
      @scrollbar.x = 612
      @scrollbar.y = 127
      @scrollbar.z = @z_level + 1
      @scrollbar.visible = false

      # Accueil PC
      s1 = "" # Stockage PKMN
      s2 = "" # Stockage Objets
      #s3 = "" # PC Prof.
      #s4 = "" # Panthéon
      s3 = "" # Eteindre
      @command_window = Window_Command.new(260, [s1, s2, s3], $fontsize)
      @command_window.visible = false

      # PC de Stockage Pokémon
      s1 = "" # Transfert
      s2 = "" # Créer boite
      s3 = "" # Retour
      @store_window = Window_Command.new(260, [s1, s2, s3], $fontsize)
      @store_window.visible = false


      # PC du joueur (Stockage d'objets)
      s1 = "" # Stocker
      s2 = "" # Retirer
      s3 = "" # Retour
      @item_window = Window_Command.new(260, [s1, s2, s3], $fontsize)
      @item_window.visible = false


      case @window_active
      when 0
        @store_window.active = false
        @item_window.active = false
      when 1
        @item_window.active = false
        @command_window.active = false
      when 2
        @command_window.active = false
        @store_window.active = false
      end

      Graphics.transition
      loop do
        Graphics.update
        Input.update
        update
        if $scene != self
          break
        end
      end
      Graphics.freeze
      @command_window.dispose
      @store_window.dispose
      @item_window.dispose
      @question.dispose
      @choix.dispose
      @text_help.dispose
      @background_pc.dispose
      @scrollrect.dispose
      @scrollbar.dispose
      @cursor_choice.dispose
      @spriteset.dispose
    end

    def update
      @command_window.update
      @item_window.update
      @store_window.update
      @spriteset.update
      if @command_window.active
        update_command
        return
      end
      if @item_window.active
        update_item
        return
      end
      if @store_window.active
        update_store
        return
      end
    end


    # Accueil
    def update_command

      # Liste
      #@start_list = ["PC de Stockage", "PC de #{POKEMON_S::Player.name}",
      #  "Analyse Pokédex", "Panthéon", "Eteindre"]
      @start_list = ["PC de Stockage", "PC de #{POKEMON_S::Player.name}", "Eteindre"]

      @question.contents.clear
      @question.draw_text(2, -5, 326, 40, "Accéder à quel PC?")

      # Visibilité Scrollrect/Scrollbar
      if @start_list.size > 3
        @scrollbar.visible = true
        @scrollrect.visible = true
        @scrollrect.y = 145 + (206 * @command_window.index) / (@start_list.size - 1) - 16
      else
        @scrollbar.visible = false
        @scrollrect.visible = false
      end

      # Curseur de selection + Help
      @cursor_choice.y = 129 + 79 * (@command_window.index % 3)
      case @command_window.index
      when 0
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Déposer, retirer des Pokémon ou créer des boîtes")

      when 1
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Déposer ou retirer des objets", 1)
      # Exemple
      #when 2
      #  @text_help.contents.clear
      #  @text_help.draw_text(0, -10, 552, 60, "Obtenir l'avis du Prof. Damien pour le Pokédex", 1)
      #when 3
      #  @text_help.contents.clear
      #  @text_help.draw_text(0, -10, 552, 60, "Consulter l'historique du Panthéon des dresseurs", 1)
      # when 4
      when 2
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Retour au jeu", 1)
      end


      # Liste Choix (start_list)
      red_color = Color.new(255, 128, 128, 255)

      case @command_window.index
      when 0..2
        @background_pc.src_rect.set(0, 0, 640, 480)
        @choix.contents.clear
        if $pokemon_party.size == 0
         @choix.draw_text(54, 3, 400, 40, @start_list[0], 0, red_color)
       else
         @choix.draw_text(54, 3, 400, 40, @start_list[0])
       end
       @choix.draw_text(54, 82, 400, 40, @start_list[1])
       @choix.draw_text(54, 161, 400, 40, @start_list[2])
     when 3..4
       @background_pc.src_rect.set(0, 480, 640, 480)
       @choix.contents.clear
       @choix.draw_text(54, 3, 400, 40, @start_list[3])
       @choix.draw_text(54, 82, 400, 40, @start_list[4])
      end



      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.cancel_se)
        $scene = Scene_Map.new
        return
      end

      # C ボタンが押された場合
      if Input.trigger?(Input::C)
        # コマンドウィンドウのカーソル位置で分岐

        case @command_window.index
        when 0 # Stockage Pokemon
          if $pokemon_party.size == 0
            $game_system.se_play($data_system.buzzer_se)
            return
          end
          $game_system.se_play($data_system.decision_se)
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:connexion_pc]}")
          @command_window.active = false
          @store_window.active = true
        when 1  # PC du joueur
          $game_system.se_play($data_system.decision_se)
          Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:connexion_pc]}")
          @command_window.active = false
          @item_window.active = true
        # Exemple
        #when 2 # PC du Prof
        #  $game_system.se_play($data_system.decision_se)
        #  Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:connexion_pc]}")
        #when 3 # Panthéon
        #  $game_system.se_play($data_system.decision_se)
        #  Audio.se_play("Audio/SE/#{DATA_AUDIO_SE[:connexion_pc]}")
        # when 4
        when 2  # Retour au jeu
          $game_system.se_play($data_system.decision_se)
          $scene = Scene_Map.new
          return
        end
        return
      end
    end

    # PC stockage Pokemon
    def update_store

      # Liste
      @store_list = ["Transférer des Pokémon", "Créer une boîte", "Retour"]

      @question.contents.clear
      @question.draw_text(2, -5, 326, 40, "Que voulez-vous faire ?")

      # Visibilité Scrollrect/Scrollbar
      if @store_list.size > 3
        @scrollbar.visible = true
        @scrollrect.visible = true
        @scrollrect.y = 145 + (206 * @store_window.index) / (@store_list.size - 1) - 16
      else
        @scrollbar.visible = false
        @scrollrect.visible = false
      end


      # Curseur de selection + Help
      @cursor_choice.y = 129 + 79 * (@store_window.index % 3)
      case @store_window.index
      when 0
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Déposer ou retirer des Pokémon", 1)
      when 1
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Créer une nouvelle boîte de stockage", 1)
      when 2
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Retour au menu précédent", 1)
      end

      # Liste Choix (store_list)
      @background_pc.src_rect.set(0, 0, 640, 480)
      @choix.contents.clear
      @choix.draw_text(54, 3, 400, 40, @store_list[0])
      @choix.draw_text(54, 82, 400, 40, @store_list[1])
      @choix.draw_text(54, 161, 400, 40, @store_list[2])


      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.decision_se)
        @store_window.active = false
        @command_window.active = true
      end
      if Input.trigger?(Input::C)
        case @store_window.index
        when 0
          $game_system.se_play($data_system.decision_se)
          $scene = POKEMON_S::Pokemon_Box.new
        when 1
          $game_system.se_play($data_system.decision_se)
          $pokemon_party.create_box
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Une nouvelle boîte a été crée !", 1)
        wait(50)
        when 2
          $game_system.se_play($data_system.decision_se)
          @store_window.active = false
          @command_window.active = true
          return
        end
        return
      end
    end

    # PC du joueur
    def update_item

      # Liste
      @item_list = ["Stocker des Objets", "Retirer des Objets","Retour"]

      # Visibilité Scrollrect/Scrollbar
      if @item_list.size > 3
        @scrollbar.visible = true
        @scrollrect.visible = true
        @scrollrect.y = 145 + (206 * @item_window.index) / (@item_list.size - 1) - 16
      else
        @scrollbar.visible = false
        @scrollrect.visible = false
      end

      @question.contents.clear
      @question.draw_text(2, -5, 326, 40, "Que voulez-vous faire ?")

      # Curseur de selection + Help
      @cursor_choice.y = 129 + 79 * (@item_window.index % 3)
      case @item_window.index
      when 0
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Déposer des Objets", 1)

      when 1
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Retirer des Objets", 1)
      when 2
        @text_help.contents.clear
        @text_help.draw_text(0, -10, 552, 60, "Retour au menu précédent", 1)
      end

      # Liste Choix (item_list)
      @background_pc.src_rect.set(0, 0, 640, 480)
      @choix.contents.clear
      @choix.draw_text(54, 3, 400, 40, @item_list[0])
      @choix.draw_text(54, 82, 400, 40, @item_list[1])
      @choix.draw_text(54, 161, 400, 40, @item_list[2])



      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.decision_se)
        @item_window.active = false
        @command_window.active = true
      end

      if Input.trigger?(Input::C)

        case @item_window.index
        when 0 # Déposer des objets
          $game_system.se_play($data_system.decision_se)
          $scene = Pokemon_Computer_Item_Stock.new
        when 1  # Retirer des objets
          $game_system.se_play($data_system.decision_se)
          $scene = Pokemon_Computer_Item_Retiring.new
        when 2  # Retour au menu
          $game_system.se_play($data_system.decision_se)
          @item_window.active = false
          @command_window.active = true
          return
        end
      end
    end

    def wait(frame)
      i = 0
      loop do
        i += 1
        Graphics.update
        if i >= frame
          break
        end
      end
    end
  end
end
