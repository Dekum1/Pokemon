#===============================================================================
# Menu d'édition des tags - G!n0
#-------------------------------------------------------------------------------
# Scène Tag_Menu
#===============================================================================

module TAG_SYS
  
  class Tag_Menu
    
    #----------------------------------------------------
    # Les Constantes
    #----------------------------------------------------
    FONTFACE = ["Calibri", "Trebuchet MS"]
    FS_BIG = 24
    FS_SMALL = 16
    
    #----------------------------------------------------
    # Initialisation
    #----------------------------------------------------
    def initialize
      @done = false
      @save = false
    end
    
    #----------------------------------------------------
    # Main
    #----------------------------------------------------
    def main
      # Fond d'écran
      @background = Sprite.new
      @background.bitmap = RPG::Cache.picture(DATA_TAG_EDITOR[:fond])
      @background.z = 10
      
      # Titre
      @title = Window_Base.new(0,-16,640,104)
      @title.opacity = 0
      @title.contents = Bitmap.new(640-32, 104-32)
      @title.contents.font.name = FONTFACE
      @title.contents.font.size = FS_BIG
      @title.contents.draw_text(0,0,640-32,32,"Editeur de Tags",1)
      @title.contents.draw_text(1,40,184,32,"Tilesets",1)
      
      # Liste des tilesets
      @tilesets_list = Tilesets_List.new
      @tilesets_list.active = true
      
      # Fenêtre en charge de l'édition du tileset sélectionné
      @tileset_edit = Tilesets_Edit.new
      @tileset_edit.active = false
      
      # Fenêtre des commandes
      @command_window = Tags_Command.new
      @command_window.active = false
      
      # Barre des commandes
      @command_bar = Sprite.new
      @command_bar.bitmap = Bitmap.new(640,16)
      @command_bar.x = 0
      @command_bar.y = 480-16
      @command_bar.z = 20
      @command_bar.bitmap.font.name = FONTFACE
      @command_bar.bitmap.font.size = FS_SMALL
      @command_bar.bitmap.font.color = Color.new(255,255,255)
      refresh_command_bar
      
      Graphics.transition
      
      # Boucle principale
      until @done
        Graphics.update
        Input.update
        update
      end
      
      # Compilation en cas d'enregistrement
      if @save
        TAG_SYS.compilation
      end
      
      Graphics.freeze
      # libération de la mémoire
      dispose
    end
    
    #----------------------------------------------------
    # Libération de la mémoire
    #----------------------------------------------------
    def dispose
      @background.dispose
      @title.dispose
      @tilesets_list.dispose
      @tileset_edit.dispose
      @command_window.dispose
      @command_bar.bitmap.dispose
      @command_bar.dispose
      @background = nil
      @title = nil
      @tilesets_list = nil
      @tileset_edit = nil
      @command_window = nil
      @command_bar = nil
    end
    
    #----------------------------------------------------
    # Mise à jour
    #----------------------------------------------------
    def update
      # MAJ liste des tilesets
      if @tilesets_list.active
        update_tileset_list
      # MAJ fenêtre d'édition du tileset
      elsif @tileset_edit.active
        update_tileset_edit
      # MAJ fenêtre des commandes
      elsif @command_window.active
        update_command_window
      end
    end
    
    #----------------------------------------------------
    # MAJ de la liste des tilesets
    #----------------------------------------------------
    def update_tileset_list
      # MAJ de la fenêtre de la liste des tilesets
      @tilesets_list.update
      # C : sélectionner un tileset
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        @tilesets_list.change_selected
        @tileset_edit.change(@tilesets_list.index+1)
        return
      end
      # Droite : Basculer dans la fenêtre d'édition du tileset
      if Input.trigger?(Input::RIGHT)
        @tilesets_list.active = false
        @tileset_edit.index_ltop
        @tileset_edit.active = true
        refresh_command_bar
        return
      end
      # Gauche : Basculer dans la fenêtre des commandes
      if Input.trigger?(Input::LEFT)
        @tilesets_list.active = false
        @command_window.active = true
        refresh_command_bar
        return
      end
    end
    
    #----------------------------------------------------
    # MAJ de la fenêtre d'édition du tileset
    #----------------------------------------------------
    def update_tileset_edit
      # Basculer vers la liste des tilesets
      if Input.trigger?(Input::LEFT)
        if @tileset_edit.index % 8 == 0
          @tileset_edit.active = false
          @tilesets_list.active = true
          refresh_command_bar
          return
        end
      end
      # Basculer vers la fenêtre des commandes
      if Input.trigger?(Input::RIGHT)
        if @tileset_edit.index % 8 == 7
          @tileset_edit.active = false
          @command_window.active = true
          refresh_command_bar
          return
        end
      end
      # MAJ de la fenêtre d'édition du tileset
      @tileset_edit.update
      # C : Modifier le tag du tile sélectionné
      if Input.trigger?(Input::C)
        $game_system.se_play($data_system.decision_se)
        @tileset_edit.change_tag
        return
      end
      # B : Modifier le tag du tile sélectionné
      if Input.trigger?(Input::B)
        $game_system.se_play($data_system.decision_se)
        @tileset_edit.change_tag(-1)
        return
      end
    end
    
    #----------------------------------------------------
    # MAJ de la fenêtre des commandes
    #----------------------------------------------------
    def update_command_window
      # MAJ de la fenêtre des commandes
      @command_window.update
      # Basculer ver la fenêtre d'édition du tileset
      if Input.trigger?(Input::LEFT)
        @command_window.active = false
        @tileset_edit.index_rtop
        @tileset_edit.active = true
        refresh_command_bar
        return
      end
      # Basculer ver la liste des tilesets
      if Input.trigger?(Input::RIGHT)
        @command_window.active = false
        @tilesets_list.active = true
        refresh_command_bar
        return
      end
      # C : Selectionner la commande
      if Input.trigger?(Input::C)
        case @command_window.index
        when 0 # Terrains
          @tileset_edit.change_mode(:terrain)
          @tileset_edit.text_refresh_all
          @command_window.refresh
        when 1 # Systèmes
          @tileset_edit.change_mode(:system)
          @tileset_edit.text_refresh_all
          @command_window.refresh
        when 2 # OK
          @tileset_edit.save
          @done = true
          @save = true
        when 3 # Annuler
          $game_system.se_play($data_system.cancel_se)
          $scene = Scene_Map.new
          @done = true
        end
        
      end
    end
    
    #----------------------------------------------------
    # Rafraichissement de la barre des commandes
    #----------------------------------------------------
    def refresh_command_bar
      if @tileset_edit.active
        string = "C : Augmenter    X : Diminuer    "
        string += "W : Déplacement rapide vers le bas    "
        string += "Q : Déplacement rapide vers le haut"
      else
        string = "C : Selectionner"
      end
      @command_bar.bitmap.clear
      @command_bar.bitmap.draw_text(16,0,640,16,string)
    end
    
  end
  
end