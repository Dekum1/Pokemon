#==============================================================================
# ■ Gestion_Graphic_Audio
# Pokemon Script Project - Krosk 
# Gestion_Graphic_Audio - Damien Linux
# 14/01/2020
#-----------------------------------------------------------------------------
# Modulable
#-----------------------------------------------------------------------------

  # Si false, alors les tableaux $data_trainers et DATA_WILD
  # ci-dessous ne sont pas utilisés et il faut passer
  # par la modifications des musiques via les events de RPG Maker
  DEFAULT_CONFIGURATION = true
  
  # Modèle : 
  # Valeur de la variable => { :audio => "Nom de l'audio",
  #                            :victoire_audio => "Nom de l'audio en cas de victoire",
  #                            :graphic => "Nom de l'image de transition.extension",
  #                            :nb_transition => Nombre de transitions, choisie aléatoirement,
  #                            :frame => Temps d'exécution en frame}
  #
  # POUR GERER LE BOUCLAGE PRECIS DES MUSIQUES ET LEUR LANCEMENT, MERCI DE
  # VOIR LE SCRIPT FmodEx !
  #
  # -1 = configuration par défaut, il s'agit des musiques et de l'animation
  # :nb_transition => 0 désactive la recherche de transition aléatoire (nom exact)
  #
  # Les :graphic sont en PNG, pas besoin de préciser l'extension (mais cependant
  # l'image ne sera pas trouvé si elle n'est pas en PNG)
  # Pour :audio il faut mentionner les extensions comme .mp3
  # Il est déconseillé d'utiliser des espaces ou caractères spéciaux dans un titre
  # cependant dans ce script cela ne cause pas de problèmes.
  # ATTENTION : Tous les audios ayant des accents ne seront pas fonctionnels
  # en-dehors de ce script ! (Par exemple ceux dans Système dans la BDD)
  #
  # exécutée si la variable CONFIGURATION_BATTLE_WILD ou CONFIGURATION_BATTLE_TRAINER
  # ne contiennent aucune des valeurs 
  # $data_trainer : pour les combats contre les dresseurs
  # DATA_WILD : pour les combats contre les pokémon sauvages
  # dans le hash ci-dessous
  DATA_TRAINERS_AUDIO_GRAPHIC = {
                        -1 => { :audio => "CombatDresseurPokemon.mp3", 
                                :victoire_audio => "VictoireDresseursPokemon.mp3",
                                :graphic => "battle_Trainer",
                                :nb_transition => 4,
                                :frame => 70},
                        1 => { :audio => "CombatRivaux.mp3", 
                               :victoire_audio => "VictoireDresseursPokemon.mp3",
                               :graphic => "battle_Special5",
                               :nb_transition => 0,
                               :frame => 80},
                        2 => { :audio => "CombatChampion.mp3", 
                               :victoire_audio => "VictoireChampionArene.mp3",
                               :graphic => "battle_Special2",
                               :nb_transition => 0,
                               :frame => 80},
                        3 => { :audio => "CombatTeam.mp3", 
                               :victoire_audio => "VictoireTeam.mp3",
                               :graphic => "battle_Special1",
                               :nb_transition => 0,
                               :frame => 80},
                        4 => { :audio => "CombatDresseurPokemon.mp3", 
                               :victoire_audio => "VictoireDresseursPokemon.mp3",
                               :graphic => "battle_Special1",
                               :nb_transition => 0,
                               :frame => 80}, 
                        5 => { :audio => "CombatSpeciaux.mp3", 
                               :victoire_audio => "VictoireDresseursPokemon.mp3",
                               :graphic => "battle_Special6",
                               :nb_transition => 0,
                               :frame => 80},
                        6 => { :audio => "ConseilMakers.wav", 
                               :victoire_audio => "VictoireChampionArene.mp3",
                               :graphic => "battle_Special6",
                               :nb_transition => 0,
                               :frame => 80},
                        7 => { :audio => "CombatDamienLinux.wav", 
                               :victoire_audio => "VictoireChampionArene.mp3",
                               :graphic => "battle_Special6",
                               :nb_transition => 0,
                               :frame => 40}
                      }
                   
  DATA_WILD = {
                  -1 => { :audio => "PokemonSauvage.mp3", 
                          :victoire_audio => "VictoirePokemonSauvages.mp3",
                          :graphic => "battle_Wild",
                          :nb_transition => 4,
                          :frame => 50},
                  1 => { :audio => "SauvageRare.mp3", 
                         :victoire_audio => "VictoirePokemonSauvages.mp3",
                         :graphic => "battle_Special3",
                         :nb_transition => 0,
                         :frame => 70},
               }
               
  # Les tableaux ci-dessous seront utilisés quelque soit la valeur de
  # DEFAULT_CONFIGURATION
  DATA_AUDIO_BGM = {
                      # Evolution d'un Pokémon
                      :evolution => "Evolution.mp3", 
                      # Musique du Panthéon après la ligue
                      :pantheon => "PantheonDresseurs.mp3",
                      # Son de victoire en combat contre des dresseurs si
                      # DEFAULT_CONFIGURATION = false
                      :victoire_default => "PkmRS_Victory2.mid",
                      # Son de victoire en combat contre des pokémon sauvages
                      # si DEFAULT_CONFIGURATION = false
                      :victoire_wild_default => "PkmRS-Victory.mid",
                    }
                    
  DATA_AUDIO_ME = {
                      # Obtention d'un objet
                      :item => "PkmRB-Item.mid", 
                      # Grimpe d'un niveau
                      :level_plus => "NiveauSuperieur.mp3", 
                      # Réussite d'une capture
                      :capturer_pokemon => "PokemonCapturer.mp3", 
                      # Réussite d'une quête
                      :victoire_quete => "trainer_jingle.mid", 
                      # Obtention d'une nouvelle quête
                      :acquisition_quete => "AcquisitionQuetes.mp3",
                      # Obtention d'un objet
                      :acquisition_objet => "AcquisitionObjets.mp3",
                      # Obtention d'une CT ou CS
                      :acquisition_ct_cs => "AcquisitionCTCS.mp3",
                      # Obtention d'une baie
                      :acquisition_baie => "AcquisitionBaies.mp3",
                      # Obtention d'un objet rare
                      :acquisition_objet_rare => "AcquisitionObjetsRares.mp3"
                   }
                   
  DATA_AUDIO_SE = {
                      # Fermeture du menu
                      :fermeture_menu => "FermetureMenu.mp3", 
                      # Soin via un objet
                      :soin_objet => "SoinObjet.wav", 
                      # Accès au PC
                      :connexion_pc => "ConnexionPC.wav", 
                      # Navigation menu PC
                      :open_break => "Pokeopenbreak.wav", 
                      # Curseur de navigation du sac
                      :curseur_poche => "CurseurPoche.wav", 
                      # Indication du choix en combat
                      :phase_joueur => "PhaseJoueur.wav", 
                      # Valide un choix en combat
                      :validation_combat => "ValidationCombat.wav", 
                      # Lancement ou rappelle du pokémon en combat
                      :recall_pokemon => "Pokeopen.wav", 
                      # Pokémon K.O.
                      :ko => "Down.wav", 
                      # Dégâts sur un pokémon
                      :degat => "Hit.wav", 
                      # Dégâts lorsque cela est super efficace
                      :degat_plus => "Hitplus.wav", 
                      # Dégâts lorsque cela n'est pas très efficace
                      :degat_moins => "Hitlow.wav", 
                      # Pokéball lors de la capture
                      :pokeball_capture => "Pokerebond.wav",
                      # Pokéball qui bouge
                      :pokeball_move => "Pokemove.wav", 
                      # Affichage des pokéballs des équipes en combat de 
                      # dresseurs
                      :affichage_equipe => "ConfrontationBall.mp3", 
                      # Eclair lors d'un orage
                      :eclair => "061-Thunderclap01.ogg", 
                      # Ouverture du puzzle des ruines Alpha
                      :menu_puzzle => "menu.wav", 
                      # Pose une pièce du puzzle des ruines Alpha
                      :place_pice => "notverydamage.wav",
                      :exp => "exp_sound.wav",
                      # Méga-évolution
                      :mega_evo => "058-Wrong02.ogg"
                   }

# Effet sonore quand on ouvre une boîte de message sur la map
SOUND_CHOICE = "Choose.WAV"