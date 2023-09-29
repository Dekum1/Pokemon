#==============================================================================
# ■ MAPPANEL
# Pokemon Script Project - Krosk 
# 08/05/08
#-----------------------------------------------------------------------------
# Scène à ne pas modifier de préférence
#-----------------------------------------------------------------------------
# Gestion de messages de localisations
#-----------------------------------------------------------------------------
# $data_mapzone regroupe les informations sur les messages de localisation
# propre à chaque map (contrairement à $data_zone qui regroupe les infos
# par zone
#-----------------------------------------------------------------------------
module POKEMON_S
  $data_zone = [] 
  $data_mapzone = []
  if FileTest.exist?("Data/data_zone.txt")
    begin
      file = File.open("Data/data_zone.txt", "rb")
      file.readchar
      file.readchar
      file.readchar
      file.each {|line| eval(line) }
      file.close
    rescue Exception => exception
      EXC::error_handler(exception, file)
    end
    
    # Processing Map
    # data_mapzone[map_id] = [numero zone, nom zone, panneau, marque]
    map_info           = load_data("Data/MapInfos.rxdata")
    
    for data in map_info
      id = data[0]
      data_map = data[1]
      
      if data_map == nil 
        $data_mapzone[id] = [0, "INCONNU", "", false]
        next
      end
      
      # Extraction nom de carte : saut si non conforme
      name = data_map.name.split('/')
      if name.length == 1
        $data_mapzone[id] = [0, "INCONNU", "", false]
        next
      end
      
      # Extraction numéro de zone
      number = name[0]
      number = eval(number)
      if number.type == Array
        number = number[0]
      end
      
      # En cas d'échec/erreur
      if number.type != Fixnum or $data_zone[number] == nil or 
          $data_zone[number].type != Array or $data_zone[number][0].type != String or
          $data_zone[number][1].type != String
        print("Erreur de Map Processing pour ID #{id} et zone #{number}\nVeuillez vérifier le fichier data_zone.txt, et le nom de la map.")
        $data_mapzone[id] = [0, "INCONNU", "", false]
        next
      end
      
      # Assignation données
      $data_mapzone[id] = [number, $data_zone[number][0], $data_zone[number][1], (eval(name[0]).type == Array)]
    end
    #print $data_mapzone.inspect
  else
    $data_mapzone = load_data("Data/data_mapzone.rxdata")
    $data_zone = load_data("Data/data_zone.rxdata")
  end
end
  
if POKEMON_S::MAPPANEL  
  class Game_Map
    alias alias_setup setup
    def setup(map_id, reload_map = false)
      if $scene.is_a?(Scene_Map)
        $scene.panel_determination(map_id)
      end
      alias_setup(map_id, reload_map)
    end
  end
  
  class Scene_Map
    alias alias_update update
    def update
      alias_update
      if @panel != nil and not @panel.disposed?
        if @panel_timer > 160
          @panel_timer -= 1
          @panel.y += 3
        elsif @panel_timer > 40
          @panel_timer -= 1
        elsif @panel_timer > 0
          @panel_timer -= 1
          @panel.y -= 3
        end
      end
      if $scene != self
        panel_determination(0)
      end
    end
    
    #alias main_temp main
    #def main
    #  @panel_timer = 200
    #  main_temp
    #end
    
    def panel_determination(new_map_id)
      # Effacement panneau précédent
      if @panel != nil and not @panel.disposed?
        @panel.dispose
        @panel = nil
      end
        
      # Cas sans affichage :
      # Mapzone vide
      if $data_mapzone[new_map_id] == nil
        #print("Mapzone vide, id %d", new_map_id)
        return
      end
      
      # Carte destination non marquée
      if not $data_mapzone[new_map_id][3]
        #print("destination non marquée")
        return
      end
      
      # Carte destination zone inconnue
      if $data_mapzone[new_map_id][0] == 0
        #print("destination inconnue")
        return
      end
        
      # Carte destination marquée, Carte départ existante
      if $data_mapzone[new_map_id][3] and $data_mapzone[$game_map.map_id] != nil
        # destination marquée, Même zone
        if $data_mapzone[$game_map.map_id][3] and $data_mapzone[new_map_id][0] == $data_mapzone[$game_map.map_id][0]
          #print("destination meme zone")
          return
        end
      end
      
      @panel = Window_Base.new(-16, -16 - 120, 96*3+32, 36*3+32)
      @panel.contents = Bitmap.new("Graphics/Pictures/" + $data_mapzone[new_map_id][2])
      @panel.contents.font.name = $fontnarrow
      @panel.contents.font.size = $fontnarrowsize
      @panel.draw_text(0, 30, 96*3, 36, $data_mapzone[new_map_id][1], 1)
      @panel.opacity = 0
      @panel_timer = 200
    end
  end
end