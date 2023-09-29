#==============================================================================
# ■ Gestion_Objets
# Pokemon Script Project - Krosk 
# Gestion_Talents - Damien Linux
# 13/01/2020
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------
# Attribution des noms des objets aux clés d'exécution des méthodes des objets
# - Vérification de l'utilisation d'un objet
# - Utilisation d'un objet
#-----------------------------------------------------------------------------
module POKEMON_S
  ID_OBJECTS_VERIF = {
                        "ATTAQUE +" => :objet_plus,
                        "DEFENSE +" => :objet_plus,
                        "VITESSE +" => :objet_plus,
                        "SPECIAL +" => :objet_plus,
                        "DEF.SPE +" => :objet_plus,
                        "MUSCLE +" => :objet_plus,
                        "PRECISION +" => :objet_plus,
                        "DEFENSE SPEC" => :objet_plus,
                        "ANTIDOTE" => :antidote,
                        "ANTI-PARA" => :anti_para,
                        "ANTIGEL" => :antigel,
                        "ANTI-BRULE" => :anti_brule,
                        "REVEIL" => :reveil,
                        "TOTAL SOIN" => :soin_total,
                        "POUDRE SOIN" => :soin_total,
                        "LAVA COOKIE" => :soin_total,
                        "BONBON RAGE" => :soin_total,
                        "POTION" => :guerison_pv,
                        "JUS DE BAIE" => :guerison_pv,
                        "EAU FRAICHE" => :guerison_pv,
                        "SODA COOL" => :guerison_pv,
                        "SUPER POTION" => :guerison_pv,
                        "POUDRENERGIE" => :guerison_pv,
                        "LIMONADE" => :guerison_pv,
                        "LAIT MEUMEU" => :guerison_pv,
                        "HYPER POTION" => :guerison_pv,
                        "RACINERGIE" => :guerison_pv,
                        "POTION MAX" => :guerison_pv,
                        "GUERISON" => :guerison_pv,
                        "RAPPEL" => :rappel_ko,
                        "RAPPEL MAX" => :rappel_ko,
                        "HERBE RAPPEL" => :rappel_ko,
                        "CENDRESACREE" => :rappel_ko
                      }
                      
  ID_OBJECTS_UTIL = {
                        "ATTAQUE +" => :attaque_plus,
                        "DEFENSE +" => :defense_plus,
                        "VITESSE +" => :vitesse_plus,
                        "SPECIAL +" => :special_plus,
                        "DEF.SPE +" => :defense_spe_plus,
                        "MUSCLE +" => :muscle_plus,
                        "PRECISION +" => :precision_plus,
                        "DEFENSE SPEC" => :defense_spec,
                        "ANTIDOTE" => :antidote,
                        "ANTI-PARA" => :anti_para,
                        "ANTIGEL" => :antigel,
                        "ANTI-BRULE" => :anti_brule,
                        "REVEIL" => :reveil,
                        "TOTAL SOIN" => :soin_total,
                        "POUDRE SOIN" => :soin_total,
                        "LAVA COOKIE" => :soin_total,
                        "BONBON RAGE" => :soin_total,
                        "POTION" => :potion,
                        "JUS DE BAIE" => :potion,
                        "EAU FRAICHE" => :eau_fraiche,
                        "SODA COOL" => :soda_cool,
                        "SUPER POTION" => :super_potion,
                        "POUDRENERGIE" => :super_potion,
                        "LIMONADE" => :limonade,
                        "LAIT MEUMEU" => :lait_meumeu,
                        "HYPER POTION" => :hyper_potion,
                        "RACINERGIE" => :hyper_potion,
                        "POTION MAX" => :potion_max,
                        "GUERISON" => :guerison,
                        "RAPPEL" => :rappel,
                        "RAPPEL MAX" => :rappel_max,
                        "HERBE RAPPEL" => :rappel_max,
                        "CENDRESACREE" => :cendresacree
                     }
end