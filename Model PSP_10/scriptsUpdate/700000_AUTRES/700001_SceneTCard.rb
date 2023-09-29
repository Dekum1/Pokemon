#==============================================================================  
# ■ Carte Dresseur  
#    Script Communauté PSP - Slash  
#    le 18/7/09  
#-----------------------------------------------------------------------------  
# Support de carte dresseur  
#-----------------------------------------------------------------------------  
# Pour changer l'image de vos badges, allez dans le dossier Icons de votre   
# projet et remplacer les images BadgeX.png ou X est le numero du badge  
#-----------------------------------------------------------------------------  
# Interrupteurs occupés : 1001-1008 : Gestion des badge : activé ses  
# intérupteurs lorsque vous recevez un badge  
# ex : vous recevez le badge 1 alors activé l'intérupteur 1001  
# 1002 pour le badge 2 etc ...  
#-----------------------------------------------------------------------------  
# Variables occupés : 1501-1504 : Gestion des Objectifs : Augmenter ou Diminuer  
# ces Variables pour gerez vos objectifs  
# La variable 1501 correspond a l'objectif 1  
# La variable 1502 correspond a l'objectif 2 etc...  
# Vous pouvez renomés les objectifs via le script ci dessous  
#-----------------------------------------------------------------------------  
module POKEMON_S_TCARD  
  # Nom des objectifs  
  OBJECTIF1 = "???"  
  OBJECTIF2 = "???"  
  OBJECTIF3 = "???"  
  OBJECTIF4 = "???"  
end  
  
class Scene_T_Card  
  def main  
    Graphics.freeze  
    @z_level = 10000  
    @background = Sprite.new  
    @background.bitmap = RPG::Cache.picture(DATA_CARD[:interface_card])  
    @background.x = 0  
    @background.y = 0  
    @background.z = @z_level
    @perso = Sprite.new
    if $game_switches[FILLE]      
      @perso.bitmap = RPG::Cache.picture(DATA_CARD[:sprite_fille])      
    elsif $game_switches[GARCON]    
      @perso.bitmap = RPG::Cache.picture(DATA_CARD[:sprite_gars])      
    else        
      @perso.bitmap = RPG::Cache.picture(DATA_CARD[:sprite_gars])
    end
    @perso.x = 414  
    @perso.y = 162  
    @perso.z = @z_level + 2  
    @badge1 = Sprite.new     
    @badge2 = Sprite.new     
    @badge3 = Sprite.new     
    @badge4 = Sprite.new     
    @badge5 = Sprite.new     
    @badge6 = Sprite.new     
    @badge7 = Sprite.new     
    @badge8 = Sprite.new   
    @badge1.bitmap = RPG::Cache.icon(DATA_CARD[:badge1])     
    @badge2.bitmap = RPG::Cache.icon(DATA_CARD[:badge2])       
    @badge3.bitmap = RPG::Cache.icon(DATA_CARD[:badge3])       
    @badge4.bitmap = RPG::Cache.icon(DATA_CARD[:badge4])       
    @badge5.bitmap = RPG::Cache.icon(DATA_CARD[:badge5])     
    @badge6.bitmap = RPG::Cache.icon(DATA_CARD[:badge6])       
    @badge7.bitmap = RPG::Cache.icon(DATA_CARD[:badge7])     
    @badge8.bitmap = RPG::Cache.icon(DATA_CARD[:badge8])     
    @badge1.x = 150  
    @badge2.x = 198  
    @badge3.x = 246    
    @badge4.x = 294    
    @badge5.x = 342     
    @badge6.x = 390     
    @badge7.x = 438     
    @badge8.x = 486   
    @badge1.y = 340  
    @badge2.y = 340  
    @badge3.y = 340   
    @badge4.y = 340  
    @badge5.y = 340  
    @badge6.y = 340  
    @badge7.y = 340     
    @badge8.y = 340  
    @badge1.z = @z_level + 2  
    @badge2.z = @z_level + 2      
    @badge3.z = @z_level + 2   
    @badge4.z = @z_level + 2  
    @badge5.z = @z_level + 2  
    @badge6.z = @z_level + 2  
    @badge7.z = @z_level + 2  
    @badge8.z = @z_level + 2  
    if $game_switches[BADGE_1]
      @badge1.opacity = 255  
      else  
      @badge1.opacity = 0  
    end    
    if $game_switches[BADGE_2] 
      @badge2.opacity = 255  
      else  
      @badge2.opacity = 0  
    end   
    if $game_switches[BADGE_3]
      @badge3.opacity = 255  
      else  
      @badge3.opacity = 0  
    end   
    if $game_switches[BADGE_4]  
      @badge4.opacity = 255  
      else  
      @badge4.opacity = 0  
    end   
    if $game_switches[BADGE_5] 
      @badge5.opacity = 255  
      else  
      @badge5.opacity = 0  
    end   
    if $game_switches[BADGE_6]
      @badge6.opacity = 255  
      else  
      @badge6.opacity = 0  
    end   
    if $game_switches[BADGE_7]
      @badge7.opacity = 255  
      else  
      @badge7.opacity = 0  
    end   
    if $game_switches[BADGE_8]
      @badge8.opacity = 255  
      else  
      @badge8.opacity = 0  
    end       
    @card = Window_T_Card.new  
    @card.x = 0  
    @card.y = 0  
    @card.z = @z_level + 2  
    @card.opacity = 0   
    @spriteset = Spriteset_Map.new  
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
      
    @badge1.dispose  
    @badge2.dispose  
    @badge3.dispose  
    @badge4.dispose  
    @badge5.dispose  
    @badge6.dispose  
    @badge7.dispose  
    @badge8.dispose  
    @perso.dispose  
    @card.dispose  
    @background.dispose  
    @spriteset.dispose  
  end  
    
  def update  
    @spriteset.update  
    if Input.trigger?(Input::B)  
      # キャンセル SE を演奏  
      $game_system.se_play($data_system.cancel_se)  
      # マップ画面に切り替え  
      $scene = POKEMON_S::Pokemon_Menu.new(5)  
      return  
    end      
    if Input.trigger?(Input::C)  
      # キャンセル SE を演奏  
      $game_system.se_play($data_system.cancel_se)  
      # マップ画面に切り替え  
      $scene = Scene_T_Card_Verso.new  
      return  
    end          
  end    
    
