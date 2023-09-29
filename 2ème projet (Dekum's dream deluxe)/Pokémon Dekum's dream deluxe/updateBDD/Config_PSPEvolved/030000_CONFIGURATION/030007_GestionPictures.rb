#==============================================================================
# ■ Gestion_Pictures
# Pokemon Script Project - Krosk 
# Gestion_Pictures - Damien Linux
# 28/01/2020
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------

# Variables globales (utilisées dans de nombreux scripts)
# --------------------------------------------------------
# MSG
#   - Fichier image de la boîte de dialogue du jeu
#     dans le dossier Graphics/Pictures
# --------------------------------------------------------
MSG = "messagedummy_0.png"

# --------------------------------------------------------
# BATTLE_MSG
#   - Fond de la fenêtre de message au combat
#     dans le dossier Graphics/Pictures
# --------------------------------------------------------
BATTLE_MSG = "dummyBattle1.png"

# --------------------------------------------------------
# INFO_MSG
#   - Fond de la fenêtre de divers scène
#     dans le dossier Graphics/Pictures
# --------------------------------------------------------
INFO_MSG = "dummy1.png"

# --------------------------------------------------------
# ARRIERE_PLAN
#   - Fond de l'arrière plan du PC / Battle_Core /
#     MAPLINK dans le dossier Graphics/Pictures
# --------------------------------------------------------
ARRIERE_PLAN = "black.png"

# --------------------------------------------------------
# FEMELLE
#   - Icon indiquant un pokémon femelle dans :
#     Window_Pokemon / Pokemon_Party_Window / Pokemon_Battle_Status /
#     Carte_Dresseur dans le dossier Graphics/Pictures
# --------------------------------------------------------
FEMELLE = "Femaleb.png"

# --------------------------------------------------------
# MALE
#   - Icon indiquant un pokémon male dans :
#     Window_Pokemon / Pokemon_Party_Window / Pokemon_Battle_Status /
#     Carte_Dresseur dans le dossier Graphics/Pictures
# --------------------------------------------------------
MALE = "Maleb.png"
  
# --------------------------------------------------------
# SHINY_INTERFACE
#   - Icon indiquant un pokémon shiny dans l'inteface menu dans :
#     Pokemon_Status / Pokemon_Box_Status dans le dossier Graphics/Pictures
# --------------------------------------------------------
SHINY_INTERFACE = "shiny_interface.PNG"

# --------------------------------------------------------
# SHINY_INTERFACE
#   - Icon indiquant un pokémon shiny dans l'inteface status dans :
#     Pokemon_Box_Viewer
# --------------------------------------------------------
SHINY = "shiny.PNG"
  
# --------------------------------------------------------
# HP_BARRE
#   - Barre d'HP du pokémon dans : Pokemon_Party_Window / 
#     Pokemon_Battle_Status dans le dossier Graphics/Pictures
# --------------------------------------------------------
HP_BARRE = "Battle/hpbar.png"
  
# --------------------------------------------------------
# HP_BARRE_SMALL
#   - Petite barre d'HP du pokémon dans : Pokemon_Party_Window / 
#     Pokemon_Battle_Status dans le dossier Graphics/Pictures
# --------------------------------------------------------
HP_BARRE_SMALL = "Battle/hpbarsmall.png"
  
# --------------------------------------------------------
# SKILL_SELECTION
#   - Cadre de sélection des attaques dans : Pokemon_Status /
#     Pokemon_Skill_Learn / Pokemon_Skill_Selection
#     dans le dossier Graphics/Pictures
# --------------------------------------------------------
SKILL_SELECTION = "skillselection.png"
  
# --------------------------------------------------------
# SKILL_SELECTIONNE
#   - Cadre sur une attaque sélectionnée dans : Pokemon_Status /
#     Pokemon_Skill_Learn / Pokemon_Skill_Selection
#     dans le dossier Graphics/Pictures
# --------------------------------------------------------
SKILL_SELECTIONNE = "skillselected.png"

# --------------------------------------------------------
# MENU_SKILL
#   - Interface du menu des attaques dans : Pokemon_Skill_Learn / 
#     Pokemon_Skill_Selection dans le dossier Graphics/Pictures
# --------------------------------------------------------
MENU_SKILL = "MenuSkill.png"

# --------------------------------------------------------
# TRACES DE PAS (FootPrint)
#   - Traces de pas pour l'ensemble des déplacements
#   - dans le dossier Tilesets
# --------------------------------------------------------
FP_FILE = "footprints_default"

# --------------------------------------------------------
# Ombre sous les personnages (Graphics/Pictures)
# --------------------------------------------------------
SHADOW = "shadow.png"

# --------------------------------------------------------
# FOND QUAND SURF ou CANNE
# --------------------------------------------------------
FOND_SURF = "Océans.png"

# --------------------------------------------------------
# FOND de la scène Pokemon_Evolve
# --------------------------------------------------------
EVOLVE_BACKGROUND = "HatchBack.png"
  
# Centralisation des images qui sont dans les scripts. Les tableaux sont des
# regroupement de scripts. Les scripts concernés sont et doivent être
# précisés en commentaire avec le dossier appellé dans "Graphics" (où se
# trouve l'image) pour pouvoir s'y retrouver
# Scene_Title_SG
DATA_TITLE = {
   # Dossier : Titles
   :opening1 => "Opening2.jpg",
   :opening2 => "Opening3.png",
   :opening3 => "Opening4.png",
   :opening4 => "Opening1.png",
   :opening5 => "Opening6.png",
   :opening6 => "Opening7.png",
   :opening7 => "Opening8.png",
   :opening8 => "Opening5.png",
   :opening9 => "Opening10.png",
   :opening10 => "Opening11.png",
   # Dossier : Pictures
   :fond_menu => "fondsaved.png"
}
                
# Dossier : Pictures              
DATA_MENU = {
   # Pokemon_Menu - Interface menu
   :interface_garcon => "Interface Menu_2.png",
   :interface_fille => "Interface Menu_1.png",
   # Pokemon_Party_Menu
   :interface_equipe => "Partyfond.png",
   # Pokemon_Party_Windows - Premier pokémon de l'équipe
   :cadre_premier_pokemon_selection => "cadretetem.png",
   :cadre_premier_pokemon_hover => "cadretetedl.png",
   :cadre_premier_pokemon_ko_hover => "cadretetel.png",
   :cadre_premier_pokemon => "cadreteted.png",
   :cadre_premier_pokemon_ko => "cadretete.png",
   # Pokemon_Party_Windows - Autres pokémon de l'équipe
   :cadre_pokemon_selection => "cadrepartym.png",
   :cadre_pokemon_hover => "cadrepartydl.png",
   :cadre_pokemon_ko_hover => "cadrepartyl.png",
   :cadre_pokemon => "cadrepartyd.png",
   :cadre_pokemon_ko => "cadreparty.png",
   # Pokemon_Party_Windows - Icon possession d'un objet
   :objet => "item_hold.png",
   # Pokemon_Status - Interface menu
   :interface_informations => "MenuAfond.png",
   :interface_skills => "MenuCfond.png",
   :interface_skills_details => "MenuDfond.png",
   :interface_informations_stats => "MenuBfond.png",
   :icon_physique => "icon_physique.png",
   :icon_speciale => "icon_speciale.png",
   :icon_status => "icon_status.png"
}

DATA_PC = {
   # Dossier : Pictures
   # Pokemon_Computer
   :background => "pc/background.png",
   :selection => "pc/select.png",
   :scrollrect => "pc/scrollrect.png",
   :scrollbar => "pc/scrollbar.png",
   # Pokemon_Box
   :fleche_navigation => "pc/boxarrow.png",
   :arriere_plan_boite => "pc/boxbackc.png",
   :arriere_plan_equipe => "pc/boxleft.png",
   # Pokemon_Computer_Item_Retiring
   :background_retire => "pc/item_retire.png",
   :icon_sac => "pc/icon_poche.png",
   :fleche_sac => "pc/arrow_item.png",
   # Dossier : Transitions
   # Pokemon_Box
   :computer_open => "computertr.png",
   :computer_close => "computertrclose.png"
}
    
# Dossier : Pictures           
DATA_SAC = {
   # Pokemon_Computer_Item_Stock et Pokemon_Item_Bag
   :background_fille => "background_sac_fille.png",
   :background_gars => "background_sac_gars.png",
   :icon_sac_fille => "bag_fille.png",
   :icon_sac_gars => "bag_gars.png",
   :navigation => "bag/arrow_item.png"
}
        
# Dossier : Pictures
DATA_SHOP = {
   # Pokemon_Shop_Buy et Pokemon_Shop_Buy_Distrib
   :fond_shop => "shopfond.png"
}
               
# Dossier : Pictures
DATA_BATTLE = {
   # Pokemon_Battle_Status
   :fenetre_status_enemy => "Battle/battle_sprite1.png",
   :ball_fenetre_status => "Battle/ballbattlestatus.png",
   :fenetre_status => "Battle/battle_sprite2.png",
   # Pokemon_Battle_Party_Status
   :party_status_enemy => "Battle/partystatusenemy.png",
   :party_status_actor => "Battle/partystatus.png",
   :ball_party_status => "Battle/ballpartystatus.png",
   :ball_party_status_ko => "Battle/ballpartystatusko.png",
   :back_default => "battle0.png",
   :ground_default => "groundbattle0.png",
   # Battle_Core_Interface ET Pokemon_Battle_Core
   :curseur_general => "Battle/CurseurMultiple.png",
   :curseur_attaque => "Battle/CurseurMultipleAttaque.png",
   :curseur_pokemon => "Battle/CurseurMultiplePokemon.png",
   :curseur_sac => "Battle/CurseurMultipleSac.png",
   :curseur_fuite => "Battle/CurseurMultipleFuite.png",
   # Battle_Core_Interface
   :curseur_choix_attaque => "Battle/CurseurAttaque.png",
   :choix_action => "Battle/ChoixMultiple.png",
   :choix_attaque => "Battle/ChoixAttaque.png",
   # Mega_evo
   :mega_off => "mega1.png",
   :mega_on => "mega2.png"
}

# Dossier : Pictures
DATA_PKDX = {
   # Pokemon_Pokdex et Pokemon_Detail
   :fond_1 => "Pokedex/Background_1.png",
   :fond_2 => "Pokedex/Background_2.png",
   :barre_commandes => "Pokedex/Commands_Bar.png",
   :cursors => "Pokedex/Cursors_Pkdx.png",
   :fenetre_forme => "Pokedex/Descr_Window.png",
   :femelle => "Pokedex/Female.png",
   :male => "Pokedex/Male.png",
   :intro_curseur => "Pokedex/Intro_Pkdx_Cursor.png",
   :intro_fenetre_on => "Pokedex/Intro_Pkdx_Win_On.png",
   :intro_fenetre_off => "Pokedex/Intro_Pkdx_Win_Off.png",
   :pokemon_capture => "Pokedex/Pokedexball.png",
   :selection => "Pokedex/Selection_Pkdx.png",
   :barre_titre => "Pokedex/Title_Bar.png",
   :fenetres_detail => "Pokedex/Windows_Pkdx_Detail.png",
   # Dossier : Windowskins
   :windowskin => "pokesys_pokedex.png"
}

# Dossier : Pictures
DATA_SCENE_NAME = {
   # Scene_Name_NOM et Pokemon_Name 
   :interface_name => "name.png"
}

# Dossier : Pictures
DATA_QUETES = {
   # Organisation_Quetes
   :interface_journal => "grim4.png"
}


DATA_CARD = {
   # Scene_T_Card
   # Dossier : Pictures
   :interface_card => "T_Card.PNG",
   :interface_verso_card => "T_Card_Verso",
   :sprite_fille => "Fille_001.png",
   :sprite_gars => "Garçon_001.png",
   :ensemble_pokemon => "T_Card Pokémon.PNG",
   :egg => "T_Card_Eggs.PNG",
   # Dossier : Icons
   :badge1 => "badge1.png",
   :badge2 => "badge2.png",
   :badge3 => "badge3.png",
   :badge4 => "badge4.png",
   :badge5 => "badge5.png",
   :badge6 => "badge6.png",
   :badge7 => "badge7.png",
   :badge8 => "badge8.png"
}

# Dossier : Pictures
DATA_PANTHEON = {
   # Scene_Pantheon
   :sprite_fille => "persofille.png",
   :sprite_gars => "persogars.png",
   :interface_pantheon => "Panthéon.png" 
}

# Dossier : Pictures
DATA_PUZZLE_ALPHA = {
   # Alph_Ruins_Puzzle
   :fond1 => "Puzzle_Ruines/Fond",
   :fond2 => "Puzzle_Ruines/Curseur",
   :curseur => "Puzzle_Ruines/Curseur",
   :curseurB => "Puzzle_Ruines/Curseur_b"
}

# Dossier : Pictures
DATA_OPTIONS = {
   # Scene_Settings
   :background => "Options_Background.png",
   :select_categorie => "Select_Category.png",
   :select_settings => "Select_Settings.png"
}

# Dossier : Pictures
DATA_TRACES = {  
  # Traces_Pas
  :trace_pas => "Traces/trace.png",
  :trace_velo => "Traces/trace_bike.png"
}

# Dossier : Pictures
DATA_TAG_EDITOR = {  
  :fond => "Tag_Editor/Fond_Menu_Tag",
  :cursor => "Tag_Editor/Cursor_Select",
  :tile_cursor => "Tag_Editor/Tile_Cursor",
  :grid => "Tag_Editor/Tileset_Grid"
}

# Dossier : Pictures
DATA_BATTLE_SAFARI =  {
  :appat => "appat_sprite.png",
  :boue => "boue_sprite.png"
}