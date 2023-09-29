#==============================================================================
# ■ Scene_Map
# Pokemon Script Project - Krosk 
# 18/07/07
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Variables appelées:
# $random_encounter
#   Défini les monstres rencontrés sur la map et la fréquence d'apparition.
#   Voir le script Random_Encounter.
#----------------------------------------------------------------------------

class Scene_Map
  attr_reader :spriteset

  #----------------------------------------------------
  # Appel du menu
  #----------------------------------------------------
  def call_menu
    # Redéfinition
    $game_temp.menu_calling = false
    if $game_temp.menu_beep
      $game_system.se_play($data_system.decision_se)
      $game_temp.menu_beep = false
    end
    $game_player.straighten
    $scene = POKEMON_S::Pokemon_Menu.new
  end
  
  
  #----------------------------------------------------
  # Appel de la sauvegarde
  ##----------------------------------------------------
  def call_save
    $game_player.straighten
    $scene = POKEMON_S::Pokemon_Save.new
  end
  
  
  #----------------------------------------------------
  # Mise à jour de Scene_map
  #----------------------------------------------------
  def update
    # MAJ du système général
    loop do
      $game_map.update
      $game_system.map_interpreter.update
      $game_player.update
      $game_system.update
      $game_screen.update
      break unless $game_temp.player_transferring
      transfer_player
      break if $game_temp.transition_processing
    end
    @spriteset.update
    @message_window.update
    
    # Contrôler la taille de l'écran
    size_screen_checking
    
    # Contrôler un changement de scène
    if $game_temp.gameover
      $scene = Scene_Gameover.new
      return
    end
    if $game_temp.to_title
      $scene = Scene_Title.new
      return
    end
    
    # Contrôler les transitions
    transition_checking
    
    # Si un message est affiché
    if $game_temp.message_window_showing
      return
    end
    
    if $game_map.map_id != POKEMON_S::_WMAPID
      # Contrôler Repousse
      repel_checking
      
      # Contrôler les rencontres avec des Pokémon Sauvages
      encounter_checking
    else
      # Contrôler le mode mappemonde
      world_map_checking
    end
    
    # Contrôler les Inputs
    input_checking
    
    # Contrôler les appels
    call_checking
  end
  
  
  #----------------------------------------------------
  # Changement de map :
  # $random_encounter se met à jour : reset, puis remplissage
  # s'il y a des groupes d'ennemis définis sur la map
  #----------------------------------------------------
  def transfer_player
    $game_switches[CANNE_UTILISABLE] = false
    # Indicateur Force
    $on_strength = false
    
    $game_temp.player_transferring = false

    if $game_map.map_id != $game_temp.player_new_map_id
      $game_map.setup($game_temp.player_new_map_id)
    end
    
     if $game_map.map_id != POKEMON_S::_WMAPID and 
        $game_temp.player_new_map_id != POKEMON_S::_WMAPID
      # MAJ des listes de rencontres
      $random_encounter.update
    end
    
    $game_player.moveto($game_temp.player_new_x, $game_temp.player_new_y)

    case $game_temp.player_new_direction
    when 2  # 下
      $game_player.turn_down
    when 4  # 左
      $game_player.turn_left
    when 6  # 右
      $game_player.turn_right
    when 8  # 上
      $game_player.turn_up
    end

    $game_player.straighten
    $game_map.update
    @spriteset.dispose
    @spriteset = Spriteset_Map.new
    
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      Graphics.transition(20)
    end
    
    $game_map.autoplay
    Graphics.frame_reset
    Input.update
  end
  
  
  #----------------------------------------------------
  # Contrôler les transitions
  #----------------------------------------------------
  def transition_checking
    if $game_temp.transition_processing
      $game_temp.transition_processing = false
      if $game_temp.transition_name == ""
        Graphics.transition(20)
      else
        Graphics.transition(40, "Graphics/Transitions/" +
          $game_temp.transition_name)
      end
    end
  end
  
  
  #----------------------------------------------------
  # Contrôler les Inputs
  #----------------------------------------------------
  def input_checking
    if Input.trigger?(Input::B)
      unless $game_system.map_interpreter.running? or $game_system.menu_disabled
        $game_temp.menu_calling = true
        $game_temp.menu_beep = true
      end
    end
	
    if $DEBUG and Input.press?(Input::F8)
      TAG_SYS.call_tag_editor
    end
    
    if $DEBUG and Input.press?(Input::F9)
      $game_temp.debug_calling = true
    end
    
    if $DEBUG and Input.press?(Input::F7)
      CONVERTISSEUR_BDD.call_menu
    end
  end
  
  
  #----------------------------------------------------
  # Changement du paramètre de la taille de la fenêtre si
  # le joueur appuie sur ALT+Entrée
  #----------------------------------------------------
  def size_screen_checking
    if $ecran != 0 and $screen_ratio.call(0) != 640 and 
       $screen_ratio.call(1) != 480
      $ecran = 0
    elsif $ecran != 1 and $screen_ratio.call(0) == 640 and 
          $screen_ratio.call(1) == 480
      $ecran = 1
    end
  end
  
  
  #----------------------------------------------------
  # Contrôler le mode Mappemonde
  #----------------------------------------------------
  def world_map_checking
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    $game_temp.debug_calling = false
    if Input.trigger?(Input::B)
      $game_temp.back_calling = true
    end
    if [2,4,6,8].include?(Input.dir4)
      $game_temp.world_map_event_checking = true
    end
    $game_player.check_world_map unless $game_player.moving?
  end
  
  
  #----------------------------------------------------
  # Contrôler les appels de scènes
  #----------------------------------------------------
  def call_checking
    unless $game_player.moving?
      return call_battle if $game_temp.battle_calling
      return call_shop if $game_temp.shop_calling
      return call_name if $game_temp.name_calling
      return call_menu if $game_temp.menu_calling
      return call_save if $game_temp.save_calling
      return call_debug if $game_temp.debug_calling
      return call_back_world_map if $game_temp.back_calling
    end
  end
  
  
  #----------------------------------------------------
  # Contrôler Repousse
  #----------------------------------------------------
  def repel_checking
    @message_rappel = true if $pokemon_party.repel_count > 0
    if !$game_player.moving? and $pokemon_party.repel_count == 0 and @message_rappel
      $game_temp.common_event_id = 45 #45 = l'id de l'événement commun du message
      @message_rappel = false
    end
  end
  
  
  #----------------------------------------------------
  # Contrôler les rencontres avec des Pokémon Sauvages
  #----------------------------------------------------
  def encounter_checking
    # MAJ du repère horaire et de la liste des rencontres à chaque chgt d'heure
    $random_encounter.hour_checking
    # Comptage Rencontre aléatoire
    if !$random_encounter.empty? and $game_player.encounter_count == 0
      tag = $game_player.terrain_tag
      unless $game_system.map_interpreter.running? or
              $game_system.encounter_disabled or 
              tag == 0 or 
              $pokemon_party.empty?
        enemy_list = $random_encounter[tag]
        if enemy_list and enemy_list.size >= 1
          $game_temp.battle_calling = true
        end
      end
    end
  end
  
  
  #----------------------------------------------------
  # Appel d'un combat sauvage
  #----------------------------------------------------
  def call_battle
    tag = $game_player.terrain_tag
    $game_temp.battle_calling = false
    $game_temp.menu_calling = false
    $game_temp.menu_beep = false
    $game_player.make_encounter_count
    
    list_pokemon = []
    total_rarity = 0
    
    # On Ajoute tous les Pokémon des différents groupes
    $random_encounter[tag].each do |group|
      if group.is_a?(POKEMON_S::Encounter) and
          group.id_page == POKEMON_S::Encounter.index_page(group.id)
        group.info_pokemon.each do |pokemon| 
          list_pokemon.push(pokemon)
          total_rarity += pokemon.rarity
        end
      end
    end
    
    # On tri la liste en sortie
    list_pokemon.sort do |pokemon_a, pokemon_b|
      pokemon_a.rarity <=> pokemon_b.rarity
    end
    
    # On détermine un nombre aléatoire parmi le total de rarity
    value_random = rand(total_rarity)
    
    # Recherche du Pokémon le plus proche de la valeur
    pokemon = list_pokemon[0]
    i = 0
    if list_pokemon[0]
      total_rarity = list_pokemon[0].rarity 
      while i < list_pokemon.size and value_random > total_rarity
        i += 1
        pokemon = list_pokemon[i]
        total_rarity += list_pokemon[i].rarity
      end
      
      pokemon = pokemon.create_pokemon
      if $pokemon_party.repel_count > 0 and pokemon.level < $pokemon_party.max_level
        $game_player.make_encounter_count
        return
      end
      
      $game_temp.map_bgm = $game_system.playing_bgm
      $game_system.bgm_stop
      $game_system.se_play($data_system.battle_start_se)
      $game_player.straighten
      
      if $game_switches[MODE_SAFARI]
        $scene = POKEMON_S::Pokemon_Battle_Safari.new(pokemon)
      else
        $scene = POKEMON_S::Pokemon_Battle_Wild.new($pokemon_party, pokemon)
      end
    end
  end
  
end