end  
  
class Window_T_Card < Window_Base  
  include POKEMON_S  
  def initialize  
    super(0, 0, 640, 480)     
    self.contents = Bitmap.new(width - 32, height - 32)     
    self.contents.font.name = $fontface     
    self.contents.font.size = $fontsize     
    self.contents.font.color = Color.new(255,255,255)     
    @captured = $pokedex.state[1] 
    refresh     
  end  
    
  def refresh  
    self.contents.clear  
    self.contents.font.color = Color.new(255,255,255)  
    self.contents.draw_text(82, 84, 120, 32,Player.name)  
    self.contents.draw_text(184, 84, 120, 32,"ID " + Player.id.to_s, 2)  
    self.contents.draw_text(365, 70, 120, 32, "Code Echange",2)  
    self.contents.draw_text(351, 98, 120, 32, Player.trainer_trade_code,2)  
    @order = [0,1,2,3,4,5]  
    if $pokemon_party.size > 0  
      for i in 0..($pokemon_party.size - 1)  
       @pokemon = $pokemon_party.actors[@order[i]]  
       id = @pokemon.id  
       idx = (id - 1 )% 15  
       idy = (id - 1 ) / 15  
       xrect = idx * 100  
       yrect = idy * 60  
       src_rect = Rect.new(xrect, yrect, 100, 60)  
       bitmap = RPG::Cache.picture(DATA_CARD[:ensemble_pokemon])  
       if i < 3  
        if @pokemon.egg   
          bitmap = RPG::Cache.picture(DATA_CARD[:egg])  
          src_rect = Rect.new(0, 0, 100, 60)  
          self.contents.blt(70 + 104 * i, 156, bitmap, src_rect, 255)  
        else  
          self.contents.blt(70 + 104 * i, 156, bitmap, src_rect, 255)  
          draw_gender(154 +104 * i, 190, @pokemon.gender)  
        end  
      else  
        if @pokemon.egg   
          bitmap = RPG::Cache.picture(DATA_CARD[:egg])  
          src_rect = Rect.new(0, 0, 100, 60)  
          self.contents.blt(70 + 104 * (i-3), 220, bitmap, src_rect, 255)  
        else  
          self.contents.blt(70 + 104 * (i-3), 220, bitmap, src_rect, 255)  
          draw_gender(154 + 104 * (i-3), 254, @pokemon.gender)  
        end  
       end  
     end  
     return  
    end  
  
  
  end  
      
  def draw_gender(x, y, gender)  
      if gender == 1  
        rect = Rect.new(0, 0, 18, 33)  
        bitmap = RPG::Cache.picture(MALE)  
        self.contents.blt(x, y, bitmap, rect, 255)  
      end  
      if gender == 2  
        rect = Rect.new(0, 0, 18, 33)  
        bitmap = RPG::Cache.picture(FEMELLE)  
        self.contents.blt(x, y, bitmap, rect, 255)          
      end  
  end    
    
  
