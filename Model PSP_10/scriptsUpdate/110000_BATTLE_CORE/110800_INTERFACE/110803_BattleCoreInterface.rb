#==============================================================================
# ■ Pokemon_Battle_Core
# Pokemon Script Project - Krosk 
# 20/07/07
#-----------------------------------------------------------------------------
# Corrigé par RhenaudTheLukark et FL0RENT
# 10/01/16
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Restructuré par Damien Linux
# 14/01/2020
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Système de Combat - Squelette général
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# 0: Normal, 1: Poison, 2: Paralysé, 3: Brulé, 4:Sommeil, 5:Gelé, 8: Toxic
# @confuse (6), @flinch (7)
#-----------------------------------------------------------------------------
# 1 Normal  2 Feu  3 Eau 4 Electrique 5 Plante 6 Glace 7 Combat 8 Poison 9 Sol
# 10 Vol 11 Psy 12 Insecte 13 Roche 14 Spectre 15 Dragon 16 Acier 17 Tenebres
#-----------------------------------------------------------------------------
#-----------------------------------------------------------------------------
# $battle_var.action_id
#   0 : Phase de Sélection
#   1 : Sélection Item
#   2 : Switch Pokémon
#   4 : Switch Fin de Tour
#-----------------------------------------------------------------------------
module POKEMON_S
  #------------------------------------------------------------  
  # Pokemon_Battle_Core
  # - Début de scene
  # - Fin de scene
  # - Actualisation du placement des sprites
  #------------------------------------------------------------ 
  class Pokemon_Battle_Core
    #------------------------------------------------------------       
    # Début de scene
    #------------------------------------------------------------
    def initialisation_interface
      # Pré-création des Sprites
      # Fond
      coord = $game_player.front_tile
      if $game_switches[SURF_PECHE]
        @battleback_name = FOND_SURF
        @ground_name = "ground#{ FOND_SURF}"
      elsif @battleback_name != ""
        @battleback_name = "#{$game_map.battleback_name}.png"
        @ground_name = "ground#{ $game_map.battleback_name}.png"
      else
        @battleback_name = DATA_BATTLE[:back_default]
        @ground_name = DATA_BATTLE[:ground_default]
      end
      @background = Sprite.new
      @background.z = @z_level
      
      # Fond du message
      @message_background = Sprite.new
      @message_background.y = 336
      @message_background.z = @z_level + 19
      
      # Sprite de flash
      @flash_sprite = Sprite.new
      @flash_sprite.bitmap = RPG::Cache.picture(ARRIERE_PLAN)
      @flash_sprite.color = Color.new(255,255,255)
      @flash_sprite.opacity = 0
      @flash_sprite.z = @z_level + 13
      
      # Fenetre de texte
      @text_window = Window_Base.new(12, 340, 632, 136)
      @text_window.opacity = 0
      @text_window.z = @z_level + 25
      @text_window.contents = Bitmap.new(600 + 32, 104 + 32)
      @text_window.contents.font.name = $fontface
      @text_window.contents.font.size = $fontsizebig
      
      @status = Window_Base.new(0 - 16, 0, 640 + 32, 426 + 32)
      @status.opacity = 0
      @status.contents = Bitmap.new(640, 426)     
      @status.contents.font.name = $fontface
      @status.contents.font.size = $fontsizebig
      @status.z = @z_level + 30
      @skill_index = 0
      @skill_selected = -1
      
      @fond = Sprite.new
      @fond.bitmap = RPG::Cache.picture(DATA_BATTLE[:choix_attaque])
      @fond.y = 336
      @fond.z = @z_level + 21
      @fond.visible = false
      
      @curseur = Sprite.new
      @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_general])
      @curseur.z = @z_level + 23
      @curseur.visible = false 
      
      @choix = Sprite.new
      @choix.bitmap = RPG::Cache.picture(DATA_BATTLE[:choix_action])
      @choix.y = 336
      @choix.z = @z_level + 22
      @choix.visible = false            
      
      @curseur2 = Sprite.new
      @curseur2.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_choix_attaque])      
      @curseur2.z = @z_level + 23
      @curseur2.visible = false
      
      @index ||= 0
      
      # Position du curseur
      case @index
      when 0 # Attaque    
        @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_attaque])
        @curseur.x = 331
        @curseur.y = 353               
      when 1 # Pokémon   
        @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_pokemon])
        @curseur.x = 331
        @curseur.y = 409
      when 2 # Sac 
        @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_sac])
        @curseur.x = 488
        @curseur.y = 353       
      when 3 # Fuite   
        @curseur.bitmap = RPG::Cache.picture(DATA_BATTLE[:curseur_fuite])
        @curseur.x = 488
        @curseur.y = 409
      end

      # Sprites acteurs # Positions par défaut des centres
      @enemy_sprite = Pokemon_Battler.new()
      @enemy_sprite.visible = false

      @enemy_sprite.x = 464
      @enemy_sprite.y = 135
      @enemy_sprite.z = @z_level + 15
      @enemy_ground = RPG::Sprite.new()
      @enemy_ground.x = 464
      @enemy_ground.y = 176
      @enemy_ground.z = @z_level + 11
      @actor_sprite = Pokemon_Battler.new()
      @actor_sprite.x = 153
      @actor_sprite.y = 301
      @actor_sprite.z = @z_level + 15
      @actor_ground = RPG::Sprite.new()
      @actor_ground.x = 153
      @actor_ground.y = 386
      @actor_ground.z = @z_level + 11
      
      # Création des fenêtres de status
      @actor_party_status = Pokemon_Battle_Party_Status.new(@party, 
                                                            @battle_order, 
                                                            false, 
                                                            @z_level + 10)
      party_enemy = $battle_var.enemy_party
      order_enemy = $battle_var.enemy_battle_order
      @enemy_party_status = Pokemon_Battle_Party_Status.new(party_enemy,
                                                            order_enemy, 
                                                            true, @z_level + 10)
    end

    #------------------------------------------------------------       
    # Fenêtre des attaques
    #------------------------------------------------------------
    def initialisation_interface_skill(types, list)
      @att1 = Sprite.new
      @att1.bitmap = RPG::Cache.picture("Battle/battle_attack_dummy#{types[0]}.PNG")
      @att1.x = 36
      @att1.y = 355
      @att1.z = @z_level + 21
      @att2 = Sprite.new
      @att2.bitmap = RPG::Cache.picture("Battle/battle_attack_dummy#{types[1]}.PNG")
      @att2.x = 262
      @att2.y = 355
      @att2.z = @z_level + 21
      @att3 = Sprite.new
      @att3.bitmap = RPG::Cache.picture("Battle/battle_attack_dummy#{types[2]}.PNG")
      @att3.x = 36
      @att3.y = 410
      @att3.z = @z_level + 21
      @att4 = Sprite.new
      @att4.bitmap = RPG::Cache.picture("Battle/battle_attack_dummy#{types[3]}.PNG")
      @att4.x = 262
      @att4.y = 410
      @att4.z = @z_level + 21
      @att1.visible = false
      @att2.visible = false
      @att3.visible = false
      @att4.visible = false
      @skills_window = Window_Command.new(452, list, 35, 2, 56)
      @skills_window.x = 30
      @skills_window.y = 334
      @skills_window.opacity = 0
      @skills_window.height = 200
    end
    
    #------------------------------------------------------------       
    # Fin de scene
    #------------------------------------------------------------
    def end_scene
      # Fin de scene
      Graphics.freeze
      @background.dispose
      @message_background.dispose
      @flash_sprite.dispose
      @text_window.dispose
      @enemy_ground.dispose
      @actor_ground.dispose
      if @skill_window != nil
        @skills_window.dispose
      end
      if @ball_sprite != nil
        @ball_sprite.dispose
      end
      @enemy_sprite.dispose
      @actor_sprite.dispose
      @actor_status.dispose
      @enemy_status.dispose
      @actor_party_status.dispose
      @enemy_party_status.dispose
      @fond.dispose
      @choix.dispose
    end
    
    #------------------------------------------------------------       
    # Actualisation du placement des sprites
    #------------------------------------------------------------
    def update_sprite
      @actor_sprite.bitmap = RPG::Cache.battler(@actor.battler_back, 0)
      @actor_sprite.y = 301
      @actor_sprite.ox = @actor_sprite.bitmap.width / 2
      if not @actor.is_anime
        @actor_sprite.zoom_x = 1.5
        @actor_sprite.zoom_y = 1.5
      else
        @actor_sprite.zoom_x = 1
        @actor_sprite.zoom_y = 1
      end
      height = @actor_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @actor_sprite.oy = height - height / coef_position
      @enemy_sprite.bitmap = RPG::Cache.battler(@enemy.battler_face, 0)
      if not @enemy.is_anime
        @enemy_sprite.y = 175
      else
        @enemy_sprite.y = 135
      end
      @enemy_sprite.ox = @enemy_sprite.bitmap.width / 2
      height = @enemy_sprite.bitmap.height
      coef_position = height / (height * 0.16 + 14)
      @enemy_sprite.oy = height - height / coef_position
    end
  end
end