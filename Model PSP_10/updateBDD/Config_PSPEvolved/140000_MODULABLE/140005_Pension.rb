#regles speciales pour les oeufs

module POKEMON_S
  class Pokemon
    def breeding_custom_rules(baby, father, mother)
      baby_id = baby
      if baby_id == 132 #Metamorph
        baby_id = base_id(father.id)
      end
      
      case baby_id
      when 292# munja => ningale
        baby_id = 290
      when 29, 32 #Nidoran femelle
        baby_id = [29, 32][rand(2)]    
      when 313, 314 #Lumivole
        baby_id = ["313", "314"][rand(2)]
      when 490 # Manaphy
        baby_id = 489
      when 360 # Okeoke avec Encens doux
        if (father.id == 202 and father.item_hold == 104) or 
          (mother.id == 202 and mother.item_hold == 104)
          
          baby_id = 360
        else
          baby_id = 202
        end
      when 298# Azurill avec Encens mer
        if ([183, 184].include?(mother.id) and mother.item_hold == 91)
          baby_id = 298
        else
          baby_id = 183
        end
      when 406 #Rozbouton
        if ([315, 407].include?(father.id) and father.item_hold == 346) or 
          ([315, 407].include?(mother.id) and mother.item_hold == 346)
          baby_id = 406
        else
          baby_id = 315
        end
      when 438 #manzai
        if (father.id == 185 and father.item_hold == 347) or 
          (mother.id == 185 and mother.item_hold == 347)
          baby_id = 438
        else
          baby_id = 185
        end
      when 439 #mime jr
        if (father.id == 122 and father.item_hold == 345) or 
          (mother.id == 122 and mother.item_hold == 345)
          baby_id = 439
        else
          baby_id = 122
        end
      when 433#korillon
        if (father.id == 358 and father.item_hold == 349) or 
          (mother.id == 358 and mother.item_hold == 349)
          baby_id = 433
        else
          baby_id = 358
        end
      when 440 #ptiravi
        if ([113, 242].include?(father.id) and father.item_hold == 348) or 
          ([113, 242].include?(mother.id) and mother.item_hold == 348)
          baby_id = 440
        else
          baby_id = 113
        end
      when 446 #goinfrex
        if (father.id == 143 and father.item_hold == 350) or 
          (mother.id == 143 and mother.item_hold == 350)
          baby_id = 446
        else
          baby_id = 143
        end
      when 458 #Babimanta
        if (father.id == 226 and father.item_hold == 344) or 
          (mother.id == 226 and mother.item_hold == 344)
          baby_id = 458
        else
          baby_id = 226
        end
      end
      return baby_id
    end
  end
end