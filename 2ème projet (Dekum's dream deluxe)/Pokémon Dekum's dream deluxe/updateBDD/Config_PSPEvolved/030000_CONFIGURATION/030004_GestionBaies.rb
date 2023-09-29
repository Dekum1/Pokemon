#==============================================================================
# ■ Gestion_Baies
# Pokemon Script Project - Krosk 
# Gestion_Baies - Damien Linux
# 24/04/2020
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------
# Lien des baies en BDD avec l'effet qu'elle provoque en script
#-----------------------------------------------------------------------------
module POKEMON_S
  # Baies classiques utilisées en combat
  # ID de la baie dans objets en BDD => :nom_methode
  HASH_BERRY = {
                  205 => :baie_ceriz, # Baie Ceriz
                  206 => :baie_maron, # Baie Maron
                  207 => :baie_pecha, # Baie Pêcha
                  208 => :baie_fraive, # Baie Fraive
                  209 => :baie_willia, # Baie Willia
                  210 => :baie_mepo, # Baie Mepo
                  211 => :baie_oran, # Baie Oran
                  212 => :baie_kika, # Baie Kika
                  213 => :baie_prine, # Baie Prine
                  214 => :baie_sitrus, # Baie Sitrus
                  215 => :baie_figuy, # Baie Figuy
                  216 => :baie_wiki, # Baie Wiki
                  217 => :baie_mago, # Baie Mago
                  218 => :baie_gowav, # Baie Gowav
                  219 => :baie_papaya, # Baie Papaya
                  240 => :baie_lichii, # Baie Lichii
                  241 => :baie_lingan, # Baie Lingan
                  242 => :baie_sailak, # Baie Sailak
                  243 => :baie_pitaye, # Baie Pitaye
                  244 => :baie_abriko, # Baie Abriko
                  246 => :baie_frista, # Baie Frista
                  381 => :baie_micle # Baie Micle
                }
  
  # Baies utilisées pour baisser les dégâts d'une attaque super efficace
  # ID de la baie dans objets en BDD => :type
  HASH_BERRY_TYPE = {
                      364 => :fire, # Baie Chocco
                      365 => :water, # Baie Pocpoc
                      366 => :electric, # Baie Parma
                      367 => :grass, # Baie Ratam
                      368 => :ice, # Baie Nanone
                      369 => :fighting, # Baie Pomroz
                      370 => :poison, # Baie Kébia
                      371 => :ground, # Baie Jouca
                      372 => :fly, # Baie Cobaba
                      373 => :psy, # Baie Yapap
                      374 => :insect, # Baie Panga
                      375 => :rock, # Baie Charti
                      376 => :ghost, # Baie Sédra
                      377 => :dragon, # Baie Fraigo
                      378 => :steel, # Baie Babiri
                      379 => :dark, # Baie Lampou
                      380 => :fee # Baie Selro
                     }

  # Baies dont l'effet varie en fonction des attaques
  # ID de la baie dans objets en BDD => :nom_methode
  HASH_BERRY_SKILL = {
                        383 => :baie_jacoba, # Baie Jacoba
                        384 => :baie_pommo, # Baie Pommo
                        385 => :baie_rangma, # Baie Rangma
                        386 => :baie_eka # Baie Eka
                       }
  
  # Baies qui ont des effets spécifiques
  # :nom_baie => ID de la baie dans objets en BDD
  HASH_BERRY_ANNEXE = {
                        :baie_zalis => 363, # Baie Zalis
                        :baie_cherim => 382, # Baie Cherim
                        :baie_enigma => 247, # Baie Enigma
                        :baie_lansat => 245 # Baie Lansat
                       }
end