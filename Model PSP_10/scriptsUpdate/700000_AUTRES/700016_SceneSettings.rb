#============================================================================
# Système d'options
#----------------------------------------------------------------------------
# Réalisé par Metaiko
# Version 1.1
# Le 21/05/2019
#============================================================================

#----------------------------------------------------------------------------
# Liste des Windowskin pour les boîtes de dialogue
# Vous pouvez supprimer les Windowskin que vous ne voulez pas utiliser et en
# ajouter en respectant la synthaxe "Nom_du_Windowskin.extension", (avec la 
# virgule à la fin de chaque ligne SAUF LA DERNIERE !
# Ensuite, rendez-vous dans le dossier Graphics/Puctures et ajoutez vos boîtes
# pour les dialogues. Il faudra les renommer de cette manière : 
#        messagedummy_N.png
# Avec N le numéro correspondant au rang du Windowskin associée à cette boîte
# dans la liste (0 pour le premier, 1 pour le deuxième, ..., n-1 pour le n-ième)
#----------------------------------------------------------------------------
BOX_LIST =   ["pokesys0.png",
              "pokesys1.png",
              "pokesys2.png",
              "pokesys3.png",
              "pokesys4.png"
              ]
              
#----------------------------------------------------------------------------
# FONT_LIST correspond à la liste des polices d'écriture
# Vous pouvez supprimer les polices que vous ne voulez pas utiliser et en
# ajouter en respectant la synthaxe "Nom_de_la_Police", (avec la virgule
# à la fin de chaque lignes SAUF LA DERNIERE !
# Vous trouverez le nom des polices installés sur votre PC dans C:/Windows/Fonts
# ou dans un logiciel de traitement de texte
#
# FONT_SHORTCUT correspond au raccourcis de chaque polices d'écriture
# Si vous avez supprimé une police d'écriture, il faut supprimer le raccourcis
# correspondant à la police supprimée. Si vous en avez ajouter une, il faut 
# ajouter un raccourcis au même rang (si votre police est à la 3e place dans 
# FONT_LIST le raccourcis doit être à la 3e place dans FONT_SHORTCUT)
# En jeu, dans le menu des options, il sera afficher "Pokémon <Raccourcis>"
# lorsque la police sera sélectionnée
#
# FONT_SIZE regroupe les tailles de police.
# Comme pour FONT_SHORTCUT si vous avez supprimé ou ajouté une police dans
# FONT_LIST, il faudra supprimer ou ajouter les paramètres de taille de cette
# police au même rang que celle-ci.
# Lors de l'ajout de tailles de police, il faudra respecter cette synthaxe :
#           Taille_petite, Taille_normal, Taille_grosse,
# Par exemple, pour la police de FRLG, Taille_petite vaut 15, Taillle_normal
# vaut 29 et Taille_grosse vaut 43 (en 1px, 2px et 3px respectivement)
# Pensez aux virgules SAUF APRES LA DERNIERE VALEUR
#----------------------------------------------------------------------------
FONT_LIST =  ["Power Red and Green",
              "Power Red and Blue",
              "Pokemon DP"
              
             ]
FONT_SHORTCUT =  ["FRLG",
                  "RSE",
                  "DP"
                  
                 ]
FONT_SIZE =   [15,29,43,
               15,31,47,
               15,31,47
               
               ]

#Tableaux de valeurs pour l'affichage des textes
ECRAN_HASH = {0 => "Fenêtre", 1 => "Plein Écran"}
ANIM_HASH = {0 => "Désactiver", 1 => "Activer"}
BATTLE_STYLE_HASH = { 0 =>"Choix", 1 => "Défini"}
#-----------------------------------------------------------------------------
# Vous pouvez modifier le hash ci-dessous pour modifier les vitesses de jeu 
# disponibles en respectant de même schéma :
# "Mot à afficher dans le menu d'options" => Nb_de_fps
# Le jeu tourne de base à 40fps, vous pouvez bous baser sur cette valeur pour 
# proposer d'autres vitesses de jeu. 
# PENSEZ A AJOUTER DES VIRGULES ENTRE CHAQUE VITESSES SAUF APRES LA DERNIERE !
# Pensez à mettre les différentes valeurs de FPS par ordre croissant afin  
# d'éviter les mauvaises surprises
#-----------------------------------------------------------------------------
FRAME_RATE_HASH = {20 => "x0.5", 40 => "x1", 80 => "x2", 120 => "x3", 
                   160 => "x4"}


