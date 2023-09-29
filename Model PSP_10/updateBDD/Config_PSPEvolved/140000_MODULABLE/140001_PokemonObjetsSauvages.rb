#-----------------------------------------------------
#              Objets tenus par les pokémon sauvages
#
#                       Par FL0RENT_
#-----------------------------------------------------
module POKEMON_S
  class Pokemon_Battle_Core
    def wild_item
      case @enemy.name
      # Table par Pokémon (prioritaire sur les autres tables)
      # Les objets plus haut dans la liste sont prioritaires sur les autres (voir exemple de Ronflex)
      when "Pikachu"
        return 116 if 0 == rand(75) # 1 chance sur 75 que Pikachu tienes une BALLELUMIERE.
      when "Zigzaton", "Lineon"
        return 2 if 0 == rand(100) # 1 chance sur 100 de tenir une Hyper Ball
        return 211 if 0 == rand(20) # 1 chance sur 20 de tenir une baie oran
      when "Rozbouton", "Roselia", "Roserade", "Ortide"
        return 81 if 0 == rand(50) # 1 chance sur 50 de tenir un Pic venin.
      when "Ronflex"
        return 102 if 0 == rand(3) # 1 chance sur 3 de tenir des restes.
        return 206 if 0 == rand(2) # 1 chance sur 2 de tenir une baie maron.
        return 161 if 0 == rand(1) # si il ne tient aucun des autres objets, il tiendra la ct repos
      # ... etc
      #-----------------------------------
      end
      @verif_type = @enemy.type1
      string = item_by_type
      return string if string != 0
      @verif_type = @enemy.type2
      string = item_by_type
      return string if string != 0
       
      # Table générale
      # Placez ici les objets pouvant être tenus par n'importe quel pokémon sauvage.
      return 190 if 0 == rand(1000) #1 chance sur 1000 de tenir une pépite
      return 1 if 0 == rand(999999) #1 chance sur 999999 de tenir une masterball
       
      # ...etc
      #-----------------------------------
      return 0
    end
     
    def item_by_type
      case @verif_type
      # Table par Type
      # Tous les pokemon de ce type auront la possibilité de tenir cet objet.
      when 1 # Normal
         
      when 2 # Feu
         
      when 3 # Eau
         
      when 4 # Electrique
         
      when 5 # Plante
         
      when 6 # Glace
         
      when 7 # Combat
         
      when 8 # Poison
         
      when 9 # Sol
         
      when 10 # Vol
         
      when 11 # Psy
         
      when 12 # Insecte
        return 85 if 0 == rand(300) # Les pokemon Insect auront 1 chance sur 300 de tenir POUDRE ARG.
         
      when 13 # Roche
         
      when 14 # Spectre
         
      when 15 # Dragon
         
      when 16 # Acier
         
      when 17 # Ténébres
         
      when 18  # Fée
         
      # when 19    #(possibilité de rajouter les types custom.)
         
      #--------------------------------------
      end
      return 0
    end
  end
end