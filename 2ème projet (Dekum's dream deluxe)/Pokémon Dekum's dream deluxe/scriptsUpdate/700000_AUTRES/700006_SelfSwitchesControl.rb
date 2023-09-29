#==============================================================================
# ■ Self_Switches_Control
#   Leikt
#------------------------------------------------------------------------------
#Utilisation : set_ss(value, self_switch, event_id, map_id)
#avec
#value : true (activé) ou false (désactivé)
#self_switch : 'A', 'B', 'C' ou 'D'
#event_id : id de l'évent à modifier
#map_id : id de la map où se trouve l'évènement 
# (ne pas mettre si l'event est sur la meme map que le joueur au moment de 
#  l'éxécution du script)
class Interpreter # Classe gérant les commandes d'évènement
  # Pour changer un interrupteur local
  def set_self_switch(value, self_switch, event_id, map_id = @map_id) # Notre fonction
    key = [map_id, event_id, self_switch]  # Clef pour retrouver l'interrupteur local que l'on veut modifier
    $game_self_switches[key] = value # Modification de l'interrupteur local (on le veut à True ou à False)
    $game_map.events[event_id].refresh if $game_map.map_id == map_id # On rafraichi l'event s'il est sur la même map, pour qu'il prenne en compte la modification
  end
  alias set_ss set_self_switch # Création d'un alias : on peut appeler notre fonction par set_ss ou par set_self_switch (comme vous préférer)
   
  # Pour récupérer par script un interrupteur local
  def get_self_switch(self_switch, event_id, map_id = @map_id)
     key = [map_id, event_id, self_switch]  # Clef pour retrouver l'interrupteur local que l'on veut modifier
     return $game_self_switches[key]
  end
  alias get_ss get_self_switch
 
  def toggle_self_switch(self_switch, event_id, map_id = @map_id)
     set_self_switch(!get_self_switch(self_switch, event_id, map_id), self_switch, event_id, map_id)
  end
  alias toggle_ss toggle_self_switch
end