#-----------------------------------------------------------------------------
# Ne touchez pas à cette partie du script sauf si vous savez ce que 
# vous faites !
#-----------------------------------------------------------------------------
begin
  # Préparation des entrées clavier pour le passage en full screen/fenêtré
  $screen_switch = Win32API.new("user32","keybd_event", "I I I I","") 
  # Servira à récupérer la résolution de l'écran pour savoir si le jeu est déjà 
  # en plein écran ou non
  $screen_ratio = Win32API.new("user32","GetSystemMetrics", "L","i") 
  
  
  # Inisation des variables liés à la police. 
  # Certaines variables seront modifiées au chargement du fichier Options.rxdata
  $style = "DP"
  $fontface = ["Pokemon DP", "Trebuchet MS"]
  $fontsizesmall = 15 # // hauteur min 14
  $fhs = 14
  $fontsize = 31 # // hauteur min 28
  $fh = 28
  $fontsizebig = 47
  $fhb = 42
  
  
  # Chargement du fichier Options.rxdata s'il existe
  if File.exist?("Options.rxdata")
      $save=load_data("Options.rxdata")
      $vit_txt                            =$save[0]
      $ecran                              =$save[1]
      $style                              =$save[2]
      # Les boîtes de dialogue sont chargées dans Scene_Title de Système General
      $anim                               =$save[5]
      $battle_style                       =$save[6]
      $bgm_master                         =$save[7]
      $bgs_master                         =$save[8]
      $me_master                          =$save[9]
      $se_master                          =$save[10]
      $dial_type                          =$save[11]
      $fontface                           =$save[12]
      $fontsizesmall                      =$save[13]
      $fontsize                           =$save[14]
      $fontsizebig                        =$save[15]
      $frame_rate                         =$save[16]
      Graphics.frame_rate                 =$save[16] if $frame_rate
      
      if $ecran == 1 and $screen_ratio.call(0) != 640 and 
         $screen_ratio.call(1) !=480
        #passage en mode plein écran
        $screen_switch.call(18,0,0,0) # ALT Down
        $screen_switch.call(13,0,0,0) # Entrée Down
        $screen_switch.call(13,0,2,0) # Entrée Up
        $screen_switch.call(18,0,2,0) # ALT Up
      end
    end
  end