end    
  
class Scene_T_Card_Verso  
  def main  
    Graphics.freeze  
    @z_level = 10000  
    @background = Sprite.new  
    @background.bitmap = RPG::Cache.picture(DATA_CARD[:interface_verso_card])  
    @background.x = 0  
    @background.y = 0  
    @background.z = @z_level      
    @Verso = Window_T_Card_Verso.new  
    @Verso.x = 0  
    @Verso.y = 0  
    @Verso.z = @z_level + 2  
    @Verso.opacity = 0   
    @spriteset = Spriteset_Map.new  
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
    @Verso.dispose  
    @background.dispose  
    @spriteset.dispose  
  end  
    
  def update  
    @spriteset.update  
    if Input.trigger?(Input::B)  
      # キャンセル SE を演奏  
      $game_system.se_play($data_system.cancel_se)  
      # マップ画面に切り替え  
      $scene = POKEMON_S::Pokemon_Menu.new(5)  
      return  
    end   
    if Input.trigger?(Input::C)  
      # キャンセル SE を演奏  
      $game_system.se_play($data_system.cancel_se)  
      # マップ画面に切り替え  
      $scene = POKEMON_S::Pokemon_Menu.new(5)  
      return  
    end   
  end    
    
end  
  
class Window_T_Card_Verso < Window_Base  
  include POKEMON_S  
  include POKEMON_S_TCARD  
  def initialize  
    super(0, 0, 640, 480)     
    self.contents = Bitmap.new(width - 32, height - 32)     
    self.contents.font.name = $fontface     
    self.contents.font.size = $fontsize     
    self.contents.font.color = Color.new(255,255,255)     
    state = $pokedex.state
    @captured = state[1]
    @viewed = state[0]  
    refresh     
  end  
    
  def refresh  
    self.contents.clear  
    self.contents.font.color = Color.new(255,255,255)  
    self.contents.draw_text(82, 84, 120, 32,Player.name)  
    self.contents.draw_text(184, 84, 120, 32,"ID " + Player.id.to_s, 2)  
    self.contents.draw_text(365, 70, 120, 32, "Code Echange",2)  
    self.contents.draw_text(351, 98, 120, 32, Player.trainer_trade_code,2)  
    self.contents.draw_text(74, 300, 300, 32, "Argent : " + $pokemon_party.money.to_s  + "$")  
    @total_sec = Graphics.frame_count / Graphics.frame_rate     
    hour = @total_sec / 60 / 60     
    min = @total_sec / 60 % 60     
    temps = sprintf("%02d:%02d", hour, min)  
    self.contents.draw_text(336, 300, 300, 32, "Temps de jeu : " + temps)  
    self.contents.draw_text(74, 340, 500, 32, "Pokédex : " + @captured.to_s + " Capturés / " + @viewed.to_s + " Aperçus")  
    self.contents.font.color = Color.new(41,53,57)  
    self.contents.draw_text(74, 120, 380, 64, " " + OBJECTIF1)  
    self.contents.draw_text(74, 160, 380, 64, " " + OBJECTIF2)  
    self.contents.draw_text(74, 200, 380, 64, " " + OBJECTIF3)  
    self.contents.draw_text(74, 240, 380, 64, " " + OBJECTIF4)  
    self.contents.draw_text(156, 120, 380, 64, $game_variables[CONTENT_DRESSEUR_1].to_s,2)  
    self.contents.draw_text(156, 160, 380, 64, $game_variables[CONTENT_DRESSEUR_2].to_s,2)  
    self.contents.draw_text(156, 200, 380, 64, $game_variables[CONTENT_DRESSEUR_3].to_s,2)  
    self.contents.draw_text(156, 240, 380, 64, $game_variables[CONTENT_DRESSEUR_4].to_s,2)      
    return  
  end  
end  