module POKEMON_S
class Scene_Settings
  #-------------------------------------------------------------------------
  # Suivez les instructions dans les commentaires
  #-------------------------------------------------------------------------
  Interface = "" # Mettez le nom du fichier de votre interface avec l'extension 
                 # dans les guillemets. 
                 # L'image doit se trouver dans Graphics/Pictures
  # mettre à true si vous voulez utiliser l'interface
  Affichage_Interface = false 
  
  def main        
    #------------------------------------------------------------------------
    # Ne touchez pas à la suite du script sauf si vous savez ce que 
    # vous faites !
    #------------------------------------------------------------------------
	
    # Définition des variables globales qui seront sauvegardées et appelées dans 
    # les autres scripts
    $vit_txt ||= POKEMON_S::SPEED_MSG
    $ecran ||= 0
    $message_dummy ||= MSG
    $dial_type ||= 1
    $anim ||= 1
    $battle_style ||= 0
    $bgm_master ||= 100
    $bgs_master ||= 100
    $me_master ||= 100
    $se_master ||= 100
    $frame_rate ||= 40
    # compatibilité avec les variables de la 1.0
    $ecran = ECRAN_HASH.index($ecran) if $ecran.is_a?(String)
    $anim = ANIM_HASH.index($anim) if $anim.is_a?(String)
    if $battle_style.is_a?(String)
      $battle_style = BATTLE_STYLE_HASH.index($battle_style) 
    end
    
    # Mémorisation des audios qui tournent en boucle
    $game_system.bgm_memorize
    $game_system.bgs_memorize
    
    # Valeur de sauvegarde d'entrée dans le menu options
    @vit_text_initial = $vit_txt
    @ecran_initial = $ecran
    @message_dummy_initial = $message_dummy
    @dial_type_initial = $dial_type
    @anim_initial = $anim
    @battle_style_initial = $battle_style
    @bgm_master_initial = $bgm_master
    @bgs_master_initial = $bgs_master
    @me_master_initial = $me_master
    @se_master_initial = $se_master
    @frame_rate_initial = $frame_rate
    
    @fenetre = 0
    @index = 0
    @index_font_initial = @index_font = FONT_SHORTCUT.index($style)
    
    @background = Sprite.new
    @background.bitmap = RPG::Cache.picture(DATA_OPTIONS[:background])
    
    if Affichage_Interface
      @interface = Sprite.new
      @interface.bitmap = RPG::Cache.picture(Interface)
      @interface.z = 100
    end
    
    @select_categ = Sprite.new
    @select_categ.bitmap = RPG::Cache.picture(DATA_OPTIONS[:select_categorie])
    @select_categ.x = 15
    @select_categ.y = 56
    @select_categ.z = 101
    
    @select_param = Sprite.new
    @select_param.bitmap = RPG::Cache.picture(DATA_OPTIONS[:select_settings])
    @select_param.visible = false
    @select_param.x = 442
    @select_param.y = 18
    @select_param.z = 101
    
    @category = Window_Base.new(0,18,160,312)
    @category.contents = Bitmap.new(160,312)
    @category.z = 100
    @category.opacity = 0 if Affichage_Interface
    @category.contents.font.name = $fontface
    @category.contents.font.size = $fontsize
    @category.contents.font.color = @category.normal_color
    @category.contents.draw_text(-15,21,@category.width,32,"Système",1)
    @category.contents.draw_text(-15,90,@category.width,32,"Graphismes",1)
    @category.contents.draw_text(-15,159,@category.width,32,"Audio",1)
    @category.contents.draw_text(-15,228,@category.width,32,"Sauver",1)
    
    unless Affichage_Interface
      @setting_window = Window_Base.new(165,6,470,337)
      @setting_window.z = 100
    end
    
    @settings_text = Window_Base.new(165,6,280,337)
    @settings_text.opacity = 0
    @settings_text.z = 101
    @settings_text.contents = Bitmap.new(235,337)
    @settings_text.contents.font.name=$fontface
    @settings_text.contents.font.size=$fontsize
    @settings_text.contents.font.color= @settings_text.disabled_color
    
    @settings_select = Window_Base.new(400,6,235,337)
    @settings_select.opacity = 0
    @settings_select.z = 101
    @settings_select.contents = Bitmap.new(235,337)
    @settings_select.contents.font.name=$fontface
    @settings_select.contents.font.size=$fontsize
    @settings_select.contents.font.color= @settings_select.disabled_color
    
    @text_window = Window_Base.new(5,347,630,123)
    @text_window.z = 101
    @text_window.opacity = 0
    @text_window.contents=Bitmap.new(@text_window.width-16,@text_window.height)
    @text_window.contents.font.name=$fontface
    @text_window.contents.font.size=$fontsize
    @text_window.contents.font.color = @text_window.normal_color
    @dummy = Sprite.new
    unless $message_dummy
      @dummy.bitmap = RPG::Cache.picture(MSG)
    else
      @dummy.bitmap = RPG::Cache.picture($message_dummy)
    end
    @dummy.y = 336
    @dummy.z = 100
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
    
    # Restauration des audios qui tournent en boucle
    $game_system.bgm_restore
    $game_system.bgs_restore

    @background.dispose
    @interface.dispose if Affichage_Interface
    @text_window.dispose
    @dummy.dispose
    @category.dispose
    @setting_window.dispose unless Affichage_Interface
    @settings_text.dispose
    @settings_select.dispose
    @select_categ.dispose
    @select_param.dispose
  end
  
  def update
    # Changement du paramètre de la taille de la fenêtre si le joueur appuie 
    # sur ALT+Entrée
    if $ecran != 0 and $screen_ratio.call(0) != 640 and 
       $screen_ratio.call(1) != 480
      $ecran = 0
    elsif $ecran != 1 and $screen_ratio.call(0) == 640 and 
          $screen_ratio.call(1) == 480
      $ecran = 1
    end
    @background.update
    @interface.update if Affichage_Interface
    @category.update
    @text_window.update
    @dummy.update
    @setting_window.update unless Affichage_Interface
    @settings_text.update
    @settings_select.update
    @select_categ.update
    @select_param.update
    update_command
  end
  
  def update_command
    if Input.repeat?(Input::DOWN)
      $game_system.se_play($data_system.cursor_se)
      # Si on est sur la fenêtre des catégories
      if @fenetre == 0
        @index += 1
        @select_categ.y += 69
        if @index > 3
          @index =3
          @select_categ.y = 263
        end
      # Si on est sur la fenêtre des options
      else
        @select_index += 1
        @select_param.y += 32
        if @select_index > @nb_param
          @select_index = @nb_param
          @select_param.y = 18+@select_index*32
        end
      end
    end
    
    if Input.repeat?(Input::UP)
      $game_system.se_play($data_system.cursor_se)
      # Si on est sur la fenêtre des catégories
      if @fenetre == 0
        @index -= 1
        @select_categ.y -= 69
        if @index < 0
          @index =0
          @select_categ.y = 56
        end
      # Si on est sur la fenêtre des options
      else
        @select_index -= 1
        @select_param.y -= 32
        if @select_index < 0
          @select_index = 0
          @select_param.y = 18
        end
      end
    end
    
    # Gestion des commandes sur la fenêtre des options
    if @fenetre == 1
      if Input.repeat?(Input::RIGHT)
        $game_system.se_play($data_system.cursor_se)
        case @index
        when 0
          # Options système
          case @select_index
          when 0
            # Changer la vitesse du texte
            $vit_txt +=1
            $vit_txt = 1 if $vit_txt >3
          when 1
            #Plein ecran/fenetre
            $ecran = $ecran == 0 ? 1 : 0
            # Execution de ALT+Entrée
            $screen_switch.call(18,0,0,0) # ALT Down
            $screen_switch.call(13,0,0,0) # Entrée Down
            $screen_switch.call(13,0,2,0) # Entrée Up
            $screen_switch.call(18,0,2,0) # ALT Up
          when 2
            # Changement de police
            @index_font += 1
            @index_font = 0 if @index_font > FONT_LIST.length-1
            $style = FONT_SHORTCUT[@index_font]
            $fontface = [FONT_LIST[@index_font], "Trebuchet MS"]
            $fontsizesmall = FONT_SIZE[3*@index_font]
            $fontsize = FONT_SIZE[3*@index_font+1]
            $fontsizebig = FONT_SIZE[3*@index_font+2]
            refresh
          when 3
            # Activation/Désactivation des animations de combat
            $anim += 1
            $anim = 0 if $anim > 1
          when 4
            # Changement du style de combat
            $battle_style += 1
            $battle_style = 0 if $battle_style > 1
          when 5
            # Changement de la vitesse du jeu
            frame_array = FRAME_RATE_HASH.keys.sort
            frame_index = frame_array.index($frame_rate) + 1
            if frame_index < frame_array.size 
              $frame_rate = frame_array[frame_index]
            end
            refresh
          end
        when 1
          # Options graphiques
          case @select_index
          when 0
            # Changement de la boîte de dialogue
            $dial_type +=1
            $dial_type = 1 if $dial_type > BOX_LIST.length
            $data_system.windowskin_name = BOX_LIST[$dial_type-1]
            $message_dummy = "messagedummy_"+($dial_type-1).to_s+".png"
            refresh
          end          
        when 2
          # Options Audio
          case @select_index
          when 0
            # Augmentation des BGM
            $bgm_master +=5
            $bgm_master = 100 if $bgm_master > 100
            $game_system.bgm_restore
            $game_system.bgm_memorize
          when 1
            # Augmentation des BGS
            $bgs_master +=5
            $bgs_master = 100 if $bgs_master > 100
            $game_system.bgs_restore
            $game_system.bgs_memorize
          when 2
            # Augmentation des ME
            $me_master +=5
            $me_master = 100 if $me_master > 100
          when 3
            # Augmentation des SE
            $se_master +=5
            $se_master = 100 if $se_master > 100
          end
        end
      end
    
      if Input.repeat?(Input::LEFT)
        $game_system.se_play($data_system.cursor_se)
        case @index
        when 0
          # Options système
          case @select_index
          when 0
            # Changer la vitesse du texte
            $vit_txt -=1
            $vit_txt = 3 if $vit_txt < 1
          when 1
            # Plein ecran/fenetre
            $ecran = $ecran == 0 ? 1 : 0
            # Execution de ALT+Entrée
            $screen_switch.call(18,0,0,0) #ALT Down
            $screen_switch.call(13,0,0,0) #Entrée Down
            $screen_switch.call(13,0,2,0) #Entrée Up
            $screen_switch.call(18,0,2,0) #ALT Up
          when 2
            # changement de police
            @index_font -= 1
            @index_font = FONT_LIST.length-1 if @index_font < 0
            $style = FONT_SHORTCUT[@index_font]
            $fontface = [FONT_LIST[@index_font], "Trebuchet MS"]
            $fontsizesmall = FONT_SIZE[3*@index_font]
            $fontsize = FONT_SIZE[3*@index_font+1]
            $fontsizebig = FONT_SIZE[3*@index_font+2]
            refresh
          when 3
            # Activation/Désactivation des animations de combat
            $anim -= 1
            $anim = 1 if $anim < 0
          when 4
            # Changement du style de combat
            $battle_style -= 1
            $battle_style = 1 if $battle_style < 0
          when 5
            # Changement de la vitesse du jeu
            frame_array = FRAME_RATE_HASH.keys.sort
            frame_index = frame_array.index($frame_rate) - 1
            if frame_index >= 0
              $frame_rate = frame_array[frame_index]
            end
            refresh
          end
        when 1
          # Options graphiques
          case @select_index
          when 0
          # Changement de la boîte de dialogue
          $dial_type -=1
          if $dial_type < 1
            $dial_type = BOX_LIST.length
          end
          $data_system.windowskin_name = BOX_LIST[$dial_type-1]
          $message_dummy = "messagedummy_"+($dial_type-1).to_s+".png"
          refresh
          end          
        when 2
          # Options Audio
          case @select_index
          when 0
            # Diminution des BGM
            $bgm_master -=5
            if $bgm_master < 0
              $bgm_master = 0
            end
            $game_system.bgm_restore
            $game_system.bgm_memorize
          when 1
            # Diminution des BGS
            $bgs_master -=5
            if $bgs_master < 0
              $bgs_master = 0
            end
            $game_system.bgs_restore
            $game_system.bgs_memorize
          when 2
            # Diminution des ME
              $me_master -=5
            if $me_master< 0
              $me_master = 0
            end
          when 3
            # Diminution des SE
              $se_master -=5
            if $se_master < 0
              $se_master = 0
            end
          end
        end
      end
    end
    
    if Input.trigger?(Input::B)
      if @fenetre == 0 
          # Proposer la sauvegarde et quitter
          draw_text_window("Voulez-vous sauvegarder ces paramètres ?")
          if draw_choice
            sauvegarde
          else
            # Rétablissement des valeurs initiales des variables globales
            if @ecran_initial != $ecran
              # Modification de l'affichage d'écran
              $screen_switch.call(18,0,0,0) # ALT Down
              $screen_switch.call(13,0,0,0) # Entrée Down
              $screen_switch.call(13,0,2,0) # Entrée Up
              $screen_switch.call(18,0,2,0) # ALT Up
            end
            $game_system.se_play($data_system.cancel_se)
            $vit_txt = @vit_text_initial
            $ecran = @ecran_initial
            $message_dummy = @message_dummy_initial
            $dial_type = @dial_type_initial
            $anim = @anim_initial
            $battle_style = @battle_style_initial
            $bgm_master = @bgm_master_initial
            $bgs_master = @bgs_master_initial
            $me_master = @me_master_initial
            $se_master = @se_master_initial
            $frame_rate = @frame_rate_initial
            # Rétablissement des polices d'écritures initiales
            $style = FONT_SHORTCUT[@index_font_initial]
            $fontface = [FONT_LIST[@index_font_initial], "Trebuchet MS"]
            $fontsizesmall = FONT_SIZE[3*@index_font_initial]
            $fontsize = FONT_SIZE[3*@index_font_initial+1]
            $fontsizebig = FONT_SIZE[3*@index_font_initial+2]
            # Rétablissement de la couleur des fenêtres
            $data_system.windowskin_name = BOX_LIST[@dial_type_initial-1]
          end
        $scene = POKEMON_S::Pokemon_Menu.new(4)
        return
      else
        # Retour sur la fenêtre des catégories
        @settings_text.contents.font.color = @settings_text.disabled_color
        @settings_select.contents.font.color = @settings_select.disabled_color
        @fenetre = 0
        @select_param.visible = false
        @select_categ.visible = true
      end
    end
      
    if Input.trigger?(Input::C)
      if @index != 3
        if @fenetre == 0
          # Passer sur la fenêtre des Options
          $game_system.se_play($data_system.decision_se)
          @settings_text.contents.font.color = @settings_text.normal_color
          @settings_select.contents.font.color = @settings_select.normal_color
          @select_index = 0
          @select_param.y = 18
          @select_param.visible = true
          @select_categ.visible = false
          @fenetre = 1
        else
          $game_system.se_play($data_system.cancel_se)
          # Retour sur la fenêtre des Catégories
          @settings_text.contents.font.color = @settings_text.disabled_color
          @settings_select.contents.font.color = @settings_select.disabled_color
          @fenetre = 0
          @select_param.visible = false
          @select_categ.visible = true
        end
      else
        # Sauvegarder
        sauvegarde
        $scene = Scene_Map.new
        return
      end
    end
      
    case @index
    # Ecriture des paramètres et des définitions
    when 0
      if @fenetre == 0
        draw_text_window("","Gérer les paramètres système")
      else
        case @select_index
        when 0
          draw_text_window("Sélectionnez la vitesse des dialogues :",
                           "1 - Lent      2 - normal      3 - rapide")
        when 1
          draw_text_window("Sélectionnez la taille de l'écran :",
                           "- Fenêtré","- Plein écran")
        when 2
          draw_text_window("Sélectionnez la police d'écriture")
        when 3
          draw_text_window("Activez ou désactivez les animations de combat")
        when 4 
          draw_text_window("Sélectionnez le style de combat :",
                           "- Choix","- Défini")
        when 5
          draw_text_window("Changer la vitesse du jeu.",
                           "la vitesse dépendra de la puissance de votre PC")
        end
      end
      draw_text_settings(["Vitesse des dialogues", "Taille de l'écran", 
                          "Police d'écriture", "Animations de combat", 
                          "Style de combat", "Vitesse du jeu"])
      draw_text_select([$vit_txt.to_s, ECRAN_HASH[$ecran], 
                        "Pokémon #{$style}", ANIM_HASH[$anim],
                        BATTLE_STYLE_HASH[$battle_style],
                        FRAME_RATE_HASH[$frame_rate]])
    when 1
      if @fenetre == 0
        draw_text_window("","Gérer les paramètres graphiques")
      else
        case @select_index
        when 0
          draw_text_window("Choisir l'apparence des boîtes de dialogue")
        end
      end
      draw_text_settings(["Boîtes de dialogue"])
      draw_text_select(["Type #{$dial_type.to_s}"])
    when 2
      if @fenetre == 0
        draw_text_window("", "Gérer les paramètres audio")
      else
        case @select_index
        when 0
          draw_text_window("Réglez le volume des musiques",
                           "Les modifications seront effectuées lors du prochain", 
                           "changement de zone.")
        when 1
          draw_text_window("Réglez le volume des sons d'ambiance",
                           "Les modifications seront effectuées lors du prochain", 
                           "changement de zone.")
        when 2
          draw_text_window("Réglez le volume des effets musicaux")
        when 3
          draw_text_window("Réglez le volume des effets sonores")
        end
      end
      draw_text_settings(["Musiques","Sons d'ambiance", "Effets musicaux",
                          "Effets sonores"])
      draw_text_select(["#{$bgm_master} %", "#{$bgs_master} %", 
                        "#{$me_master} %", "#{$se_master} %"])
    when 3
      draw_text_window("","Sauvegarder les paramètres") if @fenetre == 0
      draw_text_settings([])
      draw_text_select([])
    end
      
  end
  
  def refresh
    @category.contents.font.name = $fontface
    @category.contents.font.size = $fontsize
    @category.contents.clear
    @category.contents.draw_text(-15,21,@category.width,32,"Système",1)
    @category.contents.draw_text(-15,90,@category.width,32,"Graphismes",1)
    @category.contents.draw_text(-15,159,@category.width,32,"Audio",1)
    @category.contents.draw_text(-15,228,@category.width,32,"Sauver",1)
    
    
    @settings_text.contents.font.name=$fontface
    @settings_text.contents.font.size=$fontsize
    
    @settings_select.contents.font.name=$fontface
    @settings_select.contents.font.size=$fontsize
    
    @dummy.bitmap = RPG::Cache.picture($message_dummy)
    
    Graphics.frame_rate = $frame_rate
  end
    
    def draw_text_window(string_1="",string_2="",string_3="")
      @text_window.contents.clear
      @text_window.contents.draw_text(4,-4,@text_window.width-40,32,string_1)
      @text_window.contents.draw_text(4,26,@text_window.width-40,32,string_2)
      @text_window.contents.draw_text(4,58,@text_window.width-40,32,string_3)
    end
    
    def draw_text_settings(string=[])
      @settings_text.contents.clear
      (0..string.length-1).each do |i|
        @settings_text.contents.draw_text(0, -4+32*i, @settings_text.width, 32,
                                          string[i])
      end
    end
    
    def draw_text_select(string=[])
      @settings_select.contents.clear
      (0..string.length-1).each do |i|
        @settings_select.contents.draw_text(0, -4+32*i, @settings_select.width,
                                            32, string[i], 1)
      end
      @nb_param = string.length-1
    end
    
    def draw_choice
      @command = Window_Command.new(120, ["OUI", "NON"], $fontsizebig)
      @command.x = 515
      @command.y = 224
      loop do
        Graphics.update
        Input.update
        @command.update
        if Input.trigger?(Input::C) and @command.index == 0
          @command.dispose
          @command = nil
          Input.update
          return true
        end
        if Input.trigger?(Input::C) and @command.index == 1
          @command.dispose
          @command = nil
          Input.update
          return false
        end
      end
    end
    
    def sauvegarde
      file = File.open("Options.rxdata","wb")
      $save = [$vit_txt, $ecran, $style, $data_system.windowskin_name, 
               $message_dummy, $anim, $battle_style, $bgm_master, $bgs_master, 
               $me_master, $se_master, $dial_type, $fontface, $fontsizesmall, 
               $fontsize, $fontsizebig, $frame_rate]
      Marshal.dump($save,file)
      file.close
      $game_system.se_play($data_system.save_se)
    end
  end